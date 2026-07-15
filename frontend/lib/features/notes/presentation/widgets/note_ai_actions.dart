import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// AI Actions card shown in the Note Detail screen.
/// All buttons are UI-only placeholders.
class NoteAIActions extends StatelessWidget {
  const NoteAIActions({super.key});

  static const List<_AIAction> _actions = [
    _AIAction(
      icon: Icons.summarize_outlined,
      label: 'Summarize',
      subtitle: 'Generate a concise summary',
      color: Color(0xFF50E3C2),
    ),
    _AIAction(
      icon: Icons.lightbulb_outline_rounded,
      label: 'Explain',
      subtitle: 'Get simplified explanation',
      color: Color(0xFF4A90E2),
    ),
    _AIAction(
      icon: Icons.style_outlined,
      label: 'Flashcards',
      subtitle: 'Create study flashcards',
      color: Color(0xFFAB47BC),
    ),
    _AIAction(
      icon: Icons.quiz_outlined,
      label: 'Generate Quiz',
      subtitle: 'Auto-create practice quiz',
      color: Color(0xFFFFA726),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
          borderRadius: AppRadius.roundedXl,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.20),
                    borderRadius: AppRadius.roundedLg,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.tertiary, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Study Actions',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Powered by StudyFlow AI',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.20),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text(
                    'Beta',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Action buttons (2 × 2 grid)
            ...List.generate(2, (row) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: row < 1 ? AppSpacing.sm : 0),
                child: Row(
                  children: List.generate(2, (col) {
                    final idx = row * 2 + col;
                    final action = _actions[idx];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: col == 1 ? AppSpacing.sm : 0),
                        child: _AIActionButton(action: action),
                      ),
                    );
                  }),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _AIAction {
  const _AIAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
}

class _AIActionButton extends StatelessWidget {
  const _AIActionButton({required this.action});
  final _AIAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withValues(alpha: 0.08),
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
              color: AppColors.onPrimary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.20),
                borderRadius: AppRadius.roundedMd,
              ),
              child: Icon(action.icon, color: action.color, size: 15),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    action.subtitle,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.55),
                      fontSize: 8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
