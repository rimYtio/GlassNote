enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromStorageValue(String value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

class AppSettings {
  const AppSettings({
    required this.id,
    required this.themeMode,
    required this.themeColor,
    required this.enableAppLock,
    required this.autoTranscribeVoice,
    required this.defaultFolderId,
    required this.exportIncludeMetadata,
    required this.createdAt,
    required this.updatedAt,
  });

  static const defaultId = 'default';

  final String id;
  final AppThemeMode themeMode;
  final String themeColor;
  final bool enableAppLock;
  final bool autoTranscribeVoice;
  final String defaultFolderId;
  final bool exportIncludeMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AppSettings.defaults({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return AppSettings(
      id: defaultId,
      themeMode: AppThemeMode.system,
      themeColor: '#5B6CFF',
      enableAppLock: false,
      autoTranscribeVoice: false,
      defaultFolderId: 'inbox',
      exportIncludeMetadata: true,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  AppSettings copyWith({
    String? id,
    AppThemeMode? themeMode,
    String? themeColor,
    bool? enableAppLock,
    bool? autoTranscribeVoice,
    String? defaultFolderId,
    bool? exportIncludeMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      themeColor: themeColor ?? this.themeColor,
      enableAppLock: enableAppLock ?? this.enableAppLock,
      autoTranscribeVoice: autoTranscribeVoice ?? this.autoTranscribeVoice,
      defaultFolderId: defaultFolderId ?? this.defaultFolderId,
      exportIncludeMetadata:
          exportIncludeMetadata ?? this.exportIncludeMetadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
