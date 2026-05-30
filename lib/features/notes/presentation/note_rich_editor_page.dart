import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../app/di/note_folder_use_case_providers.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/entities/note.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'notes_controller.dart';

import 'widgets/reminder_picker.dart';
import 'widgets/tag_chip_display.dart';
import 'widgets/tag_picker.dart';
class NoteRichEditorPage extends ConsumerStatefulWidget {
  const NoteRichEditorPage({super.key, this.noteId, this.folderId});

  final String? noteId;
  final String? folderId;

  @override
  ConsumerState<NoteRichEditorPage> createState() =>
      _NoteRichEditorPageState();
}

class _NoteRichEditorPageState extends ConsumerState<NoteRichEditorPage> {
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _quillController = QuillController.basic();
  bool _loadedExistingNote = false;
  bool _loadFailed = false;
  bool _editorReady = false;
  bool _saving = false;
  Timer? _autoSaveTimer;
  String _saveStatus = '';
  String? _createdNoteId;

  @override
  void initState() {
    super.initState();
    // Listener added only after content is loaded — prevents auto-save during load
  }

  @override
  void dispose() {
    _titleController.removeListener(_onContentChanged);
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (_loadFailed) return;
    _scheduleAutoSave();
  }

  bool get _hasContent =>
      _titleController.text.trim().isNotEmpty ||
      _quillController.document.toPlainText().trim().isNotEmpty;

  String? get _effectiveNoteId => widget.noteId ?? _createdNoteId;

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _autoSave);
  }

  String _plainText() =>
      _quillController.document.toPlainText().trimRight();

  String _richContentJson() =>
      jsonEncode(_quillController.document.toDelta().toJson());
  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final plain = _plainText();
    final richJson = _richContentJson();

    if (!_hasContent) return;

    if (_loadFailed) {
      debugPrint('[AutoSave] skipped: loadFailed');
      return;
    }
    if (!_editorReady) {
      debugPrint('[AutoSave] skipped: editor not ready');
      return;
    }

    final actions = ref.read(notesActionsProvider);

    // New note: create first, then subsequent auto-saves update
    if (widget.noteId == null && _createdNoteId == null) {
      final note = await actions.createNote(
        title: title.isEmpty ? '无标题笔记' : title,
        plainText: plain,
        richContentJson: richJson,
        folderId: widget.folderId ?? Folder.uncategorizedId,
      );
      _createdNoteId = note.id;
      if (!mounted) return;
      setState(() => _saveStatus = '已保存');
      _clearSaveStatusAfterDelay();
      return;
    }

    // Update existing note
    final effectiveId = _effectiveNoteId;
    if (effectiveId == null) return;
    final existing = await ref.read(noteByIdProvider(effectiveId).future);
    if (existing == null) return;
    await actions.updateNote(
      existing.copyWith(
        title: title.isEmpty ? '无标题笔记' : title,
        plainText: plain,
        richContentJson: richJson,
      ),
    );
    // DB check: verify save persisted correctly
    try {
      final check = await ref.read(noteByIdProvider(effectiveId).future);
      if (check != null) {
        debugPrint('[EditNote] autoSave db check id=$effectiveId contentLen=${check.plainText.length} deltaLen=${check.richContentJson.length}');
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _saveStatus = '已保存');
    _clearSaveStatusAfterDelay();
  }

  void _clearSaveStatusAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saveStatus = '');
    });
  }

  void _loadContent(Note note) {
    _loadFailed = false;
    // Try Delta JSON first
    if (note.richContentJson.isNotEmpty && note.richContentJson != '{}') {
      try {
        final decoded = jsonDecode(note.richContentJson);
        if (decoded is List && decoded.isNotEmpty) {
          _quillController.document = Document.fromJson(decoded);
          return;
        }
      } catch (_) {
        // Fall through to plainText
      }
    }
    // Fallback: plain text
    if (note.plainText.isNotEmpty) {
      _quillController.document = Document()..insert(0, note.plainText);
    }
    // If both failed or are empty, mark load failed
    if (_quillController.document.toPlainText().trim().isEmpty) {
      _loadFailed = note.plainText.isNotEmpty || note.richContentJson != '{}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteId = widget.noteId;

    // Load existing note content once
    if (noteId != null && !_loadedExistingNote) {
      final noteAsync = ref.watch(noteByIdProvider(noteId));
      noteAsync.whenData((note) {
        if (note != null && !_loadedExistingNote) {
          debugPrint('[EditNote] open noteId=$noteId contentLen=${note.plainText.length} deltaLen=${note.richContentJson.length}');
          _titleController.text = note.title;
          _loadContent(note);
          _loadedExistingNote = true;
          if (!_loadFailed) {
            _titleController.addListener(_onContentChanged);
            _editorReady = true;
          }
          debugPrint('[EditNote] existing note loaded noteId=$noteId editorReady=$_editorReady loadFailed=$_loadFailed');
        }
      });
    }

    // New note: mark editor ready immediately (no content to load)
    if (noteId == null && !_editorReady) {
      _editorReady = true;
      _titleController.addListener(_onContentChanged);
      debugPrint('[EditNote] new note initialized editorReady=$_editorReady loadFailed=$_loadFailed');
    }

    return _editor(context);
  }
  Widget _editor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveId = _effectiveNoteId;

    return GlassScaffold(
      title: widget.noteId == null ? '新建笔记' : '编辑笔记',
      leading: IconButton(
        tooltip: '返回',
        icon: const Icon(Icons.chevron_left),
        onPressed: _finish,
      ),
      actions: [
        if (effectiveId != null) ...[
          IconButton(
            key: const ValueKey('btn-reminder'),
            tooltip: '设置提醒',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showReminderPicker(effectiveId),
          ),
          IconButton(
            key: const ValueKey('btn-tags'),
            tooltip: '标签',
            icon: const Icon(Icons.local_offer_outlined),
            onPressed: () => showTagPicker(context, ref, effectiveId),
          ),
        ],
        IconButton(
          key: const ValueKey('btn-export'),
          tooltip: '导出',
          icon: const Icon(Icons.ios_share),
          onPressed: _hasContent ? _showExportSheet : null,
        ),
        IconButton(
          icon: const Icon(Icons.image_outlined),
          tooltip: '插入图片',
          onPressed: _pickImage,
        ),
        TextButton(
          onPressed: _saving ? null : _finish,
          child: const Text('完成'),
        ),
      ],
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
child: TextField(
            key: const ValueKey('note-title-field'),
            focusNode: _titleFocusNode,
            controller: _titleController,
              decoration: const InputDecoration(
                hintText: '标题',
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          // Quill toolbar removed — flutter_quill 11.x has touch bleed bug
          const Divider(height: 1),
          // Tag display row (if note has tags)
          if (effectiveId != null) _tagRow(effectiveId),
          // Rich editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
              child: QuillEditor.basic(
                controller: _quillController,
                config: QuillEditorConfig(
                  placeholder: '开始输入',
                  expands: true,
                  autoFocus: false,
                  embedBuilders: [
                    ImageEmbedBuilder(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _tagRow(String noteId) {
    final tagsAsync = ref.watch(tagsByNoteProvider(noteId));
    return tagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
          child: TagChipDisplay(tags: tags),
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    final fileStore = ref.read(attachmentFileStoreProvider);
    final fileName = 'img_${const Uuid().v4()}.${xFile.path.split('.').last}';
    final localPath = await fileStore.saveImage(bytes, fileName);

    // Insert image block into Quill document at cursor position
    final index = _quillController.selection.baseOffset;
    _quillController.document.insert(index, BlockEmbed.image(localPath));
    _quillController.document.insert(index + 1, '\n');
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
        preferredTime: null,
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
      final body = _plainText();
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

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    _autoSaveTimer?.cancel();

    final title = _titleController.text.trim();
    final plain = _plainText();
    final richJson = _richContentJson();
    debugPrint('[EditNote] quill plain="${plain}"');
    debugPrint('[EditNote] quill richLen=${richJson.length}');

    if (_loadFailed) {
      debugPrint('[EditNote] finish blocked: loadFailed=true');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('笔记加载异常，已阻止保存以避免覆盖原内容')),
      );
      setState(() => _saving = false);
      return;
    }

    if (!_editorReady) {
      debugPrint('[EditNote] finish blocked: editor not ready');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('编辑器尚未初始化完成，请稍后再试')),
      );
      setState(() => _saving = false);
      return;
    }

    final actions = ref.read(notesActionsProvider);
    var targetFolderId = widget.folderId ?? Folder.uncategorizedId;

    if (widget.noteId == null && _createdNoteId == null) {
      // Brand new note: only save if has content
      if (title.isNotEmpty || plain.trim().isNotEmpty) {
        final note = await actions.createNote(
          title: title, plainText: plain,
          richContentJson: richJson, folderId: targetFolderId,
        );
        targetFolderId = note.folderId;
      }
    } else if (widget.noteId != null || _createdNoteId != null) {
      final existingId = _effectiveNoteId;
      if (existingId == null) {
        if (!mounted) return;
        context.go('/notes');
        return;
      }
      final existing = await ref.read(noteByIdProvider(existingId).future);
      if (existing != null) {
        debugPrint('[EditNote] before save oldContentLen=${existing.plainText.length} oldDeltaLen=${existing.richContentJson.length}');
        debugPrint('[EditNote] before save latestPlainLen=${plain.length} latestDeltaLen=${richJson.length}');

        final note = await actions.updateNote(
          existing.copyWith(
            title: title.isEmpty ? '无标题笔记' : title,
            plainText: plain,
            richContentJson: richJson,
          ),
        );
        targetFolderId = note.folderId;
        // DB check: verify save persisted
        try {
          final check = await ref.read(noteByIdProvider(existingId).future);
          if (check != null) {
            debugPrint('[EditNote] finish db check id=$existingId contentLen=${check.plainText.length} deltaLen=${check.richContentJson.length}');
            debugPrint('[EditNote] expected latestPlainLen=${plain.length} latestDeltaLen=${richJson.length}');
          }
        } catch (_) {}
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

class ImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final path = embedContext.node.value.data as String;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(path), fit: BoxFit.contain),
      ),
    );
  }
}
