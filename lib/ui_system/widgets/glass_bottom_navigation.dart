import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBottomNavigation extends StatelessWidget {
  const GlassBottomNavigation({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: SizedBox(
          height: 78,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(200, 225, 252, 0.28),
                        Color.fromRGBO(0, 0, 0, 0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: DecoratedBox(
                    key: const ValueKey('glass-bottom-navigation-surface'),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(
                        alpha: isLight ? 0.55 : 0.45,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.08),
                          blurRadius: 32,
                          offset: const Offset(0, -4),
                        ),
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      for (var index = 0; index < _destinations.length; index++)
                        Expanded(
                          child: _GlassNavItem(
                            index: index,
                            destination: _destinations[index],
                            selected: currentIndex == index,
                            onTap: () => onTap(index),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.index,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final _NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface.withValues(alpha: 0.78);

    return Semantics(
      button: true,
      selected: selected,
      label: '${destination.label}\nTab ${index + 1} of 4',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            key: ValueKey('nav-pill-$index'),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            width: selected ? 88 : 58,
            height: selected ? 62 : 58,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
                color: selected
                    ?                     colorScheme.primaryContainer.withValues(alpha: 0.65)
                    : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: selected
                  ? Border.all(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.10,
                      ),
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 22,
                  color: foreground,
                ),
                const SizedBox(height: 4),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _NavDestination(label: '捕获', icon: Icons.mic_none, selectedIcon: Icons.mic),
  _NavDestination(
    label: '笔记',
    icon: Icons.note_alt_outlined,
    selectedIcon: Icons.note_alt,
  ),
  _NavDestination(
    label: '时间线',
    icon: Icons.timeline_outlined,
    selectedIcon: Icons.timeline,
  ),
  _NavDestination(
    label: '设置',
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune,
  ),
];
