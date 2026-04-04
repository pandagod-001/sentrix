import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';

/// Role Layout - Enforces role-based content visibility
class RoleLayout extends StatelessWidget {
  final Widget child;
  final UserRole? userRole; // Can be overridden for testing

  const RoleLayout({
    Key? key,
    required this.child,
    this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In a real app, you would get the current user role from auth provider
    // For now, we just pass through child widget
    // Role checking is done at route level via route_guard.dart

    return child;
  }
}

/// Overlay for restricted features
class RestrictedFeatureOverlay extends StatelessWidget {
  final bool isRestricted;
  final Widget child;
  final String? restrictionMessage;

  const RestrictedFeatureOverlay({
    Key? key,
    required this.isRestricted,
    required this.child,
    this.restrictionMessage = 'Feature not available for your role',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isRestricted) {
      return child;
    }

    return Stack(
      children: [
        Opacity(
          opacity: 0.5,
          child: child,
        ),
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    restrictionMessage ?? 'Feature not available',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Conditional widget based on role
class RoleBasedWidget extends StatelessWidget {
  final UserRole currentUserRole;
  final Widget child;
  final List<UserRole> allowedRoles;
  final Widget? deniedWidget;

  const RoleBasedWidget({
    Key? key,
    required this.currentUserRole,
    required this.child,
    required this.allowedRoles,
    this.deniedWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAllowed = allowedRoles.contains(currentUserRole);

    if (isAllowed) {
      return child;
    }

    return deniedWidget ?? const SizedBox.shrink();
  }
}

/// Visibility toggle based on role
class VisibleIfRole extends StatelessWidget {
  final UserRole currentUserRole;
  final List<UserRole> visibleRoles;
  final Widget child;

  const VisibleIfRole({
    Key? key,
    required this.currentUserRole,
    required this.visibleRoles,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isVisible = visibleRoles.contains(currentUserRole);
    return isVisible ? child : const SizedBox.shrink();
  }
}
