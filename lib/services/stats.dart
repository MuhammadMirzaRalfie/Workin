import '../models/workout_session.dart';

DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Minggu dimulai hari Senin.
DateTime startOfWeek(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));

class ActivityTotal {
  const ActivityTotal({
    required this.calories,
    required this.seconds,
    required this.sessions,
  });

  static const zero = ActivityTotal(calories: 0, seconds: 0, sessions: 0);

  final double calories;
  final int seconds;
  final int sessions;

  int get minutes => (seconds / 60).round();
}

/// Total aktivitas untuk sesi yang dimulai di rentang [from, to).
ActivityTotal totalBetween(
  Iterable<WorkoutSession> sessions,
  DateTime from,
  DateTime to,
) {
  var calories = 0.0;
  var seconds = 0;
  var count = 0;
  for (final s in sessions) {
    if (!s.startedAt.isBefore(from) && s.startedAt.isBefore(to)) {
      calories += s.calories;
      seconds += s.durationSeconds;
      count++;
    }
  }
  return ActivityTotal(calories: calories, seconds: seconds, sessions: count);
}

/// Tujuh total harian (Senin–Minggu) untuk minggu yang memuat [now].
List<ActivityTotal> dailyTotalsForWeek(
  Iterable<WorkoutSession> sessions,
  DateTime now,
) {
  final monday = startOfWeek(now);
  return List.generate(7, (i) {
    final day = DateTime(monday.year, monday.month, monday.day + i);
    final next = DateTime(day.year, day.month, day.day + 1);
    return totalBetween(sessions, day, next);
  });
}
