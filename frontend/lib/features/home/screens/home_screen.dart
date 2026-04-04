import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/layouts/main_scaffold.dart';
import '../controllers/home_controller.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/home_appbar.dart';

/// Home Screen - Main dashboard after authentication
class HomeScreen extends StatefulWidget {
  final UserRole? userRole;
  final String? userName;

  const HomeScreen({
    super.key,
    this.userRole,
    this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = HomeController();
  }

  void _handleLogout() {
    context.read<AuthController>().logout();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userRole = widget.userRole ?? UserRole.personnel;
    final authUserName = context.select<AuthController, String?>(
      (controller) => controller.currentUser?.name,
    );
    final userName = (widget.userName?.trim().isNotEmpty ?? false)
        ? widget.userName!.trim()
        : (authUserName?.trim().isNotEmpty ?? false)
            ? authUserName!.trim()
            : 'User';

    return ChangeNotifierProvider.value(
      value: _homeController,
      child: Consumer<HomeController>(
        builder: (context, homeController, _) {
          final subtitle = homeController.recentChats.isEmpty
              ? 'No conversations yet'
              : '${homeController.totalChats} active chat${homeController.totalChats == 1 ? '' : 's'}';

          return MainScaffold(
            title: 'Personnel Dashboard',
            appBar: HomeAppBar(
              userName: userName,
              subtitle: subtitle,
              notificationCount: homeController.totalChats,
              onNotificationTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      homeController.totalChats == 0
                          ? 'No conversations yet'
                          : 'Showing ${homeController.totalChats} chat${homeController.totalChats == 1 ? '' : 's'}',
                    ),
                  ),
                );
              },
            ),
            drawer: DrawerMenu(
              userName: userName,
              userRole: userRole,
              onLogout: _handleLogout,
            ),
            body: RefreshIndicator(
              onRefresh: homeController.refreshData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Quick Access',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (userRole == UserRole.personnel)
                          _buildFeatureCard(
                            title: 'Scan QR',
                            subtitle: 'Scan and connect',
                            icon: Icons.qr_code_scanner_outlined,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.qrScan),
                          ),
                        if (userRole == UserRole.personnel)
                          _buildFeatureCard(
                            title: 'Generate QR',
                            subtitle: 'Share your code',
                            icon: Icons.qr_code_2_outlined,
                            onTap: () => Navigator.of(context).pushNamed(AppRoutes.qrDisplay),
                          ),
                        _buildFeatureCard(
                          title: 'Chats',
                          subtitle: 'Open all messages',
                          icon: Icons.chat_bubble_outline,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.chatList),
                        ),
                        _buildFeatureCard(
                          title: 'Groups',
                          subtitle: 'See all your groups',
                          icon: Icons.groups_outlined,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.groupList),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your Messages',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    if (homeController.topRecentChats.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Text(
                          'No messages yet. Start chatting to see your recent conversations.',
                          style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    else
                      Column(
                        children: homeController.topRecentChats.map((chat) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).pushNamed(AppRoutes.chatList),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: colorScheme.outlineVariant),
                                  boxShadow: AppColors.softShadowSmall,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.account_circle_outlined,
                                      color: AppColors.accentBlue,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            chat.participantName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            chat.lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.caption.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.muted,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Personnel',
                          style: AppTextStyles.titleSmall,
                        ),
                        if (homeController.availableUsers.isNotEmpty)
                          Text(
                            '${homeController.availableUsers.length} online',
                            style: AppTextStyles.caption.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (homeController.isLoadingUsers)
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      )
                    else if (homeController.availableUsers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Text(
                          'No personnel available',
                          style: AppTextStyles.caption.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      )
                    else
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: homeController.availableUsers.length,
                          itemBuilder: (context, index) {
                            final user = homeController.availableUsers[index];
                            return Padding(
                              padding: EdgeInsets.only(right: index == homeController.availableUsers.length - 1 ? 0 : 12),
                              child: GestureDetector(
                                onTap: () async {
                                  final chatId = await homeController.createChatWithUser(user.id);
                                  if (chatId != null && mounted) {
                                    if (mounted) {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.chatScreen,
                                        arguments: chatId,
                                      );
                                    }
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [AppColors.accentBlue, AppColors.accentPurple],
                                        ),
                                        boxShadow: AppColors.softShadowSmall,
                                      ),
                                      child: user.avatar != null
                                          ? ClipOval(
                                              child: Image.network(
                                                user.avatar!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: Text(
                                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                                style: AppTextStyles.titleSmall.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 70,
                                      child: Text(
                                        user.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.caption,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadowSmall,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accentBlue, size: 24),
              const SizedBox(height: 10),
              Text(title, style: AppTextStyles.titleSmall),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
