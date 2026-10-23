import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/exercise.dart';
import '../models/workout_session.dart';
import '../services/voice_coach.dart';
import '../services/workout_run.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/exercise_figure.dart';
import 'workout_summary_screen.dart';

void startWorkout(BuildContext context, WorkoutProgram program) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => WorkoutPlayerScreen(program: program),
    ),
  );
}

/// Warna penuh per fase, supaya fase terbaca dari sudut mata.
({Color background, Color foreground, String label}) _phaseLook(
  WorkoutPhase phase,
  int exerciseCount,
  AppPalette p,
) {
  return switch (phase.kind) {
    PhaseKind.ready => (
      background: p.latar,
      foreground: p.tinta,
      label: 'Bersiap',
    ),
    PhaseKind.rest => (
      background: p.air,
      foreground: p.onAir,
      label: 'Istirahat',
    ),
    PhaseKind.exercise => switch (phase.step!.kind) {
      StepKind.main => (
        background: p.kunyit,
        foreground: p.onKunyit,
        label: 'Gerakan ${phase.number} dari $exerciseCount',
      ),
      StepKind.warmUp => (
        background: p.matras,
        foreground: p.onMatras,
        label: 'Pemanasan',
      ),
      StepKind.recovery => (
        background: p.matras,
        foreground: p.onMatras,
        label: 'Pemulihan aktif',
      ),
      StepKind.coolDown => (
        background: p.matras,
        foreground: p.onMatras,
        label: 'Pendinginan',
      ),
    },
  };
}

class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({super.key, required this.program});

  final WorkoutProgram program;

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  /// Latihan di bawah durasi ini tidak disimpan saat diakhiri lebih awal.
  static const _minSavedSeconds = 60;

  late final WorkoutRun _run;
  late final Speaker _speaker;
  late final DateTime _startedAt;
  Timer? _timer;
  bool _paused = false;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final state = AppScope.read(context);
    _run = WorkoutRun(widget.program, weightKg: state.weightKg ?? 60);
    _speaker = state.speaker;
    _startedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
    _keepScreenOn(true);
    _say(startCue(_run));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _keepScreenOn(false);
    // Biarkan ucapan "Latihan selesai" tuntas saat pindah ke ringkasan.
    if (!_run.isFinished) _speaker.stop();
    super.dispose();
  }

  /// Ucapkan isyarat jika panduan suara menyala.
  void _say(String? text) {
    if (text != null && AppScope.read(context).voiceEnabled) {
      _speaker.speak(text);
    }
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) _speaker.stop();
  }

  /// Layar tetap menyala selama latihan berlangsung.
  Future<void> _keepScreenOn(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } catch (_) {
      // Tidak tersedia (mis. saat tes); latihan tetap bisa jalan.
    }
  }

  void _onTick() {
    if (_paused || _finishing) return;
    final before = _run.phaseIndex;
    setState(_run.tick);
    _say(voiceCue(_run, phaseChanged: _run.phaseIndex != before));
    if (_run.isFinished) {
      _finish();
    } else if (_run.phaseIndex != before) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.click);
    } else if (!_run.current.isReps && _run.remaining <= 3) {
      HapticFeedback.selectionClick();
    }
  }

  void _act(void Function() action) {
    final before = _run.phaseIndex;
    setState(action);
    if (_run.phaseIndex != before) {
      _say(voiceCue(_run, phaseChanged: true));
    }
    if (_run.isFinished) _finish();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    _timer?.cancel();

    final session = WorkoutSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      programId: widget.program.id,
      programName: widget.program.name,
      startedAt: _startedAt,
      durationSeconds: _run.elapsedSeconds,
      calories: _run.calories,
      exercisesDone: _run.exercisesDone,
    );
    await AppScope.read(context).addSession(session);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => WorkoutSummaryScreen(
              session: session,
              totalExercises: widget.program.exerciseCount,
            ),
      ),
    );
  }

  Future<void> _confirmStop() async {
    final wasPaused = _paused;
    setState(() => _paused = true);
    _speaker.stop();
    final canSave = _run.elapsedSeconds >= _minSavedSeconds;

    final stop = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Akhiri latihan?'),
            content: Text(
              canSave
                  ? 'Gerakan yang sudah kamu lakukan tetap dicatat.'
                  : 'Latihan di bawah 1 menit tidak dicatat.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Lanjutkan'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Akhiri'),
              ),
            ],
          ),
    );

    if (!mounted) return;
    if (stop != true) {
      setState(() => _paused = wasPaused);
      return;
    }
    if (canSave) {
      await _finish();
    } else {
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final voiceOn = AppScope.of(context).voiceEnabled;
    final phase = _run.isFinished ? _run.phases.last : _run.current;
    final step = phase.step;
    final upcoming = _run.upcomingStep;
    final look = _phaseLook(
      phase,
      widget.program.exerciseCount,
      context.palette,
    );
    final fg = look.foreground;
    final fgSoft = fg.withValues(alpha: 0.72);

    // Saat istirahat/bersiap, peragakan gerakan berikutnya.
    final figureStep = phase.kind == PhaseKind.exercise ? step : upcoming;
    final figureId =
        figureStep != null && ExerciseFigure.hasPose(figureStep.exercise.id)
            ? figureStep.exercise.id
            : null;

    final String bigNumber;
    if (phase.isReps) {
      bigNumber = '×${step!.reps}';
    } else {
      bigNumber = _run.isFinished ? '0' : '${_run.remaining}';
    }

    final String title;
    final String detail;
    switch (phase.kind) {
      case PhaseKind.exercise:
        title = step!.exercise.name;
        detail = step.exercise.cue;
      case PhaseKind.ready || PhaseKind.rest:
        title =
            upcoming == null
                ? 'Hampir selesai'
                : 'Berikutnya: ${upcoming.exercise.name}';
        detail = upcoming?.exercise.cue ?? '';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value:
            fg.computeLuminance() > 0.5
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
        child: AnimatedContainer(
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          color: look.background,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Akhiri latihan',
                          color: fg,
                          icon: const Icon(Icons.close),
                          onPressed: _confirmStop,
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _run.progress,
                              minHeight: 4,
                              color: fg,
                              backgroundColor: fg.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip:
                              voiceOn
                                  ? 'Matikan panduan suara'
                                  : 'Nyalakan panduan suara',
                          color: fg,
                          icon: Icon(
                            voiceOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                          ),
                          onPressed:
                              () => AppScope.read(
                                context,
                              ).setVoiceEnabled(!voiceOn),
                        ),
                        IconButton(
                          tooltip: _paused ? 'Lanjut' : 'Jeda',
                          color: fg,
                          icon: Icon(
                            _paused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                          onPressed: _togglePause,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Text(
                            formatClock(_run.elapsedSeconds),
                            style: numeralStyle(20, color: fgSoft),
                          ),
                          const Spacer(),
                          if (_paused)
                            Text(
                              'Dijeda',
                              style: textTheme.titleSmall?.copyWith(color: fg),
                            ),
                          const Spacer(),
                          Text(
                            '${formatNumber(_run.calories)} kkal',
                            style: numeralStyle(20, color: fgSoft),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                look.label,
                                style: textTheme.titleMedium?.copyWith(
                                  color: fg,
                                ),
                              ),
                              if (figureId != null) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: 260,
                                  height: 150,
                                  child: ExerciseFigure(
                                    exerciseId: figureId,
                                    color: fg,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  bigNumber,
                                  style: numeralStyle(
                                    figureId != null ? 128 : 168,
                                    color: fg,
                                  ),
                                ),
                              ),
                              if (phase.isReps)
                                Text(
                                  step!.perSide
                                      ? 'per sisi, ${formatClock(_run.spentInPhase)} berjalan'
                                      : '${formatClock(_run.spentInPhase)} berjalan',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: fgSoft,
                                  ),
                                )
                              else if (!_run.isFinished)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: SizedBox(
                                    width: 160,
                                    child: LinearProgressIndicator(
                                      value: _run.remaining / phase.seconds,
                                      minHeight: 3,
                                      color: fg,
                                      backgroundColor: fg.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  color: fg,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                detail,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: fgSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (phase.kind == PhaseKind.exercise && upcoming != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          'Berikutnya: ${upcoming.exercise.name}, ${upcoming.target}',
                          style: textTheme.bodySmall?.copyWith(color: fgSoft),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildControls(phase, fg, look.background),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(WorkoutPhase phase, Color fg, Color bg) {
    const height = Size.fromHeight(64);
    Widget secondary(String text, IconData icon, VoidCallback onPressed) =>
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: height,
              foregroundColor: fg,
              side: BorderSide(color: fg, width: 1.5),
            ),
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
          ),
        );
    Widget primary(String text, IconData icon, VoidCallback onPressed) =>
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: height,
              backgroundColor: fg,
              foregroundColor: bg,
            ),
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(text),
          ),
        );

    final buttons = switch (phase.kind) {
      PhaseKind.ready => [
        primary('Mulai', Icons.skip_next_rounded, () => _act(_run.skip)),
      ],
      PhaseKind.rest => [
        secondary(
          '+20 dtk',
          Icons.more_time_rounded,
          () => setState(() => _run.extendRest(20)),
        ),
        primary('Mulai', Icons.skip_next_rounded, () => _act(_run.skip)),
      ],
      PhaseKind.exercise when phase.isReps => [
        secondary('Lewati', Icons.skip_next_rounded, () => _act(_run.skip)),
        primary('Selesai', Icons.check_rounded, () => _act(_run.completeReps)),
      ],
      PhaseKind.exercise => [
        primary(
          _paused ? 'Lanjut' : 'Jeda',
          _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          _togglePause,
        ),
        secondary('Lewati', Icons.skip_next_rounded, () => _act(_run.skip)),
      ],
    };

    return Row(
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          buttons[i],
        ],
      ],
    );
  }
}
