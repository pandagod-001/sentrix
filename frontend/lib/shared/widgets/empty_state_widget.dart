import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import 'custom_button.dart';

/// Empty State Widget - Shows when no data is available
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final Color iconColor;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
    this.iconColor = AppColors.muted,
  }) : super(key: key);

  /// Factory constructor for no results state
  factory EmptyStateWidget.noResults(
    BuildContext? context, {
    Key? key,
    required String title,
    String? message,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      key: key,
      title: title,
      subtitle: message,
      icon: Icons.search_off,
      iconColor: AppColors.muted,
      actionLabel: onAction != null ? 'Try Again' : null,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              CustomButton(
                label: actionLabel!,
                onPressed: onAction!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// No Internet Empty State
class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Internet Connection',
      subtitle: 'Please check your connection and try again',
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.warning,
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}

/// Error Empty State
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    Key? key,
    this.title = 'Something went wrong',
    this.subtitle = 'An error occurred while loading data',
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: title,
      subtitle: subtitle,
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}

/// Access Denied Widget
class AccessDeniedWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onBack;

  const AccessDeniedWidget({
    Key? key,
    this.message,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Access Denied',
      subtitle: message ?? 'You don\'t have permission to access this feature',
      icon: Icons.lock_outline,
      iconColor: AppColors.error,
      actionLabel: onBack != null ? 'Go Back' : null,
      onAction: onBack,
    );
  }
}

/// No Results Found Widget
class NoResultsWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClear;

  const NoResultsWidget({
    Key? key,
    required this.searchQuery,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Results Found',
      subtitle: 'No results for "$searchQuery"',
      icon: Icons.search_off,
      actionLabel: onClear != null ? 'Clear Search' : null,
      onAction: onClear,
    );
  }
}

/// Empty List with Illustration
class EmptyListWidget extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? illustrationWidget;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyListWidget({
    Key? key,
    required this.title,
    this.description,
    this.illustrationWidget,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (illustrationWidget != null)
              SizedBox(
                height: 200,
                child: illustrationWidget,
              )
            else
              Icon(
                Icons.folder_open_outlined,
                size: 80,
                color: AppColors.muted,
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              CustomButton(
                label: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Upgrade Required Widget
class UpgradeRequiredWidget extends StatelessWidget {
  final VoidCallback? onUpgrade;

  const UpgradeRequiredWidget({
    Key? key,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Update Required',
      subtitle: 'Please update the app to continue using this feature',
      icon: Icons.system_update_outlined,
      iconColor: AppColors.warning,
      actionLabel: onUpgrade != null ? 'Update Now' : null,
      onAction: onUpgrade,
    );
  }
}

/// Custom Empty State Container (for reusable empty states)
class CustomEmptyState extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final double? maxWidth;

  const CustomEmptyState({
    Key? key,
    required this.child,
    this.title,
    this.subtitle,
    this.maxWidth = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? 300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              child,
              if (title != null) ...[
                const SizedBox(height: 24),
                Text(
                  title!,
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
