import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/entities/capture_draft_preview.dart';
import '../../../domain/entities/timeline_task.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'capture_controller.dart';

class CapturePage extends ConsumerWidget {
  const CapturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureControllerProvider);
    final controller = ref.read(captureControllerProvider.notifier);
    final secrets = ref.watch(aiSecretsProvider);
    if (state.status == CaptureStatus.error &&
        state.errorType == CaptureErrorType.configuration &&
        (secrets.asData?.value.hasCaptureKeys ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          controller.clearConfigurationError();
        }
      });
    }

    return GlassScaffold(
      title: '捕获',
      actions: [
        IconButton(
          icon: const Icon(Icons.dashboard_outlined),
          tooltip: '总览',
          onPressed: () => context.go('/home'),
        ),
      ],
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 168),
            children: [
              _VoiceCaptureStage(state: state),
              const SizedBox(height: 16),
              if (state.previews.isNotEmpty) ...[
                for (final preview in state.previews)
                  _PreviewItem(preview: preview),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: state.status == CaptureStatus.saving
                          ? null
                          : controller.cancelPreview,
                      child: const Text('取消'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: state.status == CaptureStatus.saving
                          ? null
                          : () => controller.confirmPreview(),
                      child: Text(
                        state.status == CaptureStatus.saving
                            ? '创建中...'
                            : '确认创建全部 (${state.previews.length})',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (state.status != CaptureStatus.preview &&
              state.status != CaptureStatus.saving) ...[
            Positioned(
              left: 0,
              right: 0,
              bottom: 104,
              child: Center(
                child: _GlassMicButton(
                  active: state.status == CaptureStatus.recording,
                  onStart: controller.startRecording,
                  onStop: controller.stopRecording,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceCaptureStage extends StatelessWidget {
  const _VoiceCaptureStage({required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        VoxSphere(status: state.status, transcript: state.transcript),
        const SizedBox(height: 18),
        _TranscriptGlass(state: state),
      ],
    );
  }
}

class _TranscriptGlass extends StatelessWidget {
  const _TranscriptGlass({required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final title = switch (state.status) {
      CaptureStatus.recording => '正在聆听',
      CaptureStatus.analyzing => '正在整理',
      CaptureStatus.preview => '识别完成',
      CaptureStatus.error => '捕获失败',
      CaptureStatus.success => '创建完成',
      _ => '语音捕获',
    };
    final text = state.errorMessage ?? state.transcript;

    return ClipRRect(
      key: const ValueKey('capture-transcript-glass'),
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isLight ? 0.65 : 0.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.80)),
            boxShadow: [
              const BoxShadow(
                color: Color(0x1A788CA0),
                blurRadius: 22,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text.isEmpty ? '字幕会在你说话时出现在这里。' : text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VoxSphere extends ConsumerStatefulWidget {
  const VoxSphere({super.key, required this.status, required this.transcript});

  final CaptureStatus status;
  final String transcript;

  @override
  ConsumerState<VoxSphere> createState() => _VoxSphereState();
}

const _voxSphereShaderAsset = 'assets/shaders/vox_sphere.frag';
const double kVoxSphereStageLightAlpha = 0.30;
const double kVoxSphereStageDarkAlpha = 0.34;
const double kVoxSphereEdgeStrokeMax = 1.20;

class _VoxSphereState extends ConsumerState<VoxSphere>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _activationCtrl;
  late final Animation<double> _speechPulse;
  StreamSubscription<double>? _amplitudeSub;
  double _amplitude = 0.0;
  double _smoothedAmplitude = 0.0;
  bool _showActivation = false;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _activationCtrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 760),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _showActivation = false);
          }
        });
    _speechPulse = CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeOutCubic,
    );
    _syncAmplitudeSubscription();
  }

  @override
  void didUpdateWidget(covariant VoxSphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      _syncAmplitudeSubscription();
      if (widget.status == CaptureStatus.recording &&
          oldWidget.status != CaptureStatus.recording) {
        _triggerActivation();
      }
    }
    if (widget.transcript != oldWidget.transcript &&
        widget.transcript.length > oldWidget.transcript.length) {
      _pulseCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    _activationCtrl.dispose();
    super.dispose();
  }

  double get _targetScale {
    return switch (widget.status) {
      CaptureStatus.recording => 1.07 + _smoothedAmplitude * 0.13,
      CaptureStatus.analyzing => 1.08,
      CaptureStatus.preview => 1.04,
      CaptureStatus.success => 1.04,
      CaptureStatus.error => 0.98,
      _ => 1.0,
    };
  }

  void _syncAmplitudeSubscription() {
    if (widget.status != CaptureStatus.recording) {
      _amplitudeSub?.cancel();
      _amplitudeSub = null;
      if ((_amplitude != 0 || _smoothedAmplitude != 0) && mounted) {
        setState(() {
          _amplitude = 0;
          _smoothedAmplitude = 0;
        });
      } else {
        _amplitude = 0;
        _smoothedAmplitude = 0;
      }
      return;
    }
    if (_amplitudeSub != null) {
      return;
    }
    _amplitudeSub = ref.read(audioInputServiceProvider).amplitudeStream.listen((
      value,
    ) {
      if (!mounted) return;
      setState(() {
        _amplitude = value.clamp(0.0, 1.0);
        _smoothedAmplitude = _smoothedAmplitude * 0.82 + _amplitude * 0.18;
      });
    });
  }

  void _triggerActivation() {
    setState(() => _showActivation = true);
    _activationCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final activeLevel = widget.status == CaptureStatus.recording
        ? _smoothedAmplitude
        : widget.status == CaptureStatus.analyzing
        ? 0.22
        : 0.04;
    final sphereSize = MediaQuery.sizeOf(context).width.clamp(360.0, 620.0);
    final visualSize = (sphereSize * 0.54).clamp(204.0, 260.0);
    final brightness = Theme.of(context).brightness;

    return SizedBox(
      key: const ValueKey('capture-voice-orb'),
      height: visualSize + 56,
      child: Center(
        child: AnimatedScale(
          key: const ValueKey('capture-voice-orb-scale'),
          scale: _targetScale,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _waveCtrl,
              _pulseCtrl,
              _activationCtrl,
            ]),
            builder: (context, child) {
              return SizedBox(
                width: visualSize,
                height: visualSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      key: const ValueKey('capture-vox-sphere-stage'),
                      size: Size.square(visualSize),
                      painter: _VoxSphereStagePainter(
                        phase: _waveCtrl.value,
                        amplitude: activeLevel,
                        activation: _activationCtrl.value,
                        status: widget.status,
                        brightness: brightness,
                      ),
                    ),
                    _VoxSphereShaderLayer(
                      key: const ValueKey('capture-vox-sphere-shader'),
                      phase: _waveCtrl.value,
                      amplitude: activeLevel,
                      speechPulse: _speechPulse.value,
                      activation: _activationCtrl.value,
                      status: widget.status,
                      brightness: brightness,
                    ),
                    if (_showActivation)
                      IgnorePointer(
                        key: const ValueKey(
                          'capture-vox-sphere-lottie-activation',
                        ),
                        child: Lottie.asset(
                          'assets/lottie/vox_sphere_activation.json',
                          controller: _activationCtrl,
                          width: visualSize * 0.76,
                          height: visualSize * 0.76,
                          fit: BoxFit.contain,
                          repeat: false,
                        ),
                      ),
                    CustomPaint(
                      key: const ValueKey('capture-vox-sphere-canvas'),
                      size: Size.square(visualSize),
                      painter: _VoxSphereOverlayPainter(
                        phase: _waveCtrl.value,
                        amplitude: activeLevel,
                        speechPulse: _speechPulse.value,
                        activation: _activationCtrl.value,
                        status: widget.status,
                        brightness: brightness,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VoxSphereShaderLayer extends StatefulWidget {
  const _VoxSphereShaderLayer({
    super.key,
    required this.phase,
    required this.amplitude,
    required this.speechPulse,
    required this.activation,
    required this.status,
    required this.brightness,
  });

  final double phase;
  final double amplitude;
  final double speechPulse;
  final double activation;
  final CaptureStatus status;
  final Brightness brightness;

  @override
  State<_VoxSphereShaderLayer> createState() => _VoxSphereShaderLayerState();
}

class _VoxSphereShaderLayerState extends State<_VoxSphereShaderLayer> {
  FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _loadProgram();
  }

  Future<void> _loadProgram() async {
    try {
      final program = await FragmentProgram.fromAsset(_voxSphereShaderAsset);
      if (mounted) {
        setState(() => _program = program);
      }
    } on Object {
      if (mounted) {
        setState(() => _program = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RepaintBoundary(
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _VoxSphereShaderPainter(
              program: _program,
              phase: widget.phase,
              amplitude: widget.amplitude,
              speechPulse: widget.speechPulse,
              activation: widget.activation,
              status: widget.status,
              brightness: widget.brightness,
            ),
          ),
        );
      },
    );
  }
}

class _VoxSphereStagePainter extends CustomPainter {
  _VoxSphereStagePainter({
    required this.phase,
    required this.amplitude,
    required this.activation,
    required this.status,
    required this.brightness,
  });

  final double phase;
  final double amplitude;
  final double activation;
  final CaptureStatus status;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.01);
    final radius = size.shortestSide * 0.39;
    final energy = (amplitude + activation * 0.55).clamp(0.0, 1.0);
    final isLight = brightness == Brightness.light;
    final tint = _statusTint(status);
    final deepAlpha = isLight
        ? kVoxSphereStageLightAlpha
        : kVoxSphereStageDarkAlpha;

    final stagePaint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.05),
        colors: [
          const Color(0xFF102649).withValues(alpha: deepAlpha),
          const Color(0xFF10223A).withValues(alpha: deepAlpha * 0.62),
          const Color(0xFF101826).withValues(alpha: deepAlpha * 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.42, 0.74, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.72));
    canvas.drawCircle(center, radius * 1.60, stagePaint);

    final haloPaint = Paint()
      ..isAntiAlias = true
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(
        colors: [
          tint.withValues(alpha: 0.10 + energy * 0.10),
          const Color(0xFF89E4FF).withValues(alpha: 0.045 + energy * 0.070),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.42));
    canvas.drawCircle(center, radius * (1.15 + energy * 0.08), haloPaint);

    final orbitPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(
        0xFF9FDBFF,
      ).withValues(alpha: 0.075 + energy * 0.055);
    for (var i = 0; i < 5; i += 1) {
      final orbitRadius = radius * (0.82 + i * 0.13);
      final wobble = math.sin(phase * math.pi * 2 + i) * radius * 0.015;
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: orbitRadius * 2.0 + wobble,
          height: orbitRadius * (1.56 + i * 0.035),
        ),
        orbitPaint,
      );
    }

    final particlePaint = Paint()
      ..isAntiAlias = true
      ..blendMode = BlendMode.plus
      ..color = const Color(0xFF8FE2FF).withValues(alpha: 0.22);
    for (var i = 0; i < 18; i += 1) {
      final seed = i * 1.618;
      final angle = seed + phase * math.pi * (0.32 + i % 3 * 0.07);
      final distance = radius * (0.78 + (i % 5) * 0.12);
      final opacity =
          0.08 + 0.18 * (0.5 + 0.5 * math.sin(seed + phase * math.pi * 2));
      particlePaint.color =
          (i % 4 == 0 ? const Color(0xFF9D8AFF) : const Color(0xFF8FE2FF))
              .withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * distance,
          center.dy + math.sin(angle) * distance * 0.78,
        ),
        1.0 + (i % 3) * 0.35,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoxSphereStagePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.activation != activation ||
        oldDelegate.status != status ||
        oldDelegate.brightness != brightness;
  }
}

class _VoxSphereShaderPainter extends CustomPainter {
  _VoxSphereShaderPainter({
    required this.program,
    required this.phase,
    required this.amplitude,
    required this.speechPulse,
    required this.activation,
    required this.status,
    required this.brightness,
  });

  final FragmentProgram? program;
  final double phase;
  final double amplitude;
  final double speechPulse;
  final double activation;
  final CaptureStatus status;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final shaderProgram = program;
    if (shaderProgram == null) {
      _drawFallbackBody(canvas, size);
      return;
    }

    final shader = shaderProgram.fragmentShader()
      ..setFloat(0, phase * 8.0)
      ..setFloat(1, size.width)
      ..setFloat(2, size.height)
      ..setFloat(3, amplitude)
      ..setFloat(4, activation)
      ..setFloat(5, speechPulse)
      ..setFloat(6, _statusValue(status))
      ..setFloat(7, brightness == Brightness.light ? 1.0 : 0.0);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _drawFallbackBody(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.01);
    final radius = size.shortestSide * 0.36;
    final energy = (amplitude + activation * 0.5 + speechPulse * 0.2).clamp(
      0.0,
      1.0,
    );
    final bodyPath = _liquidPath(
      center,
      radius * (1.0 + activation * 0.035),
      phase * math.pi * 2,
      radius * (0.010 + amplitude * 0.030),
      gravity: radius * 0.034,
    );
    final tint = _statusTint(status);
    final paint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        colors: [
          Colors.white.withValues(alpha: 0.42),
          const Color(0xFFB7EEFF).withValues(alpha: 0.26 + energy * 0.08),
          tint.withValues(alpha: 0.22 + energy * 0.08),
          const Color(0xFF071C38).withValues(alpha: 0.42),
        ],
        stops: const [0.0, 0.30, 0.64, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.28));
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant _VoxSphereShaderPainter oldDelegate) {
    return oldDelegate.program != program ||
        oldDelegate.phase != phase ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.speechPulse != speechPulse ||
        oldDelegate.activation != activation ||
        oldDelegate.status != status ||
        oldDelegate.brightness != brightness;
  }
}

class _VoxSphereOverlayPainter extends CustomPainter {
  _VoxSphereOverlayPainter({
    required this.phase,
    required this.amplitude,
    required this.speechPulse,
    required this.activation,
    required this.status,
    required this.brightness,
  });

  final double phase;
  final double amplitude;
  final double speechPulse;
  final double activation;
  final CaptureStatus status;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + size.height * 0.01);
    final radius = size.shortestSide * 0.36;
    final phaseRadians = phase * math.pi * 2;
    final activationPulse = math.sin(activation * math.pi).clamp(0.0, 1.0);
    final energy = (amplitude + speechPulse * 0.30 + activationPulse * 0.42)
        .clamp(0.0, 1.0);
    final tint = _statusTint(status);
    final cyan = const Color(0xFF28DAFF);
    final violet = const Color(0xFF8A5DFF);

    final edgePath = _liquidPath(
      center,
      radius * (1.0 + activationPulse * 0.035),
      phaseRadians,
      radius * (0.007 + amplitude * 0.030 + activationPulse * 0.014),
      gravity: radius * 0.034,
    );
    final edgePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.72 + energy * (kVoxSphereEdgeStrokeMax - 0.72)
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.36),
          cyan.withValues(alpha: 0.34),
          Colors.transparent,
          violet.withValues(alpha: 0.16),
          Colors.white.withValues(alpha: 0.24),
          cyan.withValues(alpha: 0.34),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(edgePath, edgePaint);

    final ripplePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus;
    for (var i = 0; i < 4; i += 1) {
      final progress = ((phase * (0.44 + amplitude * 0.32) + i * 0.20) % 1.0);
      final ringRadius = radius * (0.15 + progress * (0.63 + energy * 0.12));
      final alpha = (1.0 - progress).clamp(0.0, 1.0) * (0.10 + energy * 0.20);
      ripplePaint
        ..strokeWidth = 0.55 + energy * 0.55
        ..color = (i.isEven ? cyan : violet).withValues(alpha: alpha * 0.72);
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: ringRadius * 2.0,
          height: ringRadius * (1.68 + math.sin(phaseRadians + i) * 0.06),
        ),
        ripplePaint,
      );
    }

    final topHighlight = Paint()
      ..isAntiAlias = true
      ..blendMode = BlendMode.plus
      ..shader =
          RadialGradient(
            center: const Alignment(-0.45, -0.50),
            colors: [
              Colors.white.withValues(alpha: 0.46),
              cyan.withValues(alpha: 0.11 + energy * 0.10),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(
                center.dx - radius * 0.20,
                center.dy - radius * 0.25,
              ),
              radius: radius * 0.68,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.18, center.dy - radius * 0.32),
        width: radius * 0.95,
        height: radius * 0.40,
      ),
      topHighlight,
    );

    final sweepOffset = math.sin(phaseRadians * 0.82) * radius * 0.16;
    final sweepPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.45
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus
      ..color = violet.withValues(alpha: 0.09 + energy * 0.13);
    final sweepPath = Path()
      ..moveTo(
        center.dx + radius * 0.40 + sweepOffset,
        center.dy - radius * 0.58,
      )
      ..cubicTo(
        center.dx + radius * 0.82,
        center.dy - radius * 0.16,
        center.dx + radius * 0.70,
        center.dy + radius * 0.42,
        center.dx + radius * 0.24,
        center.dy + radius * 0.72,
      );
    canvas.drawPath(sweepPath, sweepPaint);

    final corePaint = Paint()
      ..isAntiAlias = true
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.34 * energy),
          tint.withValues(alpha: 0.20 * energy),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.45));
    canvas.drawCircle(center, radius * (0.10 + energy * 0.10), corePaint);
  }

  @override
  bool shouldRepaint(covariant _VoxSphereOverlayPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.speechPulse != speechPulse ||
        oldDelegate.activation != activation ||
        oldDelegate.status != status ||
        oldDelegate.brightness != brightness;
  }
}

Path _liquidPath(
  Offset center,
  double radius,
  double phase,
  double distortion, {
  required double gravity,
}) {
  final path = Path();
  const segments = 96;
  for (var i = 0; i <= segments; i += 1) {
    final a = i / segments * math.pi * 2;
    final bottomBias = math.max(0.0, math.sin(a)) * gravity;
    final wave =
        math.sin(a * 4 + phase) * distortion * 0.52 +
        math.sin(a * 6 - phase * 1.28) * distortion * 0.28 +
        math.sin(a * 9 + phase * 0.72) * distortion * 0.14;
    final r = radius + wave + bottomBias;
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

Color _statusTint(CaptureStatus status) {
  return switch (status) {
    CaptureStatus.error => const Color(0xFFFF6474),
    CaptureStatus.success => const Color(0xFF55F0C4),
    CaptureStatus.analyzing || CaptureStatus.saving => const Color(0xFF65B8FF),
    _ => const Color(0xFF21D7FF),
  };
}

double _statusValue(CaptureStatus status) {
  return switch (status) {
    CaptureStatus.idle => 0,
    CaptureStatus.recording => 1,
    CaptureStatus.analyzing => 2,
    CaptureStatus.preview => 3,
    CaptureStatus.saving => 3.5,
    CaptureStatus.success => 4,
    CaptureStatus.error => 5,
  };
}

class _GlassMicButton extends StatefulWidget {
  const _GlassMicButton({
    required this.active,
    required this.onStart,
    required this.onStop,
  });

  final bool active;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  State<_GlassMicButton> createState() => _GlassMicButtonState();
}

class _GlassMicButtonState extends State<_GlassMicButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _showLongPressHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('长按开始录音'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 140, left: 60, right: 60),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final lit = widget.active || _pressed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.active ? null : _showLongPressHint,
      onLongPressStart: (_) {
        _setPressed(true);
        HapticFeedback.heavyImpact();
        widget.onStart();
        // micArm sound disabled during recording — avoids audio focus conflict
      },
      onLongPressEnd: (_) {
        _setPressed(false);
        HapticFeedback.lightImpact();
        widget.onStop();
      },
      onLongPressCancel: () {
        _setPressed(false);
        HapticFeedback.lightImpact();
        widget.onStop();
      },
      child: SizedBox(
        width: 132,
        height: 132,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              key: const ValueKey('capture-mic-halo'),
              opacity: _pressed ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(
                        alpha: isLight ? 0.55 : 0.08,
                      ),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.38),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 24,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const SizedBox(width: 122, height: 122),
                  ),
                ),
              ),
            ),
            AnimatedScale(
              key: const ValueKey('capture-mic-scale'),
              scale: _pressed ? 0.88 : 1,
              duration: Duration(milliseconds: _pressed ? 130 : 430),
              curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    key: const ValueKey('capture-mic-button'),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: lit
                            ? (isLight ? 0.78 : 0.18)
                            : (isLight ? 0.65 : 0.12),
                      ),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.03),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 92,
                      height: 92,
                      child: Icon(
                        lit ? Icons.mic : Icons.mic_none,
                        size: 34,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  const _PreviewItem({required this.preview});

  final CaptureDraftPreview preview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        key: const ValueKey('capture-preview-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    preview.type == CaptureDraftType.task ? '任务' : '笔记',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(preview.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(preview.content),
            if (preview.type == CaptureDraftType.task &&
                preview.taskDate != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Tag(label: '📅 ${_fmtDate(preview.taskDate!)}'),
                  if (preview.startTime != null)
                    _Tag(
                      label:
                          '⏰ ${_fmtTime(preview.startTime!)}'
                          '${preview.endTime != null ? ' - ${_fmtTime(preview.endTime!)}' : ''}',
                    ),
                  if (preview.importance != null)
                    _Tag(label: _importanceLabel(preview.importance!)),
                ],
              ),
            ] else if (preview.type == CaptureDraftType.note &&
                preview.folderName != null &&
                preview.folderName!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _Tag(label: '📁 ${preview.folderName}'),
              ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String _fmtTime(CaptureClockTime t) {
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

String _importanceLabel(TimelineImportance i) {
  return switch (i) {
    TimelineImportance.high => '🔴 高优先级',
    TimelineImportance.medium => '🟡 中等',
    TimelineImportance.low => '🟢 低优先级',
  };
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
