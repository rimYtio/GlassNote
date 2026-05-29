import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/notifications/local_notification_service.dart';
import '../infrastructure/providers/infrastructure_providers.dart';
import 'app.dart';
import 'lifecycle/app_lock_gate.dart';

void bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = await LocalNotificationService.create();

  runApp(
    ProviderScope(
      overrides: [
        localNotificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const AppLockGate(child: GlassNoteApp()),
    ),
  );
}
