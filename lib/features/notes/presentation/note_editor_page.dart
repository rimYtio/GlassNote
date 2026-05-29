import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/di/note_folder_use_case_providers.dart';
import '../../../domain/entities/folder.dart';
import '../../notes/presentation/widgets/reminder_picker.dart';
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
  final _quillController = QuillController.basic();
  final _exportKey = GlobalKey();
  bool _loadedExistingNote = false;
  bool _saving = false;
  Timer? _autoSaveTimer;
  String _saveStatus = '';

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onContentChanged);
    _quillController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    setState(() {});
    _scheduleAutoSave();
  }

  bool get _hasContent =>
      _titleController.text.trim().isNotEmpty ||
      _quillController.document.toPlainText().trim().isNotEmpty;

  @override
  void dispose() {
    _titleController.removeListener(_onContentChanged);
    _quillController.removeListener(_onContentChanged);
    _autoSaveTimer?.cancel();
    _titleController.dispose();
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
            _loadContent(value);
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
        if (_saveStatus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: Text(
                _saveStatus,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        if (existingNoteId != null)
          IconButton(
            tooltip: '设置提醒',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showReminderPicker(existingNoteId),
          ),
        if (_hasContent)
          IconButton(
            tooltip: '导出',
            icon: const Icon(Icons.ios_share),
            onPressed: _showExportSheet,
          ),
        TextButton(
          onPressed: _saving ? null : _finish,
          child: const Text('完成'),
        ),
      ],
      child: RepaintBoundary(
        key: _exportKey,
        child: Column(
          key: const ValueKey('note-editor-content'),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 4),
              child: TextField(
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
            ),
            QuillSimpleToolbar(
              controller: _quillController,
              config: const QuillSimpleToolbarConfig(
                showFontSize: false,
                showFontFamily: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showStrikeThrough: false,
                showInlineCode: false,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: false,
                showRedo: false,
                showUndo: false,
                showIndent: false,
                showJustifyAlignment: false,
                showAlignmentButtons: false,
                showLeftAlignment: false,
                showCenterAlignment: false,
                showRightAlignment: false,
                showQuote: true,
                showHeaderStyle: true,
                showListNumbers: true,
                showListBullets: true,
                showListCheck: true,
                showCodeBlock: false,
                showDirection: false,
                showLink: false,
                showUnderLineButton: false,
                showLineHeightButton: false,
                multiRowsDisplay: false,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                child: QuillEditor.basic(
                  controller: _quillController,
                  config: const QuillEditorConfig(
                    placeholder: '开始输入',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderPicker(String noteId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ReminderPicker(
        targetType: 'note',
        targetId: noteId,
        targetTitle: _titleController.text.trim(),
      ),
    );
  }

  void _showExportSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '导出笔记',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('导出 PDF'),
              subtitle: const Text('生成格式化的 PDF 文档'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('导出 PNG'),
              subtitle: const Text('将笔记保存为图片'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportPng();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final pdfExporter = ref.read(pdfExporterProvider);
      final title = _titleController.text.trim();
      final body = _bodyController.text;
      DateTime? createdAt;
      if (widget.noteId != null) {
        final note = await ref.read(noteByIdProvider(widget.noteId!).future);
        createdAt = note?.createdAt;
      }
      final file = await pdfExporter.export(
        title.isNotEmpty ? title : '无标题笔记',
        body,
        createdAt: createdAt,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: title.isNotEmpty ? title : '笔记导出',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF 已导出')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF 导出失败: $e')),
      );
    }
  }

  Future<void> _exportPng() async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final pngExporter = ref.read(pngExporterProvider);
      final title = _titleController.text.trim();
      final fileName = title.isNotEmpty ? title : 'note';
      final file = await pngExporter.exportFromWidget(_exportKey, fileName);
      if (!mounted) return;
      Navigator.of(context).pop();
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: fileName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PNG 已导出')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PNG 导出失败: $e')),
      );
    }
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final title = _titleController.text.trim();
    final body = _bodyController.text;
    final actions = ref.read(notesActionsProvider);
    final existingId = widget.noteId;
    var targetFolderId = widget.folderId ?? Folder.uncategorizedId;
    if (existingId == null) {
      if (title.isNotEmpty || body.trim().isNotEmpty) {
        final note = await actions.createNote(
          title: title, plainText: body, richContentJson: '{}',
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
            plainText: body, richContentJson: '{}',
          ),
        );
        targetFolderId = note.folderId;
      }
    }
    if (!mounted) return;
    if (targetFolderId == Folder.uncategorizedId) {
      context.go('/notes');
    } else {
      context.go('/notes/folder/$targetFolderId');
    }
  }
}

class _EditorFrame extends StatelessWidget {
  const _EditorFrame({required this.title, required this.child, super.key,
    this.leading, this.actions = const []});
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
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.28),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 10, 2),
              child: Row(children: [
                SizedBox(width: 48, child: leading),
                Expanded(child: Text(title,
                  textAlign: TextAlign.center, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                )),
                SizedBox(width: 120, child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                )),
              ]),
            ),
            Expanded(child: child),
          ]),
        ),
      ),
    );
  }
}
