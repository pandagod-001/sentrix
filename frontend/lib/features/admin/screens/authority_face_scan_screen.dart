import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../services/api_service.dart';

class AuthorityFaceScanScreen extends StatefulWidget {
  const AuthorityFaceScanScreen({super.key});

  @override
  State<AuthorityFaceScanScreen> createState() => _AuthorityFaceScanScreenState();
}

class _AuthorityFaceScanScreenState extends State<AuthorityFaceScanScreen> {
  final ApiService _apiService = ApiService();
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isScanning = false;
  String? _errorMessage;
  String? _resultMessage;
  String? _matchedUserName;
  String? _matchedRole;
  bool _matchAllowed = false;

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

      final frontCameras = cameras.where((camera) => camera.lensDirection == CameraLensDirection.front).toList();
      final selectedCamera = frontCameras.isNotEmpty ? frontCameras.first : cameras.first;

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
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
      if (!mounted) return;
      setState(() {
        _cameraController = null;
        _isInitializing = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _scanFace() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
      _resultMessage = null;
      _matchedUserName = null;
      _matchedRole = null;
      _matchAllowed = false;
    });

    try {
      final photo = await controller.takePicture();
      final imageBytes = await photo.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      final response = await _apiService.scanFaceDatabase(imageBase64);
      final success = response['success'] == true;
      final data = response['data'] as Map<String, dynamic>?;
      final userData = data?['user'] as Map<String, dynamic>?;

      if (!mounted) return;

      setState(() {
        _resultMessage = success
            ? (response['message']?.toString() ?? 'Face matched')
            : (response['message']?.toString() ?? 'No matching face found');
        _matchedUserName = userData?['name']?.toString();
        _matchedRole = userData?['role']?.toString();
        _matchAllowed = (data?['allowed'] == true);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_resultMessage ?? 'Scan complete'),
          backgroundColor: success ? Colors.green : AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultMessage = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_resultMessage ?? 'Scan failed'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Widget _buildCameraArea() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off_outlined, size: 72, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                'Camera unavailable',
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Retry camera',
                useGradient: false,
                onPressed: _initializeCamera,
              ),
            ],
          ),
        ),
      );
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Authority Face Scan',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Scan a personnel or dependent face. If the face is registered in the database, the system will allow it and record the scan.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 380,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentBlue, width: 2),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(child: _buildCameraArea()),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.10),
                                Colors.black.withOpacity(0.30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 200,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54, width: 2),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: _isScanning ? 'Scanning...' : 'Scan Face',
                onPressed: _scanFace,
                isEnabled: !_isScanning,
                isLoading: _isScanning,
              ),
              const SizedBox(height: 12),
              if (_resultMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _matchAllowed ? Colors.green.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _matchAllowed ? Colors.green : AppColors.error),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _resultMessage!,
                        style: AppTextStyles.body.copyWith(
                          color: _matchAllowed ? Colors.green : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_matchedUserName != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Matched user: $_matchedUserName',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                      if (_matchedRole != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Role: $_matchedRole',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _matchAllowed ? 'Access allowed' : 'Access denied',
                        style: AppTextStyles.caption.copyWith(
                          color: _matchAllowed ? Colors.green : AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Tips: keep the face centered, use good lighting, and make sure the user is already registered in the system.',
                style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}