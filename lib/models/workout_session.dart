/// Penilaian pengguna setelah latihan, dasar saran naik/turun level.
enum Effort {
  ringan('Terlalu ringan'),
  pas('Pas'),
  berat('Terlalu berat');

  const Effort(this.label);

  final String label;
}

/// Satu sesi latihan yang sudah selesai (atau diakhiri lebih awal).
class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.programId,
    required this.programName,
    required this.startedAt,
    required this.durationSeconds,
    required this.calories,
    required this.exercisesDone,
    this.effort,
  });

  final String id;
  final String programId;
  final String programName;
  final DateTime startedAt;
  final int durationSeconds;
  final double calories;
  final int exercisesDone;

  /// null jika belum dinilai.
  final Effort? effort;

  WorkoutSession withEffort(Effort? effort) => WorkoutSession(
    id: id,
    programId: programId,
    programName: programName,
    startedAt: startedAt,
    durationSeconds: durationSeconds,
    calories: calories,
    exercisesDone: exercisesDone,
    effort: effort,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'programId': programId,
    'programName': programName,
    'startedAt': startedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'calories': calories,
    'exercisesDone': exercisesDone,
    if (effort != null) 'effort': effort!.name,
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
    id: json['id'] as String,
    programId: json['programId'] as String,
    programName: json['programName'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String),
    durationSeconds: json['durationSeconds'] as int,
    calories: (json['calories'] as num).toDouble(),
    exercisesDone: json['exercisesDone'] as int? ?? 0,
    effort: Effort.values.asNameMap()[json['effort']],
  );
}
