import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Auth Status Card - Shows current authentication step
class AuthStatusCard extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final String? stepDescription;
  final List<String> steps;
  final bool isCompleted;

  const AuthStatusCard({
    Key? key,
    required this.currentStep,
    this.totalSteps = 5,
    required this.stepTitle,
    this.stepDescription,
    this.steps = const [
      'Verification',
      'Device',
      'Face Auth',
      'Approval',
      'Ready',
    ],
    this.isCompleted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          // Progress indicator
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: steps.length,
              separatorBuilder: (context, index) {
                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: index < currentStep
                        ? AppColors.accentBlue
                        : AppColors.border,
                  ),
                );
              },
              itemBuilder: (context, index) {
                final isActive = index < currentStep;
                final isCurrent = index == currentStep - 1;

                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.accentBlue
                        : (isCurrent ? AppColors.accentBlue : AppColors.surfaceLight),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.accentBlue
                          : (isActive ? AppColors.accentBlue : AppColors.border),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: isActive
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Step title and description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stepTitle,
                style: AppTextStyles.titleSmall,
              ),
              if (stepDescription != null) ...[
                const SizedBox(height: 4),
                Text(
                  stepDescription!,
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple Step Indicator
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            minHeight: 6,
            backgroundColor: AppColors.surfaceLight,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
          ),
        ),
        const SizedBox(height: 8),

        // Step counter
        Text(
          'Step $currentStep of $totalSteps',
          style: AppTextStyles.captionMedium,
        ),

        // Step labels
        if (stepLabels != null && stepLabels!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            stepLabels![currentStep - 1],
            style: AppTextStyles.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Circular Progress Badge
class ProgressBadge extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double size;

  const ProgressBadge({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.surfaceLight,
            child: CircleAvatar(
              radius: (size / 2) - 3,
              backgroundColor: AppColors.card,
            ),
          ),

          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: AppColors.surfaceLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
            ),
          ),

          // Step counter
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentStep.toString(),
                style: TextStyle(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'of $totalSteps',
                style: TextStyle(
                  fontSize: size * 0.15,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
