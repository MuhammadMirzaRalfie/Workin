import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../theme.dart';

/// Level sebagai bar sinyal: 1 bar = Pemula, 3 bar = Lanjutan.
class LevelBars extends StatelessWidget {
  const LevelBars({
    super.key,
    required this.level,
    this.color,
    this.emptyColor,
    this.height = 14,
    this.showLabel = false,
    this.labelColor,
  });

  final Level level;

  /// Bawaan: hijau matras untuk teks.
  final Color? color;

  /// Bawaan: warna garis.
  final Color? emptyColor;
  final double height;
  final bool showLabel;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final filled = level.index + 1;
    final color = this.color ?? context.palette.matrasTeks;
    final emptyColor = this.emptyColor ?? context.palette.garis;
    final bars = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < Level.values.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Container(
              width: height * 0.36,
              height: height * (0.45 + 0.275 * i),
              decoration: BoxDecoration(
                color: i < filled ? color : emptyColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      label: 'Level ${level.label}',
      child: ExcludeSemantics(
        child:
            showLabel
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    bars,
                    const SizedBox(width: 6),
                    Text(
                      level.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: labelColor ?? color,
                      ),
                    ),
                  ],
                )
                : bars,
      ),
    );
  }
}
