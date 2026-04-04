import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/badge_widget.dart';
// import '../widgets/drawer_menu.dart'; // File does not exist
// import '../controllers/home_controller.dart'; // File does not exist

/// Dependent Home Screen - Home dashboard for dependent users
class DependentHomeScreen extends StatefulWidget {
  const DependentHomeScreen({Key? key}) : super(key: key);

  @override
  State<DependentHomeScreen> createState() => _DependentHomeScreenState();
}

class _DependentHomeScreenState extends State<DependentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Dependent Dashboard',
      appBar: _buildAppBar(),
      drawer: null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            _buildWelcomeCard(),

            const SizedBox(height: 20),

            // Guardian info card
            _buildGuardianCard(),

            const SizedBox(height: 28),

            // Quick actions section (limited for dependents)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Quick Actions',
                style: AppTextStyles.titleSmall,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(),

            const SizedBox(height: 28),

            // Recent messages section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Messages',
                style: AppTextStyles.titleSmall,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentMessages(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.card,
      elevation: 0,
      automaticallyImplyLeading: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: AppTextStyles.titleSmall,
          ),
          Text(
            'Restricted Access',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              color: AppColors.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: CountBadge(
                count: 0,
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Limited Access Mode',
            style: AppTextStyles.titleSmall.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As a dependent, you have limited access to app features. Contact your guardian for more information.',
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardianCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Guardian',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AvatarWidget(
                name: 'John Doe',
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Active now',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.message),
                color: AppColors.accentBlue,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.chatScreen);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Messages button
          _buildActionButton(
            icon: Icons.message,
            label: 'Messages',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.chatList);
            },
          ),

          const SizedBox(width: 12),

          // Groups button
          _buildActionButton(
            icon: Icons.group,
            label: 'Family Groups',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.groupList);
            },
          ),

          const SizedBox(width: 12),

          // Profile button
          _buildActionButton(
            icon: Icons.person,
            label: 'Profile',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),

          const SizedBox(width: 12),

          // Settings button
          _buildActionButton(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.accentBlue,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.captionMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMessages() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('Recent messages placeholder')),
    );
  }
}

/// Dependent Status Widget - Shows access status
class DependentStatusWidget extends StatelessWidget {
  const DependentStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are using the app in dependent mode',
              style: AppTextStyles.caption.copyWith(
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
