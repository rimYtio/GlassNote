import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/presentation/settings_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class GlassNoteApp extends ConsumerWidget {
  const GlassNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
