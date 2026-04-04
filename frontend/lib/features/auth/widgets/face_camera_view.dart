import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Face Camera View Widget
class FaceCameraView extends StatefulWidget {
  final String status; // 'idle', 'scanning', 'recognized', 'failed'
  final VoidCallback? onScanComplete;
  final ValueChanged<String>? onFaceCaptured;

  const FaceCameraView({
    Key? key,
    this.status = 'idle',
    this.onScanComplete,
    this.onFaceCaptured,
  }) : super(key: key);

  @override
  State<FaceCameraView> createState() => _FaceCameraViewState();
}

class _FaceCameraViewState extends State<FaceCameraView> {
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No camera found on this device');
      }

      final frontCameras = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.front)
          .toList();
      final selectedCamera = frontCameras.isNotEmpty ? frontCameras.first : cameras.first;

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cameraController = null;
        _isInitializing = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _getStatusWidget() {
    switch (status) {
      case 'scanning':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Scanning face...',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        );
      case 'recognized':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.2),
                border: Border.all(
                  color: Colors.green,
                  width: 3,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Face Recognized!',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        );
      case 'failed':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withOpacity(0.2),
                border: Border.all(
                  color: AppColors.error,
                  width: 3,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  size: 60,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Face Recognition Failed',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white70,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 60,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Align your face in the frame',
              style: AppTextStyles.body.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        );
    }
  }

  String get status => widget.status;

  Widget _buildCameraLayer() {
    if (_isInitializing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Opening camera...',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              size: 72,
              color: Colors.white70,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera unavailable',
              style: AppTextStyles.titleSmall.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _initializeCamera,
              child: const Text(
                'Retry camera',
                style: TextStyle(color: AppColors.accentBlue),
              ),
            ),
          ],
        ),
      );
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  Future<void> _captureFace() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });

    try {
      final image = await controller.takePicture();
      final bytes = await image.readAsBytes();
      final faceBase64 = base64Encode(bytes);
      widget.onFaceCaptured?.call(faceBase64);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentBlue,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: _buildCameraLayer(),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.15),
                      Colors.black.withOpacity(0.35),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 180,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white30,
                  width: 2,
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCornerMark(top: true, left: true),
                  _buildCornerMark(top: true, left: false),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCornerMark(top: false, left: true),
                  _buildCornerMark(top: false, left: false),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getStatusWidget(),
                  if (widget.status == 'idle' || widget.status == 'scanning')
                    const SizedBox(height: 8),
                  if (widget.status == 'idle' || widget.status == 'scanning')
                    Text(
                      'Keep your face centered in the frame',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: ElevatedButton.icon(
                onPressed: _isCapturing ? null : _captureFace,
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: Text(_isCapturing ? 'Capturing...' : 'Capture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMark({required bool top, required bool left}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? BorderSide(color: AppColors.accentBlue, width: 2)
              : BorderSide.none,
          bottom: top
              ? BorderSide.none
              : BorderSide(color: AppColors.accentBlue, width: 2),
          left: left
              ? BorderSide(color: AppColors.accentBlue, width: 2)
              : BorderSide.none,
          right: left
              ? BorderSide.none
              : BorderSide(color: AppColors.accentBlue, width: 2),
        ),
      ),
    );
  }
}

/// Oval Face Frame (alternative design)
class OvalFaceFrame extends StatelessWidget {
  final String status;

  const OvalFaceFrame({
    Key? key,
    this.status = 'idle',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black87,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == 'recognized'
              ? Colors.green
              : status == 'failed'
                  ? AppColors.error
                  : AppColors.accentBlue,
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Oval frame indicator
          Container(
            width: 180,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white30,
                width: 2,
                strokeAlign: BorderSide.strokeAlignCenter,
              ),
            ),
          ),

          // Status indicator
          if (status == 'scanning')
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
              ),
            )
          else if (status == 'recognized')
            const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            )
          else if (status == 'failed')
            const Icon(
              Icons.cancel,
              size: 80,
              color: AppColors.error,
            ),

          // Corner brackets
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                  left: BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                  right: BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                  left: BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                  right: BorderSide(
                    color: AppColors.accentBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
