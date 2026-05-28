import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 168),
            children: [
              _CaptionCard(state: state),
              if (state.previews.isEmpty &&
                  state.status != CaptureStatus.preview) ...[
                const SizedBox(height: 24),
                if (state.status == CaptureStatus.recording ||
                    state.status == CaptureStatus.analyzing)
                  const SizedBox(height: 140),
                const SizedBox(height: 24),
              ] else
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
              ] else if (state.status != CaptureStatus.recording &&
                  state.status != CaptureStatus.analyzing)
                const _IdleFlow(),
            ],
          ),
          if (state.status == CaptureStatus.recording)
            const _VoiceBall(),
          if (state.status != CaptureStatus.preview &&
              state.status != CaptureStatus.saving)
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
      ),
    );
  }
}

class _CaptionCard extends StatelessWidget {
  const _CaptionCard({required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    final text = state.errorMessage ?? state.transcript;
    final title = switch (state.status) {
      CaptureStatus.recording => '正在聆听',
      CaptureStatus.analyzing => '正在整理',
      CaptureStatus.preview => '识别完成',
      CaptureStatus.error => '捕获失败',
      CaptureStatus.success => '创建完成',
      _ => '语音捕获',
    };

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(text.isEmpty ? '字幕会在你说话时出现在这里。' : text),
        ],
      ),
    );
  }
}

class _IdleFlow extends StatefulWidget {
  const _IdleFlow();

  @override
  State<_IdleFlow> createState() => _IdleFlowState();
}

class _IdleFlowState extends State<_IdleFlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _IdleFlowPainter(phase: _ctrl.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _IdleFlowPainter extends CustomPainter {
  _IdleFlowPainter({required this.phase});
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) * 0.28;
    final outerPaint = Paint()
      ..color = const Color(0x885B8DEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var r = 0; r < 3; r++) {
      final path = Path();
      final radius = baseRadius + r * 14;
      final circles = r == 0 ? 11 : r == 1 ? 17 : 23;
      for (var i = 0; i <= circles; i++) {
        final a = i / circles * math.pi * 2;
        final wave =
            math.sin(a * 3 + phase * math.pi * 2 * (1 + r * 0.4)) * 4;
        final x = center.dx + math.cos(a) * (radius + wave);
        final y = center.dy + math.sin(a) * (radius + wave);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      outerPaint.color = const Color(0x335B8DEF).withValues(
        alpha: 0.15 + r * 0.08,
      );
      canvas.drawPath(path, outerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _IdleFlowPainter oldDelegate) =>
      oldDelegate.phase != phase;
}

class _VoiceBall extends ConsumerStatefulWidget {
  const _VoiceBall();

  @override
  ConsumerState<_VoiceBall> createState() => _VoiceBallState();
}

class _VoiceBallState extends ConsumerState<_VoiceBall>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryAnimation;
  late final AnimationController _waveCtrl;
  double _amplitude = 0.0;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryAnimation = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOutBack,
    );
    _entryCtrl.forward();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _startAmplitudeListener();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  void _startAmplitudeListener() {
    ref.read(audioInputServiceProvider).amplitudeStream.listen((a) {
      if (mounted) {
        setState(() => _amplitude = a);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: Center(
        child: ScaleTransition(
          scale: _entryAnimation,
          child: AnimatedBuilder(
            animation: _waveCtrl,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(200, 200),
                painter: _VoiceBallPainter(
                  fillColor: colorScheme.primaryContainer
                      .withValues(alpha: 0.22),
                  ringColor: colorScheme.primary.withValues(alpha: 0.55),
                  amplitude: _amplitude,
                  wavePhase: _waveCtrl.value,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VoiceBallPainter extends CustomPainter {
  _VoiceBallPainter({
    required this.fillColor,
    required this.ringColor,
    required this.amplitude,
    required this.wavePhase,
  });

  final Color fillColor;
  final Color ringColor;
  final double amplitude;
  final double wavePhase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 - 6;
    final distortion = amplitude * 14;
    final linearPhase = wavePhase * math.pi * 2;

    final path = Path();
    const segments = 50;
    for (var i = 0; i <= segments; i++) {
      final a = i / segments * math.pi * 2;
      final wave =
          math.sin(a * 5 + linearPhase) * distortion * 0.8 +
          math.sin(a * 3 + linearPhase * 1.6) * distortion * 0.5 +
          math.sin(a * 8 + linearPhase * 0.3) * distortion * 0.3;
      final r = baseRadius + wave;
      final x = center.dx + math.cos(a) * r;
      final y = center.dy + math.sin(a) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius - 2, fillPaint);
    canvas.drawPath(path, fillPaint);

    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _VoiceBallPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude ||
        oldDelegate.wavePhase != wavePhase;
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
              widget.onStart();
            },
      onLongPressEnd: (_) {
              _setPressed(false);
              widget.onStop();
            },
      onLongPressCancel: () {
        _setPressed(false);
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
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.28),
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
                              .withValues(alpha: lit ? 0.42 : 0.30),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    preview.type == CaptureDraftType.task ? '任务' : '笔记',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(preview.title,
                style: Theme.of(context).textTheme.titleLarge),
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
                      label: '⏰ ${_fmtTime(preview.startTime!)}'
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
