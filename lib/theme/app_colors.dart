import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF1E4FA3);
  static const primaryTint = Color(0xFFE8F0FB);
  static const accent = Color(0xFF0E9384); // staff badge only
  static const accentTint = Color(0xFFCCFBEF);

  // Critical
  static const critical = Color(0xFFD92D20);
  static const criticalTint = Color(0xFFFEE4E2);
  static const criticalText = Color(0xFFB42318);

  // Status badges
  static const pendingBg = Color(0xFFFEF0C7);
  static const pendingText = Color(0xFF93370D);
  static const progressBg = Color(0xFFE0F2FE);
  static const progressText = Color(0xFF026AA2);
  static const resolvedBg = Color(0xFFD1FADF);
  static const resolvedText = Color(0xFF05603A);
  static const neutralBg = Color(0xFFF1F5F9);
  static const neutralText = Color(0xFF475467);

  // Stat card backgrounds
  static const pendingCard = Color(0xFFFFFAEB);
  static const progressCard = Color(0xFFF0F9FF);
  static const resolvedCard = Color(0xFFECFDF3);

  // Neutrals
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const outline = Color(0xFF64748B); // inputs and chips (3:1 contrast)
  static const text = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);

  // Password strength
  static const strong = Color(0xFF12B76A);
}
