import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../../utils/role_checker.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_tile.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/empty_state_widget.dart';

/// Chat List Screen - Main chat conversations screen
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late TextEditingController _searchController;
  List<Chat>? _filteredChats;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterChats);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatController>().loadChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats() {
    final chatController =
        Provider.of<ChatController>(context, listen: false);
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredChats = null;
      } else {
        _filteredChats = chatController.chats
            .where((chat) =>
                chat.participantName.toLowerCase().contains(query) ||
                chat.lastMessage.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ChatController>().loadChats();
    if (!mounted) return;
    setState(() {
      _filterChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MainScaffold(
      title: 'Messages',
      appBar: CustomAppBar.standard(
        title: 'Messages',
        context: context,
        subtitle: 'Tap to open conversation',
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        onPressed: () => _openNewChatSheet(context),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: Consumer<ChatController>(
        builder: (context, chatController, _) {
          final chats =
              _filteredChats ?? chatController.chats;

          return Column(
            children: [
              if (chatController.error != null && chatController.error!.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.error.withOpacity(0.5)),
                  ),
                  child: Text(
                    chatController.error!,
                    style: AppTextStyles.caption.copyWith(color: colorScheme.onErrorContainer),
                  ),
                ),

              // Search box
              Padding(
                padding: const EdgeInsets.all(12),
                child: CustomTextField(
                  controller: _searchController,
                  label: 'Search conversations',
                  hint: 'Name or message...',
                  prefixIcon: Icon(Icons.search),
                  onChanged: (_) => _filterChats(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Conversations',
                      style: AppTextStyles.titleSmall,
                    ),
                    Text(
                      '${chats.length}',
                      style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              // Chat list
              Expanded(
                child: chats.isEmpty
                    ? EmptyStateWidget.noResults(
                        context,
                        title: _searchController.text.isNotEmpty
                            ? 'No matches found'
                            : 'No conversations yet',
                        message: _searchController.text.isNotEmpty
                            ? 'Try searching for a different name'
                            : 'Start a new conversation',
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.accentBlue,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];

                            return ChatTile(
                              chat: chat,
                              onTap: () {
                                chatController.selectChat(chat.id);
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.chatScreen,
                                  arguments: chat.id,
                                );
                              },
                              onLongPress: () {
                                _showChatOptions(context, chat);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openNewChatSheet(BuildContext context) async {
    final chatController = Provider.of<ChatController>(context, listen: false);
    await chatController.loadAvailableUsers();

    if (!mounted) return;

    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final query = searchController.text.trim().toLowerCase();
            final users = chatController.availableUsers.where((user) {
              final name = user.name.toLowerCase();
              final email = user.email.toLowerCase();
              final role = RoleChecker.getRoleDisplayName(user.role).toLowerCase();
              return query.isEmpty ||
                  name.contains(query) ||
                  email.contains(query) ||
                  role.contains(query);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.55,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: AppColors.softShadowSmall,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 42,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Start a new chat',
                            style: AppTextStyles.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pick an approved user to open a direct conversation.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search users...',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                            ),
                            onChanged: (_) {
                              setSheetState(() {});
                            },
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Consumer<ChatController>(
                              builder: (context, controller, _) {
                                if (controller.isCreatingChat) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (users.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No approved users found',
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  controller: scrollController,
                                  itemCount: users.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final user = users[index];
                                    return _buildUserTile(
                                      context,
                                      user,
                                      onTap: () async {
                                        final chatId = await chatController.createChatWithUser(user.id);
                                        if (!mounted || chatId == null) {
                                          return;
                                        }
                                        Navigator.of(sheetContext).pop();
                                        Navigator.pushNamed(
                                          this.context,
                                          AppRoutes.chatScreen,
                                          arguments: chatId,
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      searchController.dispose();
    });
  }

  Widget _buildUserTile(
    BuildContext context,
    User user, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.accentBlue.withOpacity(0.12),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      RoleChecker.getRoleDisplayName(user.role),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.accentBlue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
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

            // Chat title
            Text(
              chat.participantName,
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 20),

            // Mute option
            _buildOptionTile(
              icon: chat.isMuted ? Icons.volume_up : Icons.volume_off,
              label: chat.isMuted ? 'Unmute' : 'Mute',
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

            // Delete option
            _buildOptionTile(
              icon: Icons.delete_outline,
              label: 'Delete conversation',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, chat);
              },
            ),

            const SizedBox(height: 12),

            // Cancel button
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
          'This will permanently delete your chat history with ${chat.participantName}.',
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
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
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

/// Archived Chats Screen
class ArchivedChatsScreen extends StatelessWidget {
  const ArchivedChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Archived',
      appBar: CustomAppBar.standard(
        title: 'Archived',
        context: context,
      ),
      body: EmptyStateWidget.noResults(
        context,
        title: 'No archived conversations',
        message: 'Archive conversations to keep your inbox clean',
      ),
    );
  }
}
