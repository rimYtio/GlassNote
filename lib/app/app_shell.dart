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
  int _previousIndex = 0;

  int get _currentIndex => widget.navigationShell.currentIndex;

  void _onTabTap(int index) {
    if (index != _currentIndex) {
      _previousIndex = _currentIndex;
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == _currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          final slideCurve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slideDirection = _currentIndex > _previousIndex ? 1.0 : -1.0;
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.12 * slideDirection, 0),
              end: Offset.zero,
            ).animate(slideCurve),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: GlassBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}
