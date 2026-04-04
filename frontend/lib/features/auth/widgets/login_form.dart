import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../controllers/auth_controller.dart';

/// Login Form Widget
class LoginFormWidget extends StatefulWidget {
  final AuthController? controller;
  final VoidCallback? onLoginSuccess;

  const LoginFormWidget({
    Key? key,
    this.controller,
    this.onLoginSuccess,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _memberIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _memberIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_memberIdController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await widget.controller?.login(
      _memberIdController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (widget.controller?.state.currentStep.name == 'deviceVerify') {
      widget.onLoginSuccess?.call();
    } else {
      setState(() {
        _errorMessage = widget.controller?.state.error ?? 'Login failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Member ID Field
        CustomTextField(
          label: AppStrings.emailLabel,
          hint: AppStrings.emailHint,
          controller: _memberIdController,
          keyboardType: TextInputType.text,
          prefixIcon: const Icon(Icons.badge_outlined),
          isRequired: true,
        ),
        const SizedBox(height: 20),

        // Password Field
        CustomTextField(
          label: AppStrings.passwordLabel,
          hint: AppStrings.passwordHint,
          controller: _passwordController,
          obscureText: true,
          prefixIcon: const Icon(Icons.lock_outlined),
          isRequired: true,
        ),
        const SizedBox(height: 8),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              AppStrings.forgotPassword,
              style: TextStyle(
                color: AppColors.accentBlue,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Error Message
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        const SizedBox(height: 24),

        // Login Button
        CustomButton(
          label: AppStrings.loginButton,
          onPressed: _handleLogin,
          isLoading: _isLoading,
          isEnabled: !_isLoading,
        ),
      ],
    );
  }
}
