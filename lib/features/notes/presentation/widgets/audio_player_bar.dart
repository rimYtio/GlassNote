// Audio recording removed from product scope
import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerBar extends StatefulWidget {
  const AudioPlayerBar({
    super.key,
    required this.filePath,
    this.label,
    this.onDelete,
  });

  final String filePath;
  final String? label;
  final VoidCallback? onDelete;

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  String _fileName = '';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutCubic);
    _fileName = widget.label ?? widget.filePath.split('/').last;
    _setupPlayer();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _pulseCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  void _setupPlayer() {
    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _playerState = state);
        if (state == PlayerState.playing) {
          _pulseCtrl.repeat(reverse: true);
        } else {
          _pulseCtrl.stop();
        }
      }
    });

    _positionSub = _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _durationSub = _player.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });

    _player.setSourceDeviceFile(widget.filePath);
  }

  Future<void> _togglePlay() async {
    final state = _playerState;
    if (state == PlayerState.playing) {
      await _player.pause();
      return;
    }
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('录音文件不存在')),
          );
        }
        return;
      }
      if (state == PlayerState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play(DeviceFileSource(widget.filePath));
    } catch (e) {
      debugPrint('[AudioAttachment] play failed path=${widget.filePath} error=$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('录音文件无法播放')),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;

        return SizedBox(
          width: width,
          child: _buildContent(context),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPlaying = _playerState == PlayerState.playing;
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _togglePlay,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final scale = isPlaying ? 1.0 + _pulse.value * 0.08 : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withValues(
                              alpha: isPlaying ? 0.18 : 0.1,
                            ),
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 26,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                    onPressed: widget.onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.onSurface.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
