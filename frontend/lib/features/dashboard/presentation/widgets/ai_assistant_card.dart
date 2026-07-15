import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// AI Study Assistant promotional card with four action buttons.
class AIAssistantCard extends StatelessWidget {
  const AIAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0F2C), Color(0xFF1A2F4C)],
          ),
          borderRadius: AppRadius.roundedXl,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.20),
                    borderRadius: AppRadius.roundedLg,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.tertiary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Study Assistant',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Powered by StudyFlow AI',
                      style: AppTypography.labelSmall.copyWith(
                        color:
                            AppColors.onPrimary.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.18),
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
            const SizedBox(height: AppSpacing.lg),

            // Action grid (2 × 2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 2.8,
              children: const [
                _AIActionButton(
                  icon: Icons.chat_outlined,
                  label: 'Ask AI',
                  color: Color(0xFF50E3C2),
                ),
                _AIActionButton(
                  icon: Icons.summarize_outlined,
                  label: 'Summarize Notes',
                  color: Color(0xFF4A90E2),
                ),
                _AIActionButton(
                  icon: Icons.quiz_outlined,
                  label: 'Generate Quiz',
                  color: Color(0xFFFFA726),
                ),
                _AIActionButton(
                  icon: Icons.calendar_today_outlined,
                  label: 'Study Planner',
                  color: Color(0xFFAB47BC),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AIActionButton extends StatelessWidget {
  const _AIActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withValues(alpha: 0.08),
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: AppColors.onPrimary.withValues(alpha: 0.12),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.90),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
