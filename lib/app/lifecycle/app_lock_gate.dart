import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/presentation/lock_screen.dart';
import '../../infrastructure/providers/infrastructure_providers.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialLock();
  }

  Future<void> _checkInitialLock() async {
    try {
      final service = ref.read(appLockServiceProvider);
      final enabled = await service.isEnabled();
      if (enabled && mounted) {
        setState(() => _isLocked = true);
      }
    } catch (_) {
      // App lock check failed, allow access
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed &&
        _backgroundedAt != null) {
      final elapsed = DateTime.now().difference(_backgroundedAt!);
      if (elapsed.inSeconds > 60) {
        _checkLock();
      }
    }
  }

  Future<void> _checkLock() async {
    try {
      final service = ref.read(appLockServiceProvider);
      final enabled = await service.isEnabled();
      if (enabled && mounted) {
        setState(() => _isLocked = true);
      }
    } catch (_) {
      // Lock check failed, allow access
    }
  }

  void _onUnlocked() {
    setState(() => _isLocked = false);
    _backgroundedAt = null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        widget.child,
        if (_isLocked)
          Positioned.fill(
            child: LockScreen(onUnlocked: _onUnlocked),
          ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
