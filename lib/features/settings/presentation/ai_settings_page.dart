import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/ai_config.dart';
import '../../../domain/services/data_protection_service.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';

class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  final _volcEndpointController = TextEditingController();
  final _volcResourceController = TextEditingController();
  final _volcLanguageController = TextEditingController();
  final _deepSeekBaseUrlController = TextEditingController();
  final _deepSeekModelController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _timeoutController = TextEditingController();
  final _volcAppKeyController = TextEditingController();
  final _volcAccessKeyController = TextEditingController();
  final _deepSeekKeyController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _volcAppKeySaved = false;
  bool _volcAccessKeySaved = false;
  bool _deepSeekKeySaved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _volcEndpointController.dispose();
    _volcResourceController.dispose();
    _volcLanguageController.dispose();
    _deepSeekBaseUrlController.dispose();
    _deepSeekModelController.dispose();
    _temperatureController.dispose();
    _timeoutController.dispose();
    _volcAppKeyController.dispose();
    _volcAccessKeyController.dispose();
    _deepSeekKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'API 设置',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 180),
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '火山引擎豆包 2.0 流式语音转文字',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 14),
                          _field(
                            key: 'ai-volc-endpoint-field',
                            controller: _volcEndpointController,
                            label: 'Endpoint',
                          ),
                          _field(
                            key: 'ai-volc-resource-field',
                            controller: _volcResourceController,
                            label: 'Resource ID',
                          ),
                          _field(
                            key: 'ai-volc-language-field',
                            controller: _volcLanguageController,
                            label: '语言',
                          ),
                          _secretField(
                            key: 'ai-volc-app-key-field',
                            controller: _volcAppKeyController,
                            label: 'App Key',
                            saved: _volcAppKeySaved,
                          ),
                          _secretField(
                            key: 'ai-volc-access-key-field',
                            controller: _volcAccessKeyController,
                            label: 'Access Key',
                            saved: _volcAccessKeySaved,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DeepSeek V4 Flash',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 14),
                          _field(
                            key: 'ai-deepseek-base-url-field',
                            controller: _deepSeekBaseUrlController,
                            label: 'Base URL',
                          ),
                          _field(
                            key: 'ai-deepseek-model-field',
                            controller: _deepSeekModelController,
                            label: '模型',
                          ),
                          _field(
                            key: 'ai-temperature-field',
                            controller: _temperatureController,
                            label: '温度',
                            keyboardType: TextInputType.number,
                          ),
                          _field(
                            key: 'ai-timeout-field',
                            controller: _timeoutController,
                            label: '超时秒数',
                            keyboardType: TextInputType.number,
                          ),
                          _secretField(
                            key: 'ai-deepseek-key-field',
                            controller: _deepSeekKeyController,
                            label: 'DeepSeek API Key',
                            saved: _deepSeekKeySaved,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 108,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? '保存中...' : '保存 API 设置'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _field({
    required String key,
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        key: ValueKey(key),
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _secretField({
    required String key,
    required TextEditingController controller,
    required String label,
    required bool saved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        key: ValueKey(key),
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          helperText: saved ? '已保存' : '未保存',
        ),
      ),
    );
  }

  Future<void> _load() async {
    final config = await ref.read(aiConfigRepositoryProvider).load();
    final secrets = ref.read(secureKeyValueStoreProvider);
    final volcAppKey = await secrets.readSecret(AiConfig.volcAppKeySecretKey);
    final volcAccessKey = await secrets.readSecret(
      AiConfig.volcAccessKeySecretKey,
    );
    final deepSeekKey = await secrets.readSecret(
      AiConfig.deepSeekApiKeySecretKey,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _volcEndpointController.text = config.volcAsrEndpoint;
      _volcResourceController.text = config.volcAsrResourceId;
      _volcLanguageController.text = config.volcAsrLanguage;
      _deepSeekBaseUrlController.text = config.deepSeekBaseUrl;
      _deepSeekModelController.text = config.deepSeekModel;
      _temperatureController.text = config.temperature.toString();
      _timeoutController.text = config.timeoutSeconds.toString();
      _volcAppKeySaved = volcAppKey?.isNotEmpty ?? false;
      _volcAccessKeySaved = volcAccessKey?.isNotEmpty ?? false;
      _deepSeekKeySaved = deepSeekKey?.isNotEmpty ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final now = DateTime.now();
    final config = AiConfig(
      id: AiConfig.defaultId,
      volcAsrEndpoint: _volcEndpointController.text.trim(),
      volcAsrResourceId: _volcResourceController.text.trim(),
      volcAsrLanguage: _volcLanguageController.text.trim(),
      deepSeekBaseUrl: _deepSeekBaseUrlController.text.trim(),
      deepSeekModel: _deepSeekModelController.text.trim(),
      temperature: double.tryParse(_temperatureController.text.trim()) ?? 0.2,
      timeoutSeconds: int.tryParse(_timeoutController.text.trim()) ?? 45,
      updatedAt: now,
    );
    await ref.read(aiConfigRepositoryProvider).save(config);

    final secrets = ref.read(secureKeyValueStoreProvider);
    await _writeSecretIfPresent(
      secrets,
      AiConfig.volcAppKeySecretKey,
      _volcAppKeyController,
    );
    await _writeSecretIfPresent(
      secrets,
      AiConfig.volcAccessKeySecretKey,
      _volcAccessKeyController,
    );
    await _writeSecretIfPresent(
      secrets,
      AiConfig.deepSeekApiKeySecretKey,
      _deepSeekKeyController,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _volcAppKeySaved =
          _volcAppKeySaved || _volcAppKeyController.text.trim().isNotEmpty;
      _volcAccessKeySaved =
          _volcAccessKeySaved ||
          _volcAccessKeyController.text.trim().isNotEmpty;
      _deepSeekKeySaved =
          _deepSeekKeySaved || _deepSeekKeyController.text.trim().isNotEmpty;
      _volcAppKeyController.clear();
      _volcAccessKeyController.clear();
      _deepSeekKeyController.clear();
      _saving = false;
    });
  }

  Future<void> _writeSecretIfPresent(
    SecureKeyValueStore secrets,
    String key,
    TextEditingController controller,
  ) async {
    final value = controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    await secrets.writeSecret(key: key, value: value);
  }
}
