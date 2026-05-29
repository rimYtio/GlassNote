import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'lifecycle/app_lock_gate.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: AppLockGate(child: GlassNoteApp()),
    ),
  );
}
