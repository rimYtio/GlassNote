import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/capture_draft_preview.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'capture_controller.dart';

class CapturePage extends ConsumerWidget {
  const CapturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureControllerProvider);
    final controller = ref.read(captureControllerProvider.notifier);

    return GlassScaffold(
      title: '捕获',
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 168),
            children: [
              _CaptionCard(state: state),
              if (state.preview == null) ...[
                const SizedBox(height: 24),
                _VoiceWaveform(active: state.status == CaptureStatus.recording),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 16),
              if (state.preview != null)
                _PreviewCard(
                  preview: state.preview!,
                  saving: state.status == CaptureStatus.saving,
                  onConfirm: controller.confirmPreview,
                  onCancel: controller.cancelPreview,
                )
              else
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

class _GlassMicButton extends StatelessWidget {
  const _GlassMicButton({
    required this.active,
    required this.onDown,
    required this.onUp,
  });

  final bool active;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: DecoratedBox(
            key: const ValueKey('capture-mic-button'),
            decoration: BoxDecoration(
              color:
                  (active ? colorScheme.primaryContainer : colorScheme.surface)
                      .withValues(alpha: active ? 0.42 : 0.30),
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
                active ? Icons.mic : Icons.mic_none,
                size: 34,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.preview,
    required this.saving,
    required this.onConfirm,
    required this.onCancel,
  });

  final CaptureDraftPreview preview;
  final bool saving;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      key: const ValueKey('capture-preview-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preview.type == CaptureDraftType.task ? '任务预览' : '笔记预览',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(preview.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(preview.content),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: saving ? null : onCancel,
                child: const Text('取消'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: saving ? null : onConfirm,
                child: Text(saving ? '创建中...' : '确认创建'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
