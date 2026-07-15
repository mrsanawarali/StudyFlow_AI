import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';

/// Card showing a recent note in a horizontal scroll list.
class RecentNoteCard extends StatelessWidget {
  const RecentNoteCard({super.key, required this.note});

  final MockNote note;

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,   // size to content — no Spacer
        children: [
          // Top row: icon + favourite
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.roundedMd,
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.secondary,
                  size: 16,
                ),
              ),
              const Spacer(),
              Icon(
                note.isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: note.isFavorite
                    ? AppColors.secondary
                    : AppColors.outline,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

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
            note.previewText,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),   // fixed gap, no Spacer

          // Footer: subject + time
          Text(
            note.subject,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _formatTime(note.updatedAt),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
