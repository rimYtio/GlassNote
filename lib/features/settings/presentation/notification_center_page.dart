import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/reminder.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';

class _ReminderItem {
  final Reminder reminder;
  final String displayTitle;
  const _ReminderItem({required this.reminder, required this.displayTitle});
}

final _pendingReminderItemsProvider = FutureProvider<List<_ReminderItem>>((
  ref,
) async {
  final reminderRepo = ref.watch(reminderRepositoryProvider);
  final noteRepo = ref.watch(noteRepositoryProvider);
  final reminders = await reminderRepo.listPending();
  final items = <_ReminderItem>[];
  for (final r in reminders) {
    String title;
    if (r.targetType == 'note') {
      final note = await noteRepo.findById(r.targetId);
      title = note?.title ?? '已删除的笔记';
    } else {
      title = '行程提醒';
    }
    items.add(_ReminderItem(reminder: r, displayTitle: title));
  }
  items.sort(
    (a, b) => a.reminder.triggerTime.compareTo(b.reminder.triggerTime),
  );
  return items;
});

String _dateLabel(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDay = DateTime(dt.year, dt.month, dt.day);
  final diff = targetDay.difference(today).inDays;
  if (diff == 0) return '今天';
  if (diff == 1) return '明天';
  return '${dt.month}月${dt.day}日';
}

String _timeLabel(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class NotificationCenterPage extends ConsumerWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(_pendingReminderItemsProvider);

    return GlassScaffold(
      title: '通知中心',
      body: asyncItems.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(),
            ),
        error:
            (e, _) => Center(
              child: Text(
                '加载失败',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无即将提醒的内容',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 108),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isFirstOfGroup =
                  index == 0 ||
                  _dateLabel(item.reminder.triggerTime) !=
                      _dateLabel(items[index - 1].reminder.triggerTime);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstOfGroup)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        _dateLabel(item.reminder.triggerTime),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  _ReminderCard(item: item),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.item});

  final _ReminderItem item;

  IconData get _icon =>
      item.reminder.targetType == 'note'
          ? Icons.note_alt_outlined
          : Icons.event_note;

  String get _typeLabel =>
      item.reminder.targetType == 'note' ? '笔记提醒' : '行程提醒';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: () {
          if (item.reminder.targetType == 'note') {
            context.push('/notes/${item.reminder.targetId}/edit');
          } else {
            context.push('/timeline');
          }
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _typeLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _timeLabel(item.reminder.triggerTime),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
