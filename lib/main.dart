import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/reminders.dart';
import 'services/voice_coach.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Layout dirancang untuk posisi tegak.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final reminders = LocalReminderScheduler();
  await reminders.init();
  final state = AppState(prefs, speaker: TtsSpeaker(), reminders: reminders);
  // Pasang ulang jadwal pengingat (mis. setelah zona waktu berubah).
  unawaited(reminders.apply(state.reminder));
  runApp(HomeWorkoutApp(state: state));
}

class HomeWorkoutApp extends StatelessWidget {
  const HomeWorkoutApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder:
            (context, _) => MaterialApp(
              title: 'Home Workout',
              debugShowCheckedModeBanner: false,
              theme: buildAppTheme(Brightness.light),
              darkTheme: buildAppTheme(Brightness.dark),
              themeMode: state.themeMode,
              // Ikon status bar mengikuti tema di layar tanpa AppBar.
              builder:
                  (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
                    value:
                        Theme.of(context).brightness == Brightness.dark
                            ? SystemUiOverlayStyle.light
                            : SystemUiOverlayStyle.dark,
                    child: child!,
                  ),
              home: const _Root(),
            ),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return state.hasProfile ? const HomeShell() : const OnboardingScreen();
  }
}
