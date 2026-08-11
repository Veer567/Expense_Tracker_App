import 'package:flutter/material.dart';

/// Centralized Design System Color Tokens for Expense App
class AppColors {
  AppColors._();

  // Primary Brand Accents
  static const Color primaryIndigo = Color(0xFF6366F1);
  static const Color primaryIndigoDark = Color(0xFF818CF8);
  static const Color primaryViolet = Color(0xFF4F46E5);

  // Financial Status Colors
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color incomeGreenLight = Color(0xFFD1FAE5);
  static const Color incomeGreenDark = Color(0xFF34D399);

  static const Color expenseRed = Color(0xFFEF4444);
  static const Color expenseRedLight = Color(0xFFFEE2E2);
  static const Color expenseRedDark = Color(0xFFF87171);

  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningAmberLight = Color(0xFFFEF3C7);

  // Light Theme Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Theme Surfaces
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Category Badge Colors (Soft pastel background + vibrant icon tint)
  static const Map<String, Color> categoryColors = {
    'Food & Dining': Color(0xFFF97316),
    'Transportation': Color(0xFF3B82F6),
    'Shopping': Color(0xFFA855F7),
    'Bills & Utilities': Color(0xFFEC4899),
    'Entertainment': Color(0xFF06B6D4),
    'Health & Fitness': Color(0xFF14B8A6),
    'Salary & Income': Color(0xFF10B981),
    'Investment': Color(0xFF8B5CF6),
    'Education': Color(0xFF6366F1),
    'Travel': Color(0xFFF43F5E),
    'Other': Color(0xFF64748B),
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? const Color(0xFF64748B);
  }
}
