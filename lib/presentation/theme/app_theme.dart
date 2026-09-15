import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Neutral Colors
  static const Color background = Color(0xFFFBFBFC); // Slightly cooler, cleaner white-gray
  static const Color surface = Colors.white;
  static const Color surfaceHover = Color(0xFFF3F4F6); // Hover state color
  static const Color textPrimary = Color(0xFF0F172A); // Deeper contrast for headings
  static const Color textSecondary = Color(0xFF64748B); // Professional Slate gray
  static const Color border = Color(0xFFE2E8F0); // Softer subtle border
  static const Color primary = Color(0xFF0F172A); // Main brand color (black/slate)

  // Status Colors (Refined)
  static const Color statusPassed = Color(0xFF10B981);
  static const Color statusNeedsReview = Color(0xFFF59E0B);
  static const Color statusFailed = Color(0xFFEF4444);
  static const Color statusNotReviewed = Color(0xFF94A3B8);

  // Spacing & Border Radius
  static const double borderRadius = 8.0; // 6-10px requirement

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: textSecondary,
        surface: surface,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        titleLarge: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
        ),
        titleMedium: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.inter(
          color: textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHover,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: textSecondary, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Helper method for JetBrains Mono font
  static TextStyle get codeTextStyle => GoogleFonts.jetBrainsMono(
        color: textPrimary,
        height: 1.2,
      );
}
