import 'package:flutter/material.dart';

/// SENTRIX Color System
/// Minimal, clean, professional palette
class AppColors {
  // ============ Background & Surfaces ============
  static const Color background = Color(0xFFF8FAFC); // Light slate
  static const Color card = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceLight = Color(0xFFF1F5F9); // Lighter slate

  // ============ Text Colors ============
  static const Color primary = Color(0xFF0F172A); // Primary text (almost black/navy)
  static const Color secondary = Color(0xFF64748B); // Secondary text (slate)
  static const Color muted = Color(0xFF94A3B8); // Muted text (light slate)

  // ============ Accent Gradient ============
  // Gradient: #FF7A18 → #AF4DFF → #3B82F6
  static const Color accentOrange = Color(0xFFFF7A18); // Orange start
  static const Color accentPurple = Color(0xFFAF4DFF); // Purple middle
  static const Color accentBlue = Color(0xFF3B82F6); // Blue end

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, accentPurple, accentBlue],
  );

  // ============ Semantic Colors ============
  static const Color success = Color(0xFF22C55E); // Green
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFFBBF24); // Amber
  static const Color info = Color(0xFF06B6D4); // Cyan

  // ============ Borders & Dividers ============
  static const Color border = Color(0xFFE2E8F0); // Light border
  static const Color divider = Color(0xFFCBD5E1); // Divider color

  // ============ Shadows (for soft shadows) ============
  static List<BoxShadow> softShadow = const [
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity black
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> softShadowSmall = const [
    BoxShadow(
      color: Color(0x08000000), // 3% opacity black
      offset: Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // ============ Disabled State ============
  static const Color disabled = Color(0xFFCBD5E1);
  static const Color disabledBackground = Color(0xFFF1F5F9);
}
