import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_status_card.dart';

/// Pending Approval Screen - Wait for admin approval
class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({Key? key}) : super(key: key);

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  Timer? _approvalTimer;


  @override
  void initState() {
    super.initState();

    // Poll approval status from backend while pending.
    _approvalTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) {
        return;
      }
      final authController = context.read<AuthController>();
      await authController.checkApproval();
      if (authController.isAuthenticated && mounted) {
        _approvalTimer?.cancel();
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _approvalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.pendingApprovalTitle,
        showBackButton: false,
      ),
      body: Consumer<AuthController>(
          builder: (context, authController, _) {
            // Check if approved
            if (authController.isAuthenticated) {
              // Navigate to home after a short delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                }
              });
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    const AuthStatusCard(
                      currentStep: 4,
                      totalSteps: 5,
                      stepTitle: AppStrings.pendingApprovalTitle,
                      stepDescription: AppStrings.pendingApprovalSubtitle,
                    ),
                    const SizedBox(height: 60),

                    // Loading animation with icon
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accentBlue,
                                width: 2,
                              ),
                              boxShadow: AppColors.softShadow,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.hourglass_empty_outlined,
                                size: 60,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Animated loading indicator
                          const PulseLoadingIndicator(
                            size: 60,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Message
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppStrings.pendingApprovalTitle,
                            style: AppTextStyles.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.pendingApprovalMessage,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What happens next?',
                                      style: AppTextStyles.titleSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'An administrator is reviewing your account. You will be notified via email once your access is approved.',
                                      style: AppTextStyles.bodySmall
                                          .copyWith(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Current user info (if any)
                    if (authController.currentUser != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Details',
                              style: AppTextStyles.titleSmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Name: ${authController.currentUser!.name}',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Email: ${authController.currentUser!.email}',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Role: ${authController.currentUser!.role.toString().split('.').last}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
    );
  }
}
