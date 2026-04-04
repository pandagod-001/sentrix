import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/qr_controller.dart';

class QRScanScreen extends StatefulWidget {
	const QRScanScreen({super.key});

	@override
	State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
	final MobileScannerController _scannerController = MobileScannerController(
		detectionSpeed: DetectionSpeed.noDuplicates,
		returnImage: false,
		facing: CameraFacing.back,
	);

	bool _isProcessingScan = false;
	bool _isTorchOn = false;
	String? _lastScannedCode;
	DateTime? _lastScanAt;

	@override
	void dispose() {
		_scannerController.dispose();
		super.dispose();
	}

	Future<void> _handleScan(String code, QRController qrController) async {
		if (_isProcessingScan) {
			return;
		}

		final now = DateTime.now();
		if (_lastScannedCode == code &&
				_lastScanAt != null &&
				now.difference(_lastScanAt!).inSeconds < 3) {
			return;
		}

		setState(() {
			_isProcessingScan = true;
			_lastScannedCode = code;
			_lastScanAt = now;
		});

		await _scannerController.stop();

		final result = await qrController.scanQRCode(code);

		if (!mounted) {
			return;
		}

		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(result.message),
				backgroundColor: result.success ? Colors.green : AppColors.error,
			),
		);

		await Future.delayed(const Duration(milliseconds: 500));
		if (!mounted) {
			return;
		}

		setState(() {
			_isProcessingScan = false;
		});

		await _scannerController.start();
	}

	Future<void> _showManualEntryDialog(QRController qrController) async {
		final controller = TextEditingController();

		await showModalBottomSheet<void>(
			context: context,
			isScrollControlled: true,
			backgroundColor: AppColors.card,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
			),
			builder: (context) {
				return Padding(
					padding: EdgeInsets.only(
						left: 16,
						right: 16,
						top: 16,
						bottom: MediaQuery.of(context).viewInsets.bottom + 16,
					),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								'Enter QR code manually',
								style: AppTextStyles.titleSmall,
							),
							const SizedBox(height: 12),
							TextField(
								controller: controller,
								decoration: const InputDecoration(
									labelText: 'QR code',
									hintText: 'Paste or type code',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 12),
							CustomButton(
								label: 'Verify Code',
								onPressed: () async {
									final code = controller.text.trim();
									if (code.isEmpty) {
										return;
									}
									Navigator.of(context).pop();
									await _handleScan(code, qrController);
								},
							),
						],
					),
				);
			},
		);

		controller.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Consumer<QRController>(
			builder: (context, qrController, _) {
				final history = qrController.getScanHistory(limit: 3);

				return Scaffold(
					backgroundColor: AppColors.background,
					appBar: AppBar(
						title: const Text('Scan QR Code'),
						centerTitle: true,
						actions: [
							IconButton(
								tooltip: _isTorchOn ? 'Turn torch off' : 'Turn torch on',
								onPressed: () {
									_scannerController.toggleTorch();
									setState(() {
										_isTorchOn = !_isTorchOn;
									});
								},
								icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
							),
							IconButton(
								tooltip: 'Switch camera',
								onPressed: _scannerController.switchCamera,
								icon: const Icon(Icons.cameraswitch_outlined),
							),
						],
					),
					body: Column(
						children: [
							Expanded(
								child: Padding(
									padding: const EdgeInsets.all(16),
									child: ClipRRect(
										borderRadius: BorderRadius.circular(16),
										child: Stack(
											fit: StackFit.expand,
											children: [
												MobileScanner(
													controller: _scannerController,
													onDetect: (capture) async {
														final code = capture.barcodes.first.rawValue;
														if (code == null || code.isEmpty) {
															return;
														}
														await _handleScan(code, qrController);
													},
												),
												Container(
													decoration: BoxDecoration(
														border: Border.all(
															color: _isProcessingScan
																	? Colors.green
																	: AppColors.accentBlue,
															width: 3,
														),
														borderRadius: BorderRadius.circular(16),
													),
												),
												Positioned(
													left: 0,
													right: 0,
													bottom: 0,
													child: Container(
														color: Colors.black54,
														padding: const EdgeInsets.all(12),
														child: Text(
															_isProcessingScan
																	? 'Verifying scanned QR...'
																	: 'Align QR code inside the frame',
															textAlign: TextAlign.center,
															style: AppTextStyles.bodySmall.copyWith(
																color: Colors.white,
															),
														),
													),
												),
											],
										),
									),
								),
							),
							Container(
								width: double.infinity,
								padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Row(
											children: [
												Expanded(
													child: CustomButton(
														label: 'Enter code manually',
														useGradient: false,
														onPressed: () => _showManualEntryDialog(qrController),
													),
												),
												const SizedBox(width: 10),
												Expanded(
													child: CustomButton(
														label: 'Clear history',
														useGradient: false,
														onPressed: qrController.scanHistory.isEmpty
																? () {}
																: () => qrController.clearScanHistory(),
														isEnabled: qrController.scanHistory.isNotEmpty,
													),
												),
											],
										),
										const SizedBox(height: 12),
										Text(
											'Recent scans',
											style: AppTextStyles.titleSmall,
										),
										const SizedBox(height: 8),
										if (_lastScannedCode != null)
											Text(
												'Last code: $_lastScannedCode',
												maxLines: 1,
												overflow: TextOverflow.ellipsis,
												style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
											),
										if (history.isEmpty)
											Padding(
												padding: const EdgeInsets.only(top: 8),
												child: Text(
													'No scans yet',
													style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
												),
											)
										else
											...history.map(
												(item) => ListTile(
													dense: true,
													contentPadding: EdgeInsets.zero,
													leading: Icon(
														item.success ? Icons.check_circle : Icons.error,
														color: item.success ? Colors.green : AppColors.error,
													),
													title: Text(item.message, maxLines: 1, overflow: TextOverflow.ellipsis),
													subtitle: Text(item.scannedAt.toString()),
												),
											),
									],
								),
							),
						],
					),
				);
			},
		);
	}
}
