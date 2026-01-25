import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF050A14);
  static const Color surface = Color(0xFF111823);
  static const Color surfaceLight = Color(0xFF1E293B);
  static const Color primary = Color(0xFF00F0FF);
  static const Color secondary = Color(0xFF2D7FF9);
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF00E676);
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      error: error,
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textMain,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textMain,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textMain,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textSecondary,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: surfaceLight, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
  );
}
