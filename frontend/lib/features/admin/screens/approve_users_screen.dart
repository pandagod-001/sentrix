import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../controllers/admin_controller.dart';

/// Approve Users Screen - View and manage pending user approvals
class ApproveUsersScreen extends StatefulWidget {
  const ApproveUsersScreen({Key? key}) : super(key: key);

  @override
  State<ApproveUsersScreen> createState() => _ApproveUsersScreenState();
}

class _ApproveUsersScreenState extends State<ApproveUsersScreen> {
  String _filterStatus = 'pending'; // pending, approved, rejected
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
      title: 'Approvals',
      appBar: CustomAppBar.standard(
        title: 'Approvals',
        context: context,
        subtitle: 'Review and manage access requests',
      ),
      body: Consumer<AdminController>(
        builder: (context, adminController, _) {
          // Filter approvals based on status
          final filteredApprovals = adminController.pendingApprovals
              .where((apr) {
                final statusMatch = _filterStatus == 'all' ||
                    apr.status == _filterStatus;
                final searchMatch =
                    _searchController.text.isEmpty ||
                        apr.userName.toLowerCase().contains(
                            _searchController.text.toLowerCase()) ||
                        apr.userEmail.toLowerCase().contains(
                            _searchController.text.toLowerCase());
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
                      label: 'Search approvals',
                      hint: 'Name or Member ID...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    const SizedBox(height: 12),
                    // Status tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'All'),
                          const SizedBox(width: 8),
                          _buildFilterChip('pending', 'Pending'),
                          const SizedBox(width: 8),
                          _buildFilterChip('approved', 'Approved'),
                          const SizedBox(width: 8),
                          _buildFilterChip('rejected', 'Rejected'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Approvals list
              Expanded(
                child: adminController.isLoading && adminController.pendingApprovals.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredApprovals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              _filterStatus == 'pending'
                                  ? Icons.done_all
                                  : Icons.search_off,
                              size: 64,
                              color: AppColors.muted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${_filterStatus == 'all' ? 'requests' : _filterStatus} requests',
                              style:
                                  AppTextStyles.titleSmall
                                      .copyWith(
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        itemCount: filteredApprovals.length,
                        itemBuilder: (context, index) {
                          final approval =
                              filteredApprovals[index];

                          return _buildApprovalCard(
                            context,
                            approval,
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

  Widget _buildApprovalCard(
    BuildContext context,
    var approval,
    AdminController adminController,
  ) {
    final statusColor = approval.status == 'pending'
        ? Colors.orange
        : approval.status == 'approved'
            ? Colors.green
            : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
        boxShadow: AppColors.softShadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Status
          Row(
            children: [
              AvatarWidget(
                name: approval.userName,
                size: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approval.userName,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      approval.userEmail,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  approval.status.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Role and request details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Role',
                  approval.userRole.toUpperCase(),
                ),
                const SizedBox(height: 6),
                _buildDetailRow(
                  'Requested At',
                  approval.requestedAt.toString().split('.')[0],
                ),
                const SizedBox(height: 6),
                _buildDetailRow(
                  'Reason',
                  approval.reason,
                ),
              ],
            ),
          ),

          // Action buttons (only if pending)
          if (approval.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton.gradient(
                    label: 'Approve',
                    onPressed: () async {
                      final approved = await adminController.approveUser(approval.id);
                      if (!mounted) return;
                      if (approved) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              '${approval.userName} approved successfully',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(
                              seconds: 2,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              adminController.errorMessage ?? 'Approval failed',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.check),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showRejectDialog(
                        context,
                        approval,
                        adminController,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(
    BuildContext context,
    var approval,
    AdminController adminController,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Reject Application?',
          style: AppTextStyles.titleSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rejecting ${approval.userName}\'s application',
              style:
                  AppTextStyles.body.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Reason for rejection (optional)',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
              style: AppTextStyles.body,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final rejected = await adminController.rejectUser(
                approval.id,
                reasonController.text
                    .isNotEmpty
                    ? reasonController.text
                    : 'Application rejected',
              );
              if (!mounted) return;
              if (rejected) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '${approval.userName} application rejected',
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(
                      seconds: 2,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      adminController.errorMessage ?? 'Rejection failed',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Reject',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
