import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_enums.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/groups_controller.dart';
import 'group_detail_screen.dart';

/// Group List Screen - Shows all user groups
class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  late TextEditingController _searchController;
  String _filterType = 'all'; // all, family, official

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GroupsController>().refreshGroups();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAuthority = context.select<AuthController, bool>(
      (controller) => controller.currentUser?.role == UserRole.admin,
    );
    return MainScaffold(
      title: 'Groups',
      appBar: CustomAppBar.standard(
        title: 'Groups',
        context: context,
        subtitle: 'View all your groups',
      ),
      body: Consumer<GroupsController>(
        builder: (context, groupsController, _) {
          // Filter groups based on search and type
          final filteredGroups = groupsController.groups
              .where((group) {
                final typeMatch = _filterType == 'all' ||
                    group.type == _filterType;
                final searchMatch = _searchController
                        .text
                        .isEmpty ||
                    group.name
                        .toLowerCase()
                        .contains(_searchController.text
                            .toLowerCase()) ||
                    group.description
                        .toLowerCase()
                        .contains(_searchController.text
                            .toLowerCase());
                return typeMatch && searchMatch;
              })
              .toList();

          return Column(
            children: [
              if (groupsController.error != null && groupsController.error!.isNotEmpty)
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
                    groupsController.error!,
                    style: AppTextStyles.caption.copyWith(color: colorScheme.onErrorContainer),
                  ),
                ),

              // Search box
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _searchController,
                      label: 'Search groups',
                      hint: 'Group name...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    const SizedBox(height: 12),
                    // Type filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'All'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'family',
                            'Family',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'official',
                            'Official',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('All Groups', style: AppTextStyles.titleSmall),
                    Text(
                      '${filteredGroups.length}',
                      style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              // Groups list
              Expanded(
                child: filteredGroups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_work,
                              size: 64,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No groups found',
                              style:
                                  AppTextStyles.titleSmall
                                      .copyWith(
                                color: AppColors
                                    .secondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (isAuthority)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: CustomButton.gradient(
                                  label: 'Create Group',
                                  onPressed: () {
                                    _showCreateGroupDialog(
                                      context,
                                      groupsController,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets
                            .symmetric(
                          horizontal: 12,
                        ),
                        itemCount:
                            filteredGroups.length,
                        itemBuilder:
                            (context, index) {
                          final group =
                              filteredGroups[index];

                          return _buildGroupCard(
                            context,
                            group,
                            groupsController,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isAuthority
          ? FloatingActionButton.extended(
              onPressed: () {
                _showCreateGroupDialog(
                  context,
                  Provider.of<GroupsController>(
                    context,
                    listen: false,
                  ),
                );
              },
              label: const Text('New Group'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.accentBlue,
            )
          : null,
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _filterType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accentBlue
                : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? Colors.white
                : colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    var group,
    GroupsController groupsController,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            await groupsController
                .selectGroup(group.id);
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupDetailScreen(groupId: group.id),
                ),
              );
            }
          },
          onLongPress: () async {
            await groupsController
                .selectGroup(group.id);
            if (mounted) {
              Navigator.pushNamed(
                context,
                AppRoutes.groupChat,
                arguments: group.id,
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            group.name,
                            style: AppTextStyles
                                .titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow
                                .ellipsis,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            group
                                .getLastActivityText(),
                            style:
                                AppTextStyles
                                    .caption
                                    .copyWith(
                              color: AppColors
                                  .secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: group.isFamily
                            ? Colors.blue
                                .withOpacity(0.2)
                            : Colors.purple
                                .withOpacity(0.2),
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                      child: Text(
                        group.type
                            .toUpperCase(),
                        style:
                            AppTextStyles
                                .caption
                                .copyWith(
                          color: group
                                  .isFamily
                              ? Colors.blue
                              : Colors.purple,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  group.description,
                  style:
                      AppTextStyles.bodySmall
                          .copyWith(
                    color: AppColors
                        .secondary,
                  ),
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Stats
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color:
                              AppColors.muted,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${group.memberCount} members',
                          style:
                              AppTextStyles
                                  .caption
                                  .copyWith(
                            color: AppColors
                                .secondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons
                              .chat_bubble_outline,
                          size: 14,
                          color:
                              AppColors.muted,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          '${group.messages} msgs',
                          style:
                              AppTextStyles
                                  .caption
                                  .copyWith(
                            color: AppColors
                                .secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog(
    BuildContext context,
    GroupsController groupsController,
  ) {
    final authController = context.read<AuthController>();
    final isAuthority = authController.currentUser?.role == UserRole.admin;

    if (!isAuthority) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only authority can create groups')),
      );
      return;
    }

    final nameController = TextEditingController();
    final descController =
        TextEditingController();
    String selectedType = 'official';
    final Set<String> selectedMembers = <String>{};
    String? selectedPersonnelId;
    int requestedMembers = 0;

    groupsController.loadMemberCandidatesForType(selectedType);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Create New Group',
            style: AppTextStyles.titleSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: [
                    const DropdownMenuItem(
                      value: 'official',
                      child: Text('Official (Authority)'),
                    ),
                    const DropdownMenuItem(
                      value: 'family',
                      child: Text('Family (Authority)'),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    selectedType = value;
                    selectedMembers.clear();
                    selectedPersonnelId = null;
                    requestedMembers = 0;
                    setDialogState(() {});
                    await groupsController.loadMemberCandidatesForType(selectedType);
                    if (!context.mounted) return;
                    setDialogState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Group Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (selectedType == 'official') ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'How many people to add?',
                      hintText: 'Enter number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value.trim()) ?? 0;
                      requestedMembers = parsed < 0 ? 0 : parsed;
                      setDialogState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                Consumer<GroupsController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading && controller.memberCandidates.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (controller.memberCandidates.isEmpty) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No personnel available.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                        ),
                      );
                    }

                    if (selectedType == 'family') {
                      selectedPersonnelId ??= controller.memberCandidates.first['id'];

                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedPersonnelId,
                            decoration: InputDecoration(
                              labelText: 'Personnel',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: controller.memberCandidates
                                .map(
                                  (candidate) => DropdownMenuItem<String>(
                                    value: candidate['id'],
                                    child: Text(candidate['name'] ?? 'Unknown'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPersonnelId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Dependents linked to the selected personnel are added automatically.',
                              style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                            ),
                          ),
                        ],
                      );
                    }

                    final maxAllowed = requestedMembers <= 0
                        ? controller.memberCandidates.length
                        : requestedMembers;

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.memberCandidates.length,
                        itemBuilder: (context, index) {
                          final candidate = controller.memberCandidates[index];
                          final id = candidate['id'] ?? '';
                          final isChecked = selectedMembers.contains(id);
                          final selectionFull = !isChecked && selectedMembers.length >= maxAllowed;

                          return CheckboxListTile(
                            dense: true,
                            value: isChecked,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(candidate['name'] ?? 'Unknown'),
                            subtitle: Text((candidate['role'] ?? '').toUpperCase()),
                            onChanged: selectionFull
                                ? null
                                : (checked) {
                                    setDialogState(() {
                                      if (checked == true) {
                                        selectedMembers.add(id);
                                      } else {
                                        selectedMembers.remove(id);
                                      }
                                    });
                                  },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (selectedType == 'official' && name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group name is required for official groups')),
                  );
                  return;
                }

                if (selectedType == 'family' && (selectedPersonnelId == null || selectedPersonnelId!.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a personnel for the family group')),
                  );
                  return;
                }

                final selectedIds = selectedMembers.toList();
                final ok = await groupsController.createGroup(
                  name,
                  descController.text.trim(),
                  selectedType,
                  personnelId: selectedPersonnelId,
                  selectedMemberIds: selectedIds,
                );

                if (!context.mounted) return;
                Navigator.pop(context);

                final message = ok
                    ? 'Group created successfully'
                    : (groupsController.error ?? 'Failed to create group');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
