import '../models/exercise.dart';
import 'calories.dart';

enum PhaseKind { ready, exercise, rest }

class WorkoutPhase {
  const WorkoutPhase(this.kind, this.seconds, {this.step, this.number = 0});

  final PhaseKind kind;
  final int seconds;
  final WorkoutStep? step;

  /// Nomor urut gerakan inti (mulai dari 1), 0 untuk fase lainnya.
  final int number;

  /// Gerakan repetisi tidak punya hitung mundur; selesai lewat [WorkoutRun.completeReps].
  bool get isReps => step?.isReps ?? false;

  bool get isMain => step?.kind == StepKind.main;
}

/// Logika timer latihan tanpa ketergantungan UI, supaya mudah dites.
///
/// Panggil [tick] setiap detik. Durasi dan kalori hanya dihitung setelah
/// hitung mundur awal; kalori hanya dari fase gerakan (istirahat diabaikan).
class WorkoutRun {
  WorkoutRun(this.program, {required this.weightKg, int readySeconds = 5})
    : phases = _buildPhases(program, readySeconds) {
    remaining = phases.first.seconds;
  }

  final WorkoutProgram program;
  final double weightKg;
  final List<WorkoutPhase> phases;

  int phaseIndex = 0;
  late int remaining;
  int elapsedSeconds = 0;
  double calories = 0;
  int exercisesDone = 0;
  int _spentInPhase = 0;

  /// Detik yang sudah berjalan di fase saat ini.
  int get spentInPhase => _spentInPhase;

  static List<WorkoutPhase> _buildPhases(WorkoutProgram p, int readySeconds) {
    final phases = <WorkoutPhase>[
      if (readySeconds > 0) WorkoutPhase(PhaseKind.ready, readySeconds),
      for (final step in p.warmUp)
        WorkoutPhase(PhaseKind.exercise, step.seconds, step: step),
    ];
    var number = 0;
    var first = true;
    for (var r = 0; r < p.rounds; r++) {
      for (final step in p.steps) {
        if (!first && p.restSeconds > 0) {
          phases.add(WorkoutPhase(PhaseKind.rest, p.restSeconds));
        }
        first = false;
        phases.add(
          WorkoutPhase(
            PhaseKind.exercise,
            step.seconds,
            step: step,
            number: step.kind == StepKind.main ? ++number : 0,
          ),
        );
      }
    }
    for (final step in p.coolDown) {
      phases.add(WorkoutPhase(PhaseKind.exercise, step.seconds, step: step));
    }
    return phases;
  }

  bool get isFinished => phaseIndex >= phases.length;

  WorkoutPhase get current => phases[phaseIndex];

  /// Gerakan berikutnya setelah fase saat ini (null jika sudah terakhir).
  WorkoutStep? get upcomingStep {
    for (var i = phaseIndex + 1; i < phases.length; i++) {
      if (phases[i].kind == PhaseKind.exercise) return phases[i].step;
    }
    return null;
  }

  double get progress => isFinished ? 1 : phaseIndex / phases.length;

  void tick() {
    if (isFinished) return;
    final phase = current;
    if (phase.kind != PhaseKind.ready) elapsedSeconds++;
    if (phase.kind == PhaseKind.exercise) {
      calories += caloriesBurned(
        met: phase.step!.exercise.met,
        weightKg: weightKg,
        seconds: 1,
      );
    }
    _spentInPhase++;
    if (phase.isReps) return;
    remaining--;
    if (remaining <= 0) _advance(done: true);
  }

  /// Pengguna menyelesaikan semua repetisi.
  void completeReps() {
    if (!isFinished && current.isReps) _advance(done: true);
  }

  /// Lewati fase saat ini. Gerakan berbasis waktu tetap dihitung selesai
  /// jika dikerjakan minimal separuh waktunya.
  void skip() {
    if (isFinished) return;
    final phase = current;
    final halfDone = !phase.isReps && _spentInPhase * 2 >= phase.seconds;
    _advance(done: halfDone);
  }

  void extendRest(int seconds) {
    if (!isFinished && current.kind == PhaseKind.rest) remaining += seconds;
  }

  void _advance({required bool done}) {
    if (done && current.isMain) exercisesDone++;
    phaseIndex++;
    _spentInPhase = 0;
    if (!isFinished) remaining = current.seconds;
  }
}
