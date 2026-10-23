import 'package:flutter/material.dart';

import '../services/progression.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Tawaran naik/turun level dari penilaian setelah latihan.
class LevelAdviceCard extends StatelessWidget {
  const LevelAdviceCard({super.key, required this.advice});

  final LevelAdvice advice;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = AppScope.read(context);
    final target = advice.to.label;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: context.palette.permukaan,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: context.palette.kunyit, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            advice.up ? 'Siap naik level?' : 'Turun level dulu?',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            advice.up
                ? '$easySessionsToLevelUp latihan terakhir terasa terlalu '
                    'ringan. Pedoman ACSM menyarankan menambah beban saat '
                    'latihan sudah mudah. Coba level $target.'
                : '$hardSessionsToLevelDown latihan terakhir terasa terlalu '
                    'berat. Level $target bisa membangun dasar dulu sebelum '
                    'naik lagi.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            children: [
              TextButton(
                onPressed: () => state.setLevel(advice.to),
                child: Text('Ganti ke $target'),
              ),
              TextButton(
                onPressed: state.dismissLevelAdvice,
                child: const Text('Nanti'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
