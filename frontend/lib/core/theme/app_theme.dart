import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

/// SENTRIX Theme Configuration
/// Minimal, clean, professional design system
class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentPurple,
        tertiary: AppColors.accentOrange,
        background: AppColors.background,
        surface: AppColors.card,
        error: AppColors.error,
      ),

      // ========== Scaffold Theme ==========
      scaffoldBackgroundColor: AppColors.background,

      // ========== AppBar Theme ==========
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium,
        toolbarHeight: 64,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 24,
        ),
      ),

      // ========== Text Theme ==========
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display,
        displayMedium: AppTextStyles.headline,
        headlineSmall: AppTextStyles.title,
        titleLarge: AppTextStyles.titleMedium,
        titleMedium: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySecondary,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelSmall: AppTextStyles.caption,
      ),

      // ========== Button Theme ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          textStyle: AppTextStyles.button,
          disabledBackgroundColor: AppColors.disabledBackground,
          disabledForegroundColor: AppColors.disabled,
        ),
      ),

      // ========== Text Button Theme ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentBlue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // ========== Outlined Button Theme ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentBlue,
          side: const BorderSide(color: AppColors.border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ========== Input Decoration Theme ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        hintStyle: AppTextStyles.bodySecondary,
        labelStyle: AppTextStyles.bodySmall,
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
          height: 1.5,
        ),
        helperStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          height: 1.5,
        ),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
      ),

      // ========== Card Theme ==========
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ========== Dialog Theme ==========
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: AppTextStyles.titleMedium,
        contentTextStyle: AppTextStyles.body,
      ),

      // ========== Bottom Sheet Theme ==========
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        elevation: 8,
      ),

      // ========== Tab Bar Theme ==========
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.accentBlue,
        unselectedLabelColor: AppColors.muted,
        labelStyle: AppTextStyles.titleSmall,
        unselectedLabelStyle: AppTextStyles.titleSmall,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: AppColors.accentBlue,
      ),

      // ========== List Tile Theme ==========
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTextStyles.titleSmall,
        subtitleTextStyle: AppTextStyles.bodySecondary,
      ),

      // ========== Divider Theme ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 16,
      ),

      // ========== Drawer Theme ==========
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.card,
        scrimColor: Color(0x4D000000), // 30% black for scrim
      ),

      // ========== Icon Theme ==========
      iconTheme: const IconThemeData(
        color: AppColors.secondary,
        size: 24,
      ),

      // ========== Floating Action Button Theme ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        disabledElevation: 0,
        splashColor: AppColors.accentPurple.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ========== Chip Theme ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelStyle: AppTextStyles.bodySmall,
        selectedColor: AppColors.accentBlue,
        deleteIconColor: AppColors.secondary,
      ),

      // ========== Navigation Bar Theme ==========
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.accentBlue.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.all(AppTextStyles.captionMedium),
        elevation: 8,
      ),

      // ========== Snackbar Theme ==========
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ========== Progress Indicator Theme ==========
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentBlue,
        linearMinHeight: 4,
        circularTrackColor: AppColors.surfaceLight,
      ),
    );
  }

  static ThemeData get dark {
    const darkBg = Color(0xFF0B1220);
    const darkCard = Color(0xFF111B2E);
    const darkBorder = Color(0xFF22314D);
    const darkText = Color(0xFFE2E8F0);
    const darkMuted = Color(0xFF8FA1BF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentBlue,
        secondary: AppColors.accentPurple,
        tertiary: AppColors.accentOrange,
        background: darkBg,
        surface: darkCard,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: darkText),
        toolbarHeight: 64,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.display.copyWith(color: darkText),
        displayMedium: AppTextStyles.headline.copyWith(color: darkText),
        headlineSmall: AppTextStyles.title.copyWith(color: darkText),
        titleLarge: AppTextStyles.titleMedium.copyWith(color: darkText),
        titleMedium: AppTextStyles.titleSmall.copyWith(color: darkText),
        bodyLarge: AppTextStyles.body.copyWith(color: darkText),
        bodyMedium: AppTextStyles.bodySecondary.copyWith(color: darkMuted),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: darkText),
        labelLarge: AppTextStyles.button,
        labelSmall: AppTextStyles.caption.copyWith(color: darkMuted),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkCard,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        hintStyle: AppTextStyles.bodySecondary.copyWith(color: darkMuted),
        labelStyle: AppTextStyles.bodySmall.copyWith(color: darkMuted),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTextStyles.titleSmall.copyWith(color: darkText),
        subtitleTextStyle: AppTextStyles.bodySecondary.copyWith(color: darkMuted),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: darkMuted,
      ),
    );
  }
}
