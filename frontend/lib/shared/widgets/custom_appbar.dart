import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Custom AppBar Widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final double elevation;
  final Widget? leadingWidget;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double? toolbarHeight;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.elevation = 0,
    this.leadingWidget,
    this.titleWidget,
    this.bottom,
    this.centerTitle = false,
    this.toolbarHeight = 64,
  }) : super(key: key);

  /// Factory constructor for standard app bar with subtitle
  factory CustomAppBar.standard({
    Key? key,
    required String title,
    String? subtitle,
    BuildContext? context,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    bool showBackButton = true,
    Color? backgroundColor,
    double elevation = 0,
    double? toolbarHeight,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      onBackPressed: onBackPressed ?? (context != null ? () => Navigator.of(context).pop() : null),
      actions: actions,
      showBackButton: showBackButton,
      backgroundColor: backgroundColor,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
    );
  }

  /// Factory constructor for simple app bar without back button
  factory CustomAppBar.simple({
    Key? key,
    required String title,
    BuildContext? context,
    List<Widget>? actions,
    Color? backgroundColor,
    double elevation = 0,
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      actions: actions,
      showBackButton: false,
      backgroundColor: backgroundColor,
      elevation: elevation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? Text(title, style: AppTextStyles.titleMedium),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? (leadingWidget ??
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              ))
          : leadingWidget,
      actions: actions,
      bottom: bottom,
      toolbarHeight: toolbarHeight,
      iconTheme: Theme.of(context).appBarTheme.iconTheme,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight ?? kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

/// Simple AppBar without back button
class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;

  const SimpleAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.titleMedium),
      backgroundColor: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// Gradient AppBar (for special screens)
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final LinearGradient gradient;
  final double elevation;
  final double? toolbarHeight;

  const GradientAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.showBackButton = true,
    this.gradient = AppColors.accentGradient,
    this.elevation = 2,
    this.toolbarHeight = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: toolbarHeight,
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      size: 20, color: Colors.white),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                ),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
