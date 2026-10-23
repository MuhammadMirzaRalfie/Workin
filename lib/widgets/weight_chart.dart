import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/weight_entry.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Grafik garis berat badan. Satu seri, jadi tanpa legenda; titik terakhir
/// diberi label. Sentuh & geser untuk melihat nilai tiap catatan.
class WeightChart extends StatefulWidget {
  const WeightChart({super.key, required this.entries, this.height = 140});

  /// Terlama di depan, minimal 2.
  final List<WeightEntry> entries;
  final double height;

  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  int? _selected;

  void _select(Offset local, double width) {
    final n = widget.entries.length;
    final x = (local.dx - _ChartPainter.leftGutter).clamp(
      0.0,
      width - _ChartPainter.leftGutter,
    );
    final index = (x / (width - _ChartPainter.leftGutter) * (n - 1)).round();
    if (index != _selected) setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final first = entries.first;
    final last = entries.last;
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label:
          'Grafik berat badan, ${entries.length} catatan, dari '
          '${formatKg(first.kg)} kg pada ${formatShortDate(first.date)} '
          'ke ${formatKg(last.kg)} kg pada ${formatShortDate(last.date)}',
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder:
              (context, constraints) => GestureDetector(
                onPanDown:
                    (d) => _select(d.localPosition, constraints.maxWidth),
                onPanUpdate:
                    (d) => _select(d.localPosition, constraints.maxWidth),
                onPanEnd: (_) => setState(() => _selected = null),
                onPanCancel: () => setState(() => _selected = null),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, widget.height),
                  painter: _ChartPainter(
                    entries: entries,
                    selected: _selected,
                    line: p.matrasTeks,
                    grid: p.garis,
                    surface: p.latar,
                    ink: p.tinta,
                    inkMuted: p.tintaPudar,
                    labelStyle: textTheme.labelSmall!,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.entries,
    required this.selected,
    required this.line,
    required this.grid,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.labelStyle,
  });

  /// Ruang label sumbu-y di kiri.
  static const leftGutter = 36.0;
  static const _top = 22.0;
  static const _bottom = 18.0;

  final List<WeightEntry> entries;
  final int? selected;
  final Color line;
  final Color grid;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final TextStyle labelStyle;

  TextPainter _text(String s, Color color, {bool bold = false}) => TextPainter(
    text: TextSpan(
      text: s,
      style: labelStyle.copyWith(
        color: color,
        fontWeight: bold ? FontWeight.w800 : null,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final values = entries.map((e) => e.kg);
    var lo = values.reduce(math.min);
    var hi = values.reduce(math.max);
    // Rentang minimal 2 kg supaya perubahan kecil tidak terlihat dramatis.
    final pad = math.max(0.0, 2 - (hi - lo)) / 2 + 0.5;
    lo = (lo - pad).floorToDouble();
    hi = (hi + pad).ceilToDouble();

    final plot = Rect.fromLTRB(
      leftGutter,
      _top,
      size.width - 8,
      size.height - _bottom,
    );
    double xAt(int i) =>
        plot.left +
        plot.width * (entries.length == 1 ? 0 : i / (entries.length - 1));
    double yAt(double kg) => plot.bottom - (kg - lo) / (hi - lo) * plot.height;

    // Grid resesif: dua garis di batas atas & bawah, dengan label kg.
    final gridPaint =
        Paint()
          ..color = grid
          ..strokeWidth = 1;
    for (final v in [lo, hi]) {
      final y = yAt(v);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final t = _text(formatKg(v), inkMuted);
      t.paint(canvas, Offset(plot.left - t.width - 6, y - t.height / 2));
    }

    // Tanggal pertama & terakhir di bawah sumbu.
    final firstDate = _text(formatShortDate(entries.first.date), inkMuted);
    firstDate.paint(canvas, Offset(plot.left, plot.bottom + 4));
    final lastDate = _text(formatShortDate(entries.last.date), inkMuted);
    lastDate.paint(
      canvas,
      Offset(plot.right - lastDate.width, plot.bottom + 4),
    );

    // Garis 2px.
    final path = Path();
    for (var i = 0; i < entries.length; i++) {
      final o = Offset(xAt(i), yAt(entries[i].kg));
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    void marker(int i) {
      final o = Offset(xAt(i), yAt(entries[i].kg));
      canvas.drawCircle(o, 6, Paint()..color = surface);
      canvas.drawCircle(o, 4, Paint()..color = line);
    }

    void label(int i, String text) {
      final o = Offset(xAt(i), yAt(entries[i].kg));
      final t = _text(text, ink, bold: true);
      final dx = (o.dx - t.width / 2).clamp(plot.left, size.width - t.width);
      t.paint(canvas, Offset(dx, o.dy - t.height - 8));
    }

    final last = entries.length - 1;
    final focus = selected ?? last;
    if (selected != null) {
      final x = xAt(focus);
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        Paint()
          ..color = inkMuted
          ..strokeWidth = 1,
      );
    }
    marker(focus);
    final e = entries[focus];
    label(
      focus,
      selected == null
          ? '${formatKg(e.kg)} kg'
          : '${formatKg(e.kg)} kg, ${formatShortDate(e.date)}',
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.entries != entries ||
      old.selected != selected ||
      old.line != line ||
      old.surface != surface;
}
