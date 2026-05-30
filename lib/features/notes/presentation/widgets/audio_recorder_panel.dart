// Audio recording removed from product scope
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderPanel extends StatefulWidget {
  const AudioRecorderPanel({super.key, required this.onSaved});

  final Future<void> Function(String filePath) onSaved;

  @override
  State<AudioRecorderPanel> createState() => _AudioRecorderPanelState();
}

class _AudioRecorderPanelState extends State<AudioRecorderPanel> {
  final _recorder = AudioRecorder();
  StreamSubscription<RecordState>? _stateSub;
  StreamSubscription<Amplitude>? _ampSub;
  RecordState _recordState = RecordState.stop;
  double _amplitude = 0.0;
  Duration _duration = Duration.zero;
  Timer? _timer;
  String? _filePath;
  bool _saving = false;
  bool _hasPermission = false;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _ampSub?.cancel();
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final has = await _recorder.hasPermission();
    if (mounted) {
      setState(() {
        _hasPermission = has;
        _permissionChecked = true;
      });
    }
  }

  Future<void> _startRecording() async {
    if (!_permissionChecked) {
      await _checkPermission();
    }
    if (!_hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('未获得麦克风权限')),
        );
      }
      return;
    }

    try {
      final config = const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        numChannels: 1,
        bitRate: 128000,
      );
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path, 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');
      _filePath = tempPath;
      await _recorder.start(config, path: tempPath);

      _stateSub = _recorder.onStateChanged().listen((state) {
        if (mounted) {
          setState(() => _recordState = state);
        }
      });

      _ampSub =
          _recorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amp) {
            if (mounted) {
              final db = amp.current;
              final normalized =
                  db.isNaN || db.isInfinite ? 0.0 : ((db + 55) / 55).clamp(0.0, 1.0);
              setState(() => _amplitude = normalized);
            }
          });

      _duration = Duration.zero;
      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (mounted) {
          setState(() => _duration += const Duration(milliseconds: 200));
        }
      });
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动录音失败: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    _stateSub?.cancel();
    _stateSub = null;
    _ampSub?.cancel();
    _ampSub = null;
    _timer?.cancel();
    _timer = null;

    final path = await _recorder.stop();
    if (path != null) {
      _filePath = path;
    }

    if (mounted) {
      setState(() {
        _recordState = RecordState.stop;
        _amplitude = 0.0;
      });
    }
  }

  Future<void> _save() async {
    if (_filePath == null) return;
    setState(() => _saving = true);
    try {
      await widget.onSaved(_filePath!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
        setState(() => _saving = false);
      }
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRecording = _recordState != RecordState.stop;
    final hasRecording = _filePath != null && !isRecording;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewPadding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRecording ? '正在录音' : '录制音频',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_duration),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isRecording ? colorScheme.error : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _WaveformWidget(
                amplitude: _amplitude,
                isRecording: isRecording,
                hasRecording: hasRecording,
                primaryColor: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isRecording && !hasRecording)
                _CircleButton(
                  icon: Icons.mic,
                  color: colorScheme.primary,
                  size: 72,
                  onTap: _saving ? null : _startRecording,
                )
              else if (isRecording)
                _CircleButton(
                  icon: Icons.stop,
                  color: colorScheme.error,
                  size: 72,
                  onTap: _stopRecording,
                )
              else
                _CircleButton(
                  icon: Icons.mic,
                  color: colorScheme.primary,
                  size: 56,
                  onTap: _saving ? null : _startRecording,
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (hasRecording && !isRecording)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _cancel,
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? '保存中...' : '保存'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.color,
    required this.size,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Icon(icon, size: size * 0.44, color: color),
      ),
    );
  }
}

class _WaveformWidget extends StatefulWidget {
  const _WaveformWidget({
    required this.amplitude,
    required this.isRecording,
    required this.hasRecording,
    required this.primaryColor,
  });

  final double amplitude;
  final bool isRecording;
  final bool hasRecording;
  final Color primaryColor;

  @override
  State<_WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<_WaveformWidget>
    with SingleTickerProviderStateMixin {
  final _samples = List<double>.filled(40, 0.03);
  late final AnimationController _animCtrl;
  int _writeIndex = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isRecording) {
      _animCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _animCtrl.repeat();
      } else {
        _animCtrl.stop();
      }
    }
    if (widget.isRecording && widget.amplitude > 0) {
      _samples[_writeIndex % _samples.length] = widget.amplitude;
      _writeIndex++;
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, child) {
        return RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _WaveformPainter(
              samples: _samples,
              isRecording: widget.isRecording,
              hasRecording: widget.hasRecording,
              color: widget.primaryColor,
              writeIndex: _writeIndex,
            ),
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.samples,
    required this.isRecording,
    required this.hasRecording,
    required this.color,
    required this.writeIndex,
  });

  final List<double> samples;
  final bool isRecording;
  final bool hasRecording;
  final Color color;
  final int writeIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = samples.length;
    final barWidth = size.width / barCount;
    final maxBarHeight = size.height;
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var i = 0; i < barCount; i++) {
      final sample = samples[i].clamp(0.0, 1.0);
      final barHeight = (sample * maxBarHeight * 0.8) + (maxBarHeight * 0.08);
      final x = i * barWidth + barWidth * 0.15;
      final currentIndex = (writeIndex - 1) % barCount;
      final paint = isRecording && i == currentIndex ? activePaint : fillPaint;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, (maxBarHeight - barHeight) / 2, barWidth * 0.7, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
