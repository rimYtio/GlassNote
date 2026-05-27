import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/note_folder_use_case_providers.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/entities/note.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import '../../../ui_system/widgets/glass_search_field.dart';
import '../../../ui_system/widgets/jelly_swipe_action_row.dart';
import 'notes_controller.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key, this.folderId});

  final String? folderId;

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _openActionRowId;
  JellySwipeSide? _openActionSide;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ensureUncategorizedProvider);
    final allFolders = ref.watch(allFoldersProvider).asData?.value ?? const [];
    final path = ref.watch(buildFolderPathUseCaseProvider)(
      folderId: widget.folderId,
      folders: allFolders,
    );
    final activeFolderId = widget.folderId ?? Folder.uncategorizedId;
    final query = _query.trim();

    return GlassScaffold(
      title: path.join(' / '),
      leading: widget.folderId == null
          ? null
          : IconButton(
              tooltip: '返回',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => context.go('/notes'),
            ),
      actions: [
        PopupMenuButton<_CreateAction>(
          tooltip: '新建',
          icon: const Icon(Icons.add),
          onSelected: (action) {
            switch (action) {
              case _CreateAction.note:
                final target = widget.folderId == null
                    ? '/notes/new'
                    : '/notes/new?folderId=${widget.folderId}';
                context.go(target);
              case _CreateAction.folder:
                _showCreateFolderDialog(
                  context,
                  ref,
                  parentId: widget.folderId,
                );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: _CreateAction.note, child: Text('新建笔记')),
            PopupMenuItem(value: _CreateAction.folder, child: Text('新建文件夹')),
          ],
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.only(bottom: 108),
        children: [
          GlassSearchField(
            key: const ValueKey('notes-search-field'),
            controller: _searchController,
            hintText: '搜索文件夹和笔记',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 18),
          if (query.isNotEmpty)
            _SearchResults(
              query: query,
              folders: allFolders,
              openActionRowId: _openActionRowId,
              openActionSide: _openActionSide,
              onOpenActions: _openActions,
              onCloseActions: _closeActions,
            )
          else ...[
            if (widget.folderId == null) ...[
              _SectionTitle('文件夹'),
              _RootFolderList(
                folders: ref.watch(rootFoldersProvider),
                openActionRowId: _openActionRowId,
                openActionSide: _openActionSide,
                onOpenActions: _openActions,
                onCloseActions: _closeActions,
              ),
              const SizedBox(height: 24),
              _SectionTitle('最近笔记'),
            ],
            _NotesList(
              folderId: activeFolderId,
              openActionRowId: _openActionRowId,
              openActionSide: _openActionSide,
              onOpenActions: _openActions,
              onCloseActions: _closeActions,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showCreateFolderDialog(
    BuildContext context,
    WidgetRef ref, {
    required String? parentId,
  }) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新建文件夹'),
          content: TextField(
            key: const ValueKey('folder-name-field'),
            controller: controller,
            decoration: const InputDecoration(labelText: '文件夹名称'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  return;
                }
                await ref
                    .read(notesActionsProvider)
                    .createFolder(name, parentId: parentId);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  void _openActions(String rowId, JellySwipeSide side) {
    if (_openActionRowId != rowId || _openActionSide != side) {
      setState(() {
        _openActionRowId = rowId;
        _openActionSide = side;
      });
    }
  }

  void _closeActions() {
    if (_openActionRowId != null) {
      setState(() {
        _openActionRowId = null;
        _openActionSide = null;
      });
    }
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.query,
    required this.folders,
    required this.openActionRowId,
    required this.openActionSide,
    required this.onOpenActions,
    required this.onCloseActions,
  });

  final String query;
  final List<Folder> folders;
  final String? openActionRowId;
  final JellySwipeSide? openActionSide;
  final void Function(String rowId, JellySwipeSide side) onOpenActions;
  final VoidCallback onCloseActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingFolders = folders
        .where((folder) => folder.name.contains(query))
        .toList(growable: false);
    final notes = ref.watch(noteSearchProvider(query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('搜索结果'),
        if (matchingFolders.isNotEmpty) ...[
          _SectionTitle('文件夹'),
          for (final folder in matchingFolders) ...[
            _FolderTile(
              folder: folder,
              isActionOpen: openActionRowId == _folderRowId(folder),
              openSide: openActionSide,
              hasAnyOpenAction: openActionRowId != null,
              onOpenActions: onOpenActions,
              onCloseActions: onCloseActions,
            ),
            const SizedBox(height: 10),
          ],
        ],
        notes.when(
          data: (items) {
            if (matchingFolders.isEmpty && items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(child: Text('未找到相关文件夹或笔记')),
              );
            }

            return Column(
              children: [
                if (items.isNotEmpty) _SectionTitle('笔记'),
                for (final note in items) ...[
                  _NoteTile(
                    note: note,
                    isActionOpen: openActionRowId == _noteRowId(note),
                    openSide: openActionSide,
                    hasAnyOpenAction: openActionRowId != null,
                    onOpenActions: onOpenActions,
                    onCloseActions: onCloseActions,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
          error: (error, _) => Text('搜索失败: $error'),
          loading: () => const SizedBox(height: 48),
        ),
      ],
    );
  }
}

class _RootFolderList extends StatelessWidget {
  const _RootFolderList({
    required this.folders,
    required this.openActionRowId,
    required this.openActionSide,
    required this.onOpenActions,
    required this.onCloseActions,
  });

  final AsyncValue<List<Folder>> folders;
  final String? openActionRowId;
  final JellySwipeSide? openActionSide;
  final void Function(String rowId, JellySwipeSide side) onOpenActions;
  final VoidCallback onCloseActions;

  @override
  Widget build(BuildContext context) {
    return folders.when(
      data: (items) => Column(
        children: [
          for (final folder in items) ...[
            _FolderTile(
              folder: folder,
              isActionOpen: openActionRowId == _folderRowId(folder),
              openSide: openActionSide,
              hasAnyOpenAction: openActionRowId != null,
              onOpenActions: onOpenActions,
              onCloseActions: onCloseActions,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
      error: (error, _) => Text('文件夹加载失败: $error'),
      loading: () => const SizedBox(height: 48),
    );
  }
}

class _FolderTile extends ConsumerWidget {
  const _FolderTile({
    required this.folder,
    required this.isActionOpen,
    required this.openSide,
    required this.hasAnyOpenAction,
    required this.onOpenActions,
    required this.onCloseActions,
  });

  final Folder folder;
  final bool isActionOpen;
  final JellySwipeSide? openSide;
  final bool hasAnyOpenAction;
  final void Function(String rowId, JellySwipeSide side) onOpenActions;
  final VoidCallback onCloseActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowId = _folderRowId(folder);
    final card = GlassCard(
      onTap: () {
        if (hasAnyOpenAction) {
          onCloseActions();
          return;
        }
        onCloseActions();
        context.go('/notes/folder/${folder.id}');
      },
      child: Row(
        children: [
          const Icon(Icons.folder_rounded),
          const SizedBox(width: 12),
          if (folder.isStarred) ...[
            const Icon(Icons.star_rounded, size: 18),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              folder.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );

    if (folder.isSystem) {
      return card;
    }

    return JellySwipeActionRow(
      isOpen: isActionOpen,
      openSide: openSide,
      onOpen: (side) => onOpenActions(rowId, side),
      onClose: onCloseActions,
      leadingActions: [
        JellySwipeAction(
          label: '重命名',
          icon: Icons.drive_file_rename_outline_rounded,
          onPressed: () => _showRenameFolderDialog(context, ref, folder),
        ),
        JellySwipeAction(
          label: folder.isStarred ? '取消星标' : '星标',
          icon: folder.isStarred
              ? Icons.star_outline_rounded
              : Icons.star_rounded,
          onPressed: () {
            ref.read(notesActionsProvider).toggleFolderStar(folder);
          },
        ),
      ],
      trailingActions: [
        JellySwipeAction(
          label: '删除',
          icon: Icons.delete_rounded,
          style: JellySwipeActionStyle.danger,
          onPressed: () {
            ref.read(notesActionsProvider).deleteFolder(folder.id);
          },
        ),
      ],
      child: card,
    );
  }

  Future<void> _showRenameFolderDialog(
    BuildContext context,
    WidgetRef ref,
    Folder folder,
  ) async {
    final controller = TextEditingController(text: folder.name);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('重命名文件夹'),
          content: TextField(
            key: const ValueKey('folder-rename-field'),
            controller: controller,
            decoration: const InputDecoration(labelText: '文件夹名称'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  return;
                }
                await ref.read(notesActionsProvider).renameFolder(folder, name);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }
}

class _NotesList extends ConsumerWidget {
  const _NotesList({
    required this.folderId,
    required this.openActionRowId,
    required this.openActionSide,
    required this.onOpenActions,
    required this.onCloseActions,
  });

  final String folderId;
  final String? openActionRowId;
  final JellySwipeSide? openActionSide;
  final void Function(String rowId, JellySwipeSide side) onOpenActions;
  final VoidCallback onCloseActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesByFolderProvider(folderId));

    return notes.when(
      data: (items) {
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: Text('暂无笔记')),
          );
        }

        return Column(
          children: [
            for (final note in items) ...[
              _NoteTile(
                note: note,
                isActionOpen: openActionRowId == _noteRowId(note),
                openSide: openActionSide,
                hasAnyOpenAction: openActionRowId != null,
                onOpenActions: onOpenActions,
                onCloseActions: onCloseActions,
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
      error: (error, _) => Text('笔记加载失败: $error'),
      loading: () => const SizedBox(height: 48),
    );
  }
}

class _NoteTile extends ConsumerWidget {
  const _NoteTile({
    required this.note,
    required this.isActionOpen,
    required this.openSide,
    required this.hasAnyOpenAction,
    required this.onOpenActions,
    required this.onCloseActions,
  });

  final Note note;
  final bool isActionOpen;
  final JellySwipeSide? openSide;
  final bool hasAnyOpenAction;
  final void Function(String rowId, JellySwipeSide side) onOpenActions;
  final VoidCallback onCloseActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JellySwipeActionRow(
      isOpen: isActionOpen,
      openSide: openSide,
      onOpen: (side) => onOpenActions(_noteRowId(note), side),
      onClose: onCloseActions,
      trailingActions: [
        JellySwipeAction(
          label: note.isStarred ? '取消星标' : '星标',
          icon: note.isStarred
              ? Icons.star_outline_rounded
              : Icons.star_rounded,
          onPressed: () {
            ref.read(notesActionsProvider).toggleStar(note);
          },
        ),
        JellySwipeAction(
          label: '删除',
          icon: Icons.delete_rounded,
          style: JellySwipeActionStyle.danger,
          onPressed: () {
            ref.read(notesActionsProvider).deleteNote(note);
          },
        ),
      ],
      child: GlassCard(
        onTap: () {
          if (hasAnyOpenAction) {
            onCloseActions();
            return;
          }
          context.go('/notes/${note.id}/edit');
        },
        child: Row(
          children: [
            if (note.isStarred) ...[
              const Icon(Icons.star_rounded, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (note.plainText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      note.plainText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _folderRowId(Folder folder) => 'folder:${folder.id}';

String _noteRowId(Note note) => 'note:${note.id}';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

enum _CreateAction { note, folder }
