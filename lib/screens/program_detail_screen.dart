import 'package:flutter/material.dart';

import '../data/workout_library.dart';
import '../models/custom_workout.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/exercise_figure.dart';
import '../widgets/level_bars.dart';
import '../widgets/metric.dart';
import 'custom_workout_screen.dart';
import 'workout_player_screen.dart';

class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({super.key, required this.program});

  final WorkoutProgram program;

  Future<void> _confirmDelete(BuildContext context, CustomWorkout w) async {
    final delete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hapus ${w.name}?'),
            content: const Text(
              'Riwayat latihan yang sudah tercatat tetap ada.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
    if (delete != true || !context.mounted) return;
    Navigator.of(context).pop();
    await AppScope.read(context).deleteCustomWorkout(w.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final weight = state.weightKg ?? 60;
    final textTheme = Theme.of(context).textTheme;

    // Latihan buatan diambil ulang dari state supaya hasil edit langsung
    // terlihat.
    final custom =
        this.program.isCustom
            ? state.customWorkoutById(
              this.program.id.substring(CustomWorkout.programPrefix.length),
            )
            : null;
    final program = custom == null ? this.program : programFromCustom(custom);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (custom != null) ...[
            IconButton(
              tooltip: 'Ubah latihan',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => openCustomWorkoutEditor(context, custom),
            ),
            IconButton(
              tooltip: 'Hapus latihan',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, custom),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(
            program.isCustom
                ? 'Latihan buatanmu'
                : '${program.focus.label}, level ${program.level.label.toLowerCase()}',
            style: textTheme.titleSmall?.copyWith(
              color: context.palette.matrasTeks,
            ),
          ),
          const SizedBox(height: 4),
          Text(program.name, style: textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            program.description,
            style: textTheme.bodyMedium?.copyWith(
              color: context.palette.tintaPudar,
            ),
          ),
          const SizedBox(height: 24),
          _Prescription(program: program, weightKg: weight),
          if (program.warmUp.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text('Pemanasan', style: textTheme.titleLarge),
            for (final step in program.warmUp) _StepRow(step: step),
          ],
          const SizedBox(height: 28),
          Text(
            program.rounds > 1
                ? 'Gerakan inti, ${program.rounds} putaran'
                : 'Gerakan inti',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            program.restSeconds > 0
                ? 'Istirahat ${program.restSeconds} detik di antara gerakan'
                : 'Tanpa jeda, langsung lanjut ke gerakan berikutnya',
            style: textTheme.bodySmall,
          ),
          for (var i = 0; i < program.steps.length; i++)
            _StepRow(step: program.steps[i], number: i + 1),
          if (program.coolDown.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text('Pendinginan', style: textTheme.titleLarge),
            for (final step in program.coolDown) _StepRow(step: step),
          ],
          const SizedBox(height: 32),
          _SourceSection(
            source: program.source,
            title:
                program.isCustom ? 'Panduan menyusun latihan' : 'Dasar ilmiah',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton.icon(
            onPressed: () => startWorkout(context, program),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Mulai latihan'),
          ),
        ),
      ),
    );
  }
}

/// Takaran program, ditampilkan seperti resep.
class _Prescription extends StatelessWidget {
  const _Prescription({required this.program, required this.weightKg});

  final WorkoutProgram program;
  final double weightKg;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final perRound = program.steps.where((s) => s.kind == StepKind.main).length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.palette.permukaan,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: '${program.rounds} × $perRound',
              style: numeralStyle(48),
              children: [
                TextSpan(
                  text: '  putaran × gerakan',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Metric(
                  value: '${program.totalMinutes}',
                  label: 'menit',
                  size: 28,
                ),
              ),
              Expanded(
                child: Metric(
                  value: formatNumber(program.estimateCalories(weightKg)),
                  label: 'kkal perkiraan',
                  size: 28,
                ),
              ),
              if (!program.isCustom)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LevelBars(level: program.level, height: 24),
                      const SizedBox(height: 6),
                      Text(program.level.label, style: textTheme.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, this.number});

  final WorkoutStep step;

  /// Urutan gerakan inti; null untuk pemanasan/pendinginan.
  final int? number;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              number?.toString() ?? '',
              style: numeralStyle(20, color: context.palette.tintaPudar),
            ),
          ),
          if (ExerciseFigure.hasPose(step.exercise.id))
            Container(
              width: 64,
              height: 52,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.palette.permukaan,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExerciseFigure(
                exerciseId: step.exercise.id,
                animate: false,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.exercise.name, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  step.kind == StepKind.recovery
                      ? 'Pemulihan aktif. ${step.exercise.cue}'
                      : step.exercise.cue,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(step.target, style: numeralStyle(24)),
        ],
      ),
    );
  }
}

class _SourceSection extends StatelessWidget {
  const _SourceSection({required this.source, required this.title});

  final WorkoutSource source;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 0, 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: context.palette.matrasTeks, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(source.summary, style: textTheme.bodyMedium),
          const SizedBox(height: 14),
          Text('Cara pakai', style: textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(source.schedule, style: textTheme.bodyMedium),
          const SizedBox(height: 14),
          Text('Rujukan', style: textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(
            source.citation,
            style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 14),
          Text(
            'Kalori adalah perkiraan dari 2024 Compendium of Physical '
            'Activities. Konsultasikan dengan dokter jika punya kondisi '
            'jantung, sendi, atau baru pulih dari cedera.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
