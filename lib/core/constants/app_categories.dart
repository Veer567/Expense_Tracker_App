import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppCategory {
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncome;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.color,
    this.isIncome = false,
  });
}

class AppCategories {
  AppCategories._();

  static const List<AppCategory> categories = [
    AppCategory(
      name: 'Food & Dining',
      icon: LucideIcons.utensils,
      color: Color(0xFFF97316),
    ),
    AppCategory(
      name: 'Transportation',
      icon: LucideIcons.car,
      color: Color(0xFF3B82F6),
    ),
    AppCategory(
      name: 'Shopping',
      icon: LucideIcons.shoppingBag,
      color: Color(0xFFA855F7),
    ),
    AppCategory(
      name: 'Bills & Utilities',
      icon: LucideIcons.receipt,
      color: Color(0xFFEC4899),
    ),
    AppCategory(
      name: 'Entertainment',
      icon: LucideIcons.gamepad2,
      color: Color(0xFF06B6D4),
    ),
    AppCategory(
      name: 'Health & Fitness',
      icon: LucideIcons.heartPulse,
      color: Color(0xFF14B8A6),
    ),
    AppCategory(
      name: 'Investment',
      icon: LucideIcons.trendingUp,
      color: Color(0xFF8B5CF6),
    ),
    AppCategory(
      name: 'Education',
      icon: LucideIcons.graduationCap,
      color: Color(0xFF6366F1),
    ),
    AppCategory(
      name: 'Travel',
      icon: LucideIcons.plane,
      color: Color(0xFFF43F5E),
    ),
    AppCategory(
      name: 'Salary & Income',
      icon: LucideIcons.wallet,
      color: Color(0xFF10B981),
      isIncome: true,
    ),
    AppCategory(
      name: 'Other',
      icon: LucideIcons.moreHorizontal,
      color: Color(0xFF64748B),
    ),
  ];

  static AppCategory getByName(String name) {
    return categories.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => const AppCategory(
        name: 'Other',
        icon: LucideIcons.moreHorizontal,
        color: Color(0xFF64748B),
      ),
    );
  }
}
