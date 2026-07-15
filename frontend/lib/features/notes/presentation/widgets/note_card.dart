import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/notes/data/mock_notes_data.dart';

/// Note card — supports both grid and list display modes.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.isGrid = false,
  });

  final MockNote note;
  final VoidCallback onTap;
  final bool isGrid;

  String _fmt(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    if (d.inDays == 1) return 'Yesterday';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return isGrid ? _GridCard(note: note, onTap: onTap, fmt: _fmt) :
                    _ListCard(note: note, onTap: onTap, fmt: _fmt);
  }
}

// ── Grid variant ──────────────────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  const _GridCard({
    required this.note,
    required this.onTap,
    required this.fmt,
  });
  final MockNote note;
  final VoidCallback onTap;
  final String Function(DateTime) fmt;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(
            color: note.isPinned
                ? note.subjectColor.withValues(alpha: 0.40)
                : AppColors.outlineVariant,
            width: note.isPinned ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: note.subjectColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subject colour bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: note.subjectColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pin + fav row
                  Row(
                    children: [
                      if (note.isPinned)
                        const Icon(Icons.push_pin_rounded,
                            size: 12, color: AppColors.secondary),
                      const Spacer(),
                      Icon(
                        note.isFavorite
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 16,
                        color: note.isFavorite
                            ? AppColors.secondary
                            : AppColors.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Title
                  Text(
                    note.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Preview
                  Text(
                    note.content.trim().replaceAll(RegExp(r'#+ '), '').replaceAll('\n', ' '),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Tags (first 2)
                  if (note.tags.isNotEmpty)
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: note.tags.take(2).map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: note.subjectColor.withValues(alpha: 0.10),
                          borderRadius: AppRadius.roundedFull,
                        ),
                        child: Text('#$t',
                            style: AppTypography.labelSmall.copyWith(
                              color: note.subjectColor,
                              fontSize: 9,
                            )),
                      )).toList(),
                    ),
                  const SizedBox(height: AppSpacing.sm),

                  // Footer — subject left, time right, no overflow
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          note.subject,
                          style: AppTypography.labelSmall.copyWith(
                            color: note.subjectColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        fmt(note.updatedAt),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List variant ──────────────────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.note,
    required this.onTap,
    required this.fmt,
  });
  final MockNote note;
  final VoidCallback onTap;
  final String Function(DateTime) fmt;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left colour bar
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: note.subjectColor,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (note.isPinned) ...[
                          const Icon(Icons.push_pin_rounded,
                              size: 11,
                              color: AppColors.secondary),
                          const SizedBox(width: 3),
                        ],
                        Expanded(
                          child: Text(
                            note.title,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          note.isFavorite
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 16,
                          color: note.isFavorite
                              ? AppColors.secondary
                              : AppColors.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      note.content.trim().replaceAll(RegExp(r'#+ '), '').replaceAll('\n', ' '),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: note.subjectColor.withValues(alpha: 0.10),
                            borderRadius: AppRadius.roundedFull,
                          ),
                          child: Text(
                            note.subject,
                            style: AppTypography.labelSmall.copyWith(
                              color: note.subjectColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${note.readingTimeMin} min  ·  ${fmt(note.updatedAt)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
