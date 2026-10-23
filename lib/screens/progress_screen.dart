import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/metric.dart';
import '../widgets/profile_form.dart';
import '../widgets/settings_sections.dart';
import '../widgets/weight_section.dart';
import '../widgets/weekly_bar_chart.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _openProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                24 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pengaturan',
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  const _ThemePicker(),
                  const SizedBox(height: 28),
                  const VoiceSetting(),
                  const SizedBox(height: 20),
                  const ReminderSetting(),
                  const SizedBox(height: 28),
                  ProfileForm(
                    submitLabel: 'Simpan',
                    onSaved: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final week = state.thisWeek;
    final lastWeek = state.lastWeek;
    final sessions = state.sessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progres'),
        actions: [
          TextButton.icon(
            onPressed: () => _openProfile(context),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Pengaturan'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text('Minggu ini', style: textTheme.titleLarge),
          const SizedBox(height: 6),
          _TargetMeter(
            activeDays: state.activeDaysThisWeek,
            target: state.weeklyTargetDays,
          ),
          const SizedBox(height: 20),
          WeeklyBarChart(
            days: state.thisWeekDaily,
            todayIndex: state.now.weekday - 1,
            height: 120,
            showValues: true,
          ),
          const SizedBox(height: 12),
          Text(
            _compareText(week.calories, lastWeek.calories),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Metric(
                  value: formatNumber(week.calories),
                  label: 'kkal',
                ),
              ),
              Expanded(child: Metric(value: '${week.minutes}', label: 'menit')),
              Expanded(child: Metric(value: '${week.sessions}', label: 'sesi')),
            ],
          ),
          const SizedBox(height: 36),
          const WeightSection(),
          const SizedBox(height: 36),
          Text('Riwayat', style: textTheme.titleLarge),
          if (sessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Belum ada latihan. Selesaikan satu sesi dan catatannya '
                'muncul di sini.',
                style: textTheme.bodyMedium?.copyWith(
                  color: context.palette.tintaPudar,
                ),
              ),
            )
          else ...[
            Text('Geser ke kiri untuk menghapus', style: textTheme.bodySmall),
            const SizedBox(height: 4),
            for (var i = 0; i < sessions.length; i++) ...[
              if (i > 0) const Divider(),
              _SessionRow(session: sessions[i]),
            ],
          ],
        ],
      ),
    );
  }

  String _compareText(double thisWeek, double lastWeek) {
    if (lastWeek == 0) {
      return thisWeek == 0
          ? 'Belum ada aktivitas minggu ini maupun minggu lalu.'
          : 'Minggu lalu belum ada latihan. Awal yang bagus.';
    }
    final diff = ((thisWeek - lastWeek) / lastWeek * 100).round();
    if (diff == 0) return 'Sama dengan minggu lalu.';
    return diff > 0
        ? '$diff% lebih banyak dari minggu lalu (${formatNumber(lastWeek)} kkal).'
        : 'Kurang ${formatNumber(lastWeek - thisWeek)} kkal lagi untuk menyamai minggu lalu.';
  }
}

/// Pilihan tema; langsung diterapkan tanpa menekan Simpan.
class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tampilan', style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Mode gelap lebih nyaman untuk latihan malam di ruangan redup.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('Ikuti sistem')),
            ButtonSegment(value: ThemeMode.light, label: Text('Terang')),
            ButtonSegment(value: ThemeMode.dark, label: Text('Gelap')),
          ],
          selected: {state.themeMode},
          onSelectionChanged: (s) => state.setThemeMode(s.first),
        ),
      ],
    );
  }
}

/// Satu kotak per hari target; terisi untuk hari yang sudah latihan.
class _TargetMeter extends StatelessWidget {
  const _TargetMeter({required this.activeDays, required this.target});

  final int activeDays;
  final int target;

  @override
  Widget build(BuildContext context) {
    final reached = activeDays >= target;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '$activeDays dari $target hari target',
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < target; i++)
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i < activeDays ? context.palette.matrasTeks : null,
                  border: Border.all(
                    color:
                        i < activeDays
                            ? context.palette.matrasTeks
                            : context.palette.garis,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                reached
                    ? 'Target $target hari tercapai'
                    : '$activeDays dari $target hari target',
                style: textTheme.titleSmall?.copyWith(
                  color:
                      reached
                          ? context.palette.matrasTeks
                          : context.palette.tintaPudar,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFB3261E),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss:
          (_) => showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Hapus sesi ini?'),
                  content: Text(
                    '${session.programName}, ${formatDateTime(session.startedAt)}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus sesi'),
                    ),
                  ],
                ),
          ),
      onDismissed: (_) => AppScope.read(context).deleteSession(session.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.programName, style: textTheme.titleMedium),
                  Text(
                    formatDateTime(session.startedAt),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    text: formatNumber(session.calories),
                    style: numeralStyle(24),
                    children: [
                      TextSpan(
                        text: ' kkal',
                        style: numeralStyle(
                          13,
                          color: context.palette.tintaPudar,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatClock(session.durationSeconds),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
