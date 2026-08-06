import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Stand-in for sections not fully wired up yet (mirrors ComingSoon.tsx
/// in the web app). Swap each of these out for a real screen that calls
/// the matching /api/* endpoint once you're ready.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title screen — hook this up to the matching /api endpoint',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
      ),
    );
  }
}
