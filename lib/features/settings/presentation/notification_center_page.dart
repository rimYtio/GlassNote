import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/reminder.dart';
import '../../../domain/services/startup_permission_service.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'settings_controller.dart';

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
    } else if (r.targetType == 'schedule') {
      final task = await ref
          .read(timelineTaskRepositoryProvider)
          .findById(r.targetId);
      title = task?.title ?? '已删除的任务';
    } else {
      title = '提醒';
    }
    items.add(_ReminderItem(reminder: r, displayTitle: title));
  }
  items.sort(
    (a, b) => a.reminder.triggerTime.compareTo(b.reminder.triggerTime),
  );
  return items;
});

final _startupPermissionStatusProvider =
    FutureProvider<StartupPermissionStatus>((ref) {
      return ref.watch(startupPermissionServiceProvider).checkStatus();
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
    final permissionStatus = ref.watch(_startupPermissionStatusProvider);

    return GlassScaffold(
      title: '通知中心',
      body: Column(
        children: [
          const _ReminderPreferenceCard(),
          _PermissionStatusCard(status: permissionStatus),
          Expanded(
            child: asyncItems.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  '加载失败',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        _ReminderCard(
                          item: item,
                          permissionStatus: permissionStatus.asData?.value,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionStatusCard extends ConsumerWidget {
  const _PermissionStatusCard({required this.status});

  final AsyncValue<StartupPermissionStatus> status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: status.when(
          loading: () => const Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('正在检查权限')),
            ],
          ),
          error: (_, _) => Row(
            children: [
              const Icon(Icons.info_outline_rounded),
              const SizedBox(width: 12),
              const Expanded(child: Text('权限状态暂不可用')),
              TextButton(
                key: const ValueKey('notification-permission-request'),
                onPressed: () => _requestPermissions(ref),
                child: const Text('重新请求'),
              ),
            ],
          ),
          data: (value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('必要权限')),
                  TextButton(
                    key: const ValueKey('notification-permission-request'),
                    onPressed: () => _requestPermissions(ref),
                    child: const Text('重新请求'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PermissionChip(
                    label: '通知',
                    granted: value.notificationsGranted,
                  ),
                  _PermissionChip(
                    label: '精确闹钟',
                    granted: value.exactAlarmsGranted,
                  ),
                  _PermissionChip(
                    label: '麦克风',
                    granted: value.microphoneGranted,
                  ),
                ],
              ),
              if (!value.canDeliverScheduledNotifications) ...[
                const SizedBox(height: 8),
                Text(
                  '系统通知可能不会按时弹出，请重新授权通知和精确闹钟权限',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissions(WidgetRef ref) async {
    await ref.read(startupPermissionServiceProvider).requestAll();
    ref.invalidate(_startupPermissionStatusProvider);
    ref.invalidate(settingsControllerProvider);
  }
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({required this.label, required this.granted});

  final String label;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = granted ? colorScheme.primary : colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            granted ? Icons.check_circle_outline : Icons.error_outline,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }
}

class _ReminderPreferenceCard extends ConsumerWidget {
  const _ReminderPreferenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).asData?.value;
    final selected = settings?.defaultReminderLeadMinutes ?? 15;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Row(
          children: [
            const Icon(Icons.alarm_rounded),
            const SizedBox(width: 12),
            const Expanded(child: Text('任务默认提前提醒')),
            DropdownButton<int>(
              value: selected,
              items: const [
                DropdownMenuItem(value: 0, child: Text('准时')),
                DropdownMenuItem(value: 5, child: Text('5 分钟')),
                DropdownMenuItem(value: 15, child: Text('15 分钟')),
                DropdownMenuItem(value: 30, child: Text('30 分钟')),
                DropdownMenuItem(value: 60, child: Text('1 小时')),
              ],
              onChanged: (value) {
                if (value == null) return;
                ref
                    .read(settingsControllerProvider.notifier)
                    .setDefaultReminderLeadMinutes(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.item, required this.permissionStatus});

  final _ReminderItem item;
  final StartupPermissionStatus? permissionStatus;

  IconData get _icon => item.reminder.targetType == 'note'
      ? Icons.note_alt_outlined
      : Icons.event_note;

  String get _typeLabel => item.reminder.targetType == 'note' ? '笔记提醒' : '行程提醒';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  if (permissionStatus != null &&
                      item.reminder.targetType == 'schedule' &&
                      !permissionStatus!.canDeliverScheduledNotifications) ...[
                    const SizedBox(height: 4),
                    Text(
                      '系统通知可能不会按时弹出',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _timeLabel(item.reminder.triggerTime),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            IconButton(
              key: ValueKey(
                'notification-cancel-${item.reminder.notificationId}',
              ),
              tooltip: '取消提醒',
              icon: const Icon(Icons.notifications_off_outlined),
              onPressed: () async {
                await ref
                    .read(reminderRepositoryProvider)
                    .cancel(item.reminder.notificationId);
                ref.invalidate(_pendingReminderItemsProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}
