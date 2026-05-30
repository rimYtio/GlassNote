import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/tag.dart';
import '../../../../infrastructure/providers/infrastructure_providers.dart';
import '../notes_controller.dart';

Future<void> showTagPicker(
  BuildContext context,
  WidgetRef ref,
  String noteId,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _TagPickerSheet(noteId: noteId),
  );
}

class _TagPickerSheet extends ConsumerStatefulWidget {
  const _TagPickerSheet({required this.noteId});

  final String noteId;

  @override
  ConsumerState<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<_TagPickerSheet> {
  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(allTagsProvider);
    final noteTags = ref.watch(_noteTagsProvider(widget.noteId));
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    '选择标签',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.invalidate(tagsByNoteProvider(widget.noteId));
                      Navigator.of(context).pop();
                    },
                    child: const Text('完成'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: noteTags.when(
                data: (selectedIds) => allTags.when(
                  data: (tags) {
                    if (tags.isEmpty) {
                      return Center(
                        child: Text(
                          '暂无标签',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      );
                    }
                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8,
                      ),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final tag in tags)
                              _TagChip(
                                tag: tag,
                                isSelected: selectedIds.contains(tag.id),
                                onToggle: () async {
                                  final repo = ref.read(tagRepositoryProvider);
                                  if (selectedIds.contains(tag.id)) {
                                    await repo.removeTagFromNote(widget.noteId, tag.id);
                                  } else {
                                    await repo.addTagToNote(widget.noteId, tag.id);
                                  }
                                  ref.invalidate(_noteTagsProvider(widget.noteId));
                                  ref.invalidate(noteByIdProvider(widget.noteId));
                                },
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                  error: (error, _) => Center(
                    child: Text('标签加载失败: $error'),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Center(
                  child: Text('加载失败: $error'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCreateTagDialog(context, ref),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('新建标签'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateTagDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => const _CreateTagDialog(),
    );
  }
}

final _noteTagsProvider = StreamProvider.family<List<String>, String>((
  ref,
  noteId,
) {
  return ref.watch(tagRepositoryProvider).listByNote(noteId).asStream().map(
    (tags) => tags.map((t) => t.id).toList(),
  );
});

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onToggle,
  });

  final Tag tag;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tagColor = Color(tag.color);

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onToggle(),
      avatar: CircleAvatar(
        radius: 6,
        backgroundColor: tagColor,
      ),
      label: Text(tag.name),
      selectedColor: tagColor.withValues(alpha: 0.15),
      checkmarkColor: tagColor,
      side: BorderSide(
        color: isSelected ? tagColor : colorScheme.outline.withValues(alpha: 0.3),
      ),
    );
  }
}

class _CreateTagDialog extends ConsumerStatefulWidget {
  const _CreateTagDialog();

  @override
  ConsumerState<_CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends ConsumerState<_CreateTagDialog> {
  final _nameController = TextEditingController();
  int _selectedColor = 0xFF7C6FF7;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建标签'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '标签名称',
              hintText: '输入标签名',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('颜色：'),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showColorPicker(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(_selectedColor),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ColorPalette(
            selectedColor: _selectedColor,
            onSelect: (color) => setState(() => _selectedColor = color),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            await ref.read(tagRepositoryProvider).create(name, _selectedColor);
            if (context.mounted) Navigator.of(context).pop();
          },
          child: const Text('创建'),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('选择颜色'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Color(_selectedColor),
              onColorChanged: (color) =>
                  setState(() => _selectedColor = color.toARGB32()),
              enableAlpha: false,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

class _ColorPalette extends StatelessWidget {
  const _ColorPalette({required this.selectedColor, required this.onSelect});

  final int selectedColor;
  final ValueChanged<int> onSelect;

  static const _colors = [
    0xFFF44336, // red
    0xFFE91E63, // pink
    0xFF9C27B0, // purple
    0xFF673AB7, // deep purple
    0xFF3F51B5, // indigo
    0xFF2196F3, // blue
    0xFF03A9F4, // light blue
    0xFF00BCD4, // cyan
    0xFF009688, // teal
    0xFF4CAF50, // green
    0xFF8BC34A, // light green
    0xFFCDDC39, // lime
    0xFFFFEB3B, // yellow
    0xFFFFC107, // amber
    0xFFFF9800, // orange
    0xFFFF5722, // deep orange
    0xFF795548, // brown
    0xFF607D8B, // blue grey
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final color in _colors)
          GestureDetector(
            onTap: () => onSelect(color),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
                border: color == selectedColor
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
