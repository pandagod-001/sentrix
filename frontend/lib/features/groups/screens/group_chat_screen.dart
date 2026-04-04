import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../features/chat/widgets/typing_indicator.dart';
import '../controllers/groups_controller.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late ScrollController _scrollController;
  bool _showTypingIndicator = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar.standard(
        title: widget.groupName,
        context: context,
        subtitle: 'Group Chat',
      ),
      body: Consumer<GroupsController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: controller.currentGroupMembers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == controller.currentGroupMembers.length) {
                      if (_showTypingIndicator) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TypingIndicator(
                            isTyping: true,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final member = controller.currentGroupMembers[index];
                    // Display member info as a simple widget
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.muted.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(member.name),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.muted.withOpacity(0.1),
                    ),
                  ),
                ),
                child: const Text('Message input widget placeholder'),
              ),
            ],
          );
        },
      ),
    );
  }
}
