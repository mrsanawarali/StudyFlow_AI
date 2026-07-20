import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/quizzes/data/mock_quizzes_data.dart';

/// Phase 2H — Quiz Detail Screen.
///
/// For upcoming quizzes: interactive MCQ/T-F attempt UI.
/// For completed quizzes: read-only review showing correct answers.
class QuizDetailScreen extends StatefulWidget {
  const QuizDetailScreen({super.key, required this.quizId});
  final String quizId;

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  MockQuiz? _quiz;

  // Attempt state — maps question id → selected option index
  final Map<String, int> _answers = {};
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _quiz = MockQuizzesData.getById(widget.quizId);
  }

  int get _score {
    if (_quiz == null) return 0;
    int s = 0;
    for (final q in _quiz!.questions) {
      if (_answers[q.id] == q.correctIndex) s++;
    }
    return s;
  }

  void _submit() {
    if (_quiz == null) return;
    setState(() => _submitted = true);
    // Navigate to result screen with computed score
    context.push(
      RoutePaths.quizResultPath(widget.quizId),
      extra: {'score': _score, 'total': _quiz!.questions.length},
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;
    if (quiz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    final isReview = quiz.status == QuizStatus.completed;
    final answered = _answers.length;
    final total = quiz.questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: quiz.subjectColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (!isReview && !_submitted)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Center(
                    child: Text(
                      '$answered/$total answered',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      quiz.subjectColor,
                      quiz.subjectColor.withValues(alpha: 0.70),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xxl + AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Subject badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(quiz.subject,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(quiz.title,
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        )),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${quiz.durationMinutes} min  ·  $total questions  ·  ${quiz.totalMarks} marks',
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Progress bar (attempt mode only)
                if (!isReview && !_submitted) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress',
                                style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.onSurfaceVariant)),
                            Text(
                                '${answered == 0 ? 0 : ((answered / total) * 100).round()}%',
                                style: AppTypography.labelSmall.copyWith(
                                  color: quiz.subjectColor,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ClipRRect(
                          borderRadius: AppRadius.roundedFull,
                          child: LinearProgressIndicator(
                            value: total == 0 ? 0 : answered / total,
                            backgroundColor: quiz.subjectColor
                                .withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                quiz.subjectColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Completed quiz score card
                if (isReview && quiz.obtainedMarks != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: _ScoreCard(quiz: quiz),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Topic chip
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              quiz.subjectColor.withValues(alpha: 0.10),
                          borderRadius: AppRadius.roundedFull,
                          border: Border.all(
                              color: quiz.subjectColor
                                  .withValues(alpha: 0.25)),
                        ),
                        child: Text('Topic: ${quiz.topic}',
                            style: AppTypography.labelSmall.copyWith(
                              color: quiz.subjectColor,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadius.roundedFull,
                        ),
                        child: Text(
                            isReview ? 'Review Mode' : 'Attempt Mode',
                            style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Questions
                ...List.generate(quiz.questions.length, (i) {
                  final q = quiz.questions[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: _QuestionCard(
                      question: q,
                      index: i,
                      selectedIndex: isReview
                          ? q.correctIndex
                          : _answers[q.id],
                      isReview: isReview,
                      subjectColor: quiz.subjectColor,
                      onSelect: _submitted || isReview
                          ? null
                          : (idx) => setState(
                              () => _answers[q.id] = idx),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),

                // Submit button (attempt mode)
                if (!isReview && !_submitted)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            answered < total ? null : _submit,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(
                          answered < total
                              ? 'Answer all questions to submit'
                              : 'Submit Quiz',
                          style: AppTypography.labelLarge
                              .copyWith(color: AppColors.onPrimary),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          disabledBackgroundColor:
                              AppColors.outline,
                          disabledForegroundColor:
                              AppColors.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.roundedLg),
                        ),
                      ),
                    ),
                  ),

                // View result button (review mode)
                if (isReview)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(
                          RoutePaths.quizResultPath(widget.quizId),
                          extra: {
                            'score': quiz.obtainedMarks ?? 0,
                            'total': quiz.questions.length,
                          },
                        ),
                        icon: const Icon(Icons.bar_chart_rounded,
                            size: 18),
                        label: Text('View Result',
                            style: AppTypography.labelLarge
                                .copyWith(color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side:
                              const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.roundedLg),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score card ────────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.quiz});
  final MockQuiz quiz;

  @override
  Widget build(BuildContext context) {
    final pct = quiz.percentage;
    final scoreColor = pct >= 80
        ? AppColors.success
        : pct >= 60
            ? AppColors.warning
            : AppColors.error;

    return Container(
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.06),
        borderRadius: AppRadius.roundedXl,
        border:
            Border.all(color: scoreColor.withValues(alpha: 0.30)),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${pct.round()}%',
                style: AppTypography.titleMedium.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${quiz.obtainedMarks} / ${quiz.totalMarks} marks',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Grade: ${quiz.grade}',
                  style: AppTypography.bodySmall.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            pct >= 80
                ? Icons.emoji_events_outlined
                : Icons.school_outlined,
            color: scoreColor,
            size: 28,
          ),
        ],
      ),
    );
  }
}

// ── Question card ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.index,
    required this.selectedIndex,
    required this.isReview,
    required this.subjectColor,
    required this.onSelect,
  });

  final MockQuizQuestion question;
  final int index;
  final int? selectedIndex;
  final bool isReview;
  final Color subjectColor;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          // Question header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.labelSmall.copyWith(
                      color: subjectColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  question.question,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Options
          ...List.generate(question.options.length, (i) {
            final isSelected = selectedIndex == i;
            final isCorrect = question.correctIndex == i;

            Color bgColor = AppColors.surfaceVariant;
            Color borderColor = AppColors.outlineVariant;
            Color textColor = AppColors.onSurface;
            IconData? trailingIcon;

            if (isReview) {
              if (isCorrect) {
                bgColor = AppColors.success.withValues(alpha: 0.10);
                borderColor = AppColors.success.withValues(alpha: 0.40);
                textColor = AppColors.success;
                trailingIcon = Icons.check_circle_rounded;
              }
            } else if (isSelected) {
              bgColor = subjectColor.withValues(alpha: 0.12);
              borderColor = subjectColor;
              textColor = subjectColor;
            }

            return GestureDetector(
              onTap: onSelect != null ? () => onSelect!(i) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Option letter
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected || (isReview && isCorrect)
                            ? textColor.withValues(alpha: 0.15)
                            : AppColors.outlineVariant
                                .withValues(alpha: 0.50),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + i), // A, B, C, D
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected || (isReview && isCorrect)
                                ? textColor
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        question.options[i],
                        style: AppTypography.bodyMedium
                            .copyWith(color: textColor),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(trailingIcon, color: textColor, size: 18),
                    if (isSelected && !isReview)
                      Icon(Icons.radio_button_checked_rounded,
                          color: subjectColor, size: 18),
                  ],
                ),
              ),
            );
          }),

          // Explanation (review mode)
          if (isReview && question.explanation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: AppRadius.roundedLg,
                border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.25)),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppColors.info, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
