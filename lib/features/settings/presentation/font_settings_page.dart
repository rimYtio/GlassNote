import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'settings_controller.dart';

class FontSettingsPage extends ConsumerWidget {
  const FontSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return GlassScaffold(
      title: '字体设置',
      body: settings.when(
        data: (value) => ListView(
          padding: const EdgeInsets.only(bottom: 108),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '字体大小',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    key: const ValueKey('settings-font-scale-slider'),
                    min: 0.85,
                    max: 1.25,
                    divisions: 8,
                    value: value.fontScale,
                    label: '${(value.fontScale * 100).round()}%',
                    onChanged: (next) => ref
                        .read(settingsControllerProvider.notifier)
                        .setFontScale(next),
                  ),
                  Text(
                    '当前 ${(value.fontScale * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('预览', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 10),
                  Text(
                    '今天整理项目计划，并把重要内容记录成笔记。',
                    key: const ValueKey('settings-font-preview'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        error: (error, _) => Center(child: Text('字体设置加载失败: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
