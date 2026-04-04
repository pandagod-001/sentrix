import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// QR Result Screen - Detailed view of scanned QR code result
class QRResultScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final bool success;
  final String message;
  final DateTime scannedTime;

  const QRResultScreen({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.success,
    required this.message,
    required this.scannedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'QR Scan Result',
      appBar: CustomAppBar.standard(
        title: 'Scan Result',
        context: context,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Result icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (success ? Colors.green : Colors.red)
                    .withOpacity(0.1),
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.cancel,
                size: 60,
                color: success ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            // Result message
            Text(
              success ? 'Success!' : 'Failed',
              style: AppTextStyles.headline.copyWith(
                color: success ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Result details
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // User info card (if successful)
            if (success)
              _buildUserInfoCard()
            else
              _buildErrorCard(),

            const SizedBox(height: 32),

            // Scan details
            _buildScanDetailsCard(),

            const SizedBox(height: 32),

            // Action buttons
            CustomButton.gradient(
              label: 'Scan Another',
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 12),

            CustomButton.outline(
              label: 'View Profile',
              isEnabled: success,
              onPressed: success
                  ? () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.profile,
                      arguments: {'userName': userName},
                    );
                  }
                  : () {},
            ),

            const SizedBox(height: 12),

            CustomButton.text(
              label: 'Home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
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
          // Avatar
          AvatarWidget(
            name: userName,
            size: 80,
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            userName,
            style: AppTextStyles.titleSmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Email
          Text(
            userEmail,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              userRole.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Add to group button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(
                  NavigatorState().context,
                ).showSnackBar(
                  SnackBar(
                    content: Text('$userName added to group'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add to Group'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          Text(
            'Invalid QR Code',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'The QR code scanned is invalid or has expired. Please try again with a valid QR code.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScanDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan Details',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Scanned At', scannedTime.toString()),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Status',
            success ? 'Valid' : 'Invalid',
            color: success ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Message', message),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(
              color: color ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// QR History Screen - View past scans
class QRHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> scanHistory;

  const QRHistoryScreen({
    Key? key,
    required this.scanHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Scan History',
      appBar: CustomAppBar.standard(
        title: 'Scan History',
        context: context,
        subtitle: 'View all your scanned QR codes',
      ),
      body: scanHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scan history',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: scanHistory.length,
              itemBuilder: (context, index) {
                final scan = scanHistory[index];
                final success = scan['success'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: success ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            success
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: success
                                ? Colors.green
                                : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              scan['userName'] ?? 'Unknown',
                              style:
                                  AppTextStyles.bodySmall,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            scan['scannedTime']
                                    ?.toString()
                                    .split(' ')
                                    .first ??
                                'N/A',
                            style: AppTextStyles.caption
                                .copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      if (success) ...[
                        const SizedBox(height: 8),
                        Text(
                          scan['userEmail'] ?? '',
                          style: AppTextStyles.caption
                              .copyWith(
                            color: AppColors.secondary,
                          ),
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}
