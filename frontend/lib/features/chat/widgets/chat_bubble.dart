import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_enums.dart';
import '../../../models/message_model.dart';

/// Chat Bubble Widget - Individual message display
class ChatBubble extends StatefulWidget {
  final Message message;
  final bool showTimestamp;
  final bool showSenderName;

  const ChatBubble({
    Key? key,
    required this.message,
    this.showTimestamp = true,
    this.showSenderName = false,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _showTimestamp = false;

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isSent = widget.message.type == MessageType.sent;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showTimestamp = !_showTimestamp;
            });
          },
          child: Align(
            alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(
                left: isSent ? 60 : 8,
                right: isSent ? 8 : 60,
                bottom: 4,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSent
                    ? AppColors.accentGradient
                    : null,
                color: isSent ? null : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSent ? AppColors.softShadowSmall : [],
              ),
              child: Column(
                crossAxisAlignment: isSent
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name (only for group chats)
                  if (widget.showSenderName && !isSent)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        widget.message.senderName,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),

                  // Message text
                  Text(
                    widget.message.text,
                    style: AppTextStyles.body.copyWith(
                      color: isSent ? Colors.white : AppColors.primary,
                    ),
                  ),

                  // Timestamp (if shown)
                  if (_showTimestamp || widget.showTimestamp)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTime(widget.message.timestamp),
                        style: AppTextStyles.caption.copyWith(
                          color: isSent
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Grouped Chat Bubble - Multiple bubbles from same sender
class GroupedChatBubbles extends StatelessWidget {
  final List<Message> messages;
  final bool showSenderName;

  const GroupedChatBubbles({
    Key? key,
    required this.messages,
    this.showSenderName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        messages.length,
        (index) {
          final message = messages[index];
          final isSent = message.type == MessageType.sent;

          return Container(
            margin: EdgeInsets.only(
              bottom: index == messages.length - 1 ? 12 : 2,
            ),
            child: ChatBubble(
              message: message,
              showTimestamp: index == messages.length - 1,
              showSenderName: showSenderName && !isSent,
            ),
          );
        },
      ),
    );
  }
}

/// Bubble Widget - Generic message container
class BubbleWidget extends StatelessWidget {
  final String text;
  final bool isOwn;
  final DateTime time;
  final Widget? trailing;

  const BubbleWidget({
    Key? key,
    required this.text,
    required this.isOwn,
    required this.time,
    this.trailing,
  }) : super(key: key);

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isOwn ? 60 : 8,
          right: isOwn ? 8 : 60,
          bottom: 8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isOwn ? AppColors.accentGradient : null,
          color: isOwn ? null : AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isOwn
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: isOwn ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(time),
                  style: AppTextStyles.caption.copyWith(
                    color: isOwn
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.muted,
                    fontSize: 11,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 4),
                  trailing!,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
