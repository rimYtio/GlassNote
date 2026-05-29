import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui_system/widgets/glass_bottom_navigation.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int get _currentIndex => widget.navigationShell.currentIndex;

  void _onTabTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == _currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: GlassBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
