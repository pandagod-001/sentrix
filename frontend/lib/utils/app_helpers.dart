import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Application Helper utilities
class AppHelpers {
  /// Get responsive width
  static double getResponsiveWidth(BuildContext context, double maxWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > maxWidth ? maxWidth : screenWidth;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 375).clamp(0.8, 1.2);
    return baseSize * scale;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide > 600;
  }

  /// Check if device is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get screen padding for notch
  static EdgeInsets getScreenPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).viewPadding;
  }

  /// Close keyboard
  static void closeKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Show bottom sheet
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: builder,
    );
  }

  /// Debounce function calls
  static Future<void> debounce(
    Duration delay,
    Future<void> Function() callback, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    await Future.delayed(delay);
    await Future.any([
      callback(),
      Future.delayed(timeout),
    ]).catchError((e) => null);
  }

  /// Format phone number for display
  static String formatPhoneForDisplay(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length >= 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }

  /// Get initials from name
  static String getInitials(String name) {
    return name
        .split(' ')
        .take(2)
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join();
  }

  /// Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Get color by role
  static Color getColorByRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'personnel':
        return Colors.blue;
      case 'dependent':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get icon by file type
  static IconData getIconByFileType(String fileType) {
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType.contains('image')) return Icons.image;
    if (fileType.contains('video')) return Icons.video_library;
    if (fileType.contains('audio')) return Icons.audio_file;
    if (fileType.contains('word')) return Icons.description;
    return Icons.file_copy;
  }

  /// Generate random color
  static Color getRandomColor() {
    final colors = [
      AppColors.accentGradient.colors[0],
      AppColors.accentGradient.colors[1],
      AppColors.accentGradient.colors[2],
      Colors.blue,
      Colors.green,
      Colors.orange,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  /// Create a gradient background
  static LinearGradient createGradient({
    Color? startColor,
    Color? endColor,
    bool isVertical = true,
  }) {
    startColor ??= AppColors.accentGradient.colors[0];
    endColor ??= AppColors.accentGradient.colors[2];

    return LinearGradient(
      begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
      end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
      colors: [startColor, endColor],
    );
  }

  /// Calculate age from birthdate
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Check if date is in the past
  static bool isDateInThePast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isDateInTheFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Get days remaining until date
  static int getDaysUntilDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays;
  }

  /// Check if email is valid military email
  static bool isValidMilitaryEmail(String email) {
    return email.endsWith('.mil') || email.contains('@defense.mil');
  }

  /// Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.grey;
      case 'away':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Get status icon
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
        return Icons.check_circle;
      case 'inactive':
      case 'offline':
        return Icons.cancel;
      case 'pending':
      case 'away':
        return Icons.schedule;
      case 'suspended':
        return Icons.block;
      default:
        return Icons.help;
    }
  }
}
