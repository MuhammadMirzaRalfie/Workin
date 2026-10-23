import 'package:flutter_test/flutter_test.dart';
import 'package:home_workout/data/exercise_poses.dart';
import 'package:home_workout/data/workout_library.dart';
import 'package:home_workout/models/exercise.dart';
import 'package:home_workout/models/workout_session.dart';
import 'package:home_workout/services/calories.dart';
import 'package:home_workout/services/stats.dart';
import 'package:home_workout/services/workout_run.dart';
import 'package:home_workout/utils/format.dart';

WorkoutSession session(DateTime at, {double kcal = 100, int seconds = 600}) =>
    WorkoutSession(
      id: at.toIso8601String(),
      programId: 'x',
      programName: 'X',
      startedAt: at,
      durationSeconds: seconds,
      calories: kcal,
      exercisesDone: 1,
    );

const testSource = WorkoutSource(
  origin: 'Tes',
  citation: '-',
  summary: '-',
  schedule: '-',
);

void main() {
  test('kalori = MET × berat × jam', () {
    expect(caloriesBurned(met: 8, weightKg: 60, seconds: 3600), 480);
    expect(caloriesBurned(met: 4, weightKg: 75, seconds: 1800), 150);
  });

  test('minggu dimulai hari Senin', () {
    // 22 Okt 2026 = Kamis
    expect(startOfWeek(DateTime(2026, 10, 22, 21)), DateTime(2026, 10, 19));
    // Minggu tetap masuk minggu yang sama
    expect(startOfWeek(DateTime(2026, 10, 25)), DateTime(2026, 10, 19));
    // Lintas bulan
    expect(startOfWeek(DateTime(2026, 11, 1)), DateTime(2026, 10, 26));
  });

  test('total harian per minggu', () {
    final sessions = [
      session(DateTime(2026, 10, 19, 7)), // Senin
      session(DateTime(2026, 10, 19, 19), kcal: 50), // Senin lagi
      session(DateTime(2026, 10, 22, 6)), // Kamis
      session(DateTime(2026, 10, 18, 8)), // Minggu lalu
    ];
    final days = dailyTotalsForWeek(sessions, DateTime(2026, 10, 22, 12));
    expect(days.map((d) => d.calories).toList(), [150, 0, 0, 100, 0, 0, 0]);
    expect(days[0].sessions, 2);
  });

  test('durasi program termasuk istirahat', () {
    const program = WorkoutProgram(
      id: 't',
      name: 'T',
      level: Level.pemula,
      focus: BodyFocus.fullBody,
      description: '-',
      source: testSource,
      rounds: 2,
      restSeconds: 10,
      steps: [
        WorkoutStep(Exercises.squat, 30),
        WorkoutStep(Exercises.plank, 20),
      ],
    );
    // 4 gerakan: 2×(30+20) = 100 aktif + 3 istirahat × 10
    expect(program.totalSeconds, 130);
    expect(program.exerciseCount, 4);
  });

  test('WorkoutRun menghitung durasi & kalori hanya dari gerakan', () {
    const program = WorkoutProgram(
      id: 't',
      name: 'T',
      level: Level.pemula,
      focus: BodyFocus.fullBody,
      description: '-',
      source: testSource,
      restSeconds: 5,
      steps: [
        WorkoutStep(Exercises.jumpingJack, 10),
        WorkoutStep(Exercises.squat, 10),
      ],
    );
    final run = WorkoutRun(program, weightKg: 72, readySeconds: 3);
    var ticks = 0;
    while (!run.isFinished) {
      run.tick();
      ticks++;
    }
    expect(ticks, 3 + 10 + 5 + 10);
    expect(run.elapsedSeconds, 25); // tanpa hitung mundur awal
    expect(run.exercisesDone, 2);
    final expected =
        caloriesBurned(
          met: Exercises.jumpingJack.met,
          weightKg: 72,
          seconds: 10,
        ) +
        caloriesBurned(met: Exercises.squat.met, weightKg: 72, seconds: 10);
    expect(run.calories, closeTo(expected, 1e-9));
  });

  test('gerakan yang dilewati terlalu cepat tidak dihitung selesai', () {
    final run = WorkoutRun(
      programById('hict_7min')!,
      weightKg: 60,
      readySeconds: 0,
    );
    run.tick(); // 1 detik dari 30
    run.skip();
    expect(run.exercisesDone, 0);
    expect(run.current.kind, PhaseKind.rest);
  });

  test('protokol McMaster: 11 × 1 menit tanpa jeda istirahat', () {
    final program = programById('mcmaster_11min')!;
    expect(program.totalSeconds, 11 * 60);
    final run = WorkoutRun(program, weightKg: 60, readySeconds: 0);
    expect(run.phases.length, 11);
    expect(run.phases.every((p) => p.kind == PhaseKind.exercise), isTrue);
  });

  test('7-Minute Workout sesuai Klika & Jordan: 12 × 30 dtk, jeda 10 dtk', () {
    final program = programById('hict_7min')!;
    expect(program.steps.length, 12);
    expect(program.steps.every((s) => s.seconds == 30), isTrue);
    expect(program.restSeconds, 10);
    expect(program.totalSeconds, 12 * 30 + 11 * 10);
  });

  test('gerakan repetisi menunggu tombol Selesai', () {
    const program = WorkoutProgram(
      id: 't',
      name: 'T',
      level: Level.pemula,
      focus: BodyFocus.chest,
      description: '-',
      source: testSource,
      restSeconds: 10,
      steps: [
        WorkoutStep.reps(Exercises.pushUp, 10),
        WorkoutStep.reps(Exercises.lunge, 8, perSide: true),
      ],
    );
    expect(program.steps[0].seconds, 10 * WorkoutStep.secondsPerRep);
    expect(program.steps[1].seconds, 16 * WorkoutStep.secondsPerRep);
    expect(program.steps[1].target, '×8/sisi');

    final run = WorkoutRun(program, weightKg: 60, readySeconds: 0);
    for (var i = 0; i < 100; i++) {
      run.tick();
    }
    // Tidak maju otomatis walau melewati perkiraan waktu.
    expect(run.phaseIndex, 0);
    expect(run.elapsedSeconds, 100);

    run.completeReps();
    expect(run.exercisesDone, 1);
    expect(run.current.kind, PhaseKind.rest);

    run.extendRest(20);
    expect(run.remaining, 30);

    run.skip(); // lewati istirahat
    run.skip(); // lewati gerakan repetisi → tidak dihitung selesai
    expect(run.isFinished, isTrue);
    expect(run.exercisesDone, 1);
  });

  test('pemanasan & pendinginan tidak dihitung sebagai gerakan inti', () {
    final program = programById('chest_pemula')!;
    expect(program.exerciseCount, program.steps.length * program.rounds);
    final run = WorkoutRun(program, weightKg: 60, readySeconds: 0);
    expect(run.phases.first.step!.kind, StepKind.warmUp);
    expect(run.phases.last.step!.kind, StepKind.coolDown);
    final mainNumbers =
        run.phases.where((p) => p.isMain).map((p) => p.number).toList();
    expect(mainNumbers.last, program.exerciseCount);
  });

  test('setiap bagian tubuh punya 3 level', () {
    for (final focus in BodyFocus.values.where(
      (f) => f != BodyFocus.fullBody,
    )) {
      final levels =
          workoutPrograms
              .where((p) => p.focus == focus)
              .map((p) => p.level)
              .toSet();
      expect(levels, Level.values.toSet(), reason: focus.label);
    }
  });

  test('id program unik', () {
    final ids = workoutPrograms.map((p) => p.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('setiap gerakan di program punya figur', () {
    final ids = {
      for (final p in workoutPrograms)
        for (final s in [...p.warmUp, ...p.steps, ...p.coolDown]) s.exercise.id,
    };
    expect(ids.difference(exerciseAnimations.keys.toSet()), isEmpty);
  });

  test('pose figur hanya untuk gerakan yang ada di program', () {
    final ids = {
      for (final p in workoutPrograms)
        for (final s in [...p.warmUp, ...p.steps, ...p.coolDown]) s.exercise.id,
    };
    for (final id in exerciseAnimations.keys) {
      expect(ids, contains(id));
    }
  });

  test('semua program punya rujukan', () {
    for (final p in workoutPrograms) {
      expect(p.source.citation, isNotEmpty, reason: p.id);
    }
  });

  test('format angka Indonesia', () {
    expect(formatNumber(1240.4), '1.240');
    expect(formatNumber(999), '999');
    expect(formatNumber(1234567), '1.234.567');
    expect(formatClock(95), '1:35');
    expect(formatDayDate(DateTime(2026, 10, 22)), 'Kamis, 22 Okt');
  });

  test('session JSON bolak-balik', () {
    final s = session(DateTime(2026, 10, 22, 7, 30));
    final copy = WorkoutSession.fromJson(s.toJson());
    expect(copy.startedAt, s.startedAt);
    expect(copy.calories, s.calories);
  });
}
