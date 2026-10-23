import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/workout_library.dart';
import '../models/custom_workout.dart';
import '../models/exercise.dart';
import '../models/training_plan.dart';
import '../models/weight_entry.dart';
import '../models/workout_session.dart';
import '../services/plan_builder.dart';
import '../services/progression.dart';
import '../services/reminders.dart';
import '../services/stats.dart';
import '../services/voice_coach.dart';

class AppState extends ChangeNotifier {
  AppState(
    this._prefs, {
    DateTime Function()? clock,
    this.speaker = const SilentSpeaker(),
    this.reminders = const NoopReminderScheduler(),
  }) : _clock = clock ?? DateTime.now {
    _load();
  }

  static const _weightKey = 'weightKg';
  static const _targetKey = 'weeklyTargetDays';
  static const _levelKey = 'level';
  static const _sessionsKey = 'sessions';
  static const _themeKey = 'themeMode';
  static const _voiceKey = 'voiceEnabled';
  static const _levelChangedKey = 'levelChangedAt';
  static const _adviceDismissedKey = 'adviceDismissedAt';
  static const _planKey = 'plan';
  static const _customKey = 'customWorkouts';
  static const _reminderKey = 'reminder';
  static const _weightLogKey = 'weightLog';

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  /// Suara pemandu latihan (senyap secara default, untuk tes).
  final Speaker speaker;

  /// Pemasang notifikasi pengingat (tidak melakukan apa-apa secara default).
  final ReminderScheduler reminders;

  double? _weightKg;
  int _weeklyTargetDays = 4;
  Level _level = Level.pemula;
  ThemeMode _themeMode = ThemeMode.system;
  bool _voiceEnabled = true;
  DateTime? _levelChangedAt;
  DateTime? _adviceDismissedAt;
  TrainingPlan? _plan;
  List<WorkoutSession> _sessions = [];
  List<CustomWorkout> _customWorkouts = [];
  ReminderSettings? _reminder;
  List<WeightEntry> _weightLog = [];

  double? get weightKg => _weightKg;
  int get weeklyTargetDays => _weeklyTargetDays;
  Level get level => _level;
  ThemeMode get themeMode => _themeMode;
  bool get voiceEnabled => _voiceEnabled;
  bool get hasProfile => _weightKg != null;
  DateTime get now => _clock();
  TrainingPlan? get plan => _plan;

  /// Terbaru di depan.
  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);

  /// Urutan dibuat (terlama di depan).
  List<CustomWorkout> get customWorkouts => List.unmodifiable(_customWorkouts);

  ReminderSettings get reminder =>
      _reminder ?? ReminderSettings.defaultsFor(_weeklyTargetDays);

  /// Terlama di depan.
  List<WeightEntry> get weightLog => List.unmodifiable(_weightLog);

  List<dynamic>? _readList(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? null : jsonDecode(raw) as List<dynamic>;
  }

  Map<String, dynamic>? _readMap(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  DateTime? _readDate(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? null : DateTime.parse(raw);
  }

  void _load() {
    _weightKg = _prefs.getDouble(_weightKey);
    _weeklyTargetDays = _prefs.getInt(_targetKey) ?? 4;
    _level =
        Level.values.asNameMap()[_prefs.getString(_levelKey)] ?? Level.pemula;
    _themeMode =
        ThemeMode.values.asNameMap()[_prefs.getString(_themeKey)] ??
        ThemeMode.system;
    _voiceEnabled = _prefs.getBool(_voiceKey) ?? true;
    _levelChangedAt = _readDate(_levelChangedKey);
    _adviceDismissedAt = _readDate(_adviceDismissedKey);

    _sessions = [
      for (final e in _readList(_sessionsKey) ?? const [])
        WorkoutSession.fromJson(e as Map<String, dynamic>),
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _customWorkouts = [
      for (final e in _readList(_customKey) ?? const [])
        CustomWorkout.fromJson(e as Map<String, dynamic>),
    ];
    _weightLog = [
      for (final e in _readList(_weightLogKey) ?? const [])
        WeightEntry.fromJson(e as Map<String, dynamic>),
    ]..sort((a, b) => a.date.compareTo(b.date));
    // Data sebelum ada riwayat berat: berat profil jadi catatan pertama.
    if (_weightLog.isEmpty && _weightKg != null) {
      _weightLog = [WeightEntry(startOfDay(now), _weightKg!)];
      _saveWeightLog();
    }

    final plan = _readMap(_planKey);
    _plan = plan == null ? null : TrainingPlan.fromJson(plan);
    final reminder = _readMap(_reminderKey);
    _reminder = reminder == null ? null : ReminderSettings.fromJson(reminder);
  }

  Future<void> _saveSessions() => _prefs.setString(
    _sessionsKey,
    jsonEncode(_sessions.map((s) => s.toJson()).toList()),
  );

  Future<void> _saveCustomWorkouts() => _prefs.setString(
    _customKey,
    jsonEncode(_customWorkouts.map((w) => w.toJson()).toList()),
  );

  Future<void> _saveWeightLog() => _prefs.setString(
    _weightLogKey,
    jsonEncode(_weightLog.map((w) => w.toJson()).toList()),
  );

  // ---------------- Profil & pengaturan ----------------

  Future<void> saveProfile({
    required double weightKg,
    required int weeklyTargetDays,
    required Level level,
  }) async {
    final weightChanged = weightKg != _weightKg;
    _weeklyTargetDays = weeklyTargetDays;
    if (weightChanged) _putWeight(weightKg);
    _changeLevel(level);
    notifyListeners();
    await _prefs.setInt(_targetKey, weeklyTargetDays);
    if (weightChanged) await _persistWeight();
    await _persistLevel();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    _voiceEnabled = enabled;
    if (!enabled) await speaker.stop();
    notifyListeners();
    await _prefs.setBool(_voiceKey, enabled);
  }

  // ---------------- Level & saran ----------------

  void _changeLevel(Level level) {
    if (level == _level) return;
    _level = level;
    _levelChangedAt = now;
  }

  Future<void> _persistLevel() async {
    await _prefs.setString(_levelKey, _level.name);
    if (_levelChangedAt != null) {
      await _prefs.setString(
        _levelChangedKey,
        _levelChangedAt!.toIso8601String(),
      );
    }
  }

  Future<void> setLevel(Level level) async {
    _changeLevel(level);
    notifyListeners();
    await _persistLevel();
  }

  /// Saran naik/turun level dari penilaian sesi terakhir, jika ada.
  LevelAdvice? get levelAdvice {
    final since = [
      _levelChangedAt,
      _adviceDismissedAt,
    ].whereType<DateTime>().fold<DateTime?>(
      null,
      (latest, d) => latest == null || d.isAfter(latest) ? d : latest,
    );
    return adviseLevel(sessions: _sessions, level: _level, since: since);
  }

  /// "Nanti": sembunyikan saran sampai ada penilaian baru yang cukup.
  Future<void> dismissLevelAdvice() async {
    _adviceDismissedAt = now;
    notifyListeners();
    await _prefs.setString(
      _adviceDismissedKey,
      _adviceDismissedAt!.toIso8601String(),
    );
  }

  // ---------------- Sesi ----------------

  Future<void> addSession(WorkoutSession session) async {
    _sessions = [session, ..._sessions];
    notifyListeners();
    await _saveSessions();
  }

  Future<void> deleteSession(String id) async {
    _sessions = _sessions.where((s) => s.id != id).toList();
    notifyListeners();
    await _saveSessions();
  }

  Future<void> rateSession(String id, Effort? effort) async {
    _sessions = [
      for (final s in _sessions) s.id == id ? s.withEffort(effort) : s,
    ];
    notifyListeners();
    await _saveSessions();
  }

  // ---------------- Program 4 minggu ----------------

  /// Mulai rencana baru hari ini (menggantikan rencana lama).
  Future<void> startPlan({Level? level}) async {
    _plan = TrainingPlan(
      startedOn: startOfDay(now),
      level: level ?? _level,
      sessionsPerWeek: planSessionsFor(_weeklyTargetDays),
    );
    notifyListeners();
    await _prefs.setString(_planKey, jsonEncode(_plan!.toJson()));
  }

  Future<void> stopPlan() async {
    _plan = null;
    notifyListeners();
    await _prefs.remove(_planKey);
  }

  PlanStatus? get planStatus =>
      _plan == null ? null : computePlanStatus(_plan!, _sessions, now);

  // ---------------- Latihan buatan ----------------

  Future<void> saveCustomWorkout(CustomWorkout workout) async {
    final index = _customWorkouts.indexWhere((w) => w.id == workout.id);
    _customWorkouts = [..._customWorkouts];
    if (index < 0) {
      _customWorkouts.add(workout);
    } else {
      _customWorkouts[index] = workout;
    }
    notifyListeners();
    await _saveCustomWorkouts();
  }

  Future<void> deleteCustomWorkout(String id) async {
    _customWorkouts = _customWorkouts.where((w) => w.id != id).toList();
    notifyListeners();
    await _saveCustomWorkouts();
  }

  CustomWorkout? customWorkoutById(String id) {
    for (final w in _customWorkouts) {
      if (w.id == id) return w;
    }
    return null;
  }

  // ---------------- Pengingat ----------------

  /// Simpan dan pasang ulang jadwal pengingat.
  Future<void> setReminder(ReminderSettings settings) async {
    _reminder = settings;
    notifyListeners();
    await _prefs.setString(_reminderKey, jsonEncode(settings.toJson()));
    await reminders.apply(settings);
  }

  // ---------------- Berat badan ----------------

  void _putWeight(double kg) {
    _weightKg = kg;
    final today = startOfDay(now);
    _weightLog = [
      for (final e in _weightLog)
        if (e.date != today) e,
      WeightEntry(today, kg),
    ]..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _persistWeight() async {
    await _prefs.setDouble(_weightKey, _weightKg!);
    await _saveWeightLog();
  }

  /// Catat berat hari ini; sekaligus jadi berat untuk hitungan kalori.
  Future<void> logWeight(double kg) async {
    _putWeight(kg);
    notifyListeners();
    await _persistWeight();
  }

  // ---------------- Ringkasan ----------------

  /// Program sesuai level digilir per hari, supaya bagian tubuh yang dilatih
  /// bergantian tanpa perlu memilih.
  WorkoutProgram get todaysProgram {
    final day = startOfDay(now);
    final dayNumber =
        DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final candidates = workoutPrograms.where((p) => p.level == _level).toList();
    return candidates[dayNumber % candidates.length];
  }

  ActivityTotal get today {
    final start = startOfDay(now);
    return totalBetween(
      _sessions,
      start,
      DateTime(start.year, start.month, start.day + 1),
    );
  }

  ActivityTotal get thisWeek {
    final start = startOfWeek(now);
    return totalBetween(
      _sessions,
      start,
      DateTime(start.year, start.month, start.day + 7),
    );
  }

  ActivityTotal get lastWeek {
    final start = startOfWeek(now);
    return totalBetween(
      _sessions,
      DateTime(start.year, start.month, start.day - 7),
      start,
    );
  }

  List<ActivityTotal> get thisWeekDaily => dailyTotalsForWeek(_sessions, now);

  int get activeDaysThisWeek =>
      thisWeekDaily.where((d) => d.sessions > 0).length;

  bool get workedOutToday => today.sessions > 0;
}

/// Menyediakan [AppState] ke seluruh widget di bawahnya.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Untuk dipakai di callback (tidak ikut rebuild).
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
