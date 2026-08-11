import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Typography scale using Google Fonts Plus Jakarta Sans
class AppTypography {
  AppTypography._();

  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = 1.3,
    double letterSpacing = -0.2,
    bool tabular = false,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
    );
  }

  // Currency & Large Hero Numbers
  static TextStyle heroAmount(Color color) => _baseStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: color,
        tabular: true,
        letterSpacing: -0.8,
      );

  static TextStyle titleAmount(Color color) => _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
        tabular: true,
        letterSpacing: -0.5,
      );

  static TextStyle cardAmount(Color color) => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        tabular: true,
      );

  // Screen Headings
  static TextStyle headingLarge(Color color) => _baseStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.6,
      );

  static TextStyle headingMedium(Color color) => _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.4,
      );

  static TextStyle headingSmall(Color color) => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Body & Subtitles
  static TextStyle bodyMedium(Color color) => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodySmall(Color color) => _baseStyle(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle caption(Color color) => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.1,
      );

  static TextStyle label(Color color) => _baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.5,
      );
}
