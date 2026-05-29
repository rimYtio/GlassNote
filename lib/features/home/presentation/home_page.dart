import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";

import "../../../domain/entities/note.dart";
import "../../../domain/entities/timeline_task.dart";
import "../../../ui_system/widgets/glass_card.dart";
import "../../../ui_system/widgets/glass_scaffold.dart";
import "home_controller.dart";

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _staggeredFades;

  static const _staggerCount = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _staggeredFades = List.generate(_staggerCount, (index) {
      final begin = index * 0.12;
      final end = (begin + 0.22).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "上午好";
    if (hour < 18) return "下午好";
    return "晚上好";
  }

  String _dateText() {
    final now = DateTime.now();
    const weekdays = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"];
    final weekday = weekdays[(now.weekday - 1) % 7];
    return "${now.month}月${now.day}日 $weekday";
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = ref.watch(todayTasksProvider);
    final recentNotes = ref.watch(recentNotesProvider);
    final topFolders = ref.watch(topFoldersProvider);

    return GlassScaffold(
      title: "总览",
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/capture'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 108),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GreetingSection(
              greeting: _greeting(),
              dateText: _dateText(),
              fade: _staggeredFades[0],
            ),
            const SizedBox(height: 20),
            _QuickActionsRow(fade: _staggeredFades[1]),
            const SizedBox(height: 24),
            _TodayScheduleCard(tasks: todayTasks, fade: _staggeredFades[2]),
            const SizedBox(height: 16),
            _RecentNotesCard(notes: recentNotes, fade: _staggeredFades[3]),
            const SizedBox(height: 16),
            _FolderShortcuts(folders: topFolders, fade: _staggeredFades[4]),
          ],
        ),
      ),
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection({
    required this.greeting,
    required this.dateText,
    required this.fade,
  });

  final String greeting;
  final String dateText;
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.06),
          end: Offset.zero,
        ).animate(fade),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.fade});

  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.04),
          end: Offset.zero,
        ).animate(fade),
        child: Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.edit_note_rounded,
                label: '新建笔记',
                color: const Color(0xFF7C6FF7),
                onTap: () => context.go('/notes/new'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.event_rounded,
                label: '新建行程',
                color: const Color(0xFF5B8DEF),
                onTap: () => context.go('/timeline'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.mic_rounded,
                label: '语音随记',
                color: const Color(0xFF57B884),
                onTap: () => context.go('/capture'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isLight ? 0.14 : 0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayScheduleCard extends StatelessWidget {
  const _TodayScheduleCard({required this.tasks, required this.fade});

  final AsyncValue<List<TimelineTask>> tasks;
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.04),
          end: Offset.zero,
        ).animate(fade),
        child: GlassCard(
          onTap: () => context.go('/timeline'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                icon: Icons.timeline_rounded,
                title: '今日行程',
                trailing: '查看全部',
                onTrailingTap: () => context.go('/timeline'),
              ),
              const SizedBox(height: 12),
              tasks.when(
                data: (items) {
                  final display = items.take(3).toList();
                  if (display.isEmpty) {
                    return const _EmptyState(text: '今天还没有行程安排');
                  }
                  return Column(
                    children: display
                        .map((task) => _TimelineTaskRow(task))
                        .toList(),
                  );
                },
                error: (err, stack) => const _EmptyState(text: '加载失败'),
                loading: () => const _SkeletonLoader(lineCount: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineTaskRow extends StatelessWidget {
  const _TimelineTaskRow(this.task);
  final TimelineTask task;

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = Color(task.colorArgb);
    final hasTime = task.startAt != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4, height: 38,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough : null,
                    color: task.isCompleted
                        ? colorScheme.onSurface.withValues(alpha: 0.45)
                        : colorScheme.onSurface,
                  ),
                ),
                if (hasTime)
                  Text(
                    _formatTime(task.startAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
          ),
          if (task.isCompleted)
            Icon(Icons.check_circle_rounded, size: 20,
              color: color.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}

class _RecentNotesCard extends StatelessWidget {
  const _RecentNotesCard({required this.notes, required this.fade});

  final AsyncValue<List<Note>> notes;
  final Animation<double> fade;

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${date.month}月${date.day}日';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.04), end: Offset.zero,
        ).animate(fade),
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                icon: Icons.note_alt_rounded,
                title: '最近笔记', trailing: '全部笔记',
                onTrailingTap: () => context.go('/notes'),
              ),
              const SizedBox(height: 12),
              notes.when(
                data: (items) {
                  final display = items.take(3).toList();
                  if (display.isEmpty) {
                    return const _EmptyState(text: '还没有笔记，开始记录吧');
                  }
                  return Column(
                    children: display
                        .map((note) => _NoteRow(note, _relativeDate))
                        .toList(),
                  );
                },
                error: (err, stack) => const _EmptyState(text: '加载失败'),
                loading: () => const _SkeletonLoader(lineCount: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow(this.note, this.relativeDateFn);
  final Note note;
  final String Function(DateTime) relativeDateFn;

  String _previewText(String plainText) {
    if (plainText.length <= 60) return plainText;
    return '${plainText.substring(0, 60)}...';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/notes/${note.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                note.isStarred ? Icons.star_rounded : Icons.description_outlined,
                size: 18,
                color: note.isStarred
                    ? const Color(0xFFF5A623)
                    : colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.title, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(_previewText(note.plainText), maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(relativeDateFn(note.updatedAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderShortcuts extends StatelessWidget {
  const _FolderShortcuts({required this.folders, required this.fade});

  final AsyncValue<List<FolderWithCount>> folders;
  final Animation<double> fade;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.04), end: Offset.zero,
        ).animate(fade),
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                icon: Icons.folder_rounded,
                title: '文件夹', trailing: '管理',
                onTrailingTap: () => context.go('/notes'),
              ),
              const SizedBox(height: 12),
              folders.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const _EmptyState(text: '还没有创建文件夹');
                  }
                  return Column(
                    children: items.map((fwc) => _FolderRow(fwc)).toList(),
                  );
                },
                error: (err, stack) => const _EmptyState(text: '加载失败'),
                loading: () => const _SkeletonLoader(lineCount: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FolderRow extends StatelessWidget {
  const _FolderRow(this.folderWithCount);
  final FolderWithCount folderWithCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final f = folderWithCount.folder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/notes/folder/${f.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                f.isSystem ? Icons.inbox_rounded : Icons.folder_rounded,
                size: 20,
                color: f.isSystem
                    ? const Color(0xFF7C6FF7) : const Color(0xFFF5A623),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(f.name, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('${folderWithCount.noteCount}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon, required this.title,
    this.trailing, this.onTrailingTap,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTrailingTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(trailing!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _SkeletonLoader extends StatefulWidget {
  const _SkeletonLoader({required this.lineCount});
  final int lineCount;
  @override
  State<_SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<_SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: List.generate(widget.lineCount, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedBuilder(
            animation: _shimmer,
            builder: (context, child) {
              final alpha = 0.08 +
                  0.06 * math.sin(_shimmer.value * 2 * math.pi);
              return Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: alpha),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
