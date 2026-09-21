import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens and styling for Editorial Engineering / Swiss Technical design system.
class AppTheme {
  // Canvas & Surface Colors (Warm off-white & paper tones)
  static const Color background = Color(0xFFF3F1EC);
  static const Color surface = Color(0xFFFAF9F6);
  static const Color surfaceSubtle = Color(0xFFECEAE4);
  static const Color surfaceHover = Color(0xFFE8E5DE);
  static const Color border = Color(0xFFD8D5CD);
  static const Color borderLight = Color(0xFFECEAE4);
  static const Color borderDark = Color(0xFFBEBAB0);

  // Typography Colors (Charcoal ink)
  static const Color textPrimary = Color(0xFF191919);
  static const Color textSecondary = Color(0xFF686761);
  static const Color textMuted = Color(0xFF8E8C85);

  // Accent (Muted red / terracotta earth - used strictly for active indicators & primary actions)
  static const Color primary = Color(0xFFC94A3A);
  static const Color primaryHover = Color(0xFF9E3027);
  static const Color primarySoft = Color(0xFFF7EBE9);

  // Semantic Colors
  static const Color statusPassed = Color(0xFF47705A);
  static const Color statusNeedsReview = Color(0xFFA47732);
  static const Color statusFailed = Color(0xFFC94A3A);
  static const Color statusNotReviewed = Color(0xFF8E8C85);

  // Severity Colors
  static const Color severityLow = Color(0xFF686761);
  static const Color severityMedium = Color(0xFFA47732);
  static const Color severityHigh = Color(0xFFC94A3A);

  // Spacing Tokens
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Shape Tokens (Swiss Technical: 4px - 6px, no large bubble curves)
  static const double radiusButton = 4.0;
  static const double radiusInput = 4.0;
  static const double radiusCard = 4.0;
  static const double radiusDialog = 6.0;
  static const double radiusPill = 2.0;

  // Compatibility aliases
  static const double radiusSmall = 2.0;
  static const double radiusMedium = 4.0;
  static const double radiusLarge = 6.0;
  static const double borderRadius = 4.0;

  /// Typography Helper: IBM Plex Mono for IDs, numbers, codes, and technical metadata
  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  /// Typography Helper: IBM Plex Sans for general UI labels, titles, and body text
  static TextStyle sans({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.ibmPlexSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        surface: surface,
        error: statusFailed,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.ibmPlexSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.ibmPlexSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.ibmPlexSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.ibmPlexSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: const Size(0, 36),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: const Size(0, 36),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: textPrimary, width: 1.2),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
