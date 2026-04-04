import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isCheckingBackend = false;
  String _backendStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    final controller = context.read<SettingsController>();
    _nameController = TextEditingController(text: controller.userName);
    _emailController = TextEditingController(text: controller.email);
    _phoneController = TextEditingController(text: controller.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Settings',
        showBackButton: true,
      ),
      body: Consumer<SettingsController>(
        builder: (context, settings, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('Account'),
            _card(
              colorScheme,
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Update Profile',
                      onPressed: () {
                        settings.updateProfile(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          phone: _phoneController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            _sectionHeader('Display'),
            _card(
              colorScheme,
              child: Column(
                children: [
                  _switchRow(
                    title: 'Message Notifications',
                    subtitle: 'Chat and group notifications',
                    value: settings.messageNotifications,
                    onChanged: settings.setMessageNotifications,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            _sectionHeader('Security'),
            _card(
              colorScheme,
              child: Column(
                children: [
                  _switchRow(
                    title: 'Biometric Authentication',
                    subtitle: 'Require biometric for app access',
                    value: settings.biometricAuth,
                    onChanged: settings.setBiometricAuth,
                  ),
                  const Divider(height: 1),
                  _switchRow(
                    title: 'Auto Logout (30 mins)',
                    subtitle: 'End session after inactivity',
                    value: settings.autoLogoutMinutes > 0,
                    onChanged: (enabled) => settings.setAutoLogout(enabled ? 30 : 0),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            _sectionHeader('Backend'),
            _card(
              colorScheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('API URL', style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(AppConfig.apiBaseUrl, style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  Text('Status: $_backendStatus', style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isCheckingBackend
                          ? null
                          : () async {
                              setState(() {
                                _isCheckingBackend = true;
                                _backendStatus = 'Checking...';
                              });

                              try {
                                final response = await http.get(
                                  Uri.parse('${AppConfig.apiBaseUrl}/'),
                                ).timeout(const Duration(seconds: 5));

                                if (!mounted) return;
                                setState(() {
                                  _backendStatus = response.statusCode == 200
                                      ? 'Online'
                                      : 'Error (${response.statusCode})';
                                });
                              } catch (_) {
                                if (!mounted) return;
                                setState(() {
                                  _backendStatus = 'Offline';
                                });
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isCheckingBackend = false;
                                  });
                                }
                              }
                            },
                      icon: const Icon(Icons.cloud_done_outlined),
                      label: Text(_isCheckingBackend ? 'Checking...' : 'Check Connectivity'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _card(ColorScheme colorScheme, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _switchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: AppTextStyles.body.copyWith(color: colorScheme.onSurface)),
      subtitle: Text(subtitle, style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant)),
      value: value,
      onChanged: onChanged,
    );
  }
}
