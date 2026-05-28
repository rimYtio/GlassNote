import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/ai_config.dart';
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
  bool _testingVolc = false;
  bool _testingDeepSeek = false;
  bool _volcAppKeyEdited = false;
  bool _volcAccessKeyEdited = false;
  bool _deepSeekKeyEdited = false;
  String? _saveMessage;
  bool _feedbackSuccess = true;
  String? _volcTestMessage;
  String? _deepSeekTestMessage;
  bool _saveVisible = true;
  bool _volcTestVisible = true;
  bool _deepSeekTestVisible = true;
  Timer? _dismissTimer;

  static const _maskedKey = '••••••••';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
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
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
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
                              label: 'APP ID',
                              saved: _volcAppKeySaved,
                              onEditStart: () {
                                _volcAppKeyEdited = true;
                              },
                            ),
                            _secretField(
                              key: 'ai-volc-access-key-field',
                              controller: _volcAccessKeyController,
                              label: 'Access Token',
                              saved: _volcAccessKeySaved,
                              onEditStart: () {
                                _volcAccessKeyEdited = true;
                              },
                            ),
                            _testButton(
                              key: 'ai-test-volc-button',
                              label: _testingVolc ? '测试中...' : '测试火山 ASR',
                              onPressed: _testingVolc || _saving
                                  ? null
                                  : _testVolcAsr,
                              message: _volcTestMessage,
                              messageVisible: _volcTestVisible,
                              onMessageCleared: () {
                                _volcTestMessage = null;
                              },
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
                              onEditStart: () {
                                _deepSeekKeyEdited = true;
                              },
                            ),
                            _testButton(
                              key: 'ai-test-deepseek-button',
                              label: _testingDeepSeek ? '测试中...' : '测试 DeepSeek',
                              onPressed: _testingDeepSeek || _saving
                                  ? null
                                  : _testDeepSeek,
                              message: _deepSeekTestMessage,
                              messageVisible: _deepSeekTestVisible,
                              onMessageCleared: () {
                                _deepSeekTestMessage = null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_saveMessage != null)
                  AnimatedOpacity(
                    opacity: _saveVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      if (!_saveVisible && mounted) {
                        setState(() {
                          _saveMessage = null;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GlassCard(
                        key: const ValueKey('ai-save-feedback'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _feedbackSuccess
                                  ? Icons.check_circle
                                  : Icons.error_outline,
                              color: _feedbackSuccess
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_saveMessage!)),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
    VoidCallback? onEditStart,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: ValueKey(key),
            controller: controller,
            obscureText: true,
            onTap: () {
              if (controller.text == _maskedKey) {
                controller.clear();
              }
              onEditStart?.call();
            },
            onChanged: (_) => onEditStart?.call(),
            decoration: InputDecoration(
              labelText: label,
              helperText: saved ? '已保存' : '未保存',
            ),
          ),
          if (saved)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Chip(
                key: ValueKey(key.replaceFirst('-field', '-saved-chip')),
                avatar: const Icon(Icons.check, size: 16),
                label: const Text('已保存'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _testButton({
    required String key,
    required String label,
    required VoidCallback? onPressed,
    required String? message,
    required bool messageVisible,
    required VoidCallback onMessageCleared,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message != null)
            AnimatedOpacity(
              opacity: messageVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              onEnd: () {
                if (!messageVisible && mounted) {
                  setState(onMessageCleared);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(message),
              ),
            ),
          OutlinedButton.icon(
            key: ValueKey(key),
            onPressed: onPressed,
            icon: const Icon(Icons.network_check),
            label: Text(label),
          ),
        ],
      ),
    );
  }

  AiConfig _currentConfig() {
    return AiConfig(
      id: AiConfig.defaultId,
      volcAsrEndpoint: _volcEndpointController.text.trim(),
      volcAsrResourceId: _volcResourceController.text.trim(),
      volcAsrLanguage: _volcLanguageController.text.trim(),
      deepSeekBaseUrl: _deepSeekBaseUrlController.text.trim(),
      deepSeekModel: _deepSeekModelController.text.trim(),
      temperature: double.tryParse(_temperatureController.text.trim()) ?? 0.2,
      timeoutSeconds: int.tryParse(_timeoutController.text.trim()) ?? 45,
      updatedAt: DateTime.now(),
    );
  }

  Future<AiSecrets> _currentSecrets() async {
    final stored = await _readStoredSecrets();
    return AiSecrets(
      volcAppKey: _resolveSecret(
        _volcAppKeyController,
        _volcAppKeyEdited,
        stored.volcAppKey,
      ),
      volcAccessKey: _resolveSecret(
        _volcAccessKeyController,
        _volcAccessKeyEdited,
        stored.volcAccessKey,
      ),
      deepSeekApiKey: _resolveSecret(
        _deepSeekKeyController,
        _deepSeekKeyEdited,
        stored.deepSeekApiKey,
      ),
    );
  }

  String _resolveSecret(
    TextEditingController controller,
    bool edited,
    String storedValue,
  ) {
    if (!edited) {
      return storedValue;
    }
    final text = controller.text.trim();
    if (text == _maskedKey || text.isEmpty) {
      return storedValue;
    }
    return text;
  }

  Future<AiSecrets> _readStoredSecrets() async {
    final secrets = ref.read(secureKeyValueStoreProvider);
    return AiSecrets(
      volcAppKey: await secrets.readSecret(AiConfig.volcAppKeySecretKey) ?? '',
      volcAccessKey:
          await secrets.readSecret(AiConfig.volcAccessKeySecretKey) ?? '',
      deepSeekApiKey:
          await secrets.readSecret(AiConfig.deepSeekApiKeySecretKey) ?? '',
    );
  }

  void _cancelDismiss() {
    _dismissTimer?.cancel();
  }

  void _scheduleDismiss() {
    _cancelDismiss();
    _dismissTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _saveVisible = false;
        _volcTestVisible = false;
        _deepSeekTestVisible = false;
      });
    });
  }

  Future<void> _testVolcAsr() async {
    setState(() {
      _testingVolc = true;
      _volcTestMessage = null;
      _volcTestVisible = true;
    });
    _cancelDismiss();
    final result = await ref
        .read(aiConnectionTesterProvider)
        .testVolcAsr(
          config: _currentConfig(),
          secrets: await _currentSecrets(),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _testingVolc = false;
      _volcTestMessage = result.message;
      _saveMessage = result.message;
      _feedbackSuccess = result.success;
      _saveVisible = true;
      _volcTestVisible = true;
    });
    _scheduleDismiss();
  }

  Future<void> _testDeepSeek() async {
    setState(() {
      _testingDeepSeek = true;
      _deepSeekTestMessage = null;
      _deepSeekTestVisible = true;
    });
    _cancelDismiss();
    final result = await ref
        .read(aiConnectionTesterProvider)
        .testDeepSeek(
          config: _currentConfig(),
          secrets: await _currentSecrets(),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _testingDeepSeek = false;
      _deepSeekTestMessage = result.message;
      _saveMessage = result.message;
      _feedbackSuccess = result.success;
      _saveVisible = true;
      _deepSeekTestVisible = true;
    });
    _scheduleDismiss();
  }

  Future<void> _syncSavedSecretFlags() async {
    final savedSecrets = await _readStoredSecrets();
    _volcAppKeySaved = savedSecrets.volcAppKey.isNotEmpty;
    _volcAccessKeySaved = savedSecrets.volcAccessKey.isNotEmpty;
    _deepSeekKeySaved = savedSecrets.deepSeekApiKey.isNotEmpty;
  }

  Future<void> _load() async {
    final config = await ref.read(aiConfigRepositoryProvider).load();
    final secrets = await _readStoredSecrets();
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
      _volcAppKeySaved = secrets.volcAppKey.isNotEmpty;
      _volcAccessKeySaved = secrets.volcAccessKey.isNotEmpty;
      _deepSeekKeySaved = secrets.deepSeekApiKey.isNotEmpty;
      if (_volcAppKeySaved) {
        _volcAppKeyController.text = _maskedKey;
      }
      if (_volcAccessKeySaved) {
        _volcAccessKeyController.text = _maskedKey;
      }
      if (_deepSeekKeySaved) {
        _deepSeekKeyController.text = _maskedKey;
      }
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saveMessage = null;
      _feedbackSuccess = true;
      _saveVisible = true;
    });
    _cancelDismiss();
    try {
      await ref.read(aiConfigRepositoryProvider).save(_currentConfig());

      final resolvedSecrets = await _currentSecrets();
      final secureStore = ref.read(secureKeyValueStoreProvider);
      if (resolvedSecrets.volcAppKey.isNotEmpty) {
        await secureStore.writeSecret(
          key: AiConfig.volcAppKeySecretKey,
          value: resolvedSecrets.volcAppKey,
        );
      }
      if (resolvedSecrets.volcAccessKey.isNotEmpty) {
        await secureStore.writeSecret(
          key: AiConfig.volcAccessKeySecretKey,
          value: resolvedSecrets.volcAccessKey,
        );
      }
      if (resolvedSecrets.deepSeekApiKey.isNotEmpty) {
        await secureStore.writeSecret(
          key: AiConfig.deepSeekApiKeySecretKey,
          value: resolvedSecrets.deepSeekApiKey,
        );
      }
      ref.invalidate(aiSecretsProvider);
      await _syncSavedSecretFlags();

      if (!mounted) {
        return;
      }
      setState(() {
        _volcAppKeyController.text = _maskedKey;
        _volcAccessKeyController.text = _maskedKey;
        _deepSeekKeyController.text = _maskedKey;
        _volcAppKeyEdited = false;
        _volcAccessKeyEdited = false;
        _deepSeekKeyEdited = false;
        _saveMessage = 'API 设置已保存';
        _feedbackSuccess = true;
        _saveVisible = true;
        _saving = false;
      });
      _scheduleDismiss();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saveMessage = 'API 设置保存失败: $error';
        _feedbackSuccess = false;
        _saveVisible = true;
        _saving = false;
      });
      _scheduleDismiss();
    }
  }
}
