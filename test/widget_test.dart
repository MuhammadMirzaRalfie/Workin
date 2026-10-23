import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_workout/main.dart';
import 'package:home_workout/models/exercise.dart';
import 'package:home_workout/state/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ukuran layar HP (360×800 dp) supaya semua tombol terlihat.
void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Di layar latihan ada animasi yang berulang terus, jadi `pumpAndSettle`
/// tidak pernah selesai (dan jam latihan ikut berjalan). Pakai jeda pendek.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('onboarding lalu tampil beranda', (tester) async {
    usePhoneScreen(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs, clock: () => DateTime(2026, 10, 22, 9));

    await tester.pumpWidget(HomeWorkoutApp(state: state));
    expect(find.text('Mulai'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '65');
    await tester.ensureVisible(find.text('Mulai'));
    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(state.weightKg, 65);
    expect(state.level, Level.pemula);
    expect(state.todaysProgram.level, Level.pemula);
    expect(find.text('Siap gerak?'), findsOneWidget);
    expect(find.text('Latihan hari ini'), findsOneWidget);
    expect(find.text('Kamis, 22 Okt'), findsOneWidget);
  });

  testWidgets('berat badan wajib diisi', (tester) async {
    usePhoneScreen(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(HomeWorkoutApp(state: AppState(prefs)));
    await tester.ensureVisible(find.text('Mulai'));
    await tester.tap(find.text('Mulai'));
    await tester.pump();

    expect(find.text('Isi berat badan dulu'), findsOneWidget);
  });

  testWidgets('filter bagian tubuh & level, lalu latihan repetisi', (
    tester,
  ) async {
    usePhoneScreen(tester);
    SharedPreferences.setMockInitialValues({'weightKg': 70.0});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(HomeWorkoutApp(state: AppState(prefs)));
    await tester.tap(find.text('Latihan'));
    await tester.pumpAndSettle();

    // Default: level pengguna (Pemula).
    await tester.tap(find.widgetWithText(ChoiceChip, 'Dada'));
    await tester.pumpAndSettle();
    expect(find.text('Dada Pemula'), findsOneWidget);
    expect(find.text('Dada Menengah'), findsNothing);

    await tester.tap(find.text('Menengah').first);
    await tester.pumpAndSettle();
    expect(find.text('Dada Menengah'), findsOneWidget);

    await tester.ensureVisible(find.text('Dada Menengah'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dada Menengah'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Gerakan inti, 3 putaran'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Gerakan inti, 3 putaran'), findsOneWidget);
    expect(find.text('×10'), findsWidgets);

    await tester.tap(find.text('Mulai latihan'));
    await settle(tester);
    await tester.tap(find.text('Mulai')); // lewati hitung mundur
    await tester.pump();
    expect(find.text('Pemanasan'), findsOneWidget);
    await tester.tap(find.text('Lewati'));
    await tester.pump();
    expect(find.text('Gerakan 1 dari 12'), findsOneWidget);
    expect(find.text('×10'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await tester.pump();
    expect(find.text('Istirahat'), findsOneWidget);
    expect(find.text('+20 dtk'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
    await tester.tap(find.text('Akhiri'));
    await tester.pumpAndSettle();
  });

  testWidgets('latihan bisa dimulai dan diakhiri', (tester) async {
    usePhoneScreen(tester);
    SharedPreferences.setMockInitialValues({'weightKg': 70.0});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);

    await tester.pumpWidget(HomeWorkoutApp(state: state));
    await tester.ensureVisible(find.text('Mulai latihan'));
    await tester.tap(find.text('Mulai latihan'));
    await settle(tester);
    expect(find.text('Bersiap'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
    expect(find.text('Akhiri latihan?'), findsOneWidget);

    await tester.tap(find.text('Akhiri'));
    await tester.pumpAndSettle();
    expect(find.text('Akhiri latihan?'), findsNothing);
    expect(find.text('Mulai latihan'), findsOneWidget); // kembali ke beranda
    expect(state.sessions, isEmpty); // < 1 menit tidak disimpan
  });
}
