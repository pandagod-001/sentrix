import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Admin Stat Card - Displays a statistic with icon and value
class AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlighted;
  final VoidCallback? onTap;

  const AdminStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlighted = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted
                ? color.withOpacity(0.5)
                : AppColors.border,
            width: highlighted ? 2 : 1,
          ),
          boxShadow: highlighted ? AppColors.softShadow : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and label
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodySmall
                        .copyWith(
                      color: AppColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Value
            Text(
              value,
              style:
                  AppTextStyles.headline
                      .copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large Admin Stat Card - For prominent display
class LargeAdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const LargeAdminStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Icon
            Icon(
              icon,
              color: foregroundColor,
              size: 32,
            ),

            const SizedBox(height: 12),

            // Label
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: foregroundColor
                    .withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 8),

            // Value
            Text(
              value,
              style: AppTextStyles.headline
                  .copyWith(
                color: foregroundColor,
              ),
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.caption
                    .copyWith(
                  color: foregroundColor
                      .withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mini Admin Stat Card - Compact version
class MiniAdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const MiniAdminStatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

/// Metric Progress Card - Shows progress/change
class MetricProgressCard extends StatelessWidget {
  final String label;
  final String currentValue;
  final String previousValue;
  final bool isIncrease;
  final double percentChange;
  final Color color;

  const MetricProgressCard({
    Key? key,
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.isIncrease,
    required this.percentChange,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            currentValue,
            style: AppTextStyles.headline.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isIncrease
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: isIncrease
                    ? Colors.green
                    : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${percentChange.toStringAsFixed(1)}%',
                style: AppTextStyles.caption.copyWith(
                  color: isIncrease
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'from ${previousValue}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// System Health Card - Shows system status
class SystemHealthCard extends StatelessWidget {
  final String title;
  final bool isHealthy;
  final String status;
  final String? lastChecked;

  const SystemHealthCard({
    Key? key,
    required this.title,
    required this.isHealthy,
    required this.status,
    this.lastChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isHealthy ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall
                    .copyWith(
                  color: AppColors.secondary,
                ),
              ),
              Icon(
                isHealthy ? Icons.check_circle : Icons.error_outline,
                color: statusColor,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: AppTextStyles.caption
                  .copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (lastChecked != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last checked: $lastChecked',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
