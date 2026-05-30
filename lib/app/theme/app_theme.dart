import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7C6FF7),
        brightness: Brightness.light,
      ).copyWith(
        surfaceContainerLowest: const Color(0xFFF8F6FF),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFE0ECF5),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7C6FF7),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0F1118),
    );
  }
}

extension AppThemeModeMaterial on AppThemeMode {
  ThemeMode get materialThemeMode {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }
}
