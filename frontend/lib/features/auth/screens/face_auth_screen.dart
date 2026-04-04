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
import '../widgets/face_camera_view.dart';

/// Face Authentication Screen
class FaceAuthScreen extends StatefulWidget {
  const FaceAuthScreen({Key? key}) : super(key: key);

  @override
  State<FaceAuthScreen> createState() => _FaceAuthScreenState();
}

class _FaceAuthScreenState extends State<FaceAuthScreen> {
  String? _capturedFaceImage;

  void _handleScanFace(AuthController authController) async {
    authController.clearError();
    if (_capturedFaceImage == null || _capturedFaceImage!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capture a face image first.')),
      );
      return;
    }

    await authController.verifyFace();

    // Automatically navigate to pending approval on success
    if (authController.state.currentStep.name == 'pendingApproval') {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.pendingApproval);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.faceAuthTitle,
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
                      currentStep: 3,
                      totalSteps: 5,
                      stepTitle: AppStrings.faceAuthTitle,
                      stepDescription: AppStrings.faceAuthSubtitle,
                    ),
                    const SizedBox(height: 40),

                    // Camera view
                    FaceCameraView(
                      status: authController.state.faceStatus ?? 'idle',
                      onFaceCaptured: (base64Image) {
                        setState(() {
                          _capturedFaceImage = base64Image;
                        });
                        authController.setCapturedFaceImage(base64Image);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Face captured. Tap Scan Face to verify.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    if (_capturedFaceImage != null)
                      Text(
                        'Face capture ready',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (_capturedFaceImage != null) const SizedBox(height: 12),

                    // Instructions
                    if (authController.state.faceStatus == null ||
                        authController.state.faceStatus == 'idle')
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Face Recognition Steps',
                                        style: AppTextStyles.titleSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '1. Face should be clearly visible\n2. Good lighting is required\n3. Keep device steady\n4. Look directly at camera',
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
                      )
                    else if (authController.state.faceStatus == 'scanning')
                      Center(
                        child: Text(
                          AppStrings.scanningFace,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      )
                    else if (authController.state.faceStatus ==
                        'recognized')
                      Center(
                        child: Text(
                          AppStrings.faceRecognized,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (authController.state.faceStatus == 'failed')
                      Center(
                        child: Text(
                          'Face Recognition Failed - Try Again',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (authController.state.error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withOpacity(0.5)),
                        ),
                        child: Text(
                          authController.state.error!,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),

                    // Scan button
                    CustomButton(
                      label: authController.state.isLoading
                          ? AppStrings.scanningFace
                          : AppStrings.scanFaceButton,
                      onPressed: authController.state.faceStatus == 'recognized'
                          ? () {}
                          : () => _handleScanFace(authController),
                      isLoading: authController.state.isLoading,
                      isEnabled: !authController.state.isLoading &&
                          authController.state.faceStatus != 'recognized',
                    ),

                    // Retry button (if failed)
                    if (authController.state.faceStatus == 'failed') ...[
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Retry',
                        onPressed: () => _handleScanFace(authController),
                        useGradient: false,
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
