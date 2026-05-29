import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/capture_draft_preview.dart';
import '../../../domain/entities/timeline_task.dart';
import '../../../infrastructure/audio/sound_service.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/animations/rive_controller.dart';
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
            // Rive state machine overlay — drives visual state for the voice button area
            Positioned(
              left: 0,
              right: 0,
              bottom: 72,
              child: Center(
                child: VoiceButtonRive(
                  state: _captureStatusToVoiceButtonState(state.status),
                  size: 180,
                ),
              ),
            ),
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
        _VoiceOrb(status: state.status, transcript: state.transcript),
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
    final colorScheme = Theme.of(context).colorScheme;
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
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 26,
                offset: const Offset(0, 14),
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

class _VoiceOrb extends ConsumerStatefulWidget {
  const _VoiceOrb({required this.status, required this.transcript});

  final CaptureStatus status;
  final String transcript;

  @override
  ConsumerState<_VoiceOrb> createState() => _VoiceOrbState();
}

class _VoiceOrbState extends ConsumerState<_VoiceOrb>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _speechPulse;
  StreamSubscription<double>? _amplitudeSub;
  double _amplitude = 0.0;

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
    _speechPulse = CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeOutCubic,
    );
    _syncAmplitudeSubscription();
  }

  @override
  void didUpdateWidget(covariant _VoiceOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != oldWidget.status) {
      _syncAmplitudeSubscription();
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
    super.dispose();
  }

  double get _targetScale {
    return switch (widget.status) {
      CaptureStatus.recording => 1.12 + _amplitude * 0.16,
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
      if (_amplitude != 0 && mounted) {
        setState(() => _amplitude = 0);
      } else {
        _amplitude = 0;
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeLevel = widget.status == CaptureStatus.recording
        ? _amplitude
        : widget.status == CaptureStatus.analyzing
        ? 0.22
        : 0.04;

    return SizedBox(
      key: const ValueKey('capture-voice-orb'),
      height: 220,
      child: Center(
        child: AnimatedScale(
          key: const ValueKey('capture-voice-orb-scale'),
          scale: _targetScale,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: AnimatedBuilder(
            animation: Listenable.merge([_waveCtrl, _pulseCtrl]),
            builder: (context, child) {
              return RepaintBoundary(
                child: CustomPaint(
                  size: const Size(176, 176),
                  painter: _VoiceOrbPainter(
                    phase: _waveCtrl.value,
                    amplitude: activeLevel,
                    speechPulse: _speechPulse.value,
                    status: widget.status,
                    primary: colorScheme.primary,
                    secondary: colorScheme.secondary,
                    surface: colorScheme.surface,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VoiceOrbPainter extends CustomPainter {
  _VoiceOrbPainter({
    required this.phase,
    required this.amplitude,
    required this.speechPulse,
    required this.status,
    required this.primary,
    required this.secondary,
    required this.surface,
  });

  final double phase;
  final double amplitude;
  final double speechPulse;
  final CaptureStatus status;
  final Color primary;
  final Color secondary;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.34;
    final phaseRadians = phase * math.pi * 2;
    final energy = (amplitude + speechPulse * 0.42).clamp(0.0, 1.0);
    final tint = status == CaptureStatus.error ? Colors.redAccent : primary;

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              tint.withValues(alpha: 0.26 + energy * 0.16),
              secondary.withValues(alpha: 0.14),
              surface.withValues(alpha: 0.02),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.47),
          );
    canvas.drawCircle(center, size.width * (0.40 + energy * 0.06), glowPaint);

    for (var i = 0; i < 3; i += 1) {
      final ring = Paint()
        ..color = tint.withValues(alpha: 0.11 - i * 0.02 + energy * 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(
        _blobPath(
          center,
          baseRadius + 16 + i * 11,
          phaseRadians * (0.7 + i * 0.25),
          4 + energy * 14,
        ),
        ring,
      );
    }

    final fillPaint = Paint()
      ..shader =
          RadialGradient(
            center: const Alignment(-0.35, -0.42),
            colors: [
              Colors.white.withValues(alpha: 0.52),
              tint.withValues(alpha: 0.34 + energy * 0.16),
              secondary.withValues(alpha: 0.28),
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: baseRadius * 1.25),
          );
    canvas.drawPath(
      _blobPath(center, baseRadius, phaseRadians, 5 + energy * 18),
      fillPaint,
    );

    final edgePaint = Paint()
      ..color = tint.withValues(alpha: 0.48 + energy * 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      _blobPath(center, baseRadius + 1, phaseRadians * 1.2, 5 + energy * 18),
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
      final wave =
          math.sin(a * 3 + phase) * distortion * 0.55 +
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
  bool shouldRepaint(covariant _VoiceOrbPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude ||
        oldDelegate.phase != phase ||
        oldDelegate.speechPulse != speechPulse ||
        oldDelegate.status != status ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.surface != surface;
  }
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
    final lit = widget.active || _pressed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.active ? null : _showLongPressHint,
      onLongPressStart: (_) {
        _setPressed(true);
        HapticFeedback.heavyImpact();
        unawaited(SoundService.micArm());
        widget.onStart();
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
                      color: colorScheme.primary.withValues(alpha: 0.22),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.38),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.38),
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
                  filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                  child: DecoratedBox(
                    key: const ValueKey('capture-mic-button'),
                    decoration: BoxDecoration(
                      color:
                          (lit
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surface)
                              .withValues(alpha: lit ? 0.52 : 0.40),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
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

VoiceButtonState _captureStatusToVoiceButtonState(CaptureStatus status) {
  return switch (status) {
    CaptureStatus.idle => VoiceButtonState.idle,
    CaptureStatus.recording => VoiceButtonState.recording,
    CaptureStatus.analyzing => VoiceButtonState.processing,
    CaptureStatus.preview => VoiceButtonState.success,
    CaptureStatus.saving => VoiceButtonState.processing,
    CaptureStatus.success => VoiceButtonState.success,
    CaptureStatus.error => VoiceButtonState.error,
  };
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
