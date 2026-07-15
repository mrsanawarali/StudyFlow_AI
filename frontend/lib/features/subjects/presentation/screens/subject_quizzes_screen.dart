import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/subjects/data/mock_subject_data.dart';

/// Phase 2E — Subject Quizzes placeholder screen.
class SubjectQuizzesScreen extends StatelessWidget {
  const SubjectQuizzesScreen({super.key, required this.subjectId});
  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final detail = MockSubjectData.getById(subjectId);
    final quizzes = detail.quizzes;
    final done = quizzes.where((q) => q.isDone).toList();
    final upcoming = quizzes.where((q) => !q.isDone).toList();

    double avgScore = 0;
    if (done.isNotEmpty) {
      final total = done.fold<double>(
          0, (s, q) => s + (q.score ?? 0) / q.totalScore);
      avgScore = (total / done.length) * 100;
    }

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
            Text('Quizzes',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.onSurface)),
            Text(detail.name,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: Color(0xFFAB47BC)),
            onPressed: () {},
          ),
        ],
      ),
      body: quizzes.isEmpty
          ? _EmptyQuizzes()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Score summary banner
                if (done.isNotEmpty)
                  _ScoreBanner(
                    done: done.length,
                    upcoming: upcoming.length,
                    avgScore: avgScore,
                  ),
                if (done.isNotEmpty)
                  const SizedBox(height: AppSpacing.lg),

                if (upcoming.isNotEmpty) ...[
                  _SectionLabel(label: 'Upcoming'),
                  const SizedBox(height: AppSpacing.sm),
                  ...upcoming.map((q) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _QuizCard(quiz: q),
                      )),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (done.isNotEmpty) ...[
                  _SectionLabel(label: 'Completed'),
                  const SizedBox(height: AppSpacing.sm),
                  ...done.map((q) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _QuizCard(quiz: q),
                      )),
                ],
              ],
            ),
    );
  }
}

class _ScoreBanner extends StatelessWidget {
  const _ScoreBanner({
    required this.done,
    required this.upcoming,
    required this.avgScore,
  });
  final int done;
  final int upcoming;
  final double avgScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.roundedXl,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFAB47BC).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BannerCell(
              value: '$done', label: 'Done', icon: Icons.check_rounded),
          _BannerCell(
              value: '$upcoming',
              label: 'Upcoming',
              icon: Icons.schedule_rounded),
          _BannerCell(
              value: '${avgScore.round()}%',
              label: 'Avg Score',
              icon: Icons.stars_rounded),
        ],
      ),
    );
  }
}

class _BannerCell extends StatelessWidget {
  const _BannerCell(
      {required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: Colors.white.withValues(alpha: 0.80), size: 16),
        const SizedBox(height: 2),
        Text(value,
            style: AppTypography.titleMedium
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        Text(label,
            style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.70))),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.titleSmall.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.quiz});
  final MockSubjectQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final scoreColor = quiz.score == null
        ? AppColors.onSurfaceVariant
        : quiz.score! >= quiz.totalScore * 0.8
            ? AppColors.success
            : quiz.score! >= quiz.totalScore * 0.5
                ? AppColors.warning
                : AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFAB47BC).withValues(alpha: 0.10),
            borderRadius: AppRadius.roundedMd,
          ),
          child: const Icon(Icons.quiz_outlined,
              color: Color(0xFFAB47BC), size: 20),
        ),
        title: Text(quiz.title,
            style: AppTypography.titleSmall
                .copyWith(color: AppColors.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${quiz.date.day}/${quiz.date.month}/${quiz.date.year}',
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        trailing: quiz.isDone && quiz.score != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text('${quiz.score}/${quiz.totalScore}',
                    style: AppTypography.labelMedium.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                    )),
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text('Upcoming',
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600)),
              ),
      ),
    );
  }
}

class _EmptyQuizzes extends StatelessWidget {
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
                color: const Color(0xFFAB47BC).withValues(alpha: 0.10),
                borderRadius: AppRadius.roundedXl,
              ),
              child: const Icon(Icons.quiz_outlined,
                  color: Color(0xFFAB47BC), size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No quizzes yet',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.xs),
            Text('Add quizzes to track your performance.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
