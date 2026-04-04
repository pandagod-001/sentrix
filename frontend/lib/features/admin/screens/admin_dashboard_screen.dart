import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_stat_card.dart';

/// Admin Dashboard Screen - Main admin control panel
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false)
          .refreshAdminData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Authority Dashboard',
      appBar: CustomAppBar.standard(
        title: 'Authority Dashboard',
        context: context,
        subtitle: 'System control, approvals, and groups',
      ),
      body: Consumer<AdminController>(
        builder: (context, adminController, _) {
          if (adminController.isLoading) {
            return const Center(
              child: const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final stats = adminController.stats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics cards
                if (stats != null) ...[
                  Text(
                    'System Statistics',
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  _buildStatsGrid(stats),
                  const SizedBox(height: 28),
                ],

                // Quick action buttons
                Text(
                  'Quick Actions',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 12),
                _buildQuickActions(context, adminController),

                const SizedBox(height: 28),

                // Pending approvals section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pending Approvals',
                      style: AppTextStyles.titleSmall,
                    ),
                    if (adminController.pendingApprovals.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${adminController.pendingApprovals.length}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPendingApprovalsPreview(
                  context,
                  adminController,
                ),

                const SizedBox(height: 28),

                Text(
                  'Recent Face Scans',
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 12),
                _buildFaceScansPreview(adminController),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(AdminStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        AdminStatCard(
          label: 'Total Users',
          value: stats.totalUsers.toString(),
          icon: Icons.people,
          color: AppColors.accentBlue,
        ),
        AdminStatCard(
          label: 'Active Users',
          value: stats.activeUsers.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        AdminStatCard(
          label: 'Pending Approvals',
          value: stats.pendingApprovals.toString(),
          icon: Icons.hourglass_empty,
          color: Colors.orange,
          highlighted: stats.pendingApprovals > 0,
        ),
        AdminStatCard(
          label: 'Total Groups',
          value: stats.totalGroups.toString(),
          icon: Icons.group_work,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    AdminController adminController,
  ) {
    return Column(
      children: [
        CustomButton.outline(
          label: 'Scan Face',
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.authorityFaceScan);
          },
          icon: const Icon(Icons.face_retouching_natural),
        ),
        const SizedBox(height: 12),
        CustomButton.gradient(
          label: 'Manage Approvals',
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.managePersonnel,
            );
          },
          icon: Icon(Icons.done_all),
        ),
        const SizedBox(height: 12),
        CustomButton.outline(
          label: 'Manage Personnel',
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.managePersonnel,
            );
          },
          icon: Icon(Icons.people),
        ),
        const SizedBox(height: 12),
        CustomButton.outline(
          label: 'View System Health',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All systems operational'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: Icon(Icons.health_and_safety),
        ),
      ],
    );
  }

  Widget _buildPendingApprovalsPreview(
    BuildContext context,
    AdminController adminController,
  ) {
    final pendingList = adminController.pendingApprovals
        .where((apr) => apr.status == 'pending')
        .take(3)
        .toList();

    if (pendingList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'All pending approvals processed!',
              style: AppTextStyles.body.copyWith(
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(pendingList.length, (index) {
        final approval = pendingList[index];

        return _buildApprovalItem(context, approval, adminController);
      }),
    );
  }

  Widget _buildFaceScansPreview(AdminController adminController) {
    final scans = adminController.faceScans;

    if (scans.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No face scans recorded yet.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
        ),
      );
    }

    return Column(
      children: scans.map((scan) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scan.allowed ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  scan.allowed ? Icons.verified_user : Icons.block,
                  color: scan.allowed ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.matchedUserName != null ? '${scan.matchedUserName} (${scan.matchedUserRole ?? 'unknown'})' : 'No match found',
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scanned by ${scan.scannedByName ?? 'unknown'}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                    ),
                    if (scan.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        scan.createdAt!.toIso8601String().substring(0, 19).replaceFirst('T', ' '),
                        style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                scan.statusText,
                style: AppTextStyles.caption.copyWith(
                  color: scan.allowed ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApprovalItem(
    BuildContext context,
    var approval,
    AdminController adminController,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approval.userName,
                      style: AppTextStyles.bodySmall,
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
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  approval.userRole.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await adminController
                        .approveUser(approval.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            '${approval.userName} approved',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await adminController.rejectUser(
                      approval.id,
                      'Rejected by admin',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            '${approval.userName} rejected',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
