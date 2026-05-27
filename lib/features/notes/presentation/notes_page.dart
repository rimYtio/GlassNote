import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/note_folder_use_case_providers.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/entities/note.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import '../../../ui_system/widgets/glass_search_field.dart';
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
  String? _openActionNoteId;

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
              openActionNoteId: _openActionNoteId,
              onOpenActions: _openActions,
              onCloseActions: _closeActions,
            )
          else ...[
            if (widget.folderId == null) ...[
              _SectionTitle('文件夹'),
              _RootFolderList(
                folders: ref.watch(rootFoldersProvider),
                onCloseActions: _closeActions,
              ),
              const SizedBox(height: 24),
              _SectionTitle('最近笔记'),
            ],
            _NotesList(
              folderId: activeFolderId,
              openActionNoteId: _openActionNoteId,
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

  void _openActions(String noteId) {
    if (_openActionNoteId != noteId) {
      setState(() => _openActionNoteId = noteId);
    }
  }

  void _closeActions() {
    if (_openActionNoteId != null) {
      setState(() => _openActionNoteId = null);
    }
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.query,
    required this.folders,
    required this.openActionNoteId,
    required this.onOpenActions,
    required this.onCloseActions,
  });

  final String query;
  final List<Folder> folders;
  final String? openActionNoteId;
  final ValueChanged<String> onOpenActions;
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
            _FolderTile(folder: folder, onCloseActions: onCloseActions),
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
                    isActionOpen: openActionNoteId == note.id,
                    hasAnyOpenAction: openActionNoteId != null,
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
  const _RootFolderList({required this.folders, required this.onCloseActions});

  final AsyncValue<List<Folder>> folders;
  final VoidCallback onCloseActions;

  @override
  Widget build(BuildContext context) {
    return folders.when(
      data: (items) => Column(
        children: [
          for (final folder in items) ...[
            _FolderTile(folder: folder, onCloseActions: onCloseActions),
            const SizedBox(height: 10),
          ],
        ],
      ),
      error: (error, _) => Text('文件夹加载失败: $error'),
      loading: () => const SizedBox(height: 48),
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({required this.folder, required this.onCloseActions});

  final Folder folder;
  final VoidCallback onCloseActions;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        onCloseActions();
        context.go('/notes/folder/${folder.id}');
      },
      child: Row(
        children: [
          const Icon(Icons.folder_rounded),
          const SizedBox(width: 12),
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
  }
}

class _NotesList extends ConsumerWidget {
  const _NotesList({
    required this.folderId,
    required this.openActionNoteId,
    required this.onOpenActions,
    required this.onCloseActions,
  });

  final String folderId;
  final String? openActionNoteId;
  final ValueChanged<String> onOpenActions;
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
                isActionOpen: openActionNoteId == note.id,
                hasAnyOpenAction: openActionNoteId != null,
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
    required this.hasAnyOpenAction,
    required this.onOpenActions,
    required this.onCloseActions,
  });

  final Note note;
  final bool isActionOpen;
  final bool hasAnyOpenAction;
  final ValueChanged<String> onOpenActions;
  final VoidCallback onCloseActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        final delta = details.primaryDelta ?? 0;
        if (delta < -8 && !isActionOpen) {
          onOpenActions(note.id);
        }
      },
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < 0) {
          onOpenActions(note.id);
        }
      },
      child: Row(
        children: [
          Expanded(
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
          ),
          if (isActionOpen) ...[
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () async {
                await ref.read(notesActionsProvider).toggleStar(note);
                onCloseActions();
              },
              child: Text(note.isStarred ? '取消星标' : '星标'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                await ref.read(notesActionsProvider).deleteNote(note);
                onCloseActions();
              },
              child: const Text('删除'),
            ),
          ],
        ],
      ),
    );
  }
}

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
