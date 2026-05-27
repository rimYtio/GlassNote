import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/app_settings.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return GlassScaffold(
      title: '设置',
      body: settings.when(
        data: (value) => ListView(
          padding: const EdgeInsets.only(bottom: 108),
          children: [
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<AppThemeMode>(
              segments: const [
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text('System'),
                ),
                ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
                ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
              ],
              selected: {value.themeMode},
              onSelectionChanged: (selection) {
                ref
                    .read(settingsControllerProvider.notifier)
                    .setThemeMode(selection.single);
              },
            ),
            const SizedBox(height: 24),
            _SettingsEntry(
              title: '字体设置',
              icon: Icons.text_fields,
              onTap: () {},
            ),
            _SettingsEntry(
              title: 'API 设置',
              icon: Icons.api,
              onTap: () => context.push('/settings/ai'),
            ),
            _SettingsEntry(title: '数据导出', icon: Icons.ios_share, onTap: () {}),
            _SettingsEntry(
              title: '数据导入',
              icon: Icons.download_rounded,
              onTap: () {},
            ),
            _SettingsEntry(
              title: '安全设置',
              icon: Icons.lock_outline,
              onTap: () => context.push('/settings/security'),
            ),
            _SettingsEntry(
              title: '备份与通知',
              icon: Icons.notifications_none,
              onTap: () {},
            ),
          ],
        ),
        error: (error, _) =>
            Center(child: Text('Settings unavailable: $error')),
        loading: () => const SizedBox(height: 48),
      ),
    );
  }
}

class _SettingsEntry extends StatelessWidget {
  const _SettingsEntry({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
