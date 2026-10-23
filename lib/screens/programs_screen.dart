import 'package:flutter/material.dart';

import '../data/workout_library.dart';
import '../models/exercise.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/level_bars.dart';
import '../widgets/segment_label.dart';
import 'custom_workout_screen.dart';
import 'plan_screen.dart';
import 'program_detail_screen.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  /// null = semua.
  BodyFocus? _focus;
  Level? _level;
  bool _levelInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Awalnya tampilkan level pengguna; setelah itu ikuti pilihan filter.
    if (!_levelInitialized) {
      _level = AppScope.of(context).level;
      _levelInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final weight = state.weightKg ?? 60;
    final textTheme = Theme.of(context).textTheme;
    final custom = state.customWorkouts;
    final programs =
        workoutPrograms
            .where((p) => _focus == null || p.focus == _focus)
            .where((p) => _level == null || p.level == _level)
            .toList();
    final groups = [
      for (final focus in BodyFocus.values)
        (focus, programs.where((p) => p.focus == focus).toList()),
    ].where((g) => g.$2.isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: const Text('Latihan')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _PlanCard(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 12, 0),
            child: Row(
              children: [
                Expanded(child: Text('Latihanku', style: textTheme.titleLarge)),
                TextButton.icon(
                  onPressed: () => openCustomWorkoutEditor(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Buat latihan'),
                ),
              ],
            ),
          ),
          if (custom.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Susun latihan sendiri dari gerakan di pustaka: atur '
                'repetisi, putaran, dan istirahatnya.',
                style: textTheme.bodySmall,
              ),
            ),
          for (var i = 0; i < custom.length; i++) ...[
            if (i > 0) const Divider(indent: 20, endIndent: 20),
            _ProgramRow(
              program: programFromCustom(custom[i]),
              weightKg: weight,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Text('Pustaka', style: textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _FilterChip(
                  label: 'Semua',
                  selected: _focus == null,
                  onTap: () => setState(() => _focus = null),
                ),
                for (final focus in BodyFocus.values)
                  _FilterChip(
                    label: focus.label,
                    selected: _focus == focus,
                    onTap: () => setState(() => _focus = focus),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: SegmentedButton<Level?>(
              showSelectedIcon: false,
              segments: [
                const ButtonSegment(value: null, label: SegmentLabel('Semua')),
                for (final level in Level.values)
                  ButtonSegment(value: level, label: SegmentLabel(level.label)),
              ],
              selected: {_level},
              onSelectionChanged: (s) => setState(() => _level = s.first),
            ),
          ),
          if (programs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Belum ada program untuk pilihan ini. Coba level lain.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.palette.tintaPudar,
                ),
              ),
            ),
          for (final (focus, list) in groups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text(
                focus.label,
                style: textTheme.titleMedium?.copyWith(
                  color: context.palette.matrasTeks,
                ),
              ),
            ),
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) const Divider(indent: 20, endIndent: 20),
              _ProgramRow(program: list[i], weightKg: weight),
            ],
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ProgramRow extends StatelessWidget {
  const _ProgramRow({required this.program, required this.weightKg});

  final WorkoutProgram program;
  final double weightKg;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProgramDetailScreen(program: program),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(program.name, style: textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(program.description, style: textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 14,
                        color: context.palette.matrasTeks,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          program.source.origin,
                          style: textTheme.labelSmall?.copyWith(
                            color: context.palette.matrasTeks,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text.rich(
                  TextSpan(
                    text: '${program.totalMinutes}',
                    style: numeralStyle(28),
                    children: [
                      TextSpan(
                        text: ' mnt',
                        style: numeralStyle(
                          14,
                          color: context.palette.tintaPudar,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Text(
                  '±${formatNumber(program.estimateCalories(weightKg))} kkal',
                  style: textTheme.bodySmall,
                ),
                if (!program.isCustom) ...[
                  const SizedBox(height: 6),
                  LevelBars(level: program.level, showLabel: true),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pintu masuk program 4 minggu, dengan status singkat jika sedang berjalan.
class _PlanCard extends StatelessWidget {
  const _PlanCard();

  @override
  Widget build(BuildContext context) {
    final status = AppScope.of(context).planStatus;
    final textTheme = Theme.of(context).textTheme;
    final p = context.palette;
    final String subtitle;
    if (status == null) {
      subtitle = 'Jadwal per minggu dengan takaran yang naik bertahap';
    } else if (status.isFinished) {
      subtitle = 'Selesai, ${status.doneCount} dari ${status.totalCount} sesi';
    } else {
      subtitle =
          'Minggu ${status.currentWeek} dari 4, '
          '${status.doneCount} dari ${status.totalCount} sesi';
    }

    return Material(
      color: p.matras,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openPlan(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Program 4 minggu',
                      style: textTheme.titleLarge?.copyWith(color: p.onMatras),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: p.onMatras.withValues(alpha: 0.75),
                      ),
                    ),
                    if (status != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: status.doneCount / status.totalCount,
                          minHeight: 4,
                          color: p.kunyit,
                          backgroundColor: p.onMatras.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: p.onMatras),
            ],
          ),
        ),
      ),
    );
  }
}
