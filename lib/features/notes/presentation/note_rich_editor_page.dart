import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

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
import 'widgets/rich_toolbar_toggle.dart';
import 'widgets/tag_chip_display.dart';
import 'widgets/tag_picker.dart';

class NoteRichEditorPage extends ConsumerStatefulWidget {
  const NoteRichEditorPage({super.key, this.noteId, this.folderId});

  final String? noteId;
  final String? folderId;

  @override
  ConsumerState<NoteRichEditorPage> createState() => _NoteRichEditorPageState();
}

class _NoteRichEditorPageState extends ConsumerState<NoteRichEditorPage> {
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _quillController = QuillController.basic();
  final _bodyFocusNode = FocusNode();
  final _bodyScrollController = ScrollController();
  bool _loadedExistingNote = false;
  bool _loadFailed = false;
  bool _editorReady = false;
  bool _saving = false;
  Timer? _autoSaveTimer;
  String? _createdNoteId;
  final _exportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Listener added only after content is loaded — prevents auto-save during load
  }

  @override
  void dispose() {
    _titleController.removeListener(_onContentChanged);
    _quillController.removeListener(_onContentChanged);
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _titleFocusNode.dispose();
    _bodyFocusNode.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (_loadFailed) return;
    if (mounted) {
      setState(() {});
    }
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

  String _plainText() => _quillController.document.toPlainText().trimRight();

  String _richContentJson() =>
      jsonEncode(_quillController.document.toDelta().toJson());

  Future<String?> _ensureSavedNoteId() async {
    if (_effectiveNoteId != null) return _effectiveNoteId;
    final title = _titleController.text.trim();
    final note = await ref
        .read(notesActionsProvider)
        .createNote(
          title: title.isEmpty ? '无标题笔记' : title,
          plainText: _plainText(),
          richContentJson: _richContentJson(),
          folderId: widget.folderId ?? Folder.uncategorizedId,
        );
    _createdNoteId = note.id;
    if (mounted) {
      setState(() {});
    }
    return note.id;
  }

  Future<void> _autoSave() async {
    final title = _titleController.text.trim();
    final plain = _plainText();
    final richJson = _richContentJson();

    if (!_hasContent) return;

    if (_loadFailed) return;
    if (!_editorReady) return;

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
      if (mounted) {
        setState(() {});
      }
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
          _titleController.text = note.title;
          _loadContent(note);
          _loadedExistingNote = true;
          if (!_loadFailed) {
            _titleController.addListener(_onContentChanged);
            _quillController.addListener(_onContentChanged);
            _editorReady = true;
          }
        }
      });
    }

    // New note: mark editor ready immediately (no content to load)
    if (noteId == null && !_editorReady) {
      _editorReady = true;
      _titleController.addListener(_onContentChanged);
      _quillController.addListener(_onContentChanged);
    }

    return _editor(context);
  }

  Widget _editor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveId = _effectiveNoteId;

    return GlassScaffold(
      title: widget.noteId == null ? '新建笔记' : '编辑笔记',
      resizeToAvoidBottomInset: false,
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
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: RepaintBoundary(
          key: _exportKey,
          child: Column(
            key: const ValueKey('note-editor-page'),
            children: [
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
              _RichToolbar(
                controller: _quillController,
                onInsertImage: _pickImage,
                onInsertAudio: _showAudioRecorder,
              ),
              const Divider(height: 1),
              if (effectiveId != null) _tagRow(effectiveId),
              Expanded(
                key: const ValueKey('note-editor-content'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (_) => _bodyFocusNode.requestFocus(),
                    child: QuillEditor.basic(
                      key: const ValueKey('note-body-field'),
                      controller: _quillController,
                      focusNode: _bodyFocusNode,
                      scrollController: _bodyScrollController,
                      config: QuillEditorConfig(
                        placeholder: '开始输入',
                        expands: true,
                        autoFocus: false,
                        onTapDown: (_, _) {
                          _bodyFocusNode.requestFocus();
                          return false;
                        },
                        scrollBottomInset:
                            MediaQuery.viewInsetsOf(context).bottom + 24,
                        embedBuilders: [ImageEmbedBuilder()],
                      ),
                    ),
                  ),
                ),
              ),
              if (effectiveId != null) _audioAttachments(effectiveId),
            ],
          ),
        ),
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
    final noteId = await _ensureSavedNoteId();
    if (noteId == null) return;
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    final attachment = await ref.read(saveNoteImageAttachmentUseCaseProvider)(
      noteId: noteId,
      bytes: bytes,
      originalFileName: xFile.name.isNotEmpty ? xFile.name : xFile.path,
    );

    final index = _quillController.selection.baseOffset;
    final insertIndex = index < 0
        ? _quillController.document.length - 1
        : index;
    _quillController.document.insert(
      insertIndex,
      BlockEmbed.image(attachment.localPath),
    );
    _quillController.document.insert(insertIndex + 1, '\n');
    _scheduleAutoSave();
  }

  void _showAudioRecorder() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AudioRecorderPanel(
        onSaved: (filePath) async {
          final noteId = await _ensureSavedNoteId();
          if (noteId == null) return;
          await ref.read(saveNoteAudioAttachmentUseCaseProvider)(
            noteId: noteId,
            tempFilePath: filePath,
          );
        },
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
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('导出 PNG'),
              subtitle: const Text('生成高清图片'),
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
      final includeMetadata =
          (await ref.read(settingsRepositoryProvider).load())
              .exportIncludeMetadata;
      DateTime? createdAt;
      List<String> imagePaths = const [];
      if (widget.noteId != null) {
        final note = await ref.read(noteByIdProvider(widget.noteId!).future);
        createdAt = note?.createdAt;
      }
      final noteId = _effectiveNoteId;
      if (noteId != null) {
        final attachments = await ref
            .read(attachmentRepositoryProvider)
            .listByNote(noteId);
        imagePaths = attachments
            .where((item) => item.type == AttachmentType.image)
            .map((item) => item.localPath)
            .toList();
      }
      final file = await pdfExporter.export(
        title.isNotEmpty ? title : '无标题笔记',
        body,
        imagePaths: imagePaths,
        createdAt: includeMetadata ? createdAt : null,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: title.isNotEmpty ? title : '笔记导出');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PDF 已导出')));
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF 导出失败: $e')));
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
      final title = _titleController.text.trim();
      final file = await ref
          .read(pngExporterProvider)
          .exportFromWidget(_exportKey, title.isNotEmpty ? title : 'note');
      if (!mounted) return;
      Navigator.of(context).pop();
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: title.isNotEmpty ? title : '笔记导出');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PNG 已导出')));
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PNG 导出失败: $e')));
    }
  }

  Widget _audioAttachments(String noteId) {
    final attachments = ref.watch(attachmentsByNoteProvider(noteId));
    return attachments.when(
      data: (items) {
        final audioItems = items
            .where((item) => item.type == AttachmentType.audio)
            .toList();
        if (audioItems.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              for (final attachment in audioItems)
                AudioPlayerBar(
                  filePath: attachment.localPath,
                  label: attachment.fileName,
                  onDelete: () async {
                    await ref.read(deleteAttachmentUseCaseProvider)(attachment);
                  },
                ),
            ],
          ),
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    _autoSaveTimer?.cancel();

    final title = _titleController.text.trim();
    final plain = _plainText();
    final richJson = _richContentJson();

    if (_loadFailed) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('笔记加载异常，已阻止保存以避免覆盖原内容')));
      setState(() => _saving = false);
      return;
    }

    if (!_editorReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('编辑器尚未初始化完成，请稍后再试')));
      setState(() => _saving = false);
      return;
    }

    final actions = ref.read(notesActionsProvider);
    var targetFolderId = widget.folderId ?? Folder.uncategorizedId;

    if (widget.noteId == null && _createdNoteId == null) {
      // Brand new note: only save if has content
      if (title.isNotEmpty || plain.trim().isNotEmpty) {
        final note = await actions.createNote(
          title: title,
          plainText: plain,
          richContentJson: richJson,
          folderId: targetFolderId,
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

class _RichToolbar extends StatelessWidget {
  const _RichToolbar({
    required this.controller,
    required this.onInsertImage,
    required this.onInsertAudio,
  });

  final QuillController controller;
  final VoidCallback onInsertImage;
  final VoidCallback onInsertAudio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('note-rich-toolbar'),
      height: 48,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final attributes = controller.getSelectionStyle().attributes;
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: [
              _ToolbarButton(
                key: const ValueKey('note-toolbar-bold'),
                icon: Icons.format_bold,
                tooltip: '粗体',
                selected: isRichToolbarAttributeActive(
                  Attribute.bold,
                  attributes,
                ),
                onTap: () =>
                    toggleRichToolbarSelection(controller, Attribute.bold),
              ),
              _ToolbarButton(
                key: const ValueKey('note-toolbar-italic'),
                icon: Icons.format_italic,
                tooltip: '斜体',
                selected: isRichToolbarAttributeActive(
                  Attribute.italic,
                  attributes,
                ),
                onTap: () =>
                    toggleRichToolbarSelection(controller, Attribute.italic),
              ),
              _ToolbarButton(
                key: const ValueKey('note-toolbar-underline'),
                icon: Icons.format_underlined,
                tooltip: '下划线',
                selected: isRichToolbarAttributeActive(
                  Attribute.underline,
                  attributes,
                ),
                onTap: () =>
                    toggleRichToolbarSelection(controller, Attribute.underline),
              ),
              _ToolbarButton(
                key: const ValueKey('note-toolbar-heading'),
                icon: Icons.title,
                tooltip: '标题',
                selected: isRichToolbarAttributeActive(
                  Attribute.h1,
                  attributes,
                ),
                onTap: () =>
                    toggleRichToolbarSelection(controller, Attribute.h1),
              ),
              _ToolbarButton(
                key: const ValueKey('note-toolbar-bullet-list'),
                icon: Icons.format_list_bulleted,
                tooltip: '项目列表',
                selected: isRichToolbarAttributeActive(
                  Attribute.ul,
                  attributes,
                ),
                onTap: () =>
                    toggleRichToolbarSelection(controller, Attribute.ul),
              ),
              _ToolbarButton(
                key: const ValueKey('note-toolbar-check-list'),
                icon: Icons.check_box_outlined,
                tooltip: '待办',
                selected: isRichToolbarAttributeActive(
                  Attribute.unchecked,
                  attributes,
                ),
                onTap: () =>
                    toggleRichToolbarSelection(controller, Attribute.unchecked),
              ),
              _ToolbarButton(
                key: const ValueKey('note-toolbar-quote'),
                icon: Icons.format_quote,
                tooltip: '引用',
                selected: isRichToolbarAttributeActive(
                  Attribute.blockQuote,
                  attributes,
                ),
                onTap: () => toggleRichToolbarSelection(
                  controller,
                  Attribute.blockQuote,
                ),
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: Icons.image_outlined,
                tooltip: '插入图片',
                onTap: onInsertImage,
              ),
              _ToolbarButton(
                icon: Icons.keyboard_voice_outlined,
                tooltip: '插入音频',
                onTap: onInsertAudio,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        tooltip: tooltip,
        isSelected: selected,
        style: IconButton.styleFrom(
          backgroundColor: selected
              ? colorScheme.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          foregroundColor: selected
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        icon: Icon(icon, size: 21),
        onPressed: onTap,
      ),
    );
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
