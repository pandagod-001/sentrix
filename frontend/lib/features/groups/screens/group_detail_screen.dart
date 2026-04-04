import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/groups_controller.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isEditing = false;

  String _cleanError(Object error) {
    final raw = error.toString();
    return raw
        .replaceFirst('Exception: ', '')
        .replaceFirst('API Request Failed: ', '')
        .trim();
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddMemberDialog(BuildContext context, GroupsController controller) {
    final memberIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Member'),
        content: SizedBox(
          width: 300,
          child: TextField(
            controller: memberIdController,
            decoration: const InputDecoration(
              labelText: 'Member User ID',
              hintText: 'Paste user id to add',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final memberId = memberIdController.text.trim();
              if (memberId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Member user id is required')),
                );
                return;
              }

              try {
                await controller.addMemberToGroup(widget.groupId, memberId);
                if (!context.mounted) return;
                Navigator.pop(context);
                final message = controller.error == null
                    ? 'Member added successfully'
                    : controller.error!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_cleanError(e))),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Group Details',
        showBackButton: true,
      ),
      body: Consumer<GroupsController>(
        builder: (context, controller, _) {
          // Get the selected group from the groups list
          final groupIndex = controller.groups.indexWhere(
            (g) => g.id == widget.groupId,
          );

          if (groupIndex == -1) {
            return const Center(child: Text('Group not found'));
          }

          final group = controller.groups[groupIndex];

          final members = controller.currentGroupMembers;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Group Avatar
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Center(
                    child: Text(
                      group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                      style: AppTextStyles.headline.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Group Name
              _isEditing
                  ? TextField(
                      controller: _nameController,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Group name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : Text(
                      group.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 16),

              // Group Type Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: group.type == 'family'
                          ? AppColors.accentBlue
                          : AppColors.muted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    group.type.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Description
              _isEditing
                  ? TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Group description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.muted.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        group.description,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
              const SizedBox(height: 24),

              // Edit/Save Button
              CustomButton(
                label: _isEditing ? 'Save Changes' : 'Edit Group',
                onPressed: () {
                  if (_isEditing) {
                    // Save changes
                    controller.updateGroup(
                      widget.groupId,
                      _nameController.text,
                      _descriptionController.text,
                    );
                    setState(() => _isEditing = false);
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Members Section
              Text(
                'Members (${members.length})',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Members List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.muted.withOpacity(0.1),
                  ),
                  boxShadow: AppColors.softShadowSmall,
                ),
                child: members.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No members yet',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: members.length,
                        separatorBuilder: (_, __) => Divider(
                          color: AppColors.muted.withOpacity(0.1),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  member.name[0].toUpperCase(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              member.name,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            subtitle: Text(
                              member.role.toUpperCase(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Remove'),
                                  onTap: () {
                                    controller.removeMemberFromGroup(
                                      widget.groupId,
                                      member.id,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),

              // Add Member Button
              CustomButton(
                label: 'Add Member',
                onPressed: () => _showAddMemberDialog(context, controller),
              ),
              const SizedBox(height: 16),

              // Leave Group Button
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Leave Group?'),
                      content: const Text(
                        'Are you sure you want to leave this group? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.leaveGroup(widget.groupId);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Leave',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Leave Group',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
