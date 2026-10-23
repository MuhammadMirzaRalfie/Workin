import 'package:flutter/material.dart';

import '../services/reminders.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/format.dart';

/// Nyala/mati panduan suara saat latihan.
class VoiceSetting extends StatelessWidget {
  const VoiceSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Panduan suara'),
      subtitle: const Text(
        'Menyebut gerakan, hitung mundur, dan "setengah jalan" saat latihan',
      ),
      value: state.voiceEnabled,
      onChanged: state.setVoiceEnabled,
    );
  }
}

/// Pengingat latihan mingguan: nyala/mati, jam, dan hari.
class ReminderSetting extends StatefulWidget {
  const ReminderSetting({super.key});

  @override
  State<ReminderSetting> createState() => _ReminderSettingState();
}

class _ReminderSettingState extends State<ReminderSetting> {
  bool _denied = false;

  Future<void> _toggle(ReminderSettings current, bool enabled) async {
    final state = AppScope.read(context);
    if (enabled && !await state.reminders.requestPermission()) {
      setState(() => _denied = true);
      return;
    }
    setState(() => _denied = false);
    await state.setReminder(current.copyWith(enabled: enabled));
  }

  Future<void> _pickTime(ReminderSettings current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      helpText: 'Jam pengingat',
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
    );
    if (picked == null || !mounted) return;
    await AppScope.read(
      context,
    ).setReminder(current.copyWith(hour: picked.hour, minute: picked.minute));
  }

  void _toggleDay(ReminderSettings current, int day) {
    final days = {...current.weekdays};
    if (!days.remove(day)) days.add(day);
    if (days.isEmpty) return; // minimal satu hari
    AppScope.read(context).setReminder(current.copyWith(weekdays: days));
  }

  @override
  Widget build(BuildContext context) {
    final r = AppScope.of(context).reminder;
    final textTheme = Theme.of(context).textTheme;
    final days = [
      for (var d = 1; d <= 7; d++)
        if (r.weekdays.contains(d)) dayShortNames[d - 1],
    ].join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Pengingat latihan'),
          subtitle: Text(
            r.enabled
                ? '$days, pukul ${formatTime(r.hour, r.minute)}'
                : 'Notifikasi di hari dan jam pilihanmu',
          ),
          value: r.enabled,
          onChanged: (v) => _toggle(r, v),
        ),
        if (_denied)
          Text(
            'Izin notifikasi ditolak. Aktifkan di pengaturan aplikasi di HP, '
            'lalu coba lagi.',
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        if (r.enabled) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text('Jam', style: textTheme.bodyMedium)),
              TextButton(
                onPressed: () => _pickTime(r),
                child: Text(
                  formatTime(r.hour, r.minute),
                  style: numeralStyle(24, color: context.palette.matrasTeks),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  label: Text(dayShortNames[d - 1]),
                  showCheckmark: false,
                  selected: r.weekdays.contains(d),
                  onSelected: (_) => _toggleDay(r, d),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
