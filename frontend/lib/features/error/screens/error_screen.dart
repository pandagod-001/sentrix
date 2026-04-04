import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

enum ErrorType { networkError, serverError, notFound, unauthorized, timeout }

class ErrorScreen extends StatelessWidget {
  final ErrorType errorType;
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ErrorScreen({
    Key? key,
    required this.errorType,
    this.customMessage,
    this.onRetry,
    this.onGoHome,
  }) : super(key: key);

  String get _title {
    switch (errorType) {
      case ErrorType.networkError:
        return 'No Connection';
      case ErrorType.serverError:
        return 'Server Error';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.unauthorized:
        return 'Unauthorized';
      case ErrorType.timeout:
        return 'Connection Timeout';
    }
  }

  String get _message {
    if (customMessage != null) return customMessage!;
    switch (errorType) {
      case ErrorType.networkError:
        return 'Please check your internet connection and try again.';
      case ErrorType.serverError:
        return 'Something went wrong on our end. Please try again later.';
      case ErrorType.notFound:
        return 'The resource you are looking for could not be found.';
      case ErrorType.unauthorized:
        return 'You do not have permission to access this resource.';
      case ErrorType.timeout:
        return 'The connection took too long. Please try again.';
    }
  }

  IconData get _icon {
    switch (errorType) {
      case ErrorType.networkError:
        return Icons.wifi_off_rounded;
      case ErrorType.serverError:
        return Icons.cloud_off_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      case ErrorType.unauthorized:
        return Icons.lock_outline_rounded;
      case ErrorType.timeout:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _icon,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),

              // Error Title
              Text(
                _title,
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Error Message
              Text(
                _message,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Error Details (for debugging)
              if (customMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'Error Details: $customMessage',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.red.withOpacity(0.7),
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),

              // Buttons
              if (onRetry != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomButton(
                    label: 'Try Again',
                    onPressed: onRetry!,
                  ),
                ),
              CustomButton(
                label: onGoHome != null ? 'Go Home' : 'Back',
                onPressed: onGoHome ?? () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper builder functions for different error types
class ErrorScreens {
  static Widget networkErrorScreen({
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen(
        errorType: ErrorType.networkError,
        onRetry: onRetry,
        onGoHome: onGoHome,
      );

  static Widget serverErrorScreen({
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen(
        errorType: ErrorType.serverError,
        onRetry: onRetry,
        onGoHome: onGoHome,
      );

  static Widget notFoundScreen({
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen(
        errorType: ErrorType.notFound,
        onGoHome: onGoHome,
      );

  static Widget unauthorizedScreen({
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen(
        errorType: ErrorType.unauthorized,
        onGoHome: onGoHome,
      );

  static Widget timeoutScreen({
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen(
        errorType: ErrorType.timeout,
        onRetry: onRetry,
        onGoHome: onGoHome,
      );

  static Widget customErrorScreen(
    String message, {
    VoidCallback? onRetry,
    VoidCallback? onGoHome,
  }) =>
      ErrorScreen(
        errorType: ErrorType.serverError,
        customMessage: message,
        onRetry: onRetry,
        onGoHome: onGoHome,
      );
}
