import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../utils/format.dart';
import 'metric.dart';
import 'weight_chart.dart';

/// Berat terbaru, perubahannya, grafik, dan tombol mencatat.
class WeightSection extends StatelessWidget {
  const WeightSection({super.key});

  Future<void> _log(BuildContext context) async {
    final state = AppScope.read(context);
    final controller = TextEditingController(
      text: state.weightKg == null ? '' : formatKg(state.weightKg!),
    );
    final formKey = GlobalKey<FormState>();
    final kg = await showDialog<double>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Catat berat hari ini'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(suffixText: 'kg'),
                validator: (value) {
                  final v = double.tryParse((value ?? '').replaceAll(',', '.'));
                  if (v == null) return 'Isi berat badan dulu';
                  if (v < 25 || v > 300) return 'Masukkan angka 25–300 kg';
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(
                    context,
                    double.parse(controller.text.replaceAll(',', '.')),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
    );
    if (kg != null) await state.logWeight(kg);
  }

  @override
  Widget build(BuildContext context) {
    final log = AppScope.of(context).weightLog;
    final textTheme = Theme.of(context).textTheme;

    final String change;
    if (log.length > 1) {
      final diff = log.last.kg - log.first.kg;
      final sign = diff < 0 ? '−' : (diff > 0 ? '+' : '');
      change = '$sign${formatKg(diff.abs())}';
    } else {
      change = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Berat badan', style: textTheme.titleLarge)),
            TextButton.icon(
              onPressed: () => _log(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Catat berat'),
            ),
          ],
        ),
        if (log.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Metric(
                  value: formatKg(log.last.kg),
                  unit: 'kg',
                  label: 'terakhir, ${formatShortDate(log.last.date)}',
                ),
              ),
              if (log.length > 1)
                Expanded(
                  child: Metric(
                    value: change,
                    unit: 'kg',
                    label: 'sejak ${formatShortDate(log.first.date)}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (log.length > 1)
            WeightChart(entries: log)
          else
            Text(
              'Catat berat secara berkala, grafiknya muncul setelah ada 2 '
              'catatan. Berat terbaru dipakai untuk menghitung kalori.',
              style: textTheme.bodySmall,
            ),
        ],
      ],
    );
  }
}
