import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/note.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/animations/lottie_loader.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';

final deletedNotesProvider = StreamProvider<List<Note>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.notesDao.watchDeletedNotes();
});

class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletedNotes = ref.watch(deletedNotesProvider);

    return GlassScaffold(
      title: '回收站',
      actions: [
        IconButton(
          tooltip: '清空回收站',
          icon: const Icon(Icons.delete_sweep_outlined),
          onPressed: () => _showEmptyTrashDialog(context, ref),
        ),
      ],
      body: deletedNotes.when(
        data: (notes) {
          if (notes.isEmpty) {
            return LottieEmptyState(
              asset: 'assets/lottie/empty_trash.json',
              message: '回收站为空',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 108),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DeletedNoteTile(note: note),
              );
            },
          );
        },
        error: (error, _) => Center(child: Text('加载失败: $error')),
        loading: () => const LottieAssetWidget(
          asset: 'assets/lottie/loading.json',
          size: 64,
        ),
      ),
    );
  }

  Future<void> _showEmptyTrashDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空回收站'),
        content: const Text('确定要永久删除回收站中的所有笔记吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notes = await ref.read(noteRepositoryProvider).listDeleted();
      for (final note in notes) {
        await ref.read(noteRepositoryProvider).permanentlyDelete(note.id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('回收站已清空')));
      }
    }
  }
}

class _DeletedNoteTile extends ConsumerWidget {
  const _DeletedNoteTile({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr =
        '${note.updatedAt.year}-'
        '${note.updatedAt.month.toString().padLeft(2, '0')}-'
        '${note.updatedAt.day.toString().padLeft(2, '0')} '
        '${note.updatedAt.hour.toString().padLeft(2, '0')}:'
        '${note.updatedAt.minute.toString().padLeft(2, '0')}';

    return GlassCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (note.plainText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note.plainText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '删除于 $dateStr',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionChip(
                icon: Icons.restore_outlined,
                label: '恢复',
                onTap: () => _restoreNote(ref, context),
              ),
              const SizedBox(height: 6),
              _ActionChip(
                icon: Icons.delete_forever_outlined,
                label: '删除',
                isDanger: true,
                onTap: () => _permanentlyDeleteNote(ref, context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _restoreNote(WidgetRef ref, BuildContext context) async {
    await ref.read(noteRepositoryProvider).restore(note.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('笔记已恢复')));
    }
  }

  Future<void> _permanentlyDeleteNote(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('永久删除'),
        content: const Text('确定要永久删除此笔记吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(noteRepositoryProvider).permanentlyDelete(note.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('笔记已永久删除')));
      }
    }
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDanger ? colorScheme.error : colorScheme.primary;

    return SizedBox(
      height: 32,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
