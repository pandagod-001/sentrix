import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/chat_model.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/badge_widget.dart';

/// Chat Tile Widget - Individual chat item in list
class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const ChatTile({
    Key? key,
    required this.chat,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentBlue.withOpacity(0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  AvatarWidget(
                    name: chat.participantName,
                    size: 48,
                    showOnlineBadge: true,
                    isOnline: chat.status == 'active' ? true : false,
                  ),
                  if (chat.isMuted)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.muted,
                        ),
                        child: const Icon(
                          Icons.volume_off,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Chat info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      chat.participantName,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Last message preview
                    Text(
                      chat.lastMessage,
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: chat.unreadCount > 0
                            ? AppColors.primary
                            : AppColors.secondary,
                        fontWeight: chat.unreadCount > 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Time and unread badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Time
                  Text(
                    _formatTime(chat.lastMessageTime),
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),

                  // Unread badge
                  if (chat.unreadCount > 0)
                    CountBadge(
                      count: chat.unreadCount,
                      size: 20,
                    )
                  else
                    const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact Chat Tile (for sidebar or narrow views)
class CompactChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const CompactChatTile({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            AvatarWidget(
              name: chat.participantName,
              size: 40,
            ),
            const SizedBox(width: 8),
            if (chat.unreadCount > 0)
              CountBadge(
                count: chat.unreadCount,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
