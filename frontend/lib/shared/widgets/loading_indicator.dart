import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Loading Indicator Widget
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;
  final bool showMessage;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 48,
    this.color = AppColors.accentBlue,
    this.showMessage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full Screen Loading Overlay
class FullScreenLoadingOverlay extends StatelessWidget {
  final String? message;
  final Color backgroundColor;
  final double opacity;

  const FullScreenLoadingOverlay({
    Key? key,
    this.message,
    this.backgroundColor = Colors.black,
    this.opacity = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor.withOpacity(opacity),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: AppTextStyles.body,
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

/// Linear Progress Indicator
class LinearProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color backgroundColor;
  final Color progressColor;
  final double height;
  final bool showPercentage;

  const LinearProgressBar({
    Key? key,
    required this.progress,
    this.backgroundColor = AppColors.surfaceLight,
    this.progressColor = AppColors.accentBlue,
    this.height = 6,
    this.showPercentage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.captionMedium,
          ),
        ],
      ],
    );
  }
}

/// Shimmer Loading Skeleton
class ShimmerSkeleton extends StatefulWidget {
  final double width;
  final double? height;
  final double borderRadius;

  const ShimmerSkeleton({
    Key? key,
    required this.width,
    this.height,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, 0.5, 1],
              colors: [
                AppColors.surfaceLight,
                AppColors.background,
                AppColors.surfaceLight,
              ],
              transform: GradientRotation(_animationController.value * 2 * 3.1416),
            ),
          ),
        );
      },
    );
  }
}

/// Loading Skeleton List (multiple items)
class ShimmerSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ShimmerSkeletonList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return Row(
          children: [
            ShimmerSkeleton(
              width: itemHeight,
              height: itemHeight,
              borderRadius: 12,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(
                    width: double.infinity,
                    height: 12,
                  ),
                  const SizedBox(height: 8),
                  ShimmerSkeleton(
                    width: double.infinity * 0.7,
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Pulse Animation Loading
class PulseLoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;

  const PulseLoadingIndicator({
    Key? key,
    this.message,
    this.size = 60,
  }) : super(key: key);

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBlue.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue
                          .withOpacity(0.1 - (_animation.value / 300)),
                      spreadRadius: _animation.value,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: widget.size * 0.6,
                    height: widget.size * 0.6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
