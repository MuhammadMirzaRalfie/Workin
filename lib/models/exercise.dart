import '../services/calories.dart';

/// Satu gerakan latihan tanpa alat.
///
/// [met] = Metabolic Equivalent of Task, dipakai untuk estimasi kalori.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.met,
    required this.cue,
  });

  final String id;
  final String name;
  final double met;

  /// Petunjuk singkat cara melakukan gerakan.
  final String cue;
}

enum Level {
  pemula('Pemula', 'Belum pernah atau sudah lama tidak latihan kekuatan'),
  menengah('Menengah', 'Rutin latihan sekitar 6 bulan terakhir'),
  lanjutan('Lanjutan', 'Rutin latihan bertahun-tahun');

  const Level(this.label, this.description);

  final String label;
  final String description;
}

enum BodyFocus {
  fullBody('Seluruh Tubuh'),
  chest('Dada'),
  abs('Perut'),
  legs('Kaki'),
  upper('Tubuh Atas'),
  lower('Tubuh Bawah');

  const BodyFocus(this.label);

  final String label;
}

enum StepKind { main, warmUp, recovery, coolDown }

class WorkoutStep {
  /// Gerakan berbasis waktu (detik).
  const WorkoutStep(this.exercise, this.seconds, {this.kind = StepKind.main})
    : reps = null,
      perSide = false;

  /// Gerakan berbasis repetisi; selesai saat pengguna menekan "Selesai".
  /// [seconds] hanya perkiraan untuk durasi & kalori program.
  const WorkoutStep.reps(
    this.exercise,
    int this.reps, {
    this.perSide = false,
    this.kind = StepKind.main,
  }) : seconds = reps * (perSide ? 2 : 1) * secondsPerRep;

  /// Perkiraan waktu satu repetisi gerakan berat badan.
  static const secondsPerRep = 3;

  final Exercise exercise;
  final int seconds;
  final StepKind kind;
  final int? reps;

  /// Repetisi dihitung per sisi (kiri dan kanan).
  final bool perSide;

  bool get isReps => reps != null;

  /// Contoh: "×12", "×10/sisi", "30 dtk", "2 mnt".
  String get target {
    if (isReps) return '×$reps${perSide ? '/sisi' : ''}';
    if (seconds % 60 == 0) return '${seconds ~/ 60} mnt';
    return '$seconds dtk';
  }
}

/// Rujukan ilmiah/profesional dari sebuah program.
class WorkoutSource {
  const WorkoutSource({
    required this.origin,
    required this.citation,
    required this.summary,
    required this.schedule,
  });

  /// Label singkat, contoh: "McMaster University, 2021".
  final String origin;
  final String citation;

  /// Apa programnya dan apa yang terbukti.
  final String summary;

  /// Cara pakai yang disarankan sumbernya.
  final String schedule;
}

class WorkoutProgram {
  const WorkoutProgram({
    required this.id,
    required this.name,
    required this.level,
    required this.focus,
    required this.description,
    required this.steps,
    required this.source,
    this.warmUp = const [],
    this.coolDown = const [],
    this.rounds = 1,
    this.restSeconds = 15,
    this.progressive = false,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final Level level;
  final BodyFocus focus;
  final String description;

  /// Dilakukan sekali sebelum gerakan inti.
  final List<WorkoutStep> warmUp;

  /// Gerakan inti, diulang sebanyak [rounds].
  final List<WorkoutStep> steps;

  /// Dilakukan sekali setelah gerakan inti.
  final List<WorkoutStep> coolDown;

  final WorkoutSource source;
  final int rounds;

  /// Istirahat diam di antara gerakan inti; 0 berarti langsung lanjut.
  final int restSeconds;

  /// Boleh ditambah putaran / dipersingkat istirahatnya di program 4 minggu.
  /// Protokol riset yang takarannya baku (5BX, McMaster) bernilai false.
  final bool progressive;

  /// Latihan buatan pengguna (tanpa level & rujukan studi).
  final bool isCustom;

  WorkoutProgram copyWith({
    String? id,
    String? description,
    int? rounds,
    int? restSeconds,
  }) {
    return WorkoutProgram(
      id: id ?? this.id,
      name: name,
      level: level,
      focus: focus,
      description: description ?? this.description,
      warmUp: warmUp,
      steps: steps,
      coolDown: coolDown,
      source: source,
      rounds: rounds ?? this.rounds,
      restSeconds: restSeconds ?? this.restSeconds,
      progressive: progressive,
      isCustom: isCustom,
    );
  }

  int get exerciseCount =>
      steps.where((s) => s.kind == StepKind.main).length * rounds;

  /// Total perkiraan durasi termasuk istirahat.
  int get totalSeconds {
    int sum(List<WorkoutStep> list) => list.fold(0, (t, s) => t + s.seconds);
    final mainPhases = steps.length * rounds;
    return sum(warmUp) +
        sum(steps) * rounds +
        restSeconds * (mainPhases - 1) +
        sum(coolDown);
  }

  int get totalMinutes => (totalSeconds / 60).round();

  double estimateCalories(double weightKg) {
    double sum(List<WorkoutStep> list) => list.fold(
      0.0,
      (t, s) =>
          t +
          caloriesBurned(
            met: s.exercise.met,
            weightKg: weightKg,
            seconds: s.seconds,
          ),
    );
    return sum(warmUp) + sum(steps) * rounds + sum(coolDown);
  }
}
