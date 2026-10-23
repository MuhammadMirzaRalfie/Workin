import 'dart:math' as math;

import '../data/workout_library.dart';
import '../models/exercise.dart';
import '../models/training_plan.dart';
import '../models/workout_session.dart';

/// Jumlah sesi per minggu dari target mingguan: minimal 2 (WHO/ACSM untuk
/// latihan kekuatan), maksimal 6 supaya tetap ada hari istirahat.
int planSessionsFor(int weeklyTargetDays) => weeklyTargetDays.clamp(2, 6);

/// Urutan bagian tubuh dalam satu minggu, disusun supaya otot yang sama
/// tidak dilatih di dua sesi berurutan.
List<BodyFocus> splitFor(int sessionsPerWeek) => switch (sessionsPerWeek.clamp(
  2,
  6,
)) {
  2 => [BodyFocus.upper, BodyFocus.lower],
  3 => [BodyFocus.chest, BodyFocus.legs, BodyFocus.abs],
  4 => [BodyFocus.upper, BodyFocus.lower, BodyFocus.abs, BodyFocus.fullBody],
  5 => [
    BodyFocus.chest,
    BodyFocus.legs,
    BodyFocus.abs,
    BodyFocus.upper,
    BodyFocus.lower,
  ],
  _ => [
    BodyFocus.chest,
    BodyFocus.legs,
    BodyFocus.abs,
    BodyFocus.upper,
    BodyFocus.lower,
    BodyFocus.fullBody,
  ],
};

/// Perubahan takaran per minggu, contoh "+1 putaran". Kosong = takaran dasar.
String weekChange(int week) => switch (week) {
  2 => 'Istirahat lebih singkat',
  3 => 'Tambah 1 putaran',
  4 => 'Tambah 1 putaran, istirahat lebih singkat',
  _ => 'Takaran dasar',
};

/// Program [base] dengan takaran minggu ke-[week] (overload progresif).
/// Protokol riset yang takarannya baku dikembalikan apa adanya.
WorkoutProgram programForWeek(WorkoutProgram base, int week) {
  if (!base.progressive || week <= 1) return base;
  final shorterRest = week == 2 || week == 4;
  final extraRound = week >= 3;
  final rest =
      shorterRest && base.restSeconds > 0
          ? math.max(10, base.restSeconds - 10)
          : base.restSeconds;
  final rounds = base.rounds + (extraRound ? 1 : 0);

  final changes = [
    if (extraRound) '${rounds}x putaran',
    if (rest != base.restSeconds) 'istirahat $rest detik',
  ];
  return base.copyWith(
    id: '${base.id}@m$week',
    rounds: rounds,
    restSeconds: rest,
    description:
        changes.isEmpty
            ? base.description
            : 'Minggu $week: ${changes.join(', ')}',
  );
}

/// Program pustaka untuk satu bagian tubuh. Jika ada beberapa (mis. 2 program
/// seluruh tubuh untuk pemula), digilir per minggu.
WorkoutProgram _baseFor(BodyFocus focus, Level level, int week) {
  final options = [
    for (final p in workoutPrograms)
      if (p.focus == focus && p.level == level) p,
  ];
  return options[(week - 1) % options.length];
}

class PlanWeek {
  const PlanWeek({
    required this.number,
    required this.start,
    required this.programs,
  });

  final int number;
  final DateTime start;
  final List<WorkoutProgram> programs;

  DateTime get end => DateTime(start.year, start.month, start.day + 7);
}

List<PlanWeek> buildPlanWeeks(TrainingPlan plan) {
  final s = plan.startedOn;
  final split = splitFor(plan.sessionsPerWeek);
  return [
    for (var week = 1; week <= TrainingPlan.weeks; week++)
      PlanWeek(
        number: week,
        start: DateTime(s.year, s.month, s.day + 7 * (week - 1)),
        programs: [
          for (final focus in split)
            programForWeek(_baseFor(focus, plan.level, week), week),
        ],
      ),
  ];
}

class PlanStatus {
  const PlanStatus({
    required this.plan,
    required this.weeks,
    required this.done,
    required this.currentWeek,
  });

  final TrainingPlan plan;
  final List<PlanWeek> weeks;

  /// done[minggu-1][sesi] = sudah dikerjakan.
  final List<List<bool>> done;

  /// 1–4; lebih dari 4 berarti rencana sudah lewat.
  final int currentWeek;

  bool get isFinished => currentWeek > TrainingPlan.weeks;

  int get doneCount => done.expand((w) => w).where((d) => d).length;

  int get totalCount => done.fold(0, (t, w) => t + w.length);

  PlanWeek? get thisWeek => isFinished ? null : weeks[currentWeek - 1];

  /// Indeks sesi berikutnya minggu ini, null jika minggu ini sudah tuntas.
  int? get nextIndex {
    if (isFinished) return null;
    final index = done[currentWeek - 1].indexOf(false);
    return index < 0 ? null : index;
  }

  WorkoutProgram? get nextProgram {
    final i = nextIndex;
    return i == null ? null : thisWeek!.programs[i];
  }
}

int _dayNumber(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// Sesi rencana dianggap selesai jika programnya (varian minggu itu)
/// dikerjakan di dalam rentang minggu tersebut. Satu sesi latihan hanya
/// bisa menandai satu sesi rencana.
PlanStatus computePlanStatus(
  TrainingPlan plan,
  List<WorkoutSession> sessions,
  DateTime now,
) {
  final weeks = buildPlanWeeks(plan);
  final days = _dayNumber(now) - _dayNumber(plan.startedOn);
  final currentWeek = days < 0 ? 1 : days ~/ 7 + 1;

  final done = <List<bool>>[];
  for (final week in weeks) {
    final pool = [
      for (final s in sessions)
        if (!s.startedAt.isBefore(week.start) && s.startedAt.isBefore(week.end))
          s.programId,
    ];
    done.add([for (final program in week.programs) pool.remove(program.id)]);
  }
  return PlanStatus(
    plan: plan,
    weeks: weeks,
    done: done,
    currentWeek: currentWeek,
  );
}
