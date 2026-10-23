import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/level_advice_card.dart';
import '../widgets/level_bars.dart';
import '../widgets/metric.dart';
import '../widgets/weekly_bar_chart.dart';
import 'plan_screen.dart';
import 'program_detail_screen.dart';
import 'workout_player_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAllPrograms});

  final VoidCallback onSeeAllPrograms;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final today = state.today;
    final week = state.thisWeek;
    final advice = state.levelAdvice;

    // Program 4 minggu aktif: tampilkan sesi berikutnya. Jika target minggu
    // ini sudah tuntas (atau program selesai), kembali ke rotasi harian.
    final plan = state.planStatus;
    final planNext = plan?.nextProgram;
    final WorkoutProgram program;
    final String label;
    if (planNext != null) {
      program = planNext;
      label =
          'Minggu ${plan!.currentWeek} dari 4, sesi '
          '${plan.nextIndex! + 1} dari ${plan.plan.sessionsPerWeek}';
    } else {
      program = state.todaysProgram;
      if (plan != null && !plan.isFinished) {
        label = 'Sesi minggu ini tuntas. Latihan tambahan';
      } else {
        label =
            state.workedOutToday
                ? 'Sudah latihan hari ini'
                : 'Latihan hari ini';
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(formatDayDate(state.now), style: textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            state.workedOutToday
                ? 'Mantap, sudah gerak hari ini'
                : 'Siap gerak?',
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          if (advice != null) ...[
            LevelAdviceCard(advice: advice),
            const SizedBox(height: 16),
          ],
          _TodayBlock(
            program: program,
            label: label,
            weightKg: state.weightKg ?? 60,
            alreadyDone: state.workedOutToday,
          ),
          Wrap(
            spacing: 16,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onSeeAllPrograms,
                child: const Text('Pilih latihan lain'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => openPlan(context),
                child: Text(
                  plan == null
                      ? 'Ikuti program 4 minggu'
                      : plan.isFinished
                      ? 'Program 4 minggu selesai'
                      : 'Jadwal 4 minggu',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Hari ini',
            calories: today.calories,
            detail: '${today.minutes} menit',
          ),
          const Divider(),
          _SummaryRow(
            label: 'Minggu ini',
            calories: week.calories,
            detail: '${week.sessions} sesi',
          ),
          const SizedBox(height: 28),
          Text(
            '${state.activeDaysThisWeek} dari ${state.weeklyTargetDays} hari target minggu ini',
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: 14),
          WeeklyBarChart(
            days: state.thisWeekDaily,
            todayIndex: state.now.weekday - 1,
            height: 72,
          ),
        ],
      ),
    );
  }
}

class _TodayBlock extends StatelessWidget {
  const _TodayBlock({
    required this.program,
    required this.label,
    required this.weightKg,
    required this.alreadyDone,
  });

  final WorkoutProgram program;
  final String label;
  final double weightKg;
  final bool alreadyDone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onBlock = context.palette.onMatras;
    final onBlockSoft = context.palette.onMatras.withValues(alpha: 0.75);

    return Material(
      color: context.palette.matras,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProgramDetailScreen(program: program),
              ),
            ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(color: onBlockSoft),
              ),
              const SizedBox(height: 4),
              Text(
                program.name,
                style: textTheme.titleLarge?.copyWith(
                  color: onBlock,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                program.description,
                style: textTheme.bodySmall?.copyWith(color: onBlockSoft),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Metric(
                      value: '${program.totalMinutes}',
                      label: 'menit',
                      color: onBlock,
                      labelColor: onBlockSoft,
                    ),
                  ),
                  Expanded(
                    child: Metric(
                      value: formatNumber(program.estimateCalories(weightKg)),
                      label: 'kkal perkiraan',
                      color: onBlock,
                      labelColor: onBlockSoft,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LevelBars(
                          level: program.level,
                          color: context.palette.kunyit,
                          emptyColor: onBlock.withValues(alpha: 0.25),
                          height: 26,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          program.level.label,
                          style: textTheme.bodySmall?.copyWith(
                            color: onBlockSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: context.palette.kunyit,
                  foregroundColor: context.palette.onKunyit,
                ),
                onPressed: () => startWorkout(context, program),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(alreadyDone ? 'Latihan lagi' : 'Mulai latihan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.calories,
    required this.detail,
  });

  final String label;
  final double calories;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.titleMedium),
                Text(detail, style: textTheme.bodySmall),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text: formatNumber(calories),
              style: numeralStyle(32),
              children: [
                TextSpan(
                  text: ' kkal',
                  style: numeralStyle(
                    16,
                    color: context.palette.tintaPudar,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
