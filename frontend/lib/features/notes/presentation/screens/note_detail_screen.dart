import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';
import 'package:untitled/features/notes/data/mock_notes_data.dart';
import '../widgets/note_ai_actions.dart';

/// Phase 2F — Note Detail Screen with beautiful reading layout.
class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key, required this.noteId});
  final String noteId;

  MockNote? get _note => MockNotesData.getById(noteId);

  String _fmt(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final note = _note;

    if (note == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Note not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.onSurface),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  note.isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: note.isFavorite
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.onSurface),
                onPressed: () =>
                    context.push(RoutePaths.noteEditPath(note.id)),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    color: AppColors.onSurface),
                onPressed: () {},
              ),
            ],
          ),

          // ── Body ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: note.subjectColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.roundedFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: note.subjectColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              note.subject,
                              style: AppTypography.labelSmall.copyWith(
                                color: note.subjectColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Title
                      Text(
                        note.title,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Meta row
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _MetaChip(
                            icon: Icons.access_time_rounded,
                            label: '${note.readingTimeMin} min read',
                          ),
                          _MetaChip(
                            icon: Icons.text_fields_rounded,
                            label: '${note.wordCount} words',
                          ),
                          _MetaChip(
                            icon: Icons.update_rounded,
                            label: _fmt(note.updatedAt),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Tags
                      if (note.tags.isNotEmpty)
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: note.tags.map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: AppRadius.roundedFull,
                              ),
                              child: Text(
                                '#$t',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const Divider(
                    color: AppColors.outlineVariant, thickness: 1),

                // ── Note content (rich text placeholder) ─────────────────
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _NoteContentRenderer(content: note.content),
                ),

                // ── Attachments ───────────────────────────────────────────
                if (note.attachments.isNotEmpty) ...[
                  const Divider(
                      color: AppColors.outlineVariant, thickness: 1),
                  SectionHeader(title: 'Attachments'),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Column(
                      children: note.attachments
                          .map((a) => _AttachmentRow(attachment: a))
                          .toList(),
                    ),
                  ),
                ],

                // ── AI Actions ────────────────────────────────────────────
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: 'AI Study Actions'),
                const SizedBox(height: AppSpacing.md),
                const NoteAIActions(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rich text placeholder renderer ────────────────────────────────────────────

class _NoteContentRenderer extends StatelessWidget {
  const _NoteContentRenderer({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    final lines = content.trim().split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();

        if (trimmed.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(
                top: AppSpacing.md, bottom: AppSpacing.xs),
            child: Text(
              trimmed.substring(3),
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        if (trimmed.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(
                top: AppSpacing.sm, bottom: AppSpacing.xs),
            child: Text(
              trimmed.substring(4),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
          return Padding(
            padding:
                const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    trimmed.substring(2),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurface,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (trimmed.startsWith('```') || trimmed.endsWith('```')) {
          return const SizedBox.shrink();
        }

        if (trimmed.startsWith('|') && trimmed.endsWith('|')) {
          return _TableRow(row: trimmed);
        }

        if (trimmed.isEmpty) {
          return const SizedBox(height: AppSpacing.xs);
        }

        // Bold support: **text**
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: _BoldText(text: trimmed),
        );
      }).toList(),
    );
  }
}

class _BoldText extends StatelessWidget {
  const _BoldText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    // Simple bold rendering: split on **...**
    final parts = text.split(RegExp(r'\*\*'));
    if (parts.length <= 1) {
      return Text(text,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurface,
            height: 1.7,
          ));
    }

    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: i.isOdd
            ? AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.7,
              )
            : AppTypography.bodyMedium.copyWith(
                color: AppColors.onSurface,
                height: 1.7,
              ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.row});
  final String row;

  @override
  Widget build(BuildContext context) {
    final cells = row
        .split('|')
        .where((c) => c.trim().isNotEmpty && !c.trim().startsWith('-'))
        .map((c) => c.trim())
        .toList();

    if (cells.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: cells
            .map((c) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.outlineVariant, width: 0.5),
                    ),
                    child: Text(c,
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurface)),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Attachment row ────────────────────────────────────────────────────────────

class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.attachment});
  final MockAttachment attachment;

  IconData get _icon => switch (attachment.type) {
        'pdf' => Icons.picture_as_pdf_outlined,
        'image' => Icons.image_outlined,
        _ => Icons.link_rounded,
      };

  Color get _color => switch (attachment.type) {
        'pdf' => AppColors.error,
        'image' => AppColors.secondary,
        _ => AppColors.tertiary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.10),
            borderRadius: AppRadius.roundedMd,
          ),
          child: Icon(_icon, color: _color, size: 18),
        ),
        title: Text(
          attachment.name,
          style: AppTypography.titleSmall
              .copyWith(color: AppColors.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${attachment.sizeMb.toStringAsFixed(1)} MB · ${attachment.type.toUpperCase()}',
          style: AppTypography.labelSmall
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        trailing: Icon(Icons.download_outlined,
            color: AppColors.onSurfaceVariant, size: 18),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 0),
      ),
    );
  }
}

// ── Meta chip ─────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.labelSmall
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
