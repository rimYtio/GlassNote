import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/tag.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';
import '../../../ui_system/widgets/glass_card.dart';
import '../../../ui_system/widgets/glass_scaffold.dart';
import '../../notes/presentation/notes_controller.dart';

class TagManagementPage extends ConsumerStatefulWidget {
  const TagManagementPage({super.key});

  @override
  ConsumerState<TagManagementPage> createState() => _TagManagementPageState();
}

class _TagManagementPageState extends ConsumerState<TagManagementPage> {
  @override
  Widget build(BuildContext context) {
    final allTags = ref.watch(allTagsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassScaffold(
      title: '标签管理',
      actions: [
        IconButton(
          tooltip: '新建标签',
          icon: const Icon(Icons.add),
          onPressed: () => _showCreateTagDialog(context),
        ),
      ],
      body: allTags.when(
        data: (tags) {
          if (tags.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.label_outline_rounded,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无标签',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showCreateTagDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('新建标签'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 108),
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return _TagListTile(
                tag: tag,
                onEdit: () => _showEditTagDialog(context, tag),
                onDelete: () => _showDeleteConfirm(context, tag),
              );
            },
          );
        },
        error: (error, _) => Center(child: Text('标签加载失败: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showCreateTagDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => const _TagEditorDialog(),
    );
  }

  void _showEditTagDialog(BuildContext context, Tag tag) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _TagEditorDialog(existingTag: tag),
    );
  }

  void _showDeleteConfirm(BuildContext context, Tag tag) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('删除标签'),
          content: Text('确定要删除标签 "${tag.name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                ref.read(tagRepositoryProvider).delete(tag.id);
                Navigator.of(ctx).pop();
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}

class _TagListTile extends StatelessWidget {
  const _TagListTile({
    required this.tag,
    required this.onEdit,
    required this.onDelete,
  });

  final Tag tag;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: onEdit,
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Color(tag.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tag.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _TagEditorDialog extends ConsumerStatefulWidget {
  const _TagEditorDialog({this.existingTag});

  final Tag? existingTag;

  @override
  ConsumerState<_TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends ConsumerState<_TagEditorDialog> {
  late final _nameController = TextEditingController(
    text: widget.existingTag?.name ?? '',
  );
  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.existingTag?.color ?? 0xFF7C6FF7;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingTag != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? '编辑标签' : '新建标签'),
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
            final repo = ref.read(tagRepositoryProvider);
            if (_isEditing) {
              await repo.rename(widget.existingTag!.id, name);
            } else {
              await repo.create(name, _selectedColor);
            }
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(_isEditing ? '保存' : '创建'),
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
    0xFFF44336,
    0xFFE91E63,
    0xFF9C27B0,
    0xFF673AB7,
    0xFF3F51B5,
    0xFF2196F3,
    0xFF03A9F4,
    0xFF00BCD4,
    0xFF009688,
    0xFF4CAF50,
    0xFF8BC34A,
    0xFFCDDC39,
    0xFFFFEB3B,
    0xFFFFC107,
    0xFFFF9800,
    0xFFFF5722,
    0xFF795548,
    0xFF607D8B,
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
