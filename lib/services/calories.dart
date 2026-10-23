/// Estimasi kalori terbakar: MET × berat (kg) × durasi (jam).
///
/// Ini perkiraan standar dari Compendium of Physical Activities,
/// bukan hasil pengukuran.
double caloriesBurned({
  required double met,
  required double weightKg,
  required int seconds,
}) {
  return met * weightKg * seconds / 3600;
}
