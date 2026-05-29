enum AiProviderType {
  deepSeek,
  openAI,
  siliconFlow,
  custom;

  static AiProviderType fromStorageValue(String value) {
    return AiProviderType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => AiProviderType.deepSeek,
    );
  }
}

class AiConfig {
  const AiConfig({
    required this.id,
    required this.volcAsrEndpoint,
    required this.volcAsrResourceId,
    required this.volcAsrLanguage,
    required this.deepSeekBaseUrl,
    required this.deepSeekModel,
    required this.temperature,
    required this.timeoutSeconds,
    required this.updatedAt,
    this.providerType = AiProviderType.deepSeek,
    this.apiBaseUrl,
    this.apiModelName,
  });

  static const defaultId = 'default';
  static const volcAppKeySecretKey = 'volc_app_key';
  static const volcAccessKeySecretKey = 'volc_access_key';
  static const deepSeekApiKeySecretKey = 'deepseek_api_key';
  static const openAIApiKeySecretKey = 'openai_api_key';
  static const siliconFlowApiKeySecretKey = 'siliconflow_api_key';

  final String id;
  final String volcAsrEndpoint;
  final String volcAsrResourceId;
  final String volcAsrLanguage;
  final String deepSeekBaseUrl;
  final String deepSeekModel;
  final double temperature;
  final int timeoutSeconds;
  final DateTime updatedAt;
  final AiProviderType providerType;
  final String? apiBaseUrl;
  final String? apiModelName;

  factory AiConfig.defaults({DateTime? now}) {
    return AiConfig(
      id: defaultId,
      volcAsrEndpoint:
          'wss://openspeech.bytedance.com/api/v3/sauc/bigmodel_async',
      volcAsrResourceId: 'volc.seedasr.sauc.duration',
      volcAsrLanguage: 'zh-CN',
      deepSeekBaseUrl: 'https://api.deepseek.com',
      deepSeekModel: 'deepseek-v4-flash',
      temperature: 0.2,
      timeoutSeconds: 45,
      updatedAt: now ?? DateTime.now(),
      providerType: AiProviderType.deepSeek,
    );
  }

  AiConfig copyWith({
    String? id,
    String? volcAsrEndpoint,
    String? volcAsrResourceId,
    String? volcAsrLanguage,
    String? deepSeekBaseUrl,
    String? deepSeekModel,
    double? temperature,
    int? timeoutSeconds,
    DateTime? updatedAt,
    AiProviderType? providerType,
    String? apiBaseUrl,
    String? apiModelName,
  }) {
    return AiConfig(
      id: id ?? this.id,
      volcAsrEndpoint: volcAsrEndpoint ?? this.volcAsrEndpoint,
      volcAsrResourceId: volcAsrResourceId ?? this.volcAsrResourceId,
      volcAsrLanguage: volcAsrLanguage ?? this.volcAsrLanguage,
      deepSeekBaseUrl: deepSeekBaseUrl ?? this.deepSeekBaseUrl,
      deepSeekModel: deepSeekModel ?? this.deepSeekModel,
      temperature: temperature ?? this.temperature,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
      providerType: providerType ?? this.providerType,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiModelName: apiModelName ?? this.apiModelName,
    );
  }
}

class AiSecrets {
  const AiSecrets({
    required this.volcAppKey,
    required this.volcAccessKey,
    required this.deepSeekApiKey,
    this.openAIApiKey = '',
    this.siliconFlowApiKey = '',
  });

  final String volcAppKey;
  final String volcAccessKey;
  final String deepSeekApiKey;
  final String openAIApiKey;
  final String siliconFlowApiKey;

  bool get hasCaptureKeys =>
      volcAppKey.trim().isNotEmpty &&
      volcAccessKey.trim().isNotEmpty &&
      _resolveSelectedApiKey.isNotEmpty;

  String get _resolveSelectedApiKey {
    // This is a coarse check; real selection happens in the analyzer.
    if (deepSeekApiKey.trim().isNotEmpty) return deepSeekApiKey;
    if (openAIApiKey.trim().isNotEmpty) return openAIApiKey;
    if (siliconFlowApiKey.trim().isNotEmpty) return siliconFlowApiKey;
    return '';
  }
}
