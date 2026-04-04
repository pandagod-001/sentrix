import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// QR Status Widget - Shows QR validity status
class QRStatusWidget extends StatelessWidget {
  final bool isValid;
  final String? expiryTime;
  final VoidCallback? onRefresh;

  const QRStatusWidget({
    Key? key,
    required this.isValid,
    this.expiryTime,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.verified : Icons.error_outline,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isValid ? 'Valid' : 'Invalid',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (expiryTime != null)
                  Text(
                    expiryTime!,
                    style: AppTextStyles.caption.copyWith(
                      color: isValid ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          if (onRefresh != null && !isValid)
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Colors.red,
              iconSize: 18,
              onPressed: onRefresh,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}

/// QR Code Display Box - For showing QR code
class QRCodeBox extends StatelessWidget {
  final String qrId;
  final double size;
  final VoidCallback? onTap;

  const QRCodeBox({
    Key? key,
    required this.qrId,
    this.size = 250,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.softShadow,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                'QR Code',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                qrId,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// QR Scan History Item
class QRScanHistoryItem extends StatelessWidget {
  final String userName;
  final String userEmail;
  final bool success;
  final DateTime scannedTime;
  final VoidCallback onTap;

  const QRScanHistoryItem({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.success,
    required this.scannedTime,
    required this.onTap,
  }) : super(key: key);

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: success
                ? Colors.green.withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: success
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.cancel,
                color: success ? Colors.green : Colors.red,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(scannedTime),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// QR Statistics Widget - Shows QR usage stats
class QRStatsWidget extends StatelessWidget {
  final int totalScans;
  final int successfulScans;
  final int failedScans;
  final DateTime lastScanTime;

  const QRStatsWidget({
    Key? key,
    required this.totalScans,
    required this.successfulScans,
    required this.failedScans,
    required this.lastScanTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final successRate = totalScans > 0
        ? (successfulScans / totalScans * 100).toStringAsFixed(1)
        : '0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            'QR Statistics',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Total Scans', totalScans.toString()),
              _buildStatCard('Successful', successfulScans.toString(),
                  color: Colors.green),
              _buildStatCard('Failed', failedScans.toString(),
                  color: Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Success Rate',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              Text(
                '$successRate%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last Scan',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              Text(
                lastScanTime.toString().split('.')[0],
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value,
      {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headline.copyWith(
            color: color ?? AppColors.accentBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

/// QR Scanner Frame - Visual guide for scanning
class QRScannerFrame extends StatelessWidget {
  final double size;
  final bool isScanning;

  const QRScannerFrame({
    Key? key,
    this.size = 250,
    this.isScanning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: isScanning
              ? Colors.green
              : AppColors.accentBlue,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomPaint(
        painter: ScannerFramePainter(
          color: isScanning
              ? Colors.green
              : AppColors.accentBlue,
        ),
      ),
    );
  }
}

class ScannerFramePainter extends CustomPainter {
  final Color color;

  ScannerFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const cornerSize = 30.0;
    const strokeWidth = 3.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, 0)
        ..lineTo(cornerSize, 0),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerSize),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerSize)
        ..lineTo(0, size.height)
        ..lineTo(cornerSize, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
