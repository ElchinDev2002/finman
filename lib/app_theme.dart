import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors copied 1:1 from src/app/globals.css (:root — dark theme).
/// If you ever add a light theme, the `html.light` block in globals.css
/// has the matching light values.
class AppColors {
  static const bg = Color.fromRGBO(11, 14, 20, 1);
  static const surface = Color.fromRGBO(18, 22, 32, 1);
  static const surface2 = Color.fromRGBO(23, 28, 41, 1);
  static const border = Color.fromRGBO(35, 42, 59, 1);
  static const fg = Color.fromRGBO(255, 255, 255, 1);
  static const muted = Color.fromRGBO(138, 147, 166, 1);
  static const accent = Color.fromRGBO(63, 224, 165, 1); // mint green
  static const accent2 = Color.fromRGBO(91, 140, 255, 1); // blue
  static const brand = Color.fromRGBO(139, 92, 246, 1); // purple
  static const brand2 = Color.fromRGBO(167, 139, 250, 1);
  static const danger = Color.fromRGBO(255, 107, 107, 1);
  static const warn = Color.fromRGBO(255, 159, 67, 1);
  static const ink = Color(0xFF0B0E14); // text on top of the accent button
}

class AppRadius {
  static const card = 20.0; // .card / rounded-2xl
  static const field = 14.0; // .input-field / .btn-primary / rounded-xl
}

ThemeData buildAppTheme() {
  final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: AppColors.fg,
    displayColor: AppColors.fg,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: textTheme,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.accent,
      secondary: AppColors.accent2,
      error: AppColors.danger,
      onPrimary: AppColors.ink,
      onSurface: AppColors.fg,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface2,
      hintStyle: const TextStyle(color: AppColors.muted),
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.ink,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.field)),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
    dividerColor: AppColors.border,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.muted,
      type: BottomNavigationBarType.fixed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.fg,
      elevation: 0,
      centerTitle: false,
    ),
  );
}
