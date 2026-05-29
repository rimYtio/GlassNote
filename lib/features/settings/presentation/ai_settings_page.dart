import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
  final _apiBaseUrlController = TextEditingController();
  final _apiModelNameController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _timeoutController = TextEditingController();
  final _volcAppKeyController = TextEditingController();
  final _volcAccessKeyController = TextEditingController();
  final _deepSeekKeyController = TextEditingController();
  final _openAIKeyController = TextEditingController();
  final _siliconFlowKeyController = TextEditingController();

  AiProviderType _selectedProvider = AiProviderType.deepSeek;

  bool _loading = true;
  bool _saving = false;
  bool _volcAppKeySaved = false;
  bool _volcAccessKeySaved = false;
  bool _deepSeekKeySaved = false;
  bool _openAIKeySaved = false;
  bool _siliconFlowKeySaved = false;
  bool _testingVolc = false;
  bool _testingLlm = false;
  bool _volcAppKeyEdited = false;
  bool _volcAccessKeyEdited = false;
  bool _deepSeekKeyEdited = false;
  bool _openAIKeyEdited = false;
  bool _siliconFlowKeyEdited = false;
  String? _saveMessage;
  bool _feedbackSuccess = true;
  String? _volcTestMessage;
  String? _llmTestMessage;
  bool _saveVisible = true;
  bool _volcTestVisible = true;
  bool _llmTestVisible = true;
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
    _apiBaseUrlController.dispose();
    _apiModelNameController.dispose();
    _temperatureController.dispose();
    _timeoutController.dispose();
    _volcAppKeyController.dispose();
    _volcAccessKeyController.dispose();
    _deepSeekKeyController.dispose();
    _openAIKeyController.dispose();
    _siliconFlowKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'API 设置',
      actions: [
        _SpringSaveButton(
          saving: _saving,
          onPressed: _save,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 98,
                        ),
                        children: [
                          _buildVolcSection(context),
                          const SizedBox(height: 16),
                          _buildLlmSection(context),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_saveMessage != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: AnimatedOpacity(
                      opacity: _saveVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      onEnd: () {
                        if (!_saveVisible && mounted) {
                          setState(() {
                            _saveMessage = null;
                          });
                        }
                      },
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
              ],
            ),
    );
  }

  Widget _buildVolcSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '火山引擎豆包 2.0 流式语音转文字',
            style: Theme.of(context)
                .textTheme
                .titleMedium
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
            onPressed: _testingVolc || _saving ? null : _testVolcAsr,
            message: _volcTestMessage,
            messageVisible: _volcTestVisible,
            onMessageCleared: () {
              _volcTestMessage = null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLlmSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI 分析模型',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _providerDropdown(),
          const SizedBox(height: 8),
          ..._providerFields(),
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
          _testButton(
            key: 'ai-test-llm-button',
            label: _testingLlm ? '测试中...' : '测试 ${_providerLabel(_selectedProvider)}',
            onPressed: _testingLlm || _saving ? null : _testLlm,
            message: _llmTestMessage,
            messageVisible: _llmTestVisible,
            onMessageCleared: () {
              _llmTestMessage = null;
            },
          ),
        ],
      ),
    );
  }

  Widget _providerDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<AiProviderType>(
        key: const ValueKey('ai-provider-dropdown'),
        value: _selectedProvider,
        decoration: const InputDecoration(labelText: 'AI 提供商'),
        items: AiProviderType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(_providerLabel(type)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedProvider = value;
            });
          }
        },
      ),
    );
  }

  List<Widget> _providerFields() {
    return switch (_selectedProvider) {
      AiProviderType.deepSeek => [
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
          _secretField(
            key: 'ai-deepseek-key-field',
            controller: _deepSeekKeyController,
            label: 'DeepSeek API Key',
            saved: _deepSeekKeySaved,
            onEditStart: () {
              _deepSeekKeyEdited = true;
            },
          ),
        ],
      AiProviderType.openAI => [
          _field(
            key: 'ai-openai-base-url-field',
            controller: _apiBaseUrlController,
            label: 'Base URL',
          ),
          _field(
            key: 'ai-openai-model-field',
            controller: _apiModelNameController,
            label: '模型',
          ),
          _secretField(
            key: 'ai-openai-key-field',
            controller: _openAIKeyController,
            label: 'OpenAI API Key',
            saved: _openAIKeySaved,
            onEditStart: () {
              _openAIKeyEdited = true;
            },
          ),
        ],
      AiProviderType.siliconFlow => [
          _field(
            key: 'ai-siliconflow-model-field',
            controller: _apiModelNameController,
            label: '模型',
          ),
          _secretField(
            key: 'ai-siliconflow-key-field',
            controller: _siliconFlowKeyController,
            label: 'SiliconFlow API Key',
            saved: _siliconFlowKeySaved,
            onEditStart: () {
              _siliconFlowKeyEdited = true;
            },
          ),
        ],
      AiProviderType.custom => [
          _field(
            key: 'ai-custom-base-url-field',
            controller: _apiBaseUrlController,
            label: 'Base URL',
          ),
          _field(
            key: 'ai-custom-model-field',
            controller: _apiModelNameController,
            label: '模型',
          ),
          _secretField(
            key: 'ai-custom-key-field',
            controller: _openAIKeyController,
            label: 'API Key',
            saved: _openAIKeySaved,
            onEditStart: () {
              _openAIKeyEdited = true;
            },
          ),
        ],
    };
  }

  String _providerLabel(AiProviderType type) {
    return switch (type) {
      AiProviderType.deepSeek => 'DeepSeek',
      AiProviderType.openAI => 'OpenAI',
      AiProviderType.siliconFlow => 'SiliconFlow（硅基流动）',
      AiProviderType.custom => '自定义',
    };
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
      providerType: _selectedProvider,
      apiBaseUrl: _apiBaseUrlController.text.trim().isEmpty
          ? null
          : _apiBaseUrlController.text.trim(),
      apiModelName: _apiModelNameController.text.trim().isEmpty
          ? null
          : _apiModelNameController.text.trim(),
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
      openAIApiKey: _resolveSecret(
        _openAIKeyController,
        _openAIKeyEdited,
        stored.openAIApiKey,
      ),
      siliconFlowApiKey: _resolveSecret(
        _siliconFlowKeyController,
        _siliconFlowKeyEdited,
        stored.siliconFlowApiKey,
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
      openAIApiKey:
          await secrets.readSecret(AiConfig.openAIApiKeySecretKey) ?? '',
      siliconFlowApiKey:
          await secrets.readSecret(AiConfig.siliconFlowApiKeySecretKey) ?? '',
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
        _llmTestVisible = false;
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

  Future<void> _testLlm() async {
    setState(() {
      _testingLlm = true;
      _llmTestMessage = null;
      _llmTestVisible = true;
    });
    _cancelDismiss();
    final config = _currentConfig();
    final secrets = await _currentSecrets();
    final tester = ref.read(aiConnectionTesterProvider);

    final result = switch (config.providerType) {
      AiProviderType.deepSeek =>
        await tester.testDeepSeek(config: config, secrets: secrets),
      AiProviderType.openAI || AiProviderType.custom =>
        await tester.testOpenAI(config: config, secrets: secrets),
      AiProviderType.siliconFlow =>
        await tester.testSiliconFlow(config: config, secrets: secrets),
    };
    if (!mounted) {
      return;
    }
    setState(() {
      _testingLlm = false;
      _llmTestMessage = result.message;
      _saveMessage = result.message;
      _feedbackSuccess = result.success;
      _saveVisible = true;
      _llmTestVisible = true;
    });
    _scheduleDismiss();
  }

  Future<void> _syncSavedSecretFlags() async {
    final saved = await _readStoredSecrets();
    _volcAppKeySaved = saved.volcAppKey.isNotEmpty;
    _volcAccessKeySaved = saved.volcAccessKey.isNotEmpty;
    _deepSeekKeySaved = saved.deepSeekApiKey.isNotEmpty;
    _openAIKeySaved = saved.openAIApiKey.isNotEmpty;
    _siliconFlowKeySaved = saved.siliconFlowApiKey.isNotEmpty;
  }

  Future<void> _load() async {
    final config = await ref.read(aiConfigRepositoryProvider).load();
    final secrets = await _readStoredSecrets();
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedProvider = config.providerType;
      _volcEndpointController.text = config.volcAsrEndpoint;
      _volcResourceController.text = config.volcAsrResourceId;
      _volcLanguageController.text = config.volcAsrLanguage;
      _deepSeekBaseUrlController.text = config.deepSeekBaseUrl;
      _deepSeekModelController.text = config.deepSeekModel;
      _apiBaseUrlController.text = config.apiBaseUrl ?? '';
      _apiModelNameController.text = config.apiModelName ?? '';
      _temperatureController.text = config.temperature.toString();
      _timeoutController.text = config.timeoutSeconds.toString();
      _volcAppKeySaved = secrets.volcAppKey.isNotEmpty;
      _volcAccessKeySaved = secrets.volcAccessKey.isNotEmpty;
      _deepSeekKeySaved = secrets.deepSeekApiKey.isNotEmpty;
      _openAIKeySaved = secrets.openAIApiKey.isNotEmpty;
      _siliconFlowKeySaved = secrets.siliconFlowApiKey.isNotEmpty;
      if (_volcAppKeySaved) {
        _volcAppKeyController.text = _maskedKey;
      }
      if (_volcAccessKeySaved) {
        _volcAccessKeyController.text = _maskedKey;
      }
      if (_deepSeekKeySaved) {
        _deepSeekKeyController.text = _maskedKey;
      }
      if (_openAIKeySaved) {
        _openAIKeyController.text = _maskedKey;
      }
      if (_siliconFlowKeySaved) {
        _siliconFlowKeyController.text = _maskedKey;
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
      if (resolvedSecrets.openAIApiKey.isNotEmpty) {
        await secureStore.writeSecret(
          key: AiConfig.openAIApiKeySecretKey,
          value: resolvedSecrets.openAIApiKey,
        );
      }
      if (resolvedSecrets.siliconFlowApiKey.isNotEmpty) {
        await secureStore.writeSecret(
          key: AiConfig.siliconFlowApiKeySecretKey,
          value: resolvedSecrets.siliconFlowApiKey,
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
        _openAIKeyController.text = _maskedKey;
        _siliconFlowKeyController.text = _maskedKey;
        _volcAppKeyEdited = false;
        _volcAccessKeyEdited = false;
        _deepSeekKeyEdited = false;
        _openAIKeyEdited = false;
        _siliconFlowKeyEdited = false;
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

class _SpringSaveButton extends StatefulWidget {
  const _SpringSaveButton({required this.onPressed, required this.saving});
  final VoidCallback? onPressed;
  final bool saving;

  @override
  State<_SpringSaveButton> createState() => _SpringSaveButtonState();
}

class _SpringSaveButtonState extends State<_SpringSaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _bounce() {
    _ctrl.value = 0.85;
    _ctrl.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 500, damping: 20),
        0.85,
        1.0,
        0.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _ctrl,
      child: IconButton(
        onPressed: widget.saving
            ? null
            : () {
                _bounce();
                widget.onPressed?.call();
              },
        icon: widget.saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        tooltip: '保存',
      ),
    );
  }
}
