import '../data/workout_library.dart';
import '../models/exercise.dart';
import '../models/workout_session.dart';

/// Saran mengganti level berdasarkan penilaian setelah latihan.
class LevelAdvice {
  const LevelAdvice(this.to, {required this.up});

  final Level to;
  final bool up;
}

/// Berapa sesi berturut-turut yang dibutuhkan sebelum memberi saran.
const easySessionsToLevelUp = 3;
const hardSessionsToLevelDown = 2;

/// Model progresi ACSM: naik jika latihan sudah terasa ringan.
///
/// Hanya menghitung sesi pustaka di level pengguna yang dinilai setelah
/// [since] (perubahan level / saran terakhir ditutup). [sessions] terbaru
/// di depan.
LevelAdvice? adviseLevel({
  required List<WorkoutSession> sessions,
  required Level level,
  DateTime? since,
}) {
  final rated = [
    for (final s in sessions)
      if (s.effort != null &&
          (since == null || s.startedAt.isAfter(since)) &&
          programById(s.programId)?.level == level)
        s.effort!,
  ];

  bool lastAre(Effort effort, int count) =>
      rated.length >= count && rated.take(count).every((e) => e == effort);

  if (level != Level.lanjutan &&
      lastAre(Effort.ringan, easySessionsToLevelUp)) {
    return LevelAdvice(Level.values[level.index + 1], up: true);
  }
  if (level != Level.pemula && lastAre(Effort.berat, hardSessionsToLevelDown)) {
    return LevelAdvice(Level.values[level.index - 1], up: false);
  }
  return null;
}
