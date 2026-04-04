import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/text_styles.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_form.dart';

/// Login Screen - Main authentication screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _navigateToDeviceVerify() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.deviceVerify);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthController>(
        builder: (context, authController, _) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: SvgPicture.asset(
                        AppAssets.logoMain,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Center(
                    child: Text(
                      AppStrings.loginTitle,
                      style: AppTextStyles.headline,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Center(
                    child: Text(
                      AppStrings.loginSubtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Form
                  LoginFormWidget(
                    controller: authController,
                    onLoginSuccess: _navigateToDeviceVerify,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
