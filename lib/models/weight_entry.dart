/// Satu catatan berat badan (satu per hari).
class WeightEntry {
  const WeightEntry(this.date, this.kg);

  /// Tanggal tanpa jam.
  final DateTime date;
  final double kg;

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'kg': kg};

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
    DateTime.parse(json['date'] as String),
    (json['kg'] as num).toDouble(),
  );
}
