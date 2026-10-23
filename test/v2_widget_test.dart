import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_workout/main.dart';
import 'package:home_workout/models/exercise.dart';
import 'package:home_workout/models/workout_session.dart';
import 'package:home_workout/screens/workout_summary_screen.dart';
import 'package:home_workout/services/reminders.dart';
import 'package:home_workout/services/voice_coach.dart';
import 'package:home_workout/state/app_state.dart';
import 'package:home_workout/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget_test.dart' show settle, usePhoneScreen;

class RecordingSpeaker implements Speaker {
  final spoken = <String>[];
  int stops = 0;

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async => stops++;
}

class FakeReminders implements ReminderScheduler {
  ReminderSettings? applied;

  @override
  Future<void> apply(ReminderSettings settings) async => applied = settings;

  @override
  Future<bool> requestPermission() async => true;
}

WorkoutSession session(String id, DateTime at, {Effort? effort}) =>
    WorkoutSession(
      id: id,
      programId: 'chest_pemula',
      programName: 'Dada Pemula',
      startedAt: at,
      durationSeconds: 600,
      calories: 40,
      exercisesDone: 8,
      effort: effort,
    );

Future<AppState> makeState(
  Map<String, Object> prefs, {
  Speaker speaker = const SilentSpeaker(),
  ReminderScheduler reminders = const NoopReminderScheduler(),
}) async {
  SharedPreferences.setMockInitialValues({'weightKg': 70.0, ...prefs});
  return AppState(
    await SharedPreferences.getInstance(),
    clock: () => DateTime(2026, 10, 22, 9),
    speaker: speaker,
    reminders: reminders,
  );
}

void main() {
  testWidgets('menilai latihan memunculkan saran naik level', (tester) async {
    usePhoneScreen(tester);
    final state = await makeState({});
    await state.addSession(
      session('a', DateTime(2026, 10, 20, 7), effort: Effort.ringan),
    );
    await state.addSession(
      session('b', DateTime(2026, 10, 21, 7), effort: Effort.ringan),
    );
    final today = session('c', DateTime(2026, 10, 22, 7));
    await state.addSession(today);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          home: WorkoutSummaryScreen(session: today, totalExercises: 8),
        ),
      ),
    );
    expect(find.text('Siap naik level?'), findsNothing);

    await tester.tap(find.text('Terlalu ringan'));
    await tester.pumpAndSettle();
    expect(state.sessions.first.effort, Effort.ringan);
    expect(find.text('Siap naik level?'), findsOneWidget);

    await tester.ensureVisible(find.text('Ganti ke Menengah'));
    await tester.tap(find.text('Ganti ke Menengah'));
    await tester.pumpAndSettle();
    expect(state.level, Level.menengah);
    expect(find.text('Siap naik level?'), findsNothing);
  });

  testWidgets('mulai program 4 minggu dari beranda', (tester) async {
    usePhoneScreen(tester);
    final state = await makeState({'weeklyTargetDays': 3});
    await tester.pumpWidget(HomeWorkoutApp(state: state));

    await tester.ensureVisible(find.text('Ikuti program 4 minggu'));
    await tester.tap(find.text('Ikuti program 4 minggu'));
    await tester.pumpAndSettle();
    expect(find.text('Latihan yang naik bertahap'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Mulai program'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Mulai program'));
    await tester.pumpAndSettle();
    expect(find.text('Minggu 1 dari 4'), findsOneWidget);
    expect(find.text('0 / 12 sesi selesai'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Minggu 1 dari 4, sesi 1 dari 3'), findsOneWidget);
    expect(find.text('Dada Pemula'), findsOneWidget);
  });

  testWidgets('menyusun latihan sendiri', (tester) async {
    usePhoneScreen(tester);
    final state = await makeState({});
    await tester.pumpWidget(HomeWorkoutApp(state: state));
    await tester.tap(find.text('Latihan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buat latihan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pagi singkat');

    // Belum ada gerakan → tidak tersimpan.
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Tambahkan minimal satu gerakan'), findsOneWidget);
    expect(state.customWorkouts, isEmpty);

    await tester.tap(find.text('Tambah gerakan'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Squat'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();
    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambah').first);
    await tester.pump();
    expect(find.text('11'), findsOneWidget);

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    final saved = state.customWorkouts.single;
    expect(saved.name, 'Pagi singkat');
    expect(saved.items.single.exerciseId, 'squat');
    expect(saved.items.single.amount, 11);
    expect(saved.items.single.isReps, isTrue);
    expect(find.text('Pagi singkat'), findsOneWidget);
  });

  testWidgets('panduan suara berbicara dan bisa dimatikan', (tester) async {
    usePhoneScreen(tester);
    final speaker = RecordingSpeaker();
    final state = await makeState({}, speaker: speaker);
    await tester.pumpWidget(HomeWorkoutApp(state: state));

    await tester.ensureVisible(find.text('Mulai latihan'));
    await tester.tap(find.text('Mulai latihan'));
    await settle(tester);
    expect(speaker.spoken.first, startsWith('Bersiap. Gerakan pertama,'));

    await tester.tap(find.text('Mulai'));
    await tester.pump();
    expect(speaker.spoken.last, isNot(startsWith('Bersiap')));

    await tester.tap(find.byTooltip('Matikan panduan suara'));
    await tester.pump();
    expect(state.voiceEnabled, isFalse);
    expect(find.byTooltip('Nyalakan panduan suara'), findsOneWidget);
    final count = speaker.spoken.length;

    await tester.tap(find.text('Lewati'));
    await tester.pump();
    expect(speaker.spoken.length, count); // diam

    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
    await tester.tap(find.text('Akhiri'));
    await tester.pumpAndSettle();
  });

  testWidgets('catat berat dari tab progres', (tester) async {
    usePhoneScreen(tester);
    final state = await makeState({});
    await tester.pumpWidget(HomeWorkoutApp(state: state));
    await tester.tap(find.text('Progres'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Catat berat'));
    await tester.tap(find.text('Catat berat'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '68,5');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(state.weightKg, 68.5);
    expect(state.weightLog.last.kg, 68.5);
    expect(find.text('68,5 kg'), findsOneWidget);
  });

  testWidgets('menyalakan pengingat di pengaturan', (tester) async {
    usePhoneScreen(tester);
    final reminders = FakeReminders();
    final state = await makeState({}, reminders: reminders);
    await tester.pumpWidget(HomeWorkoutApp(state: state));
    await tester.tap(find.text('Progres'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Pengingat latihan'));
    await tester.tap(find.text('Pengingat latihan'));
    await tester.pumpAndSettle();
    expect(reminders.applied?.enabled, isTrue);
    expect(find.text('Sen, Sel, Kam, Jum, pukul 17.00'), findsOneWidget);

    await tester.ensureVisible(find.text('Sab'));
    await tester.tap(find.text('Sab'));
    await tester.pumpAndSettle();
    expect(reminders.applied?.weekdays, contains(DateTime.saturday));
  });
}
