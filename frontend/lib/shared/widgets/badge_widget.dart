import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Badge Widget - Shows status or count badges
class BadgeWidget extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double? maxWidth;
  final EdgeInsets padding;
  final double borderRadius;

  const BadgeWidget({
    Key? key,
    required this.label,
    this.backgroundColor = AppColors.info,
    this.textColor = Colors.white,
    this.maxWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Text(
        label,
        style: AppTextStyles.captionMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Status Badge - Shows online/offline status
class StatusBadge extends StatelessWidget {
  final bool isOnline;
  final String? label;
  final double size;

  const StatusBadge({
    Key? key,
    required this.isOnline,
    this.label,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green : AppColors.muted;
    final statusText = isOnline ? 'Online' : 'Offline';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                spreadRadius: 2,
                blurRadius: 4,
              ),
            ],
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 6),
          Text(
            label ?? statusText,
            style: AppTextStyles.captionMedium.copyWith(
              color: color,
            ),
          ),
        ],
      ],
    );
  }
}

/// Count Badge - Shows unread count or notification count
class CountBadge extends StatelessWidget {
  final int count;
  final Color backgroundColor;
  final Color textColor;
  final double size;

  const CountBadge({
    Key? key,
    required this.count,
    this.backgroundColor = AppColors.error,
    this.textColor = Colors.white,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Role Badge - Shows user role
class RoleBadge extends StatelessWidget {
  final String role;
  final double? maxWidth;

  const RoleBadge({
    Key? key,
    required this.role,
    this.maxWidth,
  }) : super(key: key);

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'personnel':
        return Colors.blue;
      case 'dependent':
        return Colors.orange;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BadgeWidget(
      label: role.substring(0, 1).toUpperCase() + role.substring(1),
      backgroundColor: _getRoleColor(role),
      textColor: Colors.white,
      maxWidth: maxWidth,
      borderRadius: 8,
    );
  }
}

/// Tag Widget - For labeled items
class TagWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;
  final Color backgroundColor;
  final Color textColor;

  const TagWidget({
    Key? key,
    required this.label,
    this.onRemove,
    this.backgroundColor = AppColors.surfaceLight,
    this.textColor = AppColors.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.captionMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
