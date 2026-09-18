import 'package:flutter/material.dart';

// Design tokens and styling according to SRS v1.0 Section 5
class AppTheme {
  // Brand / Action Color
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryHover = Color(0xFF1D4ED8);

  // Neutral Colors (Light mode default)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status Colors (Section 5.4)
  static const Color statusPassed = Color(0xFF16A34A); // Green
  static const Color statusNeedsReview = Color(0xFFD97706); // Amber
  static const Color statusFailed = Color(0xFFDC2626); // Red
  static const Color statusNotReviewed = Color(0xFF64748B); // Gray

  // Severity Colors
  static const Color severityLow = Color(0xFF0284C7);
  static const Color severityMedium = Color(0xFFD97706);
  static const Color severityHigh = Color(0xFFDC2626);

  // Spacing Tokens (Section 5.4)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Corner Radius (Section 5.4: 6-10px)
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 10.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        surface: surface,
        error: statusFailed,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
