import 'exercise.dart';

/// Rencana latihan bertahap 4 minggu yang sedang dijalani.
class TrainingPlan {
  const TrainingPlan({
    required this.startedOn,
    required this.level,
    required this.sessionsPerWeek,
  });

  static const weeks = 4;

  /// Tanggal (tanpa jam) hari pertama minggu 1.
  final DateTime startedOn;
  final Level level;
  final int sessionsPerWeek;

  Map<String, dynamic> toJson() => {
    'startedOn': startedOn.toIso8601String(),
    'level': level.name,
    'sessionsPerWeek': sessionsPerWeek,
  };

  factory TrainingPlan.fromJson(Map<String, dynamic> json) => TrainingPlan(
    startedOn: DateTime.parse(json['startedOn'] as String),
    level: Level.values.byName(json['level'] as String),
    sessionsPerWeek: json['sessionsPerWeek'] as int,
  );
}
