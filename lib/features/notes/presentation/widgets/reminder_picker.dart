import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/providers/infrastructure_providers.dart';

class ReminderPicker extends ConsumerStatefulWidget {
  const ReminderPicker({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetTitle,
  });

  final String targetType;
  final String targetId;
  final String targetTitle;

  @override
  ConsumerState<ReminderPicker> createState() => _ReminderPickerState();
}

class _ReminderPickerState extends ConsumerState<ReminderPicker> {
  DateTime? _selectedTime;
  bool _saving = false;

  Future<void> _setReminder(DateTime triggerTime, String label) async {
    if (_saving) return;
    setState(() => _saving = true);

    final granted =
        await ref.read(localNotificationServiceProvider).requestPermission();
    if (!granted) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('通知权限未开启，请在系统设置中开启通知权限')),
      );
      return;
    }

    // Cancel existing reminders for this target
    await ref.read(reminderRepositoryProvider).cancelByTarget(widget.targetId);

    final notificationId = await ref
        .read(localNotificationServiceProvider)
        .schedule(
          title: widget.targetTitle.isNotEmpty ? widget.targetTitle : 'GlassNote 提醒',
          body: label,
          triggerTime: triggerTime,
          payload: '${widget.targetType}:${widget.targetId}',
        );

    await ref.read(reminderRepositoryProvider).create(
      targetType: widget.targetType,
      targetId: widget.targetId,
      triggerTime: triggerTime,
      notificationId: notificationId,
    );

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已设置提醒: ${_formatDateTime(triggerTime)}')),
    );
  }

  Future<void> _clearReminder() async {
    await ref.read(reminderRepositoryProvider).cancelByTarget(widget.targetId);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已清除提醒')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final existingReminders =
        ref.watch(reminderRepositoryProvider).listByTarget(widget.targetId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '设置提醒',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List>(
              future: existingReminders,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active,
                            size: 16,
                            color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '已设置: ${_formatDateTime(snapshot.data!.first.triggerTime)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
            _PresetOption(
              label: '准时',
              description: '在任务时间提醒',
              icon: Icons.alarm,
              onTap: () => _setReminder(
                _selectedTime ?? DateTime.now().add(const Duration(minutes: 1)),
                '准时提醒',
              ),
            ),
            _PresetOption(
              label: '5分钟前',
              description: '提前5分钟提醒',
              icon: Icons.alarm,
              onTap: () => _setReminder(
                (_selectedTime ?? DateTime.now())
                    .subtract(const Duration(minutes: 5)),
                '5分钟前提醒',
              ),
            ),
            _PresetOption(
              label: '15分钟前',
              description: '提前15分钟提醒',
              icon: Icons.alarm,
              onTap: () => _setReminder(
                (_selectedTime ?? DateTime.now())
                    .subtract(const Duration(minutes: 15)),
                '15分钟前提醒',
              ),
            ),
            _PresetOption(
              label: '30分钟前',
              description: '提前30分钟提醒',
              icon: Icons.alarm,
              onTap: () => _setReminder(
                (_selectedTime ?? DateTime.now())
                    .subtract(const Duration(minutes: 30)),
                '30分钟前提醒',
              ),
            ),
            _PresetOption(
              label: '1小时前',
              description: '提前1小时提醒',
              icon: Icons.alarm,
              onTap: () => _setReminder(
                (_selectedTime ?? DateTime.now())
                    .subtract(const Duration(hours: 1)),
                '1小时前提醒',
              ),
            ),
            _PresetOption(
              label: '自定义',
              description: '选择自定义日期和时间',
              icon: Icons.edit_calendar,
              onTap: _pickCustomDateTime,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List>(
              future: existingReminders,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _clearReminder,
                      icon: const Icon(Icons.notifications_off),
                      label: const Text('清除提醒'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCustomDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime ?? now),
    );
    if (time == null || !mounted) return;

    final triggerTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (triggerTime.isBefore(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('提醒时间不能早于当前时间')),
      );
      return;
    }

    setState(() => _selectedTime = triggerTime);
    await _setReminder(triggerTime, '自定义提醒');
  }
}

class _PresetOption extends StatelessWidget {
  const _PresetOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(label),
        subtitle: Text(description),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  return '${dt.year}/${_pad(dt.month)}/${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}';
}

String _pad(int value) => value.toString().padLeft(2, '0');
