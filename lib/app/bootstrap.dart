import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/database/app_database.dart';
import '../infrastructure/notifications/local_notification_service.dart';
import '../infrastructure/providers/infrastructure_providers.dart';
import 'app.dart';
import 'lifecycle/app_lock_gate.dart';

void bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = await LocalNotificationService.create();

  // Re-register all pending reminders from the database
  final database = AppDatabase();
  await notificationService.reschedule(
    () => database.remindersDao.listPending(),
  );

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        localNotificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const AppLockGate(child: GlassNoteApp()),
    ),
  );
}
