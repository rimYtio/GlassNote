import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/di/settings_use_case_providers.dart';
import '../../../features/notes/presentation/notes_controller.dart';
import '../../../features/schedule/presentation/timeline_controller.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'settings_controller.dart';

class ExportSettingsPage extends ConsumerWidget {
  const ExportSettingsPage({super.key});

  static const _jsonFilePicker = MethodChannel('glass_note/json_file_picker');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return GlassScaffold(
      title: '数据备份',
      body: settings.when(
        data: (value) => ListView(
          padding: const EdgeInsets.only(bottom: 108),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JSON 备份',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '备份包含笔记、文件夹、标签、任务、提醒和附件文件，不会导出 API Key、PIN 或其他安全密钥。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('包含元数据'),
                    subtitle: const Text('导出创建时间、更新时间等辅助信息'),
                    value: value.exportIncludeMetadata,
                    onChanged: (enabled) => ref
                        .read(settingsControllerProvider.notifier)
                        .setExportIncludeMetadata(enabled),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    key: const ValueKey('settings-backup-export-json'),
                    leading: const Icon(Icons.upload_file_rounded),
                    title: const Text('导出 JSON'),
                    subtitle: const Text('生成备份文件并通过系统分享'),
                    onTap: () => _exportJson(context, ref),
                  ),
                  const Divider(),
                  ListTile(
                    key: const ValueKey('settings-backup-import-json'),
                    leading: const Icon(Icons.download_rounded),
                    title: const Text('导入 JSON'),
                    subtitle: const Text('选择备份 JSON，确认后恢复数据'),
                    onTap: () => _pickAndImportJson(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
        error: (error, _) => Center(child: Text('备份设置加载失败: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _exportJson(BuildContext context, WidgetRef ref) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(exportDataBackupUseCaseProvider).exportJson();
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final file = File(
        '${backupDir.path}/glassnote_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], subject: 'GlassNote 备份');
      scaffold.showSnackBar(const SnackBar(content: Text('JSON 备份已导出')));
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('导出失败: $e')));
    }
  }

  Future<void> _pickAndImportJson(BuildContext context, WidgetRef ref) async {
    final scaffold = ScaffoldMessenger.of(context);
    if (!Platform.isAndroid) {
      await _showPasteImportDialog(context, ref);
      return;
    }

    try {
      final json = await _jsonFilePicker.invokeMethod<String>('pickJsonFile');
      if (json == null || json.trim().isEmpty || !context.mounted) {
        return;
      }
      await _confirmAndImportJson(context, ref, json);
    } on PlatformException catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('读取备份文件失败: ${e.message ?? e.code}')),
      );
    }
  }

  Future<void> _showPasteImportDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final json = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('导入 JSON 备份'),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              key: const ValueKey('settings-backup-import-json-field'),
              controller: controller,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '粘贴 GlassNote 备份 JSON',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('继续'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (json == null || json.isEmpty || !context.mounted) return;
    await _confirmAndImportJson(context, ref, json);
  }

  Future<void> _confirmAndImportJson(
    BuildContext context,
    WidgetRef ref,
    String json,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认导入'),
        content: const Text('导入会按相同 ID 覆盖已有数据。确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('导入'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final scaffold = ScaffoldMessenger.of(context);
    try {
      await ref.read(importDataBackupUseCaseProvider).importJson(json);
      _refreshImportedData(ref);
      scaffold.showSnackBar(const SnackBar(content: Text('JSON 备份已导入')));
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('导入失败: $e')));
    }
  }

  void _refreshImportedData(WidgetRef ref) {
    ref.invalidate(settingsControllerProvider);
    ref.invalidate(ensureUncategorizedProvider);
    ref.invalidate(allFoldersProvider);
    ref.invalidate(rootFoldersProvider);
    ref.invalidate(allTagsProvider);
    ref.invalidate(notesByFolderProvider);
    ref.invalidate(noteSearchProvider);
    ref.invalidate(noteByIdProvider);
    ref.invalidate(attachmentsByNoteProvider);
    ref.invalidate(tagsByNoteProvider);
    ref.invalidate(notesByTagProvider);
    ref.invalidate(timelineTasksRangeProvider);
    ref.invalidate(timelineTaskSearchProvider);
  }
}
