import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../models/training_plan.dart';
import '../services/plan_builder.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/level_bars.dart';
import 'program_detail_screen.dart';
import 'workout_player_screen.dart';

void openPlan(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const PlanScreen()));
}

/// Program bertahap 4 minggu: penjelasan, lalu jadwal & progresnya.
class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  Future<void> _confirmStop(BuildContext context) async {
    final stop = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hentikan program?'),
            content: const Text(
              'Jadwal 4 minggu dihapus. Riwayat latihanmu tetap tersimpan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hentikan'),
              ),
            ],
          ),
    );
    if (stop == true && context.mounted) {
      await AppScope.read(context).stopPlan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final status = state.planStatus;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program 4 minggu'),
        actions: [
          if (status != null)
            TextButton(
              onPressed: () => _confirmStop(context),
              child: const Text('Hentikan'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: status == null ? const _PlanIntro() : _PlanSchedule(status: status),
    );
  }
}

class _PlanIntro extends StatelessWidget {
  const _PlanIntro();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final perWeek = planSessionsFor(state.weeklyTargetDays);
    final split = splitFor(perWeek).map((f) => f.label).join(', ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Text('Latihan yang naik bertahap', style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Jadwal $perWeek sesi per minggu di level '
          '${state.level.label.toLowerCase()}, bergantian bagian tubuh: '
          '$split. Takarannya naik tiap minggu supaya otot terus mendapat '
          'tantangan baru (overload progresif, model progresi ACSM).',
          style: textTheme.bodyMedium?.copyWith(
            color: context.palette.tintaPudar,
          ),
        ),
        const SizedBox(height: 24),
        for (var week = 1; week <= TrainingPlan.weeks; week++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 36,
                  child: Text('$week', style: numeralStyle(28)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Minggu $week', style: textTheme.titleMedium),
                      Text(weekChange(week), style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Jumlah sesi mengikuti target mingguanmu (minimal 2, maksimal 6 '
          'supaya tetap ada hari istirahat). Protokol riset seperti 5BX dan '
          'McMaster dijalankan sesuai takaran aslinya. Sesi yang terlewat '
          'tidak menggeser jadwal.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () => AppScope.read(context).startPlan(),
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Mulai program'),
        ),
      ],
    );
  }
}

class _PlanSchedule extends StatelessWidget {
  const _PlanSchedule({required this.status});

  final PlanStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final plan = status.plan;
    final nextLevel =
        plan.level == Level.lanjutan
            ? null
            : Level.values[plan.level.index + 1];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Row(
          children: [
            LevelBars(level: plan.level),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${plan.level.label}, ${plan.sessionsPerWeek} sesi per minggu',
                style: textTheme.titleSmall?.copyWith(
                  color: context.palette.matrasTeks,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          status.isFinished
              ? 'Program selesai'
              : 'Minggu ${status.currentWeek} dari ${TrainingPlan.weeks}',
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: '${status.doneCount}',
            style: numeralStyle(40),
            children: [
              TextSpan(
                text: ' / ${status.totalCount} sesi selesai',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: status.doneCount / status.totalCount,
            minHeight: 6,
          ),
        ),
        if (status.isFinished) ...[
          const SizedBox(height: 20),
          Text(
            nextLevel == null
                ? 'Kamu sudah di level tertinggi. Ulangi program untuk '
                    'mempertahankan kebugaran.'
                : 'Kalau minggu terakhir terasa ringan, lanjutkan di level '
                    '${nextLevel.label.toLowerCase()}.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (nextLevel != null) ...[
            FilledButton(
              onPressed: () async {
                final state = AppScope.read(context);
                await state.setLevel(nextLevel);
                await state.startPlan(level: nextLevel);
              },
              child: Text('Mulai lagi di level ${nextLevel.label}'),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton(
            onPressed:
                () => AppScope.read(context).startPlan(level: plan.level),
            child: const Text('Ulangi level ini'),
          ),
        ],
        for (final week in status.weeks) ...[
          const SizedBox(height: 28),
          Text('Minggu ${week.number}', style: textTheme.titleLarge),
          Text(
            '${formatShortDate(week.start)} sampai '
            '${formatShortDate(week.end.subtract(const Duration(days: 1)))}. '
            '${weekChange(week.number)}',
            style: textTheme.bodySmall,
          ),
          for (var i = 0; i < week.programs.length; i++)
            _PlanRow(
              program: week.programs[i],
              done: status.done[week.number - 1][i],
              isNext:
                  week.number == status.currentWeek && i == status.nextIndex,
              missed: week.number < status.currentWeek,
            ),
        ],
      ],
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.program,
    required this.done,
    required this.isNext,
    required this.missed,
  });

  final WorkoutProgram program;
  final bool done;
  final bool isNext;

  /// Minggunya sudah lewat.
  final bool missed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = context.palette;
    final faded = missed && !done;

    final Widget leading;
    if (done) {
      leading = Icon(Icons.check_circle, color: p.matrasTeks);
    } else if (isNext) {
      leading = Icon(Icons.radio_button_checked, color: p.kunyit);
    } else {
      leading = Icon(Icons.radio_button_unchecked, color: p.garis);
    }

    return InkWell(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProgramDetailScreen(program: program),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: textTheme.titleMedium?.copyWith(
                      color: faded ? p.tintaPudar : null,
                    ),
                  ),
                  Text(
                    faded
                        ? 'Terlewat'
                        : '${program.totalMinutes} menit, '
                            '${program.rounds} putaran',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isNext)
              IconButton.filled(
                tooltip: 'Mulai ${program.name}',
                style: IconButton.styleFrom(
                  backgroundColor: p.kunyit,
                  foregroundColor: p.onKunyit,
                ),
                onPressed: () => startWorkout(context, program),
                icon: const Icon(Icons.play_arrow_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
