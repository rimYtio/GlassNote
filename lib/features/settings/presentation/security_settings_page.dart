import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() =>
      _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool _appLockEnabled = false;
  bool _biometricAvailable = false;
  bool _hasPin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final service = ref.read(appLockServiceProvider);
    final enabled = await service.isEnabled();
    final bioAvailable = await service.isBiometricAvailable();
    final pinSet = await service.hasPinSet;
    if (mounted) {
      setState(() {
        _appLockEnabled = enabled;
        _biometricAvailable = bioAvailable;
        _hasPin = pinSet;
        _loading = false;
      });
    }
  }

  Future<void> _toggleAppLock(bool enabled) async {
    final service = ref.read(appLockServiceProvider);

    if (enabled) {
      // If enabling, make sure PIN is set first
      if (!_hasPin) {
        final pinSet = await _showPinSetupDialog();
        if (!pinSet) return;
      }

      // Try biometric if available
      if (_biometricAvailable) {
        final authOk = await service.authenticate(reason: '启用应用锁需要验证身份');
        if (!authOk) return;
      }
    }

    await service.setEnabled(enabled);
    if (mounted) {
      setState(() => _appLockEnabled = enabled);
    }
  }

  Future<bool> _showPinSetupDialog() async {
    if (!mounted) return false;
    final pin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PinSetupDialog(),
    );
    if (pin == null) return false;

    final service = ref.read(appLockServiceProvider);
    await service.setPin(pin);
    if (mounted) {
      setState(() => _hasPin = true);
    }
    return true;
  }

  Future<void> _changePin() async {
    if (!mounted) return;
    final newPin = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _PinSetupDialog(title: '设置新 PIN'),
    );
    if (newPin == null) return;

    final service = ref.read(appLockServiceProvider);
    await service.setPin(newPin);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN 已更新'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassScaffold(
      title: '安全设置',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 8),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '应用锁',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _appLockEnabled ? '已启用' : '已停用',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                        value: _appLockEnabled,
                        onChanged: _toggleAppLock,
                      ),
                      if (_appLockEnabled) ...[
                        const Divider(),
                        _buildInfoRow(
                          icon: _biometricAvailable
                              ? Icons.fingerprint
                              : Icons.fingerprint_outlined,
                          label: '生物识别',
                          value: _biometricAvailable ? '可用' : '不可用',
                          color: _biometricAvailable
                              ? Colors.green
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: _hasPin ? Icons.pin : Icons.pin_outlined,
                          label: 'PIN 码',
                          value: _hasPin ? '已设置' : '未设置',
                          color: _hasPin
                              ? Colors.green
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_appLockEnabled) ...[
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.lock_reset,
                            color: colorScheme.primary,
                          ),
                          title: const Text('更改 PIN'),
                          subtitle: Text(
                            '修改用于解锁应用的 PIN 码',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 13,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            size: 20,
                          ),
                          onTap: _changePin,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '应用锁启用后，每次启动或从后台返回时将需要验证身份。'
                      '生物识别（指纹/面容）优先，失败后可回退到 PIN 码。',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}

class _PinSetupDialog extends StatefulWidget {
  const _PinSetupDialog({
    this.title = '设置解锁 PIN',
  });

  final String title;

  @override
  State<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<_PinSetupDialog> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _error = '';

  void _onDigit(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      _error = '';
      if (!_isConfirming) {
        if (_pin.length < 6) _pin += digit;
        if (_pin.length >= 4) {
          // Short delay then confirm
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _isConfirming = true;
              });
            }
          });
        }
      } else {
        if (_confirmPin.length < 6) _confirmPin += digit;
        if (_confirmPin.length == _pin.length) {
          if (_confirmPin == _pin) {
            Navigator.of(context).pop(_pin);
          } else {
            setState(() {
              _error = '两次输入不一致';
              _pin = '';
              _confirmPin = '';
              _isConfirming = false;
            });
          }
        }
      }
    });
  }

  void _onDelete() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else if (!_isConfirming && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayPin = _isConfirming ? _confirmPin : _pin;
    final phaseLabel = _isConfirming ? '确认 PIN' : '输入 PIN';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  colorScheme.surface.withValues(alpha: 0.92),
                  colorScheme.surface.withValues(alpha: 0.85),
                ],
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phaseLabel,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pin dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < displayPin.length
                              ? colorScheme.primary.withValues(alpha: 0.7)
                              : colorScheme.onSurface.withValues(alpha: 0.12),
                          border: i == displayPin.length
                              ? Border.all(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(_error, style: TextStyle(color: colorScheme.error, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  // Number pad
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: row
                            .map(
                              (d) => _PinKey(
                                label: d,
                                onTap: () => _onDigit(d),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _PinKey.empty(),
                      _PinKey(label: '0', onTap: () => _onDigit('0')),
                      _PinKey(icon: Icons.backspace_outlined, onTap: _onDelete),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '取消',
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  const _PinKey({this.label, this.icon, required this.onTap});
  const _PinKey.empty()
    : label = null,
      icon = null,
      onTap = null;

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (label == null && icon == null) {
      return const SizedBox(width: 62, height: 48);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: 52,
        height: 48,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.5))
                  : Text(
                      label!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
