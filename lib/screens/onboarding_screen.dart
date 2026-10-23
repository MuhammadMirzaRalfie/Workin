import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/profile_form.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Olahraga di rumah, tanpa alat.',
                style: textTheme.headlineMedium?.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 10),
              Text(
                'Program latihan dari riset dan pedoman olahraga. Isi data '
                'singkat ini supaya takaran dan perkiraan kalorinya pas '
                'untukmu.',
                style: textTheme.bodyLarge?.copyWith(
                  color: context.palette.tintaPudar,
                ),
              ),
              const SizedBox(height: 32),
              const ProfileForm(submitLabel: 'Mulai'),
            ],
          ),
        ),
      ),
    );
  }
}
