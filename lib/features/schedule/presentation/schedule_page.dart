import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/timeline_task.dart';
import '../../../ui_system/widgets/glass_search_field.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'timeline_controller.dart';

const _timelineTodaySliverKey = ValueKey<String>('timeline-today-sliver');

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  static const _rangeDays = 14;

  DateTime? _anchorDate;
  DateTime? _overlayDate;
  bool _showDateOverlay = false;
  Timer? _overlayHideTimer;
  Timer? _overlayRemoveTimer;

  DateTime get _today => _dateOnly(DateTime.now());

  DateTime get _timelineAnchor => _anchorDate ?? _today;

  @override
  void dispose() {
    _overlayHideTimer?.cancel();
    _overlayRemoveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;
    final anchorDate = _timelineAnchor;
    final startDate = anchorDate.subtract(const Duration(days: _rangeDays));
    final endDate = anchorDate.add(const Duration(days: _rangeDays));
    final tasks = ref.watch(
      timelineTasksRangeProvider((startDate: startDate, endDate: endDate)),
    );

    return GlassScaffold(
      title: '时间线',
      actions: [
        IconButton(
          tooltip: '查看任务日历',
          icon: const Icon(Icons.calendar_month_rounded),
          onPressed: () => _showCalendarDialog(context, anchorDate: anchorDate),
        ),
        IconButton(
          tooltip: '搜索任务',
          icon: const Icon(Icons.search_rounded),
          onPressed: () => _showSearchDialog(context),
        ),
      ],
      body: Stack(
        children: [
          tasks.when(
            data: (items) => _TimelineDayList(
              rangeDays: _rangeDays,
              tasks: items,
              today: today,
              anchorDate: anchorDate,
              onCenterDateChanged: _showOverlayForDate,
            ),
            error: (error, _) => Center(child: Text('时间线加载失败: $error')),
            loading: () => const SizedBox(height: 48),
          ),
          if (_overlayDate != null)
            Positioned.fill(
              child: _TimelineDateOverlay(
                date: _overlayDate!,
                visible: _showDateOverlay,
              ),
            ),
          Positioned(
            right: 6,
            bottom: 12,
            child: FloatingActionButton(
              tooltip: '新增任务',
              onPressed: () =>
                  _showTimelineTaskEditorSheet(context, initialDate: today),
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSearchDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) => const _TimelineSearchDialog(),
    );
  }

  Future<void> _showCalendarDialog(
    BuildContext context, {
    required DateTime anchorDate,
  }) async {
    final selectedDate = await showDialog<DateTime>(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) => _TimelineCalendarDialog(initialDate: anchorDate),
    );
    if (selectedDate == null || !mounted) {
      return;
    }
    setState(() => _anchorDate = _dateOnly(selectedDate));
  }

  void _showOverlayForDate(DateTime date) {
    _overlayHideTimer?.cancel();
    _overlayRemoveTimer?.cancel();
    setState(() {
      _overlayDate = _dateOnly(date);
      _showDateOverlay = true;
    });

    _overlayHideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() => _showDateOverlay = false);
      _overlayRemoveTimer = Timer(const Duration(milliseconds: 320), () {
        if (mounted && !_showDateOverlay) {
          setState(() => _overlayDate = null);
        }
      });
    });
  }
}

Future<void> _showTimelineTaskEditorSheet(
  BuildContext context, {
  required DateTime initialDate,
  TimelineTask? task,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _TimelineTaskEditorSheet(initialDate: initialDate, task: task),
  );
}

class _TimelineDayList extends StatefulWidget {
  const _TimelineDayList({
    required this.rangeDays,
    required this.tasks,
    required this.today,
    required this.anchorDate,
    required this.onCenterDateChanged,
  });

  final int rangeDays;
  final List<TimelineTask> tasks;
  final DateTime today;
  final DateTime anchorDate;
  final ValueChanged<DateTime> onCenterDateChanged;

  @override
  State<_TimelineDayList> createState() => _TimelineDayListState();
}

class _TimelineDayListState extends State<_TimelineDayList> {
  final _dayKeys = <DateTime, GlobalKey>{};
  DateTime? _lastNotifiedDay;

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<TimelineTask>>{};
    for (final task in widget.tasks) {
      grouped.putIfAbsent(_dateOnly(task.taskDate), () => []).add(task);
    }

    final pastDays = [
      for (var offset = widget.rangeDays; offset >= 1; offset -= 1)
        widget.anchorDate.subtract(Duration(days: offset)),
    ];
    final futureDays = [
      for (var offset = 1; offset <= widget.rangeDays; offset += 1)
        widget.anchorDate.add(Duration(days: offset)),
    ];

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: CustomScrollView(
        key: const ValueKey('timeline-scroll-view'),
        center: _timelineTodaySliverKey,
        slivers: [
          SliverList.builder(
            itemCount: pastDays.length,
            itemBuilder: (context, index) {
              final day = pastDays[index];
              return KeyedSubtree(
                key: _keyFor(day),
                child: _TimelineDayEntry(
                  day: day,
                  today: widget.today,
                  tasks: grouped[day] ?? const <TimelineTask>[],
                  showDivider: index > 0,
                ),
              );
            },
          ),
          SliverList(
            key: _timelineTodaySliverKey,
            delegate: SliverChildListDelegate.fixed([
              KeyedSubtree(
                key: _keyFor(widget.anchorDate),
                child: _TimelineDayEntry(
                  day: widget.anchorDate,
                  today: widget.today,
                  tasks: grouped[widget.anchorDate] ?? const <TimelineTask>[],
                  showDivider: false,
                ),
              ),
            ]),
          ),
          SliverList.builder(
            itemCount: futureDays.length,
            itemBuilder: (context, index) {
              final day = futureDays[index];
              return KeyedSubtree(
                key: _keyFor(day),
                child: _TimelineDayEntry(
                  day: day,
                  today: widget.today,
                  tasks: grouped[day] ?? const <TimelineTask>[],
                  showDivider: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  GlobalKey _keyFor(DateTime day) {
    return _dayKeys.putIfAbsent(_dateOnly(day), GlobalKey.new);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      _notifyCenterDate();
    }
    return false;
  }

  void _notifyCenterDate() {
    if (!mounted) {
      return;
    }
    final viewport = context.findRenderObject();
    if (viewport is! RenderBox || !viewport.hasSize) {
      return;
    }

    final viewportOrigin = viewport.localToGlobal(Offset.zero).dy;
    final viewportCenter = viewport.size.height / 2;
    DateTime? bestDay;
    var bestDistance = double.infinity;

    for (final entry in _dayKeys.entries) {
      final dayContext = entry.value.currentContext;
      final renderObject = dayContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }
      final top = renderObject.localToGlobal(Offset.zero).dy - viewportOrigin;
      final center = top + renderObject.size.height / 2;
      final distance = (center - viewportCenter).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestDay = entry.key;
      }
    }

    if (bestDay != null) {
      if (_lastNotifiedDay == bestDay) {
        return;
      }
      _lastNotifiedDay = bestDay;
      widget.onCenterDateChanged(bestDay);
    }
  }
}

class _TimelineDayEntry extends StatelessWidget {
  const _TimelineDayEntry({
    required this.day,
    required this.today,
    required this.tasks,
    required this.showDivider,
  });

  final DateTime day;
  final DateTime today;
  final List<TimelineTask> tasks;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider) const _GlassDayDivider(),
        _DaySection(day: day, today: today, tasks: tasks),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.today,
    required this.tasks,
  });

  final DateTime day;
  final DateTime today;
  final List<TimelineTask> tasks;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = _dayTitle(day, today);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                if (tasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('暂无任务'),
                    ),
                  )
                else
                  for (var index = 0; index < tasks.length; index++) ...[
                    _TimelineTaskTile(task: tasks[index]),
                    if (index != tasks.length - 1)
                      Divider(
                        height: 1,
                        indent: 82,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.44,
                        ),
                      ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTaskTile extends ConsumerWidget {
  const _TimelineTaskTile({required this.task});

  final TimelineTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(task.colorArgb);
    final actions = ref.read(timelineActionsProvider);

    return Dismissible(
      key: ValueKey('timeline-task-${task.id}'),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.2,
        DismissDirection.endToStart: 0.2,
      },
      background: const _SwipeBackground(
        alignment: Alignment.centerLeft,
        icon: Icons.star_rounded,
        label: '星标',
      ),
      secondaryBackground: const _SwipeBackground(
        alignment: Alignment.centerRight,
        icon: Icons.delete_rounded,
        label: '删除',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await actions.toggleStar(task);
          return false;
        }
        await actions.delete(task);
        return true;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTimelineTaskEditorSheet(
            context,
            initialDate: task.taskDate,
            task: task,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 58,
                  child: Text(
                    _timeLabel(task),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  width: 4,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (task.isStarred) ...[
                            Icon(Icons.star_rounded, size: 17, color: color),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              task.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) => actions.toggleCompleted(task),
                          ),
                        ],
                      ),
                      if (task.description.isNotEmpty)
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _ordinalDayLabel(task.taskDate),
                  key: ValueKey('timeline-task-date-label-${task.id}'),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      color: colorScheme.primaryContainer.withValues(alpha: 0.32),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class _GlassDayDivider extends StatelessWidget {
  const _GlassDayDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 26,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.surface.withValues(alpha: 0.0),
            colorScheme.primaryContainer.withValues(alpha: 0.22),
            colorScheme.surface.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _TimelineDateOverlay extends StatelessWidget {
  const _TimelineDateOverlay({required this.date, required this.visible});

  final DateTime date;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IgnorePointer(
      child: AnimatedOpacity(
        key: const ValueKey('timeline-date-overlay'),
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${date.year}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.18),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              Text(
                '${date.month}月',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.20),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineSearchDialog extends ConsumerStatefulWidget {
  const _TimelineSearchDialog();

  @override
  ConsumerState<_TimelineSearchDialog> createState() =>
      _TimelineSearchDialogState();
}

class _TimelineSearchDialogState extends ConsumerState<_TimelineSearchDialog> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(timelineTaskSearchProvider(_query));

    return AlertDialog(
      title: const Text('搜索任务'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassSearchField(
              key: const ValueKey('timeline-search-dialog-field'),
              controller: _controller,
              hintText: '输入任务标题或备注',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 14),
            results.when(
              data: (items) {
                if (_query.trim().isEmpty) {
                  return const Text('输入关键词开始搜索');
                }
                if (items.isEmpty) {
                  return const Text('未找到相关任务');
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final task in items)
                        ListTile(
                          title: Text(task.title),
                          subtitle: Text(_dateLabel(task.taskDate)),
                        ),
                    ],
                  ),
                );
              },
              error: (error, _) => Text('搜索失败: $error'),
              loading: () => const SizedBox(height: 48),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

class _TimelineCalendarDialog extends ConsumerStatefulWidget {
  const _TimelineCalendarDialog({required this.initialDate});

  final DateTime initialDate;

  @override
  ConsumerState<_TimelineCalendarDialog> createState() =>
      _TimelineCalendarDialogState();
}

class _TimelineCalendarDialogState
    extends ConsumerState<_TimelineCalendarDialog> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
    _month = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final range = (
      startDate: DateTime(_year),
      endDate: DateTime(_year, 12, 31),
    );
    final tasks = ref.watch(timelineTasksRangeProvider(range));

    return Dialog(
      key: const ValueKey('timeline-calendar-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: SingleChildScrollView(
                child: tasks.when(
                  data: _buildCalendar,
                  error: (error, _) => Text('日历加载失败: $error'),
                  loading: () => const SizedBox(height: 320),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(List<TimelineTask> tasks) {
    final monthCounts = <int, int>{};
    final dayCounts = <int, int>{};
    for (final task in tasks) {
      if (task.taskDate.year != _year) {
        continue;
      }
      monthCounts.update(
        task.taskDate.month,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
      if (task.taskDate.month == _month) {
        dayCounts.update(
          task.taskDate.day,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: '上一年',
              onPressed: () => setState(() => _year -= 1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '$_year 年任务热力',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: '下一年',
              onPressed: () => setState(() => _year += 1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var month = 1; month <= 12; month += 1)
              _MonthHeatDot(
                key: ValueKey('timeline-calendar-month-$month'),
                month: month,
                count: monthCounts[month] ?? 0,
                selected: month == _month,
                onTap: () => setState(() => _month = month),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '$_month月',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _MonthCalendarGrid(
          year: _year,
          month: _month,
          dayCounts: dayCounts,
          onDateSelected: (date) => Navigator.of(context).pop(date),
        ),
      ],
    );
  }
}

class _MonthHeatDot extends StatelessWidget {
  const _MonthHeatDot({
    required super.key,
    required this.month,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int month;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final intensity = count == 0
        ? 0.12
        : (0.26 + count * 0.12).clamp(0.26, 0.88);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.52)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.onSurface.withValues(
              alpha: selected ? 0.16 : 0.08,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: intensity.toDouble(),
                ),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text('$month月', maxLines: 1),
            Text('$count', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _MonthCalendarGrid extends StatelessWidget {
  const _MonthCalendarGrid({
    required this.year,
    required this.month,
    required this.dayCounts,
    required this.onDateSelected,
  });

  final int year;
  final int month;
  final Map<int, int> dayCounts;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month);
    final leadingSlots = firstDay.weekday % 7;
    final dayCount = DateTime(year, month + 1, 0).day;
    final cells = <Widget>[
      for (final label in const ['日', '一', '二', '三', '四', '五', '六'])
        Center(
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
      for (var index = 0; index < leadingSlots; index += 1)
        const SizedBox.shrink(),
      for (var day = 1; day <= dayCount; day += 1)
        _CalendarDayCell(
          key: ValueKey('timeline-calendar-day-$day'),
          date: DateTime(year, month, day),
          count: dayCounts[day] ?? 0,
          onTap: onDateSelected,
        ),
    ];

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required super.key,
    required this.date,
    required this.count,
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasTasks = count > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onTap(date),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: hasTasks
              ? colorScheme.primaryContainer.withValues(alpha: 0.46)
              : colorScheme.surface.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.onSurface.withValues(
              alpha: hasTasks ? 0.12 : 0.06,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${date.day}'),
              if (hasTasks)
                Text('$count 项', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineTaskEditorSheet extends ConsumerStatefulWidget {
  const _TimelineTaskEditorSheet({required this.initialDate, this.task});

  final DateTime initialDate;
  final TimelineTask? task;

  @override
  ConsumerState<_TimelineTaskEditorSheet> createState() =>
      _TimelineTaskEditorSheetState();
}

class _TimelineTaskEditorSheetState
    extends ConsumerState<_TimelineTaskEditorSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _taskDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TimelineImportance _importance = TimelineImportance.medium;
  late Color _color;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task == null) {
      _taskDate = _dateOnly(widget.initialDate);
      _color = Color(TimelineTaskDefaults.mediumColorArgb);
      return;
    }

    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _taskDate = _dateOnly(task.taskDate);
    _startTime = _timeOfDayFrom(task.startAt);
    _endTime = _timeOfDayFrom(task.endAt);
    _importance = task.importance;
    _color = Color(task.colorArgb);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? '编辑任务' : '新增任务',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('timeline-task-title-field'),
                controller: _titleController,
                decoration: const InputDecoration(labelText: '任务标题'),
                autofocus: true,
              ),
              TextField(
                key: const ValueKey('timeline-task-description-field'),
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '备注'),
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: Text(_dateLabel(_taskDate)),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickTime(isStart: true),
                    icon: const Icon(Icons.schedule_rounded, size: 18),
                    label: Text(
                      _startTime == null
                          ? '开始: 全天'
                          : '开始: ${_timeOfDayLabel(_startTime!)}',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _startTime == null
                        ? null
                        : () => _pickTime(isStart: false),
                    icon: const Icon(Icons.timer_outlined, size: 18),
                    label: Text(
                      _endTime == null
                          ? '结束: 无'
                          : '结束: ${_timeOfDayLabel(_endTime!)}',
                    ),
                  ),
                  if (_startTime != null || _endTime != null)
                    TextButton(
                      onPressed: () => setState(() {
                        _startTime = null;
                        _endTime = null;
                      }),
                      child: const Text('清除时间'),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('低'),
                    selected: _importance == TimelineImportance.low,
                    onSelected: (_) => _setImportance(TimelineImportance.low),
                  ),
                  ChoiceChip(
                    label: const Text('中'),
                    selected: _importance == TimelineImportance.medium,
                    onSelected: (_) =>
                        _setImportance(TimelineImportance.medium),
                  ),
                  ChoiceChip(
                    label: const Text('高'),
                    selected: _importance == TimelineImportance.high,
                    onSelected: (_) => _setImportance(TimelineImportance.high),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final color in const [
                    Color(TimelineTaskDefaults.lowColorArgb),
                    Color(TimelineTaskDefaults.mediumColorArgb),
                    Color(TimelineTaskDefaults.highColorArgb),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: () => setState(() => _color = color),
                        child: CircleAvatar(backgroundColor: color, radius: 15),
                      ),
                    ),
                  TextButton(
                    onPressed: _showColorPicker,
                    child: const Text('更多颜色'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('保存任务'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setImportance(TimelineImportance importance) {
    setState(() {
      _importance = importance;
      _color = Color(TimelineTaskDefaults.colorForImportance(importance));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _taskDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _taskDate = _dateOnly(picked));
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime =
        (isStart ? _startTime : _endTime) ?? _startTime ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      if (isStart) {
        _startTime = picked;
        return;
      }
      _endTime = picked;
    });
  }

  Future<void> _showColorPicker() async {
    var picked = _color;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _color,
            onColorChanged: (color) => picked = color,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _color = picked);
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    final actions = ref.read(timelineActionsProvider);
    final startAt = _dateTimeFor(_startTime);
    final endAt = _dateTimeFor(_endTime);
    final task = widget.task;
    if (task == null) {
      await actions.create(
        TimelineTaskDraft(
          title: title,
          description: _descriptionController.text,
          taskDate: _taskDate,
          startAt: startAt,
          endAt: endAt,
          importance: _importance,
          colorArgb: _color.toARGB32(),
        ),
      );
    } else {
      await actions.update(
        task.copyWith(
          title: title,
          description: _descriptionController.text,
          taskDate: _taskDate,
          startAt: startAt,
          endAt: endAt,
          importance: _importance,
          colorArgb: _color.toARGB32(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  DateTime? _dateTimeFor(TimeOfDay? time) {
    if (time == null) {
      return null;
    }
    return DateTime(
      _taskDate.year,
      _taskDate.month,
      _taskDate.day,
      time.hour,
      time.minute,
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _dayTitle(DateTime day, DateTime today) {
  if (_dateOnly(day) == _dateOnly(today)) {
    return '今天';
  }
  if (_dateOnly(day) == _dateOnly(today).subtract(const Duration(days: 1))) {
    return '昨天';
  }
  if (_dateOnly(day) == _dateOnly(today).add(const Duration(days: 1))) {
    return '明天';
  }
  return _dateLabel(day);
}

String _timeLabel(TimelineTask task) {
  final startAt = task.startAt;
  final endAt = task.endAt;
  if (startAt == null) {
    return '全天';
  }
  final start = _hourMinute(startAt);
  if (endAt == null) {
    return start;
  }
  return '$start\n${_hourMinute(endAt)}';
}

String _dateLabel(DateTime value) {
  return '${value.year}/${value.month}/${value.day}';
}

String _ordinalDayLabel(DateTime value) {
  final day = value.day;
  final suffix = switch (day % 100) {
    11 || 12 || 13 => 'th',
    _ => switch (day % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    },
  };
  return '$day$suffix';
}

String _hourMinute(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

TimeOfDay? _timeOfDayFrom(DateTime? value) {
  if (value == null) {
    return null;
  }
  return TimeOfDay(hour: value.hour, minute: value.minute);
}

String _timeOfDayLabel(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
