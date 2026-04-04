import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../controllers/admin_controller.dart';

/// Manage Personnel Screen - View and manage personnel accounts
class ManagePersonnelScreen extends StatefulWidget {
  const ManagePersonnelScreen({Key? key}) : super(key: key);

  @override
  State<ManagePersonnelScreen> createState() =>
      _ManagePersonnelScreenState();
}

class _ManagePersonnelScreenState extends State<ManagePersonnelScreen> {
  String _filterStatus = 'all'; // all, active, suspended
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Personnel Management',
      appBar: CustomAppBar.standard(
        title: 'Personnel Management',
        context: context,
        subtitle: 'Manage personnel accounts and access',
      ),
      body: Consumer<AdminController>(
        builder: (context, adminController, _) {
          // Filter personnel
          final filteredPersonnel = adminController.personnelRecords
              .where((p) {
                final statusMatch =
                    _filterStatus == 'all' ||
                        p.status == _filterStatus;
                final searchMatch =
                    _searchController.text.isEmpty ||
                        p.name.toLowerCase().contains(
                            _searchController.text
                                .toLowerCase()) ||
                        p.email.toLowerCase().contains(
                            _searchController.text
                                .toLowerCase());
                return statusMatch && searchMatch;
              })
              .toList();

          return Column(
            children: [
              if (adminController.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    adminController.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                  ),
                ),

              // Search and filter
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _searchController,
                      label: 'Search personnel',
                      hint: 'Name or Member ID...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    const SizedBox(height: 12),
                    // Status filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('active', 'Active'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'suspended',
                            'Suspended',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Personnel list
              Expanded(
                child: adminController.isLoading && adminController.personnelRecords.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPersonnel.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No personnel found',
                              style:
                                  AppTextStyles.titleSmall
                                      .copyWith(
                                color: AppColors
                                    .secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        itemCount:
                            filteredPersonnel.length,
                        itemBuilder: (context, index) {
                          final personnel =
                              filteredPersonnel[index];

                          return _buildPersonnelCard(
                            context,
                            personnel,
                            adminController,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterStatus == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = value;
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
              : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accentBlue
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? Colors.white
                : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonnelCard(
    BuildContext context,
    var personnel,
    AdminController adminController,
  ) {
    final statusColor = personnel.status == 'active'
        ? Colors.green
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              AvatarWidget(
                name: personnel.name,
                size: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      personnel.name,
                      style:
                          AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      personnel.email,
                      style:
                          AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Text(
                  personnel.status.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Days Active',
                    '${personnel.daysActive} days'),
                const SizedBox(height: 6),
                _buildDetailRow('Last Active',
                    personnel.getLastActiveText()),
                const SizedBox(height: 6),
                _buildDetailRow(
                  'Joined',
                  personnel.joinedAt
                      .toString()
                      .split(' ')[0],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              if (personnel.status == 'active')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showSuspendDialog(
                        context,
                        personnel,
                        adminController,
                      );
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text('Suspend'),
                    style: ElevatedButton
                        .styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await adminController
                          .activatePersonnel(
                              personnel.id);
                      if (!mounted) return;
                      if (adminController.errorMessage == null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${personnel.name} activated',
                            ),
                            backgroundColor:
                                Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              adminController.errorMessage!,
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                        Icons.check_circle),
                    label:
                        const Text('Activate'),
                    style: ElevatedButton
                        .styleFrom(
                      backgroundColor:
                          Colors.green,
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showDetailsDialog(
                      context,
                      personnel,
                    );
                  },
                  icon: const Icon(Icons.info),
                  label: const Text('Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.accentBlue,
                    foregroundColor:
                        Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showSuspendDialog(
    BuildContext context,
    var personnel,
    AdminController adminController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Suspend Personnel?',
          style: AppTextStyles.titleSmall,
        ),
        content: Text(
          'Are you sure you want to suspend ${personnel.name}? They will lose access to the app.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await adminController
                  .suspendPersonnel(
                personnel.id,
                'Admin suspension',
              );
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '${personnel.name} suspended',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Suspend',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context,
    var personnel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          personnel.name,
          style: AppTextStyles.titleSmall,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildDialogDetailRow(
                'Member ID',
                personnel.email,
              ),
              const SizedBox(height: 8),
              _buildDialogDetailRow(
                'User ID',
                personnel.id,
              ),
              const SizedBox(height: 8),
              _buildDialogDetailRow(
                'Status',
                personnel.status,
              ),
              const SizedBox(height: 8),
              _buildDialogDetailRow(
                'Days Active',
                '${personnel.daysActive} days',
              ),
              const SizedBox(height: 8),
              _buildDialogDetailRow(
                'Last Active',
                personnel
                    .getLastActiveText(),
              ),
              const SizedBox(height: 8),
              _buildDialogDetailRow(
                'Joined',
                personnel.joinedAt
                    .toString()
                    .split(' ')[0],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogDetailRow(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
