import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum JellySwipeSide { leading, trailing }

enum JellySwipeActionStyle { tonal, filled, danger }

class JellySwipeAction {
  const JellySwipeAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.style = JellySwipeActionStyle.tonal,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final JellySwipeActionStyle style;
}

class JellySwipeActionRow extends StatefulWidget {
  const JellySwipeActionRow({
    required this.child,
    required this.isOpen,
    required this.onOpen,
    required this.onClose,
    super.key,
    this.openSide,
    this.leadingActions = const [],
    this.trailingActions = const [],
  });

  final Widget child;
  final bool isOpen;
  final JellySwipeSide? openSide;
  final ValueChanged<JellySwipeSide> onOpen;
  final VoidCallback onClose;
  final List<JellySwipeAction> leadingActions;
  final List<JellySwipeAction> trailingActions;

  @override
  State<JellySwipeActionRow> createState() => _JellySwipeActionRowState();
}

class _JellySwipeActionRowState extends State<JellySwipeActionRow> {
  static const _actionWidth = 86.0;
  static const _openThreshold = 46.0;

  double _dragOffset = 0;
  bool _isDragging = false;

  double get _leadingExtent => widget.leadingActions.length * _actionWidth;

  double get _trailingExtent => widget.trailingActions.length * _actionWidth;

  @override
  Widget build(BuildContext context) {
    final offset = _isDragging ? _dragOffset : _settledOffset;
    final scaleY = 1.0 + math.min(offset.abs() / 1800, 0.035).toDouble();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _hasActions
          ? (_) => setState(() => _isDragging = true)
          : null,
      onHorizontalDragUpdate: _hasActions ? _handleDragUpdate : null,
      onHorizontalDragEnd: _hasActions ? _handleDragEnd : null,
      onHorizontalDragCancel: _hasActions ? _closeDrag : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isDragging || widget.isOpen)
            Positioned.fill(
              child: ClipRect(
                child: Row(
                  children: [
                    if (widget.leadingActions.isNotEmpty)
                      SizedBox(
                        width: _leadingExtent,
                        child: _ActionRail(
                          alignment: Alignment.centerLeft,
                          actions: widget.leadingActions,
                          onActionPressed: widget.onClose,
                        ),
                      ),
                    const Spacer(),
                    if (widget.trailingActions.isNotEmpty)
                      SizedBox(
                        width: _trailingExtent,
                        child: _ActionRail(
                          alignment: Alignment.centerRight,
                          actions: widget.trailingActions,
                          onActionPressed: widget.onClose,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          AnimatedContainer(
            duration: _isDragging
                ? Duration.zero
                : const Duration(milliseconds: 430),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..setEntry(0, 3, offset)
              ..setEntry(1, 1, scaleY),
            transformAlignment: Alignment.center,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  bool get _hasActions =>
      widget.leadingActions.isNotEmpty || widget.trailingActions.isNotEmpty;

  double get _settledOffset {
    if (!widget.isOpen) {
      return 0;
    }
    return switch (widget.openSide) {
      JellySwipeSide.leading => _leadingExtent,
      JellySwipeSide.trailing => -_trailingExtent,
      null => 0,
    };
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final next = (_dragOffset + delta).clamp(-_trailingExtent, _leadingExtent);
    setState(() => _dragOffset = next.toDouble());
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpenLeading =
        widget.leadingActions.isNotEmpty &&
        (_dragOffset > _openThreshold || velocity > 520);
    final shouldOpenTrailing =
        widget.trailingActions.isNotEmpty &&
        (_dragOffset < -_openThreshold || velocity < -520);

    setState(() {
      _isDragging = false;
      _dragOffset = 0;
    });

    if (shouldOpenLeading) {
      widget.onOpen(JellySwipeSide.leading);
    } else if (shouldOpenTrailing) {
      widget.onOpen(JellySwipeSide.trailing);
    } else {
      widget.onClose();
    }
  }

  void _closeDrag() {
    setState(() {
      _isDragging = false;
      _dragOffset = 0;
    });
    widget.onClose();
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.alignment,
    required this.actions,
    required this.onActionPressed,
  });

  final Alignment alignment;
  final List<JellySwipeAction> actions;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _SwipeActionButton(
                action: action,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onActionPressed();
                  action.onPressed();
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  const _SwipeActionButton({required this.action, required this.onPressed});

  final JellySwipeAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = action.style == JellySwipeActionStyle.danger
        ? colorScheme.onErrorContainer
        : colorScheme.onSecondaryContainer;
    final background = action.style == JellySwipeActionStyle.danger
        ? colorScheme.errorContainer.withValues(alpha: 0.82)
        : colorScheme.secondaryContainer.withValues(alpha: 0.72);

    return SizedBox(
      width: 78,
      height: 58,
      child: FilledButton.tonalIcon(
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(action.icon, size: 18),
        label: Text(action.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
