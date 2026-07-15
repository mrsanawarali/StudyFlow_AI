import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/notes/data/mock_notes_data.dart';
import 'package:untitled/features/semesters/data/mock_semester_data.dart';

/// Phase 2F — Create / Edit Note Screen.
///
/// UI only — no persistence. Mock save simulates a loading state.
class NoteEditScreen extends StatefulWidget {
  const NoteEditScreen({super.key, this.noteId});

  /// If provided, loads the existing note for editing.
  final String? noteId;

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String? _selectedSubject;
  bool _isFavorite = false;
  bool _isSaving = false;

  bool get _isEditing => widget.noteId != null;

  // Available subjects from mock data
  static List<String> get _subjects {
    final seen = <String>{};
    final out = <String>[];
    for (final sem in MockSemesterData.semesters) {
      for (final s in sem.subjects) {
        if (seen.add(s.name)) out.add(s.name);
      }
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final note = MockNotesData.getById(widget.noteId!);
      if (note != null) {
        _titleCtrl.text = note.title;
        _contentCtrl.text = note.content.trim();
        _selectedSubject = note.subject;
        _isFavorite = note.isFavorite;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isSaving = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Note' : 'New Note',
          style: AppTypography.titleMedium
              .copyWith(color: AppColors.onSurface),
        ),
        actions: [
          // Favourite toggle
          IconButton(
            icon: Icon(
              _isFavorite
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _isFavorite
                  ? AppColors.secondary
                  : AppColors.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedLg),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text('Save',
                        style: AppTypography.labelMedium
                            .copyWith(color: AppColors.onPrimary)),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ────────────────────────────────────────────────────
            TextField(
              controller: _titleCtrl,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Note title...',
                hintStyle: AppTypography.headlineSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 2,
              minLines: 1,
            ),
            const Divider(
                color: AppColors.outlineVariant, thickness: 1),
            const SizedBox(height: AppSpacing.md),

            // ── Subject picker ────────────────────────────────────────────
            Text(
              'Subject',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _subjects.map((s) {
                final isSelected = _selectedSubject == s;
                return GestureDetector(
                  onTap: () => setState(() =>
                      _selectedSubject = isSelected ? null : s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: AppRadius.roundedFull,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outline,
                      ),
                    ),
                    child: Text(
                      s,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Toolbar (formatting placeholder) ─────────────────────────
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icons.format_bold_rounded,
                    Icons.format_italic_rounded,
                    Icons.format_list_bulleted_rounded,
                    Icons.format_list_numbered_rounded,
                    Icons.code_rounded,
                    Icons.link_rounded,
                    Icons.attach_file_rounded,
                    Icons.auto_awesome_rounded,
                  ]
                      .map((icon) => SizedBox(
                            width: 40,
                            height: 44,
                            child: IconButton(
                              icon: Icon(icon,
                                  size: 18,
                                  color: AppColors.onSurfaceVariant),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Content ───────────────────────────────────────────────────
            Container(
              constraints: const BoxConstraints(minHeight: 300),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedXl,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _contentCtrl,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  height: 1.7,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Start writing your note...\n\nUse ## for headings, - for bullets',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.7,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── AI assist prompt ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.08),
                borderRadius: AppRadius.roundedXl,
                border: Border.all(
                    color: AppColors.tertiary.withValues(alpha: 0.25)),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.tertiary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Writing Assistant',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Let AI help you expand, improve or summarise your notes.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: AppRadius.roundedLg,
                      ),
                      child: Text(
                        'Ask AI',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
