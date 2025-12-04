import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF000000); // Pure Black
  static const Color surface = Color(0xFF121212); // Dark Grey
  static const Color surfaceHighlight = Color(0xFF272727); // Lighter Grey
  static const Color primary = Color(0xFFFFFFFF); // White (Monochrome accent)
  static const Color secondary = Color(0xFF888888); // Grey
  static const Color success = Color.fromARGB(255, 120, 255, 176); // Light Grey
  static const Color warning = Color(0xFFAAAAAA); // Medium Grey
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFF888888); // Grey

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        background: background,
        error: Color(0xFFCF6679),
      ),
      textTheme: GoogleFonts.spaceMonoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: surfaceHighlight.withValues(alpha: 0.5)),
        ),
      ),
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }
}
