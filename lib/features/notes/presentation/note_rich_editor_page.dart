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
import '../../../domain/entities/attachment.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/entities/note.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import 'notes_controller.dart';
import 'widgets/audio_player_bar.dart';
import 'widgets/audio_recorder_panel.dart';
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
  final _quillController = QuillController.basic();
  final _exportKey = GlobalKey();
  bool _loadedExistingNote = false;
  bool _saving = false;
  Timer? _autoSaveTimer;
  String _saveStatus = '';
  String? _createdNoteId;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onContentChanged);
    _quillController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onContentChanged);
    _quillController.removeListener(_onContentChanged);
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    setState(() {});
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
    if (!mounted) return;
    setState(() => _saveStatus = '已保存');
    _clearSaveStatusAfterDelay();
  }

  void _clearSaveStatusAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saveStatus = '');
    });
  }

  Future<void> _ensureNoteCreated() async {
    if (_effectiveNoteId != null) return;
    final actions = ref.read(notesActionsProvider);
    final note = await actions.createNote(
      title: _titleController.text.trim().isEmpty
          ? '无标题笔记'
          : _titleController.text.trim(),
      plainText: _plainText(),
      richContentJson: _richContentJson(),
      folderId: widget.folderId ?? Folder.uncategorizedId,
    );
    _createdNoteId = note.id;
  }
  void _loadContent(Note note) {
    // Try to load as Delta JSON first
    if (note.richContentJson.isNotEmpty && note.richContentJson != '{}') {
      try {
        final decoded = jsonDecode(note.richContentJson);
        if (decoded is List && decoded.isNotEmpty) {
          _quillController.document = Document.fromJson(decoded);
          return;
        }
      } catch (_) {
        // Fall through to plain text loading
      }
    }

    // Fallback: load plain text as plain content
    if (note.plainText.isNotEmpty) {
      _quillController.document = Document()
        ..insert(0, note.plainText);
    }
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
          return _editor(context);
        },
        error: (error, _) => GlassScaffold(
          title: '编辑笔记',
          body: Center(child: Text('笔记加载失败: $error')),
        ),
        loading: () =>
            const GlassScaffold(title: '编辑笔记', body: SizedBox()),
      );
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
        if (effectiveId != null)
          IconButton(
            tooltip: '标签',
            icon: const Icon(Icons.local_offer_outlined),
            onPressed: () => showTagPicker(context, ref, effectiveId),
          ),
        if (effectiveId != null)
          IconButton(
            tooltip: '设置提醒',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showReminderPicker(effectiveId),
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
      body: Column(
        children: [
          // Title field
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '标题',
                border: InputBorder.none,
              ),
              maxLines: null,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          // Quill toolbar
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
              showUnderLineButton: true,
              showLineHeightButton: false,
              multiRowsDisplay: false,
            ),
          ),
          const Divider(height: 1),
          // Tag display row (if note has tags)
          if (effectiveId != null) _tagRow(effectiveId),
          // Rich editor
          Expanded(
            child: RepaintBoundary(
              key: _exportKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                child: QuillEditor.basic(
                  controller: _quillController,
                  config: const QuillEditorConfig(
                    placeholder: '开始输入',
                  ),
                ),
              ),
            ),
          ),
          // Attachment bar
          _attachmentBar(effectiveId),
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

  Widget _attachmentBar(String? noteId) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 6,
            bottom: MediaQuery.of(context).viewPadding.bottom + 6,
          ),
          child: Row(
            children: [
              _attachButton(
                icon: Icons.image_outlined,
                label: '图片',
                onTap: () => _pickImage(),
              ),
              const SizedBox(width: 12),
              _attachButton(
                icon: Icons.mic_outlined,
                label: '录音',
                onTap: () => _showAudioRecorder(),
              ),
              const Spacer(),
              if (noteId != null) _attachmentList(noteId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attachButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _attachmentList(String noteId) {
    final attachments = ref.watch(attachmentsByNoteProvider(noteId));
    return attachments.when(
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final audioAttachments =
            list.where((a) => a.type == AttachmentType.audio).toList();
        final imageCount =
            list.where((a) => a.type == AttachmentType.image).length;

        return Row(
          children: [
            if (imageCount > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '$imageCount 张图片',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ...audioAttachments.map(
              (a) => SizedBox(
                width: 200,
                child: AudioPlayerBar(
                  filePath: a.localPath,
                  label: a.fileName,
                  onDelete: () => _deleteAttachment(a),
                ),
              ),
            ),
          ],
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Future<void> _deleteAttachment(Attachment attachment) async {
    await ref.read(attachmentRepositoryProvider).delete(attachment.id);
    await ref.read(attachmentFileStoreProvider).deleteFile(attachment.localPath);
  }
  Future<void> _pickImage() async {
    await _ensureNoteCreated();
    final effectiveId = _effectiveNoteId;
    if (effectiveId == null) return;
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    final fileStore = ref.read(attachmentFileStoreProvider);
    final fileName =
        'img_${const Uuid().v4()}.${xFile.path.split('.').last}';
    final localPath = await fileStore.saveImage(bytes, fileName);

    // Get image dimensions
    final decoded = await decodeImageFromList(bytes);
    final attachment = Attachment(
      id: const Uuid().v4(),
      noteId: effectiveId,
      type: AttachmentType.image,
      fileName: fileName,
      localPath: localPath,
      mimeType: xFile.mimeType ?? 'image/jpeg',
      sizeBytes: bytes.length,
      width: decoded.width,
      height: decoded.height,
      durationMs: null,
      createdAt: DateTime.now(),
    );

    await ref.read(attachmentRepositoryProvider).save(attachment);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('图片已添加')),
      );
    }
  }

  void _showAudioRecorder() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AudioRecorderPanel(
        onSaved: (filePath) => _saveAudioAttachment(filePath),
      ),
    );
  }

  Future<void> _saveAudioAttachment(String tempPath) async {
    await _ensureNoteCreated();
    final effectiveId = _effectiveNoteId;
    if (effectiveId == null) return;
    final fileStore = ref.read(attachmentFileStoreProvider);
    final localPath = await fileStore.saveAudio(tempPath);
    final file = File(localPath);
    final fileStat = await file.stat();

    final attachment = Attachment(
      id: const Uuid().v4(),
      noteId: effectiveId,
      type: AttachmentType.audio,
      fileName: localPath.split('/').last,
      localPath: localPath,
      mimeType: 'audio/mp4',
      sizeBytes: fileStat.size,
      width: null,
      height: null,
      durationMs: null,
      createdAt: DateTime.now(),
    );

    await ref.read(attachmentRepositoryProvider).save(attachment);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('录音已保存')),
      );
    }
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
    _autoSaveTimer?.cancel();

    final title = _titleController.text.trim();
    final plain = _plainText();
    final richJson = _richContentJson();
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
        final note = await actions.updateNote(
          existing.copyWith(
            title: title.isEmpty ? '无标题笔记' : title,
            plainText: plain,
            richContentJson: richJson,
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
