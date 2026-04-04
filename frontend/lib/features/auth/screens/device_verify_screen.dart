import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_status_card.dart';

/// Device Verification Screen
class DeviceVerifyScreen extends StatefulWidget {
  const DeviceVerifyScreen({Key? key}) : super(key: key);

  @override
  State<DeviceVerifyScreen> createState() => _DeviceVerifyScreenState();
}

class _DeviceVerifyScreenState extends State<DeviceVerifyScreen> {
  void _handleVerifyDevice(AuthController authController) async {
    await authController.verifyDevice();

    // Navigate to face auth after verification
    if (authController.state.currentStep.name == 'faceAuth') {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.faceAuth);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.deviceVerifyTitle,
        showBackButton: false,
      ),
      body: Consumer<AuthController>(
          builder: (context, authController, _) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress indicator
                    const AuthStatusCard(
                      currentStep: 1,
                      totalSteps: 5,
                      stepTitle: AppStrings.deviceVerifyTitle,
                      stepDescription: AppStrings.deviceVerifySubtitle,
                    ),
                    const SizedBox(height: 40),

                    // Device icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
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
                            Icons.phone_android_outlined,
                            size: 60,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Device code display
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
                            'Device Code',
                            style: AppTextStyles.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              authController.state.deviceCode ??
                                  AppStrings.deviceCode,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentBlue,
                                letterSpacing: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This code verifies this device',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Verify description
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
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'This appears to be a new device. Please verify to continue.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Verify button
                    CustomButton(
                      label: authController.state.isLoading
                          ? AppStrings.verifyingDevice
                          : AppStrings.verifyButton,
                      onPressed: () => _handleVerifyDevice(authController),
                      isLoading: authController.state.isLoading,
                      isEnabled: !authController.state.isLoading,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
    );
  }
}
