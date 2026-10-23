const _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Inisial hari Senin–Minggu untuk label grafik.
const dayInitials = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

/// Contoh: "Kamis, 22 Okt".
String formatDayDate(DateTime d) =>
    '${_dayNames[d.weekday - 1]}, ${d.day} ${_monthNames[d.month - 1]}';

/// Contoh: "22 Okt, 07.30".
String formatDateTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_monthNames[d.month - 1]}, $hh.$mm';
}

/// Pemisah ribuan gaya Indonesia: 1240 -> "1.240".
String formatNumber(num value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Contoh: 95 -> "1:35".
String formatClock(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Nama hari singkat Senin–Minggu untuk pilihan hari.
const dayShortNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// Contoh: "22 Okt".
String formatShortDate(DateTime d) => '${d.day} ${_monthNames[d.month - 1]}';

/// Contoh: (7, 5) -> "07.05".
String formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';

/// Berat dengan koma desimal: 65.5 -> "65,5", 70.0 -> "70".
String formatKg(double kg) {
  final rounded = (kg * 10).round() / 10;
  return rounded % 1 == 0
      ? rounded.toStringAsFixed(0)
      : rounded.toStringAsFixed(1).replaceAll('.', ',');
}
