import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/avatar_widget.dart';

/// Drawer Menu Widget - Navigation drawer for authenticated screens
class DrawerMenu extends StatelessWidget {
  final String userName;
  final UserRole userRole;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogout;

  const DrawerMenu({
    Key? key,
    required this.userName,
    required this.userRole,
    this.onProfileTap,
    this.onSettingsTap,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.accentGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AvatarWidget(
                    name: userName,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    userRole.displayName,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: Text(
                      'Communication',
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                    ),
                  ),
                  MenuItemWidget(
                    icon: Icons.chat_outlined,
                    label: 'Messages',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(AppRoutes.chatList);
                    },
                  ),
                  MenuItemWidget(
                    icon: Icons.people_outline,
                    label: 'Groups',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(AppRoutes.groupList);
                    },
                  ),
                  if (userRole == UserRole.personnel)
                    MenuItemWidget(
                      icon: Icons.qr_code_outlined,
                      label: 'QR Code',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(AppRoutes.qrDisplay);
                      },
                    ),

                  if (userRole == UserRole.admin)
                    MenuItemWidget(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Authority Dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(AppRoutes.adminDashboard);
                      },
                    ),

                  const SizedBox(height: 8),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: Text(
                      'Account',
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                    ),
                  ),
                  MenuItemWidget(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      if (onProfileTap != null) {
                        onProfileTap!.call();
                      } else {
                        Navigator.of(context).pushNamed(AppRoutes.profile);
                      }
                    },
                  ),
                  MenuItemWidget(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      if (onSettingsTap != null) {
                        onSettingsTap!.call();
                      } else {
                        Navigator.of(context).pushNamed(AppRoutes.settings);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () {
                    Navigator.pop(context);
                    onLogout?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple Menu Item
class MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool isSelected;

  const MenuItemWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isSelected ? AppColors.accentBlue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            icon,
            color: isSelected ? AppColors.accentBlue : (iconColor ?? AppColors.secondary),
          ),
          title: Text(
            label,
            style: isSelected
                ? AppTextStyles.titleSmall.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w700,
                  )
                : AppTextStyles.titleSmall,
          ),
          selected: isSelected,
          onTap: onTap,
        ),
      ),
    );
  }
}
