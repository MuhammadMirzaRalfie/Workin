import 'package:flutter/material.dart';

import '../theme.dart';

/// Angka besar + satuan, dengan keterangan di bawahnya.
class Metric extends StatelessWidget {
  const Metric({
    super.key,
    required this.value,
    required this.label,
    this.unit,
    this.size = 32,
    this.color,
    this.labelColor,
  });

  final String value;
  final String? unit;
  final String label;
  final double size;

  /// Bawaan: warna teks di sekitarnya.
  final Color? color;

  /// Bawaan: tinta pudar.
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelColor = this.labelColor ?? context.palette.tintaPudar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: value,
            style: numeralStyle(size, color: color),
            children: [
              if (unit != null)
                TextSpan(
                  text: ' $unit',
                  style: numeralStyle(
                    size * 0.5,
                    color: color,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: textTheme.bodySmall?.copyWith(color: labelColor)),
      ],
    );
  }
}
