import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/services/service_locator.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/device_verify_screen.dart';
import 'features/auth/screens/face_auth_screen.dart';
import 'features/auth/screens/pending_approval_screen.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/home/screens/role_dashboard_screen.dart';
import 'features/chat/controllers/chat_controller.dart';
import 'features/chat/screens/chat_list_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/groups/controllers/groups_controller.dart';
import 'features/groups/screens/group_list_screen.dart';
import 'features/groups/screens/create_group_screen.dart';
import 'features/groups/screens/group_chat_screen.dart';
import 'features/qr/controllers/qr_controller.dart';
import 'features/qr/screens/qr_display_screen.dart';
import 'features/qr/screens/qr_scan_screen.dart';
import 'features/qr/screens/unique_code_screen.dart';
import 'features/admin/controllers/admin_controller.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/admin/screens/authority_face_scan_screen.dart';
import 'features/settings/controllers/settings_controller.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/profile_screen.dart';
import 'features/notifications/controllers/notification_controller.dart';
import 'features/error/screens/not_found_screen.dart';
import 'services/auth_service.dart';
import 'services/network_monitor.dart';

void main() async {
  // Initialize service locator
  final serviceLocator = ServiceLocator();
  await serviceLocator.initialize();
  
  runApp(const SentrixApp());
}

class SentrixApp extends StatelessWidget {
  const SentrixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Controllers
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => ChatController()),
        ChangeNotifierProvider(create: (_) => GroupsController()),
        ChangeNotifierProvider(create: (_) => QRController()),
        ChangeNotifierProvider(create: (_) => AdminController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ConnectionStatusProvider()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, _, __) => MaterialApp(
          title: AppStrings.appName,
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: _onGenerateRoute,
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(
                  child: Text('Route not found'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Route generator for named routes
  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    
    switch (uri.path) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case AppRoutes.deviceVerify:
        return MaterialPageRoute(
          builder: (_) => const DeviceVerifyScreen(),
          settings: settings,
        );
      case AppRoutes.faceAuth:
        return MaterialPageRoute(
          builder: (_) => const FaceAuthScreen(),
          settings: settings,
        );
      case AppRoutes.pendingApproval:
        return MaterialPageRoute(
          builder: (_) => const PendingApprovalScreen(),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const RoleDashboardScreen(),
          settings: settings,
        );
      case AppRoutes.chatList:
        return MaterialPageRoute(
          builder: (_) => const ChatListScreen(),
          settings: settings,
        );
      case AppRoutes.chatScreen:
        final chatId = settings.arguments is String ? settings.arguments as String : null;
        if (chatId == null || chatId.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const ChatListScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: chatId),
          settings: settings,
        );
      case AppRoutes.groupList:
        return MaterialPageRoute(
          builder: (_) => const GroupListScreen(),
          settings: settings,
        );
      case AppRoutes.createGroup:
        return MaterialPageRoute(
          builder: (_) => const CreateGroupScreen(),
          settings: settings,
        );
      case AppRoutes.groupChat:
        final groupId = settings.arguments is String ? settings.arguments as String : null;
        if (groupId == null || groupId.isEmpty) {
          return MaterialPageRoute(
            builder: (_) => const GroupListScreen(),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(groupId: groupId, groupName: 'Group Chat'),
          settings: settings,
        );
      case AppRoutes.qrDisplay:
        return MaterialPageRoute(
          builder: (_) => const QRDisplayScreen(),
          settings: settings,
        );
      case AppRoutes.qrScan:
        return MaterialPageRoute(
          builder: (_) => const QRScanScreen(),
          settings: settings,
        );
      case AppRoutes.uniqueCode:
        return MaterialPageRoute(
          builder: (_) => const UniqueCodeScreen(),
          settings: settings,
        );
      case AppRoutes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
          settings: settings,
        );
      case AppRoutes.authorityFaceScan:
        return MaterialPageRoute(
          builder: (_) => const AuthorityFaceScanScreen(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}
