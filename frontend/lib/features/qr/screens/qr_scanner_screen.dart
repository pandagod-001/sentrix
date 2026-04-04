import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../controllers/qr_controller.dart';

/// QR Scanner Screen - Scan QR codes from others
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Scan QR Code',
      appBar: CustomAppBar.standard(
        title: 'Scan QR Code',
        context: context,
        subtitle: 'Point camera at QR code',
      ),
      body: Consumer<QRController>(
        builder: (context, qrController, _) {
          return Column(
            children: [
              // Camera view area
              Expanded(
                flex: 2,
                child: _buildCameraArea(),
              ),

              // Scanner controls
              Expanded(
                child: _buildScannedResults(
                  context,
                  qrController,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraArea() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Camera feed area
          Container(
            color: AppColors.primary.withOpacity(0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: AppColors.muted.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Feed',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.muted.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanner overlay (crosshair)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.accentBlue,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomPaint(
                painter: ScannerCornerPainter(),
              ),
            ),
          ),

          // Scanning indicator
          if (_isScanning)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scanning...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannedResults(
    BuildContext context,
    QRController qrController,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scan button
          CustomButton.gradient(
            label: _isScanning
                ? 'Stop Scanning'
                : 'Start Scanning',
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
              });

              if (_isScanning) {
                _simulateQRScan(context, qrController);
              }
            },
          ),

          const SizedBox(height: 20),

          // Recent scans
          Text(
            'Recent Scans',
            style: AppTextStyles.titleSmall,
          ),

          const SizedBox(height: 12),

          if (qrController.scanHistory.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  'No scans yet',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            )
          else
            Column(
              children: List.generate(
                qrController.scanHistory.length,
                (index) {
                  final result = qrController.scanHistory[index];
                  final qrData = result.qrData;

                  return _buildScanResultTile(result, qrData);
                },
              ),
            ),

          if (qrController.scanHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            CustomButton.outline(
              label: 'Clear Scan History',
              onPressed: () {
                qrController.clearScanHistory();
                setState(() {});
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanResultTile(QRScanResult result, QRData? qrData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.success ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result header
          Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.cancel,
                color: result.success ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: result.success ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (result.success && qrData != null) ...[
            const SizedBox(height: 12),
            // User info
            Row(
              children: [
                AvatarWidget(
                  name: qrData.userName,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        qrData.userName,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        qrData.memberId,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),

          // Scan time
          Text(
            'Scanned: ${result.scannedAt.toString()}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  void _simulateQRScan(BuildContext context, QRController qrController) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || !_isScanning) return;

      final sourceQr = qrController.currentQRData;
      if (sourceQr == null) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No QR payload available. Generate a QR code first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final scannedCode = sourceQr.toJson();
      qrController.scanQRCode(scannedCode);

      setState(() {
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('QR code scanned successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
}

/// Scanner corner painter for camera overlay
class ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerSize = 30.0;
    const strokeWidth = 3.0;

    final paint = Paint()
      ..color = AppColors.accentBlue
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

/// QR Scanner Screen - Classes are imported from qr_controller.dart
