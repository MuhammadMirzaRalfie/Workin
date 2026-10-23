import 'package:flutter_tts/flutter_tts.dart';

import '../models/exercise.dart';
import 'workout_run.dart';

/// Pengucap teks. Dipisah dari TTS supaya tes tidak butuh mesin suara.
abstract class Speaker {
  Future<void> speak(String text);
  Future<void> stop();
}

/// Tidak bersuara; dipakai di tes dan saat suara dimatikan.
class SilentSpeaker implements Speaker {
  const SilentSpeaker();

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}

/// TTS bawaan HP dengan suara bahasa Indonesia.
class TtsSpeaker implements Speaker {
  final _tts = FlutterTts();
  Future<void>? _ready;

  Future<void> _init() async {
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1);
  }

  @override
  Future<void> speak(String text) async {
    try {
      _ready ??= _init();
      await _ready;
      await _tts.speak(text);
    } catch (_) {
      // Mesin TTS tidak tersedia; latihan tetap jalan tanpa suara.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

const _countdownWords = {3: 'tiga', 2: 'dua', 1: 'satu'};

/// "12 kali", "10 kali per sisi", "30 detik", "2 menit".
String spokenTarget(WorkoutStep step) {
  if (step.isReps) {
    return '${step.reps} kali${step.perSide ? ' per sisi' : ''}';
  }
  if (step.seconds % 60 == 0) return '${step.seconds ~/ 60} menit';
  return '${step.seconds} detik';
}

/// Kalimat pembuka saat layar latihan dibuka.
String startCue(WorkoutRun run) {
  final first =
      run.phases.firstWhere((p) => p.kind == PhaseKind.exercise).step!;
  return 'Bersiap. Gerakan pertama, ${first.exercise.name}.';
}

/// Apa yang diucapkan setelah satu detik berjalan atau setelah pengguna
/// menekan tombol. [phaseChanged] = fase baru saja berganti.
/// Mengembalikan null jika tidak ada yang perlu diucapkan.
String? voiceCue(WorkoutRun run, {required bool phaseChanged}) {
  if (run.isFinished) return 'Latihan selesai. Kerja bagus.';
  final phase = run.current;

  if (phaseChanged) {
    switch (phase.kind) {
      case PhaseKind.ready:
        return null;
      case PhaseKind.rest:
        final next = run.upcomingStep;
        return next == null
            ? 'Istirahat ${phase.seconds} detik.'
            : 'Istirahat ${phase.seconds} detik. Berikutnya, '
                '${next.exercise.name}.';
      case PhaseKind.exercise:
        final step = phase.step!;
        final name = step.exercise.name;
        return switch (step.kind) {
          StepKind.main => '$name, ${spokenTarget(step)}.',
          StepKind.warmUp => 'Pemanasan, $name.',
          StepKind.recovery => 'Pemulihan, $name.',
          StepKind.coolDown => 'Pendinginan, $name.',
        };
    }
  }

  if (phase.isReps) return null;
  if (phase.seconds >= 10 && _countdownWords.containsKey(run.remaining)) {
    return _countdownWords[run.remaining];
  }
  if (phase.kind == PhaseKind.exercise &&
      phase.isMain &&
      phase.seconds >= 20 &&
      run.spentInPhase == phase.seconds ~/ 2) {
    return 'Setengah jalan.';
  }
  return null;
}
