import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../models/user_model.dart';
import '../../../utils/role_checker.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/layouts/main_scaffold.dart';

/// Access Denied Screen - Shown when user lacks permissions
class AccessDeniedScreen extends StatelessWidget {
  final String? featureName;
  final User? user;

  const AccessDeniedScreen({
    Key? key,
    this.featureName,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Access Denied',
      appBar: CustomAppBar.simple(
        title: 'Access Denied',
        context: context,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                child: const Icon(
                  Icons.lock_outlined,
                  size: 48,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Access Restricted',
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                _getAccessDeniedMessage(),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Details card
              if (featureName != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feature: $featureName',
                        style: AppTextStyles.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getFeatureDetails(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Action buttons
              CustomButton.gradient(
                label: 'Go Home',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 12),

              CustomButton.outline(
                label: 'Contact Support',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Support contact:\nsupport@sentrix.com',
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAccessDeniedMessage() {
    if (user != null) {
      return RoleChecker.getRestrictionReason(user!);
    }
    return 'You don\'t have permission to access this feature. Please contact support if you believe this is an error.';
  }

  String _getFeatureDetails() {
    if (featureName == 'QR') {
      return 'QR functionality is only available for personnel';
    }
    if (featureName == 'Admin') {
      return 'Admin access is restricted to administrators only';
    }
    if (featureName == 'Dependents') {
      return 'Dependent management is only available for personnel';
    }
    return 'This feature requires special permissions';
  }
}

/// Approval Pending Screen - Shown when user is pending approval
class ApprovalPendingScreen extends StatelessWidget {
  final User user;

  const ApprovalPendingScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Pending Approval',
      appBar: CustomAppBar.simple(
        title: 'Pending Approval',
        context: context,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hourglass icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 48,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Pending Approval',
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                'Your account is awaiting admin approval.\nPlease check back shortly.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // User info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name', user.name),
                    const SizedBox(height: 12),
                    _buildInfoRow('Email', user.email),
                    const SizedBox(height: 12),
                    _buildInfoRow('Role', RoleChecker.getRoleDisplayName(user.role)),
                    const SizedBox(height: 12),
                    _buildInfoRow('Status', 'Pending Approval'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'An administrator will review your request shortly',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Buttons
              CustomButton.gradient(
                label: 'Refresh',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Checking approval status...'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              CustomButton.text(
                label: 'Logout',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.splash,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Feature Unavailable Screen - For roles that don't support a feature
class FeatureUnavailableScreen extends StatelessWidget {
  final String featureName;
  final String requiredRole;
  final String? description;

  const FeatureUnavailableScreen({
    Key? key,
    required this.featureName,
    required this.requiredRole,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Unavailable',
      appBar: CustomAppBar.simple(
        title: 'Unavailable',
        context: context,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Unavailable icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                child: const Icon(
                  Icons.block_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                '$featureName is unavailable',
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                'This feature is only available for $requiredRole users',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),

              if (description != null) ...[
                const SizedBox(height: 16),
                Text(
                  description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.muted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // Go back button
              CustomButton.gradient(
                label: 'Go Back',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
