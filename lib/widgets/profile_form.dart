import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise.dart';
import '../state/app_state.dart';
import 'level_bars.dart';

/// Form berat badan + target hari latihan per minggu.
/// Dipakai di onboarding dan di pengaturan profil.
class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, required this.submitLabel, this.onSaved});

  final String submitLabel;
  final VoidCallback? onSaved;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weight;
  late int _targetDays;
  late Level _level;

  @override
  void initState() {
    super.initState();
    final state = AppScope.read(context);
    _level = state.level;
    final w = state.weightKg;
    _weight = TextEditingController(
      text: w == null ? '' : w.toStringAsFixed(w % 1 == 0 ? 0 : 1),
    );
    _targetDays = state.weeklyTargetDays;
  }

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final weight = double.parse(_weight.text.replaceAll(',', '.'));
    await AppScope.read(context).saveProfile(
      weightKg: weight,
      weeklyTargetDays: _targetDays,
      level: _level,
    );
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Berat badan', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Dipakai untuk memperkirakan kalori yang terbakar.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
              suffixText: 'kg',
              hintText: 'contoh: 65',
            ),
            validator: (value) {
              final v = double.tryParse((value ?? '').replaceAll(',', '.'));
              if (v == null) return 'Isi berat badan dulu';
              if (v < 25 || v > 300) return 'Masukkan angka 25–300 kg';
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text('Level kebugaran', style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Menentukan latihan harian yang disarankan.',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (final level in Level.values)
            RadioListTile<Level>(
              value: level,
              groupValue: _level,
              onChanged: (v) => setState(() => _level = v ?? _level),
              contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  Text(level.label),
                  const SizedBox(width: 8),
                  LevelBars(level: level),
                ],
              ),
              subtitle: Text(level.description),
            ),
          const SizedBox(height: 16),
          Text('Target latihan per minggu', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var d = 1; d <= 7; d++)
                ChoiceChip(
                  label: Text('$d hari'),
                  selected: _targetDays == d,
                  onSelected: (_) => setState(() => _targetDays = d),
                ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
        ],
      ),
    );
  }
}
