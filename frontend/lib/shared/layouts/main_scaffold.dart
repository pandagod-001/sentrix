import 'package:flutter/material.dart';
import 'role_layout.dart';

/// Main Scaffold Layout - Base layout for authenticated screens
class MainScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Widget>? actions;
  final bool showRoleLayout;

  const MainScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.floatingActionButtonLocation,
    this.actions,
    this.showRoleLayout = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      body: body,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );

    // Wrap with role layout if needed (for role-based content filtering)
    if (showRoleLayout) {
      content = RoleLayout(child: content);
    }

    return content;
  }
}

/// Simple scaffold without app bar
class SimpleScaffold extends StatelessWidget {
  final Widget body;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const SimpleScaffold({
    Key? key,
    required this.body,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
