import 'package:flutter/material.dart';

import '../models/workout_session.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/level_advice_card.dart';
import '../widgets/metric.dart';
import '../widgets/segment_label.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({
    super.key,
    required this.session,
    required this.totalExercises,
  });

  final WorkoutSession session;
  final int totalExercises;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final complete = session.exercisesDone >= totalExercises;
    // Ambil versi terbaru dari state supaya penilaian langsung terlihat.
    final effort =
        state.sessions.where((s) => s.id == session.id).firstOrNull?.effort;
    final advice = effort == null ? null : state.levelAdvice;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 48, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.programName,
                        style: textTheme.titleSmall?.copyWith(
                          color: context.palette.matrasTeks,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        complete ? 'Latihan selesai' : 'Latihan tercatat',
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        complete
                            ? 'Semua gerakan sudah kamu kerjakan.'
                            : 'Sebagian gerakan dilewati, tapi yang sudah '
                                'dikerjakan tetap masuk catatan.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: context.palette.tintaPudar,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Metric(
                        value: formatNumber(session.calories),
                        unit: 'kkal',
                        label: 'perkiraan kalori terbakar',
                        size: 96,
                      ),
                      const SizedBox(height: 28),
                      const Divider(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Metric(
                              value: formatClock(session.durationSeconds),
                              label: 'durasi (menit:detik)',
                            ),
                          ),
                          Expanded(
                            child: Metric(
                              value: '${session.exercisesDone}/$totalExercises',
                              label: 'gerakan selesai',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Text('Bagaimana rasanya?', style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Penilaianmu dipakai untuk menyarankan kapan naik '
                        'atau turun level.',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<Effort>(
                          showSelectedIcon: false,
                          emptySelectionAllowed: true,
                          segments: [
                            for (final e in Effort.values)
                              ButtonSegment(
                                value: e,
                                label: SegmentLabel(e.label),
                              ),
                          ],
                          selected: {if (effort != null) effort},
                          onSelectionChanged:
                              (s) => state.rateSession(
                                session.id,
                                s.isEmpty ? null : s.first,
                              ),
                        ),
                      ),
                      if (advice != null) ...[
                        const SizedBox(height: 20),
                        LevelAdviceCard(advice: advice),
                      ],
                    ],
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali ke beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
