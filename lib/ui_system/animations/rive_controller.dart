import 'dart:math' as math;

import 'package:flutter/material.dart';

/// States mirroring the Rive state machine inputs for the voice button.
enum VoiceButtonState {
  idle,
  recording,
  processing,
  success,
  error,
}

/// A Flutter-based state machine widget that emulates the Rive voice button
/// animation. Accepts state changes and renders corresponding visuals.
///
/// When a real .riv file is available, replace this widget with:
///   RiveAnimation.asset('assets/rive/voice_button.riv',
///     stateMachines: ['voice_button'],
///     onInit: (artboard) { ... },
///   )
///
/// This fallback provides the identical state machine API surface so the
/// capture page integration remains unchanged.
class VoiceButtonRive extends StatefulWidget {
  const VoiceButtonRive({
    super.key,
    required this.state,
    this.amplitude = 0.0,
    this.size = 176.0,
    this.primary,
    this.secondary,
  });

  final VoiceButtonState state;
  final double amplitude;
  final double size;
  final Color? primary;
  final Color? secondary;

  @override
  State<VoiceButtonRive> createState() => _VoiceButtonRiveState();
}

class _VoiceButtonRiveState extends State<VoiceButtonRive>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _successCtrl;
  late final AnimationController _errorCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _errorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(covariant VoiceButtonRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _onStateChanged(widget.state);
    }
  }

  void _onStateChanged(VoiceButtonState newState) {
    switch (newState) {
      case VoiceButtonState.idle:
        _pulseCtrl.reverse();
        _successCtrl.value = 0;
        _errorCtrl.value = 0;
      case VoiceButtonState.recording:
        _pulseCtrl.repeat(reverse: true);
      case VoiceButtonState.processing:
        _pulseCtrl.repeat(reverse: true);
      case VoiceButtonState.success:
        _pulseCtrl.stop();
        _successCtrl.forward(from: 0);
      case VoiceButtonState.error:
        _pulseCtrl.stop();
        _errorCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    _errorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = widget.primary ?? colorScheme.primary;
    final secondary = widget.secondary ?? colorScheme.secondary;

    final size = widget.size;
    final isRecording = widget.state == VoiceButtonState.recording;
    final isProcessing = widget.state == VoiceButtonState.processing;
    final isSuccess = widget.state == VoiceButtonState.success;
    final isError = widget.state == VoiceButtonState.error;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _waveCtrl,
          _pulseCtrl,
          _successCtrl,
          _errorCtrl,
        ]),
        builder: (context, child) {
          final energy = isRecording
              ? widget.amplitude.clamp(0.0, 1.0)
              : isProcessing
              ? 0.35 + math.sin(_pulseCtrl.value * math.pi * 2) * 0.15
              : isSuccess
              ? (1.0 - _successCtrl.value).clamp(0.0, 1.0) * 0.4
              : 0.04;

          final tint = isError ? Colors.redAccent : primary;

          return RepaintBoundary(
            child: CustomPaint(
              size: Size(size, size),
              painter: _RiveOrbPainter(
                phase: _waveCtrl.value,
                amplitude: energy,
                pulse: _pulseCtrl.value,
                successProgress: _successCtrl.value,
                errorProgress: _errorCtrl.value,
                state: widget.state,
                primary: tint,
                secondary: secondary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RiveOrbPainter extends CustomPainter {
  _RiveOrbPainter({
    required this.phase,
    required this.amplitude,
    required this.pulse,
    required this.successProgress,
    required this.errorProgress,
    required this.state,
    required this.primary,
    required this.secondary,
  });

  final double phase;
  final double amplitude;
  final double pulse;
  final double successProgress;
  final double errorProgress;
  final VoiceButtonState state;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.34;
    final phaseRadians = phase * math.pi * 2;
    final energy = amplitude;

    // Outer glow halo
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primary.withValues(alpha: 0.26 + energy * 0.16),
          secondary.withValues(alpha: 0.14),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: center, radius: size.width * 0.47),
      );
    canvas.drawCircle(center, size.width * (0.40 + energy * 0.06), glowPaint);

    // Success ring
    if (successProgress > 0) {
      final successPaint = Paint()
        ..color = const Color(0xFF4CAF50)
            .withValues(alpha: (1.0 - successProgress) * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      final successRadius =
          size.width * 0.42 * (1.0 + successProgress * 0.2);
      canvas.drawCircle(center, successRadius, successPaint);
    }

    // Error shake effect
    final errorOffset =
        errorProgress > 0 && errorProgress < 1.0
            ? math.sin(errorProgress * math.pi * 6) * 4.0
            : 0.0;
    final errorCenter = Offset(center.dx + errorOffset, center.dy);

    // Blended orbital rings
    for (var i = 0; i < 3; i += 1) {
      final ringPaint = Paint()
        ..color = primary.withValues(alpha: 0.11 - i * 0.02 + energy * 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(
        _blobPath(
          errorCenter,
          baseRadius + 16 + i * 11,
          phaseRadians * (0.7 + i * 0.25),
          4 + energy * 14,
        ),
        ringPaint,
      );
    }

    // Core fill with gradient
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        colors: [
          Colors.white.withValues(alpha: 0.52),
          primary.withValues(alpha: 0.34 + energy * 0.16),
          secondary.withValues(alpha: 0.28),
        ],
      ).createShader(
        Rect.fromCircle(center: errorCenter, radius: baseRadius * 1.25),
      );
    canvas.drawPath(
      _blobPath(errorCenter, baseRadius, phaseRadians, 5 + energy * 18),
      fillPaint,
    );

    // Edge stroke
    final edgePaint = Paint()
      ..color = primary.withValues(alpha: 0.48 + energy * 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      _blobPath(
        errorCenter,
        baseRadius + 1,
        phaseRadians * 1.2,
        5 + energy * 18,
      ),
      edgePaint,
    );
  }

  Path _blobPath(
    Offset center,
    double radius,
    double phase,
    double distortion,
  ) {
    final path = Path();
    const segments = 72;
    for (var i = 0; i <= segments; i += 1) {
      final a = i / segments * math.pi * 2;
      final wave = math.sin(a * 3 + phase) * distortion * 0.55 +
          math.sin(a * 5 - phase * 1.4) * distortion * 0.28 +
          math.sin(a * 9 + phase * 0.6) * distortion * 0.17;
      final r = radius + wave;
      final point = Offset(
        center.dx + math.cos(a) * r,
        center.dy + math.sin(a) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _RiveOrbPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude ||
        oldDelegate.phase != phase ||
        oldDelegate.pulse != pulse ||
        oldDelegate.successProgress != successProgress ||
        oldDelegate.errorProgress != errorProgress ||
        oldDelegate.state != state ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}
