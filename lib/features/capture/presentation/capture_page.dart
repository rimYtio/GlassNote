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
                _VoiceWaveform(active: state.status == CaptureStatus.recording),
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
              ] else
                GlassCard(
                  child: Text(
                    state.status == CaptureStatus.success
                        ? '已创建'
                        : '长按下方话筒，说出想法、笔记或任务。',
                  ),
                ),
            ],
          ),
          if (state.status != CaptureStatus.preview &&
              state.status != CaptureStatus.saving)
            Positioned(
              left: 0,
              right: 0,
              bottom: 104,
              child: Center(
                child: _GlassMicButton(
                  active: state.status == CaptureStatus.recording,
                  onDown: controller.startRecording,
                  onUp: controller.stopRecording,
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

class _VoiceWaveform extends StatefulWidget {
  const _VoiceWaveform({required this.active});

  final bool active;

  @override
  State<_VoiceWaveform> createState() => _VoiceWaveformState();
}

class _VoiceWaveformState extends State<_VoiceWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaveformPainter(
              progress: _controller.value,
              active: widget.active,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.progress,
    required this.active,
    required this.color,
  });

  final double progress;
  final bool active;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: active ? 0.70 : 0.22)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    final centerY = size.height / 2;
    final bars = 28;
    final gap = size.width / bars;
    for (var i = 0; i < bars; i += 1) {
      final phase = progress * math.pi * 2 + i * 0.55;
      final height = active
          ? 24 + math.sin(phase).abs() * 92
          : 18 + math.sin(i).abs() * 28;
      final x = gap * i + gap / 2;
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active ||
        oldDelegate.color != color;
  }
}

class _GlassMicButton extends StatefulWidget {
  const _GlassMicButton({
    required this.active,
    required this.onDown,
    required this.onUp,
  });

  final bool active;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  State<_GlassMicButton> createState() => _GlassMicButtonState();
}

class _GlassMicButtonState extends State<_GlassMicButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lit = widget.active || _pressed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _setPressed(true);
        widget.onDown();
      },
      onTapUp: (_) {
        _setPressed(false);
        widget.onUp();
      },
      onTapCancel: () {
        _setPressed(false);
        widget.onUp();
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
