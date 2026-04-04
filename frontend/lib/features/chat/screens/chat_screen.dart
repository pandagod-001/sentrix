import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/chat_model.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';

/// Chat Screen - Individual conversation screen
class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ScrollController _scrollController;
  bool _isTyping = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatController>().loadMessages(widget.chatId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSendMessage(String message) async {
    final chatController =
        Provider.of<ChatController>(context, listen: false);
    await chatController.sendMessage(widget.chatId, message);

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    // Auto-hide typing indicator after message send + delay
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, _) {
        final chatIndex = chatController.chats.indexWhere((c) => c.id == widget.chatId);
        if (chatIndex == -1) {
          return const Scaffold(
            body: Center(child: Text('Chat not found')),
          );
        }
        final chat = chatController.chats[chatIndex];
        final messages = chatController.getMessages(widget.chatId);

            if (messages.length != _lastMessageCount) {
              _lastMessageCount = messages.length;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _scrollToBottom();
                }
              });
            }

        return MainScaffold(
          title: chat.participantName,
          appBar: _buildAppBar(context, chat),
          body: Column(
            children: [
              // Messages list
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: EmptyStateWidget.noResults(
                          context,
                          title: 'No messages yet',
                          message:
                              'Start the conversation with ${chat.participantName}',
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        itemCount: messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Typing indicator at bottom
                          if (index == messages.length && _isTyping) {
                            return TypingIndicator(
                              isTyping: _isTyping,
                              typingName: chat.participantName,
                            );
                          }

                          final message = messages[index];

                          return ChatBubble(
                            message: message,
                            showTimestamp: true,
                          );
                        },
                      ),
              ),

              // Message input
              MessageInputWidget(
                onSendMessage: _handleSendMessage,
                hintText: 'Message ${chat.participantName}...',
                enabled: !_isTyping,
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Chat chat) {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: AppColors.primary,
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          AvatarWidget(
            name: chat.participantName,
            size: 36,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                chat.participantName,
                style: AppTextStyles.titleSmall,
              ),
              Text(
                chat.status == ChatStatus.active ? 'Active now' : 'Offline',
                style: AppTextStyles.caption.copyWith(
                  color: chat.status == ChatStatus.active
                      ? Colors.green
                      : AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call),
          color: AppColors.primary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Call ${chat.participantName}'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          color: AppColors.primary,
          onPressed: () {
            _showChatOptions(context, chat);
          },
        ),
      ],
    );
  }

  void _showChatOptions(BuildContext context, Chat chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Chat settings
            _buildOptionTile(
              icon: Icons.info_outline,
              label: 'Chat info',
              onTap: () => Navigator.pop(context),
            ),

            _buildOptionTile(
              icon: Icons.search,
              label: 'Search in chat',
              onTap: () => Navigator.pop(context),
            ),

            _buildOptionTile(
              icon: chat.isMuted ? Icons.volume_up : Icons.notifications_off,
              label: chat.isMuted ? 'Unmute notifications' : 'Mute notifications',
              onTap: () {
                final controller =
                    Provider.of<ChatController>(context, listen: false);
                if (chat.isMuted) {
                  controller.unmuteChat(chat.id);
                } else {
                  controller.muteChat(chat.id);
                }
                Navigator.pop(context);
              },
            ),

            _buildOptionTile(
              icon: Icons.delete_outline,
              label: 'Delete chat',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, chat);
              },
            ),

            const SizedBox(height: 12),

            // Cancel
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Chat chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Delete conversation?',
          style: AppTextStyles.titleSmall,
        ),
        content: Text(
          'All messages will be deleted permanently.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final controller =
                  Provider.of<ChatController>(context, listen: false);
              controller.deleteChat(chat.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primary,
      ),
      title: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: isDestructive ? Colors.red : AppColors.primary,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Chat Screen with grouped messages
class ChatScreenGrouped extends StatelessWidget {
  final String chatId;

  const ChatScreenGrouped({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, _) {
        final chat = chatController.chats
            .firstWhere((c) => c.id == chatId);
        final messages = chatController.getMessages(chatId);

        // Group messages by sender
        final Map<String, List> groupedMessages = {};
        for (var msg in messages) {
          final key = msg.senderId;
          if (!groupedMessages.containsKey(key)) {
            groupedMessages[key] = [];
          }
          groupedMessages[key]!.add(msg);
        }

        return MainScaffold(
          title: chat.participantName,
          appBar: AppBar(
            backgroundColor: AppColors.card,
            title: Text(chat.participantName),
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: groupedMessages.length,
                  itemBuilder: (context, index) {
                    final messagesGroup =
                        groupedMessages.values.toList()[index];

                    return Column(
                      crossAxisAlignment: messagesGroup[0].type == MessageType.sent
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        ...messagesGroup.map((msg) {
                          return ChatBubble(
                            message: msg,
                            showTimestamp:
                                msg == messagesGroup.last,
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
              MessageInputWidget(
                onSendMessage: (message) {
                  chatController.sendMessage(chatId, message);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
