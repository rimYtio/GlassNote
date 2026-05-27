import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/entities/app_settings.dart';

void main() {
  test('creates default app settings for a local-first install', () {
    final now = DateTime(2026, 5, 27, 9);

    final settings = AppSettings.defaults(now: now);

    expect(settings.id, AppSettings.defaultId);
    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.themeColor, '#5B6CFF');
    expect(settings.enableAppLock, isFalse);
    expect(settings.autoTranscribeVoice, isFalse);
    expect(settings.defaultFolderId, 'inbox');
    expect(settings.exportIncludeMetadata, isTrue);
    expect(settings.createdAt, now);
    expect(settings.updatedAt, now);
  });

  test('copies app settings with a new theme mode', () {
    final createdAt = DateTime(2026, 5, 27, 9);
    final updatedAt = DateTime(2026, 5, 27, 10);
    final settings = AppSettings.defaults(now: createdAt);

    final copied = settings.copyWith(
      themeMode: AppThemeMode.dark,
      updatedAt: updatedAt,
    );

    expect(copied.id, settings.id);
    expect(copied.themeMode, AppThemeMode.dark);
    expect(copied.createdAt, createdAt);
    expect(copied.updatedAt, updatedAt);
  });
}
