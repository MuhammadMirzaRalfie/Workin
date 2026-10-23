import 'package:flutter/material.dart';

import '../services/stats.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Grafik batang Senin–Minggu berdasarkan kalori harian.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.days,
    required this.todayIndex,
    this.height = 90,
    this.showValues = false,
  });

  final List<ActivityTotal> days;
  final int todayIndex;
  final double height;
  final bool showValues;

  @override
  Widget build(BuildContext context) {
    final maxCalories = days.fold<double>(
      0,
      (m, d) => d.calories > m ? d.calories : m,
    );
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < days.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showValues)
                    SizedBox(
                      height: 18,
                      child:
                          days[i].calories > 0
                              ? Text(
                                formatNumber(days[i].calories),
                                style: numeralStyle(
                                  14,
                                  color: context.palette.tintaPudar,
                                ),
                              )
                              : null,
                    ),
                  SizedBox(
                    height: height,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor:
                            maxCalories == 0 || days[i].calories == 0
                                ? 0.05
                                : (days[i].calories / maxCalories).clamp(
                                  0.05,
                                  1.0,
                                ),
                        widthFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                days[i].calories == 0
                                    ? context.palette.garis
                                    : i == todayIndex
                                    ? context.palette.kunyit
                                    : context.palette.matrasTeks,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayInitials[i],
                    style: labelStyle?.copyWith(
                      color:
                          i == todayIndex
                              ? context.palette.tinta
                              : context.palette.tintaPudar,
                      fontWeight: i == todayIndex ? FontWeight.w800 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
