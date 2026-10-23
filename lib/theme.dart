import 'package:flutter/material.dart';

/// Palet "resep gerak": matras latihan + jamu kunyit, versi terang & gelap.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.latar,
    required this.permukaan,
    required this.tinta,
    required this.tintaPudar,
    required this.garis,
    required this.matras,
    required this.onMatras,
    required this.matrasTeks,
    required this.kunyit,
    required this.onKunyit,
    required this.air,
    required this.onAir,
  });

  /// Latar app.
  final Color latar;

  /// Kotak & bidang di atas latar.
  final Color permukaan;

  /// Teks utama.
  final Color tinta;

  /// Teks sekunder (kontras ±5:1 di atas latar).
  final Color tintaPudar;

  /// Garis tipis & batang grafik kosong.
  final Color garis;

  /// Bidang hijau: blok hari ini, tombol utama, fase pemanasan.
  final Color matras;
  final Color onMatras;

  /// Hijau untuk teks, ikon, dan batang grafik di atas latar.
  final Color matrasTeks;

  /// Fase gerakan & penanda hari ini.
  final Color kunyit;
  final Color onKunyit;

  /// Fase istirahat.
  final Color air;
  final Color onAir;

  static const light = AppPalette(
    latar: Color(0xFFEEF1EC),
    permukaan: Color(0xFFFFFFFF),
    tinta: Color(0xFF1B2A24),
    tintaPudar: Color(0xFF56645D),
    garis: Color(0xFFD3DAD2),
    matras: Color(0xFF2F6B4F),
    onMatras: Color(0xFFFFFFFF),
    matrasTeks: Color(0xFF2F6B4F),
    kunyit: Color(0xFFE3A92B),
    onKunyit: Color(0xFF1B2A24),
    air: Color(0xFF4A90A4),
    onAir: Color(0xFF1B2A24),
  );

  /// Gelap: hijau hutan, bukan hitam; warna fase diredam agar tidak silau.
  static const dark = AppPalette(
    latar: Color(0xFF17231D),
    permukaan: Color(0xFF213129),
    tinta: Color(0xFFE6ECE5),
    tintaPudar: Color(0xFFA3B1A9),
    garis: Color(0xFF34463D),
    matras: Color(0xFF2F6B4F),
    onMatras: Color(0xFFF2F5F1),
    matrasTeks: Color(0xFF7CC29E),
    kunyit: Color(0xFFCF9A2E),
    onKunyit: Color(0xFF17231D),
    air: Color(0xFF3B7A8C),
    onAir: Color(0xFFF2F5F1),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      latar: c(latar, other.latar),
      permukaan: c(permukaan, other.permukaan),
      tinta: c(tinta, other.tinta),
      tintaPudar: c(tintaPudar, other.tintaPudar),
      garis: c(garis, other.garis),
      matras: c(matras, other.matras),
      onMatras: c(onMatras, other.onMatras),
      matrasTeks: c(matrasTeks, other.matrasTeks),
      kunyit: c(kunyit, other.kunyit),
      onKunyit: c(onKunyit, other.onKunyit),
      air: c(air, other.air),
      onAir: c(onAir, other.onAir),
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

const _sans = 'PlusJakartaSans';
const _numeral = 'BarlowCondensed';
const _error = Color(0xFFB3261E);

/// Angka besar yang harus terbaca dari lantai: hitung mundur, ×10, kkal.
/// Tanpa [color], warnanya mengikuti teks di sekitarnya.
TextStyle numeralStyle(double size, {Color? color}) => TextStyle(
  fontFamily: _numeral,
  fontWeight: FontWeight.w700,
  fontSize: size,
  height: 1,
  color: color,
  fontFeatures: const [FontFeature.tabularFigures()],
);

ThemeData buildAppTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: p.matras,
    onPrimary: p.onMatras,
    secondary: p.kunyit,
    onSecondary: p.onKunyit,
    tertiary: p.air,
    onTertiary: p.onAir,
    error: _error,
    onError: Colors.white,
    surface: p.latar,
    onSurface: p.tinta,
    onSurfaceVariant: p.tintaPudar,
    surfaceContainerLowest: p.permukaan,
    surfaceContainerLow: p.permukaan,
    surfaceContainer: p.permukaan,
    surfaceContainerHigh: p.permukaan,
    surfaceContainerHighest: p.garis,
    outline: p.garis,
    outlineVariant: p.garis,
  );

  // Skala tipografi klasik (12, 14, 16, 18, 21, 24, 28).
  final textTheme = TextTheme(
    headlineMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.5,
    ),
    titleLarge: const TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w800,
      height: 1.2,
      letterSpacing: -0.2,
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleSmall: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: const TextStyle(fontSize: 14, height: 1.45),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, color: p.tintaPudar),
    labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    labelMedium: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    labelSmall: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: _sans,
    textTheme: textTheme,
  );

  TextStyle label(double size, FontWeight weight, Color color) => TextStyle(
    fontFamily: _sans,
    fontSize: size,
    fontWeight: weight,
    color: color,
  );

  return base.copyWith(
    extensions: [p],
    scaffoldBackgroundColor: p.latar,
    textTheme: base.textTheme.apply(bodyColor: p.tinta, displayColor: p.tinta),
    appBarTheme: AppBarTheme(
      backgroundColor: p.latar,
      foregroundColor: p.tinta,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: label(21, FontWeight.w800, p.tinta),
    ),
    dividerTheme: DividerThemeData(color: p.garis, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: p.matras,
        foregroundColor: p.onMatras,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: _sans,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: p.tinta,
        side: BorderSide(color: p.tinta, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: _sans,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.matrasTeks,
        textStyle: const TextStyle(
          fontFamily: _sans,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.permukaan,
      selectedColor: p.matras,
      side: BorderSide(color: p.garis),
      labelStyle: label(13, FontWeight.w600, p.tinta),
      secondaryLabelStyle: label(13, FontWeight.w600, p.onMatras),
      checkmarkColor: p.onMatras,
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: p.permukaan,
        foregroundColor: p.tinta,
        selectedBackgroundColor: p.tinta,
        selectedForegroundColor: p.latar,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: p.garis),
        textStyle: const TextStyle(
          fontFamily: _sans,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.permukaan,
      indicatorColor: p.matrasTeks.withValues(alpha: 0.16),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return label(
          12,
          selected ? FontWeight.w800 : FontWeight.w600,
          selected ? p.matrasTeks : p.tintaPudar,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color:
              states.contains(WidgetState.selected)
                  ? p.matrasTeks
                  : p.tintaPudar,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.permukaan,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.garis),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.garis),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.matrasTeks, width: 2),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? p.matrasTeks : p.tintaPudar,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.permukaan,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.latar,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.matrasTeks,
      linearTrackColor: p.garis,
    ),
  );
}
