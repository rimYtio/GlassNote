import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/settings_controller.dart';
import '../infrastructure/notifications/local_notification_service.dart';
import '../infrastructure/providers/infrastructure_providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class GlassNoteApp extends ConsumerStatefulWidget {
  const GlassNoteApp({super.key});

  @override
  ConsumerState<GlassNoteApp> createState() => _GlassNoteAppState();
}

class _GlassNoteAppState extends ConsumerState<GlassNoteApp> {
  @override
  void initState() {
    super.initState();
    _listenForNotificationTaps();
  }

  void _listenForNotificationTaps() {
    final notificationService = ref.read(localNotificationServiceProvider);
    notificationService.onNotificationTap.listen((NotificationPayload payload) {
      final router = ref.read(appRouterProvider);
      if (payload.targetType == 'note') {
        router.go('/notes/${payload.targetId}/edit');
      } else if (payload.targetType == 'schedule') {
        router.go('/timeline');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: 'GlassNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.when(
        data: (value) => value.themeMode.materialThemeMode,
        error: (error, stackTrace) => ThemeMode.system,
        loading: () => ThemeMode.system,
      ),
      routerConfig: router,
    );
  }
}
