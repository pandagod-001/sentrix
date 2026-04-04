import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// SENTRIX Typography System
/// Clean, minimal, professional text styles
class AppTextStyles {
  // ============ Display (48pt) ============
  static const TextStyle display = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2, // Tight line height
    color: AppColors.primary,
  );

  // ============ Headline (32pt) ============
  static const TextStyle headline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.25,
    height: 1.2,
    color: AppColors.primary,
  );

  // ============ Title (20pt) ============
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.5, // Normal line height
    color: AppColors.primary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.primary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.primary,
  );

  // ============ Body (16pt) ============
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.7, // Loose line height for readability
    color: AppColors.primary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.7,
    color: AppColors.secondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
    height: 1.5,
    color: AppColors.primary,
  );

  // ============ Caption (12pt) ============
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.5,
    color: AppColors.muted,
  );

  static const TextStyle captionMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.5,
    color: AppColors.muted,
  );

  // ============ Overline (11pt - all caps) ============
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.5,
    color: AppColors.muted,
  );

  // ============ Button Text (16pt) ============
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
    color: Colors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
    color: Colors.white,
  );
}
