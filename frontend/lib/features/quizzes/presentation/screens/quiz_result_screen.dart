import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/quizzes/data/mock_quizzes_data.dart';

/// Phase 2H — Quiz Result Screen.
///
/// Displays score, grade, performance breakdown, and motivational
/// message. Receives score via [GoRouterState.extra].
class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.quizId,
    required this.score,
    required this.total,
  });

  final String quizId;
  final int score;
  final int total;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _scaleAnim = CurvedAnimation(
    parent: _scaleCtrl,
    curve: Curves.elasticOut,
  );

  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _scaleCtrl,
    curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  double get _pct =>
      widget.total == 0 ? 0 : (widget.score / widget.total) * 100;

  String get _grade {
    final p = _pct;
    if (p >= 90) return 'A+';
    if (p >= 85) return 'A';
    if (p >= 80) return 'A-';
    if (p >= 75) return 'B+';
    if (p >= 70) return 'B';
    if (p >= 65) return 'B-';
    if (p >= 60) return 'C+';
    if (p >= 55) return 'C';
    if (p >= 50) return 'D';
    return 'F';
  }

  Color get _scoreColor {
    if (_pct >= 80) return AppColors.success;
    if (_pct >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String get _motivationalMessage {
    if (_pct >= 90) return 'Outstanding! 🏆 Perfect performance!';
    if (_pct >= 80) return 'Excellent work! 🎉 Keep it up!';
    if (_pct >= 70) return 'Good job! 👍 Almost there!';
    if (_pct >= 60) return 'Decent effort. 📚 Review the topics again.';
    if (_pct >= 50) return 'Keep studying! 💪 You can do better.';
    return 'Don\'t give up! 📖 Revise the material and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final quiz = MockQuizzesData.getById(widget.quizId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
          onPressed: () => context.go(RoutePaths.quizzesList),
        ),
        title: Text('Quiz Result',
            style: AppTypography.titleMedium
                .copyWith(color: AppColors.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // ── Animated score circle ──────────────────────────────────
            ScaleTransition(
              scale: _scaleAnim,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: _scoreColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Mid ring
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: _scoreColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Inner circle
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: _scoreColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _scoreColor.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_pct.round()}%',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _grade,
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Motivational message ───────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Text(
                    quiz?.title ?? 'Quiz',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _motivationalMessage,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Score breakdown ────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.roundedXl,
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text('Score Breakdown',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        _BreakdownCell(
                          value: '${widget.score}',
                          label: 'Correct',
                          color: AppColors.success,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        _BreakdownCell(
                          value: '${widget.total - widget.score}',
                          label: 'Wrong',
                          color: AppColors.error,
                          icon: Icons.cancel_outlined,
                        ),
                        _BreakdownCell(
                          value: '${widget.total}',
                          label: 'Total',
                          color: AppColors.secondary,
                          icon: Icons.help_outline_rounded,
                        ),
                        _BreakdownCell(
                          value: quiz != null
                              ? '${quiz.durationMinutes}m'
                              : '--',
                          label: 'Duration',
                          color: const Color(0xFFAB47BC),
                          icon: Icons.timer_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Progress bar
                    ClipRRect(
                      borderRadius: AppRadius.roundedFull,
                      child: LinearProgressIndicator(
                        value: widget.total == 0
                            ? 0
                            : widget.score / widget.total,
                        backgroundColor:
                            _scoreColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _scoreColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${widget.score} out of ${widget.total} questions correct',
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Performance level bar ──────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: _PerformanceLevelCard(percentage: _pct),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Action buttons ─────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.push(
                        RoutePaths.quizDetailPath(widget.quizId),
                      ),
                      icon: const Icon(Icons.reviews_outlined, size: 18),
                      label: Text('Review Answers',
                          style: AppTypography.labelLarge
                              .copyWith(color: AppColors.onPrimary)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedLg),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.quizzesList),
                      icon: const Icon(Icons.list_alt_rounded, size: 18),
                      label: Text('Back to Quizzes',
                          style: AppTypography.labelLarge
                              .copyWith(color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.outline),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedLg),
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

// ── Score breakdown cell ──────────────────────────────────────────────────────

class _BreakdownCell extends StatelessWidget {
  const _BreakdownCell({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            )),
        Text(label,
            style: AppTypography.labelSmall
                .copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

// ── Performance level card ────────────────────────────────────────────────────

class _PerformanceLevelCard extends StatelessWidget {
  const _PerformanceLevelCard({required this.percentage});
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final levels = [
      _Level('Fail', 0, 50, AppColors.error),
      _Level('Pass', 50, 60, AppColors.warning),
      _Level('Good', 60, 75, AppColors.warning),
      _Level('Very Good', 75, 90, AppColors.success),
      _Level('Excellent', 90, 101, AppColors.success),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Level',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: AppSpacing.md),
          ...levels.map((l) {
            final isActive =
                percentage >= l.min && percentage < l.max;
            return Container(
              margin:
                  const EdgeInsets.only(bottom: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isActive
                    ? l.color.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(
                  color: isActive
                      ? l.color.withValues(alpha: 0.40)
                      : Colors.transparent,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? l.color
                          : AppColors.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${l.min}% – ${l.max == 101 ? '100%' : '${l.max}%'}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isActive
                          ? l.color
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l.label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isActive
                          ? l.color
                          : AppColors.onSurfaceVariant,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.arrow_back_rounded,
                        color: l.color, size: 14),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Level {
  const _Level(this.label, this.min, this.max, this.color);
  final String label;
  final double min;
  final double max;
  final Color color;
}
