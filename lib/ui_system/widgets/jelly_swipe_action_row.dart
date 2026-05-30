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
  static const _actionWidth = 80.0;
  static const _actionGap = 6.0;
  static const _openThreshold = 46.0;

  double _dragOffset = 0;
  bool _isDragging = false;

  double _leadingExtent(int count) =>
      count > 0 ? count * _actionWidth + (count - 1) * _actionGap : 0.0;

  double _trailingExtent(int count) =>
      count > 0 ? count * _actionWidth + (count - 1) * _actionGap : 0.0;

  @override
  Widget build(BuildContext context) {
    final offset = _isDragging ? _dragOffset : _settledOffset;
    final leadingCount = widget.leadingActions.length;
    final trailingCount = widget.trailingActions.length;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _hasActions
          ? (_) => setState(() => _isDragging = true)
          : null,
      onHorizontalDragUpdate: _hasActions ? _handleDragUpdate : null,
      onHorizontalDragEnd: _hasActions ? _handleDragEnd : null,
      onHorizontalDragCancel: _hasActions ? _closeDrag : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final leadExtent = _leadingExtent(leadingCount)
                .clamp(0.0, maxW * 0.70);
            final trailExtent = _trailingExtent(trailingCount)
                .clamp(0.0, maxW * 0.70);

            final dx = widget.isOpen
                ? offset
                : (_isDragging ? offset : 0.0);

            return Stack(
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              children: [
                if (widget.isOpen || _isDragging) ...[
                  if (leadingCount > 0)
                    PositionedDirectional(
                      top: 0,
                      bottom: 0,
                      start: 0,
                      width: leadExtent,
                      child: _ActionRail(
                        alignment: Alignment.centerLeft,
                        actions: widget.leadingActions,
                        actionWidth: _actionWidth,
                        gap: _actionGap,
                        onActionPressed: widget.onClose,
                      ),
                    ),
                  if (trailingCount > 0)
                    PositionedDirectional(
                      top: 0,
                      bottom: 0,
                      end: 0,
                      width: trailExtent,
                      child: _ActionRail(
                        alignment: Alignment.centerRight,
                        actions: widget.trailingActions,
                        actionWidth: _actionWidth,
                        gap: _actionGap,
                        onActionPressed: widget.onClose,
                      ),
                    ),
                ],
                Transform.translate(
                  offset: Offset(dx, 0),
                  child: SizedBox(
                    width: maxW,
                    child: widget.child,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double get _settledOffset {
    if (!widget.isOpen) return 0;
    return switch (widget.openSide) {
      JellySwipeSide.leading => _leadingExtent(widget.leadingActions.length),
      JellySwipeSide.trailing => -_trailingExtent(widget.trailingActions.length),
      null => 0,
    };
  }

  bool get _hasActions =>
      widget.leadingActions.isNotEmpty || widget.trailingActions.isNotEmpty;

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    final maxLead = _leadingExtent(widget.leadingActions.length);
    final maxTrail = _trailingExtent(widget.trailingActions.length);
    setState(() => _dragOffset = (_dragOffset + delta).clamp(-maxTrail, maxLead));
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
    required this.actionWidth,
    required this.gap,
    required this.onActionPressed,
  });

  final Alignment alignment;
  final List<JellySwipeAction> actions;
  final double actionWidth;
  final double gap;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            SizedBox(
              width: actionWidth,
              child: _SwipeActionButton(
                action: actions[i],
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onActionPressed();
                  actions[i].onPressed();
                },
              ),
            ),
          ],
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

    return SizedBox.expand(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(action.icon, size: 20, color: foreground),
                  const SizedBox(width: 6),
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
