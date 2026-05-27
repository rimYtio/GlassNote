import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/folder.dart';
import 'notes_controller.dart';

class NoteEditorPage extends ConsumerStatefulWidget {
  const NoteEditorPage({super.key, this.noteId, this.folderId});

  final String? noteId;
  final String? folderId;

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _loadedExistingNote = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noteId = widget.noteId;
    final note = noteId == null ? null : ref.watch(noteByIdProvider(noteId));

    if (noteId != null) {
      return note!.when(
        data: (value) {
          if (value != null && !_loadedExistingNote) {
            _titleController.text = value.title;
            _bodyController.text = value.plainText;
            _loadedExistingNote = true;
          }
          return _editor(context, existingNoteId: noteId);
        },
        error: (error, _) => _EditorFrame(
          title: '编辑笔记',
          child: Center(child: Text('笔记加载失败: $error')),
        ),
        loading: () => const _EditorFrame(title: '编辑笔记', child: SizedBox()),
      );
    }

    return _editor(context);
  }

  Widget _editor(BuildContext context, {String? existingNoteId}) {
    final colorScheme = Theme.of(context).colorScheme;

    return _EditorFrame(
      key: const ValueKey('note-editor-page'),
      title: existingNoteId == null ? '新建笔记' : '编辑笔记',
      leading: IconButton(
        tooltip: '返回',
        icon: const Icon(Icons.chevron_left),
        onPressed: _finish,
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : _finish,
          child: const Text('完成'),
        ),
      ],
      child: ListView(
        key: const ValueKey('note-editor-content'),
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: [
          TextField(
            key: const ValueKey('note-title-field'),
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: '标题',
              border: InputBorder.none,
            ),
            maxLines: null,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          TextField(
            key: const ValueKey('note-body-field'),
            controller: _bodyController,
            decoration: const InputDecoration(
              hintText: '开始输入',
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.multiline,
            minLines: 18,
            maxLines: null,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }

  Future<void> _finish() async {
    if (_saving) {
      return;
    }

    setState(() => _saving = true);

    final title = _titleController.text.trim();
    final body = _bodyController.text;
    final actions = ref.read(notesActionsProvider);
    final existingId = widget.noteId;
    var targetFolderId = widget.folderId ?? Folder.uncategorizedId;

    if (existingId == null) {
      if (title.isNotEmpty || body.trim().isNotEmpty) {
        final note = await actions.createNote(
          title: title,
          plainText: body,
          richContentJson: '{}',
          folderId: targetFolderId,
        );
        targetFolderId = note.folderId;
      }
    } else {
      final existing = await ref.read(noteByIdProvider(existingId).future);
      if (existing != null) {
        final note = await actions.updateNote(
          existing.copyWith(
            title: title.isEmpty ? '无标题笔记' : title,
            plainText: body,
            richContentJson: '{}',
          ),
        );
        targetFolderId = note.folderId;
      }
    }

    if (!mounted) {
      return;
    }

    if (targetFolderId == Folder.uncategorizedId) {
      context.go('/notes');
    } else {
      context.go('/notes/folder/$targetFolderId');
    }
  }
}

class _EditorFrame extends StatelessWidget {
  const _EditorFrame({
    required this.title,
    required this.child,
    super.key,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.28),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 10, 2),
                child: Row(
                  children: [
                    SizedBox(width: 48, child: leading),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
