import 'package:flutter/material.dart';

import '../../../../domain/entities/tag.dart';

class TagChipDisplay extends StatelessWidget {
  const TagChipDisplay({
    super.key,
    required this.tags,
    this.compact = false,
    this.onChipTap,
  });

  final List<Tag> tags;
  final bool compact;
  final void Function(Tag)? onChipTap;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final tag in tags)
          GestureDetector(
            onTap: onChipTap != null ? () => onChipTap!(tag) : null,
            child: Container(
              height: compact ? 20 : 24,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Color(tag.color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(compact ? 10 : 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 7 : 8,
                    height: compact ? 7 : 8,
                    decoration: BoxDecoration(
                      color: Color(tag.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    tag.name,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      color: Color(tag.color),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
