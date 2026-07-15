import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/subjects/data/mock_subject_data.dart';

/// Phase 2E — Subject Notes placeholder screen.
class SubjectNotesScreen extends StatelessWidget {
  const SubjectNotesScreen({super.key, required this.subjectId});
  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final detail = MockSubjectData.getById(subjectId);
    final notes = detail.notes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.onSurface)),
            Text(detail.name,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.secondary),
            onPressed: () {},
          ),
        ],
      ),
      body: notes.isEmpty
          ? _EmptyNotes()
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: notes.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (ctx, i) => _NoteCard(note: notes[i]),
            ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final MockSubjectNote note;

  String _fmt(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.roundedMd,
                ),
                child: const Icon(Icons.description_outlined,
                    color: AppColors.secondary, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.title,
                        style: AppTypography.titleSmall.copyWith(
                            color: AppColors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('${note.pageCount} pages · ${_fmt(note.updatedAt)}',
                        style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
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
          Text(
            note.preview,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.10),
                borderRadius: AppRadius.roundedXl,
              ),
              child: const Icon(Icons.description_outlined,
                  color: AppColors.secondary, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No notes yet',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add your first note to start studying.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
