import 'package:flutter_test/flutter_test.dart';
import 'package:home_workout/data/exercise_poses.dart';
import 'package:home_workout/data/workout_library.dart';
import 'package:home_workout/models/custom_workout.dart';
import 'package:home_workout/models/exercise.dart';
import 'package:home_workout/models/training_plan.dart';
import 'package:home_workout/models/workout_session.dart';
import 'package:home_workout/services/plan_builder.dart';
import 'package:home_workout/services/progression.dart';
import 'package:home_workout/services/reminders.dart';
import 'package:home_workout/services/voice_coach.dart';
import 'package:home_workout/services/workout_run.dart';
import 'package:home_workout/state/app_state.dart';
import 'package:home_workout/utils/format.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _source = WorkoutSource(
  origin: 'Tes',
  citation: '-',
  summary: '-',
  schedule: '-',
);

WorkoutSession rated(
  DateTime at,
  Effort? effort, {
  String programId = 'chest_pemula',
}) => WorkoutSession(
  id: at.toIso8601String(),
  programId: programId,
  programName: programId,
  startedAt: at,
  durationSeconds: 600,
  calories: 50,
  exercisesDone: 4,
  effort: effort,
);

class FakeReminders implements ReminderScheduler {
  ReminderSettings? applied;
  bool allow = true;

  @override
  Future<void> apply(ReminderSettings settings) async => applied = settings;

  @override
  Future<bool> requestPermission() async => allow;
}

Future<AppState> makeState(
  Map<String, Object> prefs, {
  DateTime? now,
  ReminderScheduler reminders = const NoopReminderScheduler(),
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  return AppState(
    await SharedPreferences.getInstance(),
    clock: () => now ?? DateTime(2026, 10, 22, 9),
    reminders: reminders,
  );
}

void main() {
  group('panduan suara', () {
    const program = WorkoutProgram(
      id: 't',
      name: 'Tes',
      level: Level.pemula,
      focus: BodyFocus.fullBody,
      description: '',
      source: _source,
      restSeconds: 10,
      steps: [
        WorkoutStep(Exercises.jumpingJack, 20),
        WorkoutStep.reps(Exercises.lunge, 8, perSide: true),
      ],
    );

    test('kalimat pembuka menyebut gerakan pertama', () {
      final run = WorkoutRun(program, weightKg: 60);
      expect(startCue(run), 'Bersiap. Gerakan pertama, Jumping Jack.');
    });

    test('isyarat per fase, setengah jalan, hitung mundur, selesai', () {
      final run = WorkoutRun(program, weightKg: 60, readySeconds: 0);
      // Awal fase gerakan berwaktu.
      expect(voiceCue(run, phaseChanged: true), 'Jumping Jack, 20 detik.');

      final spoken = <String>[];
      while (run.current.kind == PhaseKind.exercise) {
        final before = run.phaseIndex;
        run.tick();
        final cue = voiceCue(run, phaseChanged: run.phaseIndex != before);
        if (cue != null) spoken.add(cue);
      }
      expect(spoken, [
        'Setengah jalan.',
        'tiga',
        'dua',
        'satu',
        'Istirahat 10 detik. Berikutnya, Lunge.',
      ]);

      // Istirahat 10 detik juga dihitung mundur.
      for (var i = 0; i < 7; i++) {
        run.tick();
      }
      expect(voiceCue(run, phaseChanged: false), 'tiga');
      run
        ..tick()
        ..tick()
        ..tick();
      expect(voiceCue(run, phaseChanged: true), 'Lunge, 8 kali per sisi.');
      // Gerakan repetisi tidak dihitung mundur.
      run.tick();
      expect(voiceCue(run, phaseChanged: false), isNull);
      run.completeReps();
      expect(
        voiceCue(run, phaseChanged: true),
        'Latihan selesai. Kerja bagus.',
      );
    });

    test('target diucapkan dalam menit untuk kelipatan 60 detik', () {
      expect(spokenTarget(const WorkoutStep(Exercises.plank, 120)), '2 menit');
      expect(
        spokenTarget(const WorkoutStep.reps(Exercises.squat, 15)),
        '15 kali',
      );
    });
  });

  group('saran level', () {
    final t0 = DateTime(2026, 10, 1);
    DateTime day(int n) => t0.add(Duration(days: n));

    test('3 sesi terakhir terlalu ringan → naik level', () {
      final sessions = [
        rated(day(3), Effort.ringan),
        rated(day(2), Effort.ringan),
        rated(day(1), Effort.ringan),
      ];
      final advice = adviseLevel(sessions: sessions, level: Level.pemula);
      expect(advice?.to, Level.menengah);
      expect(advice?.up, isTrue);
    });

    test('belum cukup, atau ada yang pas → tidak ada saran', () {
      expect(
        adviseLevel(
          sessions: [
            rated(day(2), Effort.ringan),
            rated(day(1), Effort.ringan),
          ],
          level: Level.pemula,
        ),
        isNull,
      );
      expect(
        adviseLevel(
          sessions: [
            rated(day(3), Effort.ringan),
            rated(day(2), Effort.pas),
            rated(day(1), Effort.ringan),
          ],
          level: Level.pemula,
        ),
        isNull,
      );
    });

    test('sesi tanpa nilai, level lain, dan latihan buatan diabaikan', () {
      final sessions = [
        rated(day(6), Effort.ringan),
        rated(day(5), null),
        rated(day(4), Effort.berat, programId: 'chest_menengah'),
        rated(day(3), Effort.berat, programId: 'custom:1'),
        rated(day(2), Effort.ringan, programId: 'legs_pemula@m3'),
        rated(day(1), Effort.ringan),
      ];
      expect(
        adviseLevel(sessions: sessions, level: Level.pemula)?.to,
        Level.menengah,
      );
    });

    test('2 sesi terlalu berat → turun; batas level dan since dihormati', () {
      final hard = [
        rated(day(2), Effort.berat, programId: 'abs_lanjutan'),
        rated(day(1), Effort.berat, programId: 'abs_lanjutan'),
      ];
      expect(
        adviseLevel(sessions: hard, level: Level.lanjutan)?.to,
        Level.menengah,
      );
      expect(
        adviseLevel(sessions: hard, level: Level.lanjutan, since: day(1)),
        isNull,
      );
      final easyTop = [
        for (var i = 3; i > 0; i--)
          rated(day(i), Effort.ringan, programId: 'abs_lanjutan'),
      ];
      expect(adviseLevel(sessions: easyTop, level: Level.lanjutan), isNull);
    });
  });

  group('program 4 minggu', () {
    test('jumlah sesi dibatasi 2–6 dan pembagian sesuai jumlah', () {
      expect(planSessionsFor(1), 2);
      expect(planSessionsFor(4), 4);
      expect(planSessionsFor(7), 6);
      for (var n = 2; n <= 6; n++) {
        expect(splitFor(n), hasLength(n));
      }
      expect(splitFor(3), [BodyFocus.chest, BodyFocus.legs, BodyFocus.abs]);
    });

    test('takaran naik per minggu untuk program kekuatan', () {
      final base = programById('chest_pemula')!;
      expect(base.rounds, 2);
      expect(base.restSeconds, 30);
      expect(programForWeek(base, 1), same(base));

      final w2 = programForWeek(base, 2);
      expect((w2.rounds, w2.restSeconds, w2.id), (2, 20, 'chest_pemula@m2'));
      final w3 = programForWeek(base, 3);
      expect((w3.rounds, w3.restSeconds), (3, 30));
      final w4 = programForWeek(base, 4);
      expect((w4.rounds, w4.restSeconds), (3, 20));
      expect(w4.totalSeconds, greaterThan(base.totalSeconds));
      expect(programById(w4.id), same(base));
    });

    test('protokol riset tidak diubah, istirahat minimal 10 detik', () {
      final mcmaster = programById('mcmaster_11min')!;
      expect(programForWeek(mcmaster, 4), same(mcmaster));
      final hict = programById('hict_7min')!;
      expect(programForWeek(hict, 2).restSeconds, 10);
      expect(programForWeek(hict, 3).rounds, 2);
      final lanjutan = programById('legs_lanjutan')!;
      expect(programForWeek(lanjutan, 2).restSeconds, 10);
    });

    test('status: sesi selesai, sesi berikutnya, minggu berjalan', () {
      final plan = TrainingPlan(
        startedOn: DateTime(2026, 10, 1),
        level: Level.pemula,
        sessionsPerWeek: 3,
      );
      final weeks = buildPlanWeeks(plan);
      expect(weeks, hasLength(4));
      expect(weeks[1].start, DateTime(2026, 10, 8));
      expect(weeks[0].programs.map((p) => p.id), [
        'chest_pemula',
        'legs_pemula',
        'abs_pemula',
      ]);

      final sessions = [
        // Minggu 2: sesi kedua dikerjakan.
        rated(DateTime(2026, 10, 9, 7), null, programId: 'legs_pemula@m2'),
        // Minggu 1: program yang sama dikerjakan dua kali → tetap satu sesi.
        rated(DateTime(2026, 10, 2, 7), null, programId: 'chest_pemula'),
        rated(DateTime(2026, 10, 1, 7), null, programId: 'chest_pemula'),
        // Varian minggu lain tidak dihitung di minggu ini.
        rated(DateTime(2026, 10, 3, 7), null, programId: 'abs_pemula@m2'),
      ];
      final status = computePlanStatus(plan, sessions, DateTime(2026, 10, 9));
      expect(status.currentWeek, 2);
      expect(status.done[0], [true, false, false]);
      expect(status.done[1], [false, true, false]);
      expect(status.doneCount, 2);
      expect(status.totalCount, 12);
      expect(status.nextProgram?.id, 'chest_pemula@m2');

      final later = computePlanStatus(plan, sessions, DateTime(2026, 10, 29));
      expect(later.isFinished, isTrue);
      expect(later.nextProgram, isNull);
    });

    test('pemula seluruh tubuh bergilir 5BX dan McMaster per minggu', () {
      final plan = TrainingPlan(
        startedOn: DateTime(2026, 10, 1),
        level: Level.pemula,
        sessionsPerWeek: 6,
      );
      final weeks = buildPlanWeeks(plan);
      expect(weeks[0].programs.last.id, 'rcaf_5bx_chart1');
      expect(weeks[1].programs.last.id, 'mcmaster_11min');
    });
  });

  group('latihan buatan', () {
    const workout = CustomWorkout(
      id: '1',
      name: 'Pagi',
      rounds: 3,
      restSeconds: 15,
      items: [
        CustomItem(exerciseId: 'squat', amount: 12, isReps: true),
        CustomItem(exerciseId: 'plank', amount: 40, isReps: false),
        CustomItem(exerciseId: 'lunge', amount: 8, isReps: true, perSide: true),
        CustomItem(exerciseId: 'tidak_ada', amount: 5, isReps: true),
      ],
    );

    test('JSON bolak-balik', () {
      final copy = CustomWorkout.fromJson(workout.toJson());
      expect(copy.name, 'Pagi');
      expect(copy.rounds, 3);
      expect(copy.items[2].perSide, isTrue);
      expect(copy.items[1].isReps, isFalse);
    });

    test('jadi program yang bisa diputar', () {
      final program = programFromCustom(workout);
      expect(program.id, 'custom:1');
      expect(program.isCustom, isTrue);
      expect(program.steps, hasLength(3)); // gerakan tak dikenal dilewati
      expect(program.steps[0].target, '×12');
      expect(program.steps[1].target, '40 dtk');
      expect(program.steps[2].target, '×8/sisi');
      expect(program.warmUp, hasLength(1));
      expect(program.exerciseCount, 9);
      expect(programById(program.id), isNull);

      final bare = programFromCustom(
        CustomWorkout(
          id: '2',
          name: 'x',
          items: workout.items,
          withWarmUp: false,
        ),
      );
      expect(bare.warmUp, isEmpty);
      expect(bare.coolDown, isEmpty);
    });

    test('katalog berisi semua gerakan inti dan semuanya berfigur', () {
      final catalog = {
        for (final (_, list) in exerciseCategories) ...list.map((e) => e.id),
      };
      final used = {
        for (final p in workoutPrograms)
          for (final s in p.steps) s.exercise.id,
      };
      expect(catalog.containsAll(used), isTrue);
      for (final id in catalog) {
        expect(exerciseAnimations.containsKey(id), isTrue, reason: id);
      }
    });

    test('takaran awal mengikuti pemakaian di pustaka', () {
      expect(defaultStepFor(Exercises.squat).reps, 10);
      expect(defaultStepFor(Exercises.lunge).perSide, isTrue);
      expect(defaultStepFor(Exercises.plank).isReps, isFalse);
      expect(defaultStepFor(Exercises.plank).seconds, 30);
    });
  });

  group('AppState v2', () {
    test('penilaian sesi tersimpan', () async {
      final state = await makeState({'weightKg': 60.0});
      await state.addSession(rated(DateTime(2026, 10, 22, 7), null));
      await state.rateSession('2026-10-22T07:00:00.000', Effort.pas);
      final prefs = await SharedPreferences.getInstance();
      final reloaded = AppState(prefs);
      expect(reloaded.sessions.single.effort, Effort.pas);
    });

    test('saran level hilang setelah ganti level atau ditutup', () async {
      final state = await makeState({'weightKg': 60.0});
      for (var i = 1; i <= 3; i++) {
        await state.addSession(rated(DateTime(2026, 10, 20, i), Effort.ringan));
      }
      expect(state.levelAdvice?.to, Level.menengah);
      await state.dismissLevelAdvice();
      expect(state.levelAdvice, isNull);

      final other = await makeState({'weightKg': 60.0});
      for (var i = 1; i <= 3; i++) {
        await other.addSession(rated(DateTime(2026, 10, 20, i), Effort.ringan));
      }
      await other.setLevel(Level.menengah);
      expect(other.level, Level.menengah);
      expect(other.levelAdvice, isNull);
    });

    test('rencana dimulai hari ini dengan sesi sesuai target', () async {
      final state = await makeState({'weightKg': 60.0, 'weeklyTargetDays': 3});
      expect(state.planStatus, isNull);
      await state.startPlan();
      expect(state.plan!.startedOn, DateTime(2026, 10, 22));
      expect(state.planStatus!.nextProgram!.id, 'chest_pemula');
      final reloaded = AppState(await SharedPreferences.getInstance());
      expect(reloaded.plan!.sessionsPerWeek, 3);
      await state.stopPlan();
      expect(state.plan, isNull);
    });

    test('catat berat: satu per hari, memperbarui berat kalori', () async {
      var now = DateTime(2026, 10, 1, 8);
      SharedPreferences.setMockInitialValues({'weightKg': 70.0});
      final state = AppState(
        await SharedPreferences.getInstance(),
        clock: () => now,
      );
      // Data lama: berat profil jadi catatan pertama.
      expect(state.weightLog.single.kg, 70);

      now = DateTime(2026, 10, 8, 8);
      await state.logWeight(69.4);
      await state.logWeight(69.2); // hari sama → menimpa
      expect(state.weightLog.map((e) => e.kg), [70, 69.2]);
      expect(state.weightKg, 69.2);

      now = DateTime(2026, 10, 15, 8);
      await state.saveProfile(
        weightKg: 68.5,
        weeklyTargetDays: 4,
        level: Level.pemula,
      );
      expect(state.weightLog, hasLength(3));
      final reloaded = AppState(await SharedPreferences.getInstance());
      expect(reloaded.weightLog.map((e) => e.kg), [70, 69.2, 68.5]);
    });

    test('pengingat: bawaan dari target, disimpan & dipasang', () async {
      final fake = FakeReminders();
      final state = await makeState({
        'weightKg': 60.0,
        'weeklyTargetDays': 3,
      }, reminders: fake);
      expect(state.reminder.enabled, isFalse);
      expect(state.reminder.weekdays, {1, 3, 5});
      await state.setReminder(state.reminder.copyWith(enabled: true, hour: 6));
      expect(fake.applied?.enabled, isTrue);
      final reloaded = AppState(await SharedPreferences.getInstance());
      expect(reloaded.reminder.hour, 6);
      expect(reloaded.reminder.enabled, isTrue);
    });

    test('latihan buatan: simpan, ubah, hapus', () async {
      final state = await makeState({'weightKg': 60.0});
      const w = CustomWorkout(
        id: 'a',
        name: 'A',
        items: [CustomItem(exerciseId: 'squat', amount: 10, isReps: true)],
      );
      await state.saveCustomWorkout(w);
      await state.saveCustomWorkout(
        CustomWorkout(id: 'a', name: 'B', items: w.items),
      );
      expect(state.customWorkouts.single.name, 'B');
      final reloaded = AppState(await SharedPreferences.getInstance());
      expect(reloaded.customWorkoutById('a')?.name, 'B');
      await state.deleteCustomWorkout('a');
      expect(state.customWorkouts, isEmpty);
    });
  });

  test('format berat & jam', () {
    expect(formatKg(65.5), '65,5');
    expect(formatKg(70), '70');
    expect(formatKg(69.96), '70');
    expect(formatTime(7, 5), '07.05');
    expect(formatShortDate(DateTime(2026, 10, 3)), '3 Okt');
  });
}
