import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';

class ExportSettingsPage extends ConsumerWidget {
  const ExportSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassScaffold(
      title: '数据导出',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 48),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              '支持将笔记导出为 PDF 文档或 PNG 图片，\n导出后可通过系统分享功能发送。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ExportOptionTile(
            icon: Icons.picture_as_pdf,
            title: '导出 PDF',
            subtitle: '生成格式化的 PDF 文档，适合打印和存档',
          ),
          ExportOptionTile(
            icon: Icons.image,
            title: '导出 PNG',
            subtitle: '将笔记保存为高清图片，方便分享',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '提示：在笔记编辑页面，点击右上角的导出按钮即可导出单篇笔记。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExportOptionTile extends StatelessWidget {
  const ExportOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
