import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Privacy Settings Widget
class PrivacySettingsSection extends StatelessWidget {
  final bool onlineStatus;
  final bool readReceipts;
  final bool lastSeenVisible;
  final bool allowGroupInvites;
  final Function(bool) onOnlineStatusChanged;
  final Function(bool) onReadReceiptsChanged;
  final Function(bool) onLastSeenChanged;
  final Function(bool) onAllowGroupInvitesChanged;

  const PrivacySettingsSection({
    Key? key,
    required this.onlineStatus,
    required this.readReceipts,
    required this.lastSeenVisible,
    required this.allowGroupInvites,
    required this.onOnlineStatusChanged,
    required this.onReadReceiptsChanged,
    required this.onLastSeenChanged,
    required this.onAllowGroupInvitesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Settings',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildPrivacyOption(
          title: 'Online Status',
          subtitle: 'Show when you are online/offline',
          value: onlineStatus,
          onChanged: onOnlineStatusChanged,
        ),
        _buildPrivacyOption(
          title: 'Read Receipts',
          subtitle: 'Let others know when you\'ve read messages',
          value: readReceipts,
          onChanged: onReadReceiptsChanged,
        ),
        _buildPrivacyOption(
          title: 'Last Seen',
          subtitle: 'Show when you were last active',
          value: lastSeenVisible,
          onChanged: onLastSeenChanged,
        ),
        _buildPrivacyOption(
          title: 'Group Invites',
          subtitle: 'Allow anyone to invite you to groups',
          value: allowGroupInvites,
          onChanged: onAllowGroupInvitesChanged,
        ),
      ],
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.muted.withOpacity(0.1),
          ),
          boxShadow: AppColors.softShadowSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.accentGradient.colors.first,
            ),
          ],
        ),
      ),
    );
  }
}

/// Blocked Users Widget
class BlockedUsersWidget extends StatelessWidget {
  final List<String> blockedUsers;
  final Function(String) onUnblock;

  const BlockedUsersWidget({
    Key? key,
    required this.blockedUsers,
    required this.onUnblock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blocked Users',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (blockedUsers.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.muted.withOpacity(0.1),
              ),
            ),
            child: Text(
              'No blocked users',
              style: AppTextStyles.body.copyWith(
                color: AppColors.secondary,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.muted.withOpacity(0.1),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blockedUsers.length,
              separatorBuilder: (_, __) => Divider(
                color: AppColors.muted.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        user[0].toUpperCase(),
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    user,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () => onUnblock(user),
                    child: const Text('Unblock'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Two-Factor Authentication Widget
class TwoFactorWidget extends StatelessWidget {
  final bool enabled;
  final Function(bool) onToggle;
  final VoidCallback onSetup;

  const TwoFactorWidget({
    Key? key,
    required this.enabled,
    required this.onToggle,
    required this.onSetup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.muted.withOpacity(0.1),
        ),
        boxShadow: AppColors.softShadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-Factor Authentication',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add an extra layer of security',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: AppColors.accentGradient.colors.first,
              ),
            ],
          ),
          if (!enabled) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onSetup,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Set Up 2FA',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
