import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_enums.dart';
import '../../../models/user_model.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../dependent/screens/dependent_home_screen.dart';
import 'home_screen.dart';

class RoleDashboardScreen extends StatelessWidget {
  const RoleDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthController, User?>((controller) => controller.currentUser);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (user.role) {
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.personnel:
        return HomeScreen(
          userRole: UserRole.personnel,
          userName: user.name,
        );
      case UserRole.dependent:
        return const DependentHomeScreen();
    }
  }
}