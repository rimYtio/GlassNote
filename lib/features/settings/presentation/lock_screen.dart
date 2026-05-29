import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/infrastructure_providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({required this.onUnlocked, super.key});

  final VoidCallback onUnlocked;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _showPinPad = false;
  bool _authenticating = false;
  String _pin = '';
  String _errorMessage = '';
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    final service = ref.read(appLockServiceProvider);
    final available = await service.isBiometricAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
    if (available) {
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    try {
      final service = ref.read(appLockServiceProvider);
      final success = await service.authenticate(reason: '验证身份以解锁应用');
      if (success && mounted) {
        widget.onUnlocked();
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _authenticating = false);
    }
  }

  void _onDigit(String digit) {
    HapticFeedback.lightImpact();
    if (_pin.length < 6) {
      setState(() {
        _pin += digit;
        _errorMessage = '';
      });
      if (_pin.length >= 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    HapticFeedback.selectionClick();
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    try {
      final service = ref.read(appLockServiceProvider);
      final valid = await service.verifyPin(_pin);
      if (valid && mounted) {
        widget.onUnlocked();
        return;
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'PIN 不正确，请重试';
          _pin = '';
          _authenticating = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pin = '';
          _authenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      child: Stack(
        children: [
          // Glass background layers
          Positioned(
            top: -80,
            right: -60,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x26F0D0E0),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: const Offset(0, 120),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 200, sigmaY: 200),
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x26B0D8F0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(215, 235, 252, 0.32),
                  Color.fromRGBO(235, 245, 255, 0.15),
                  Color.fromRGBO(255, 255, 255, 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.0,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _GrainPainter()),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                // App icon
                Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'GlassNote',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '验证身份',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ),
                const Spacer(flex: 2),

                if (!_showPinPad) ...[
                  // Biometric button
                  if (_biometricAvailable) ...[
                    _GlassButton(
                      icon: Icons.fingerprint,
                      label: '指纹/面容解锁',
                      onTap: _authenticating ? null : _authenticateWithBiometric,
                    ),
                    const SizedBox(height: 12),
                  ],
                  // PIN alternative
                  _GlassButton(
                    icon: Icons.dialpad,
                    label: '使用 PIN',
                    onTap: () => setState(() => _showPinPad = true),
                  ),
                ] else ...[
                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _pin.length
                              ? colorScheme.primary.withValues(alpha: 0.7)
                              : colorScheme.onSurface.withValues(alpha: 0.15),
                          border: i == _pin.length
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
                  const SizedBox(height: 32),
                  // Number pad
                  _NumberPad(
                    onDigit: _onDigit,
                    onDelete: _onDelete,
                    onBiometric: _biometricAvailable
                        ? _authenticateWithBiometric
                        : null,
                  ),
                ],

                const Spacer(flex: 2),
                TextButton(
                  onPressed: () => setState(() {
                    _showPinPad = false;
                    _pin = '';
                    _errorMessage = '';
                  }),
                  child: Text(
                    _showPinPad ? '返回' : '',
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 220,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.18),
                  colorScheme.primary.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({
    required this.onDigit,
    required this.onDelete,
    this.onBiometric,
  });

  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((d) => _NumKey(digit: d, onTap: () => onDigit(d))).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onBiometric != null)
              _NumKey(
                icon: Icons.fingerprint,
                onTap: onBiometric,
              )
            else
              const _NumKey.empty(),
            _NumKey(digit: '0', onTap: () => onDigit('0')),
            _NumKey(
              icon: Icons.backspace_outlined,
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({this.digit, this.icon, required this.onTap});
  const _NumKey.empty()
    : digit = null,
      icon = null,
      onTap = null;

  final String? digit;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (digit == null && icon == null) {
      return const SizedBox(width: 72, height: 56);
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        width: 60,
        height: 56,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: colorScheme.onSurface.withValues(alpha: 0.5))
                  : Text(
                      digit!,
                      style: TextStyle(
                        fontSize: 24,
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

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.015);
    final rng = math.Random(42);
    final area = size.width * size.height;
    final numDots = (area * 0.08).toInt().clamp(0, 8000);
    for (int i = 0; i < numDots; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final alpha = 0.005 + rng.nextDouble() * 0.01;
      paint.color = Colors.black.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => false;
}
