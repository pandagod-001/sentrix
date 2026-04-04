import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/qr_controller.dart';

/// QR Display Screen - Shows the current user's QR code.
class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({Key? key}) : super(key: key);

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  bool _showDetails = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final qrController = context.read<QRController>();
      try {
        await qrController.generateQRCode();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'My QR Code',
      appBar: CustomAppBar.standard(
        title: 'My QR Code',
        context: context,
        subtitle: 'Share with others to add you to groups',
      ),
      body: Consumer<QRController>(
        builder: (context, qrController, _) {
          final qrData = qrController.currentQRData;
          final error = qrController.errorMessage;

          if (_loading && qrData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (qrData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code_2_outlined, size: 68, color: AppColors.muted),
                    const SizedBox(height: 12),
                    Text(
                      error ?? 'Unable to generate QR code right now.',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    CustomButton.outline(
                      label: 'Retry',
                      onPressed: () async {
                        setState(() => _loading = true);
                        await qrController.generateQRCode();
                        if (!mounted) return;
                        setState(() => _loading = false);
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          final displayData = qrData.toJson();
          final isValid = !qrData.isExpired;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isValid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isValid ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    isValid ? '✓ Valid - ${qrController.getFormattedExpiryTime()}' : 'Expired - tap refresh',
                    style: AppTextStyles.caption.copyWith(
                      color: isValid ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 250,
                        height: 250,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: QrImageView(
                          data: displayData,
                          version: QrVersions.auto,
                          gapless: true,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ID: ${qrData.id}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.muted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoCard(qrData),
                const SizedBox(height: 20),
                CustomButton.gradient(
                  label: 'Refresh QR Code',
                  onPressed: () async {
                    setState(() => _loading = true);
                    try {
                      await qrController.refreshQRCode();
                    } catch (_) {
                      // Safe fallback is handled by the controller.
                    }
                    if (!mounted) return;
                    setState(() => _loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR code refreshed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton.outline(
                  label: 'Share QR Code',
                  onPressed: () async {
                    await qrController.shareQRCode();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR sharing is ready'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showDetails ? 'Hide Details' : 'Show Details',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accentBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.accentBlue,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showDetails) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('QR ID', qrData.id),
                        const SizedBox(height: 8),
                        _buildDetailRow('User ID', qrData.userId),
                        const SizedBox(height: 8),
                        _buildDetailRow('User Name', qrData.userName),
                        const SizedBox(height: 8),
                        _buildDetailRow('Member ID', qrData.memberId),
                        const SizedBox(height: 8),
                        _buildDetailRow('Role', qrData.userRole),
                        const SizedBox(height: 8),
                        _buildDetailRow('Expires', qrData.expiresAt.toString()),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(QRData qrData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow('Name', qrData.userName),
          const SizedBox(height: 8),
          _buildInfoRow('Member ID', qrData.memberId),
          const SizedBox(height: 8),
          _buildInfoRow('Role', qrData.userRole),
          const SizedBox(height: 8),
          _buildInfoRow('Expires', qrControllerExpiryLabel(qrData)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  String qrControllerExpiryLabel(QRData qrData) {
    if (qrData.isExpired) return 'Expired';
    final remaining = qrData.expiresAt.difference(DateTime.now());
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes.remainder(60)}m left';
    }
    if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}m left';
    }
    return '${remaining.inSeconds}s left';
  }
}
