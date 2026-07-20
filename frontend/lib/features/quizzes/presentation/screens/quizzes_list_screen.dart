import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/quizzes/data/mock_quizzes_data.dart';

/// Phase 2H — Global Quizzes List Screen.
///
/// Two tabs: Upcoming · Completed. Groups by subject.
class QuizzesListScreen extends StatefulWidget {
  const QuizzesListScreen({super.key});

  @override
  State<QuizzesListScreen> createState() => _QuizzesListScreenState();
}

class _QuizzesListScreenState extends State<QuizzesListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<MockQuiz> _data(int idx) => switch (idx) {
        1 => MockQuizzesData.upcoming,
        2 => MockQuizzesData.completed,
        _ => MockQuizzesData.all,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
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
            title: Text('Quizzes',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.onSurface)),
            bottom: TabBar(
              controller: _tab,
              onTap: (_) => setState(() {}),
              labelStyle: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: AppTypography.labelMedium,
              labelColor: const Color(0xFFAB47BC),
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: const Color(0xFFAB47BC),
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ],
        body: AnimatedBuilder(
          animation: _tab,
          builder: (ctx, _) {
            final items = _data(_tab.index);
            return _QuizListBody(
              quizzes: items,
              onTap: (q) =>
                  context.push(RoutePaths.quizDetailPath(q.id)),
            );
          },
        ),
      ),
    );
  }
}

// ── List body ─────────────────────────────────────────────────────────────────

class _QuizListBody extends StatelessWidget {
  const _QuizListBody(
      {required this.quizzes, required this.onTap});
  final List<MockQuiz> quizzes;
  final ValueChanged<MockQuiz> onTap;

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFAB47BC).withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedXl,
                ),
                child: const Icon(Icons.quiz_outlined,
                    color: Color(0xFFAB47BC), size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('No quizzes here',
                  style: AppTypography.titleSmall
                      .copyWith(color: AppColors.onSurface)),
              const SizedBox(height: AppSpacing.xs),
              Text('Quizzes will appear here when added.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    // Group by subject
    final Map<String, List<MockQuiz>> grouped = {};
    for (final q in quizzes) {
      grouped.putIfAbsent(q.subject, () => []).add(q);
    }

    final completed = quizzes
        .where((q) => q.status == QuizStatus.completed)
        .length;
    final avgPct = completed == 0
        ? 0.0
        : quizzes
                .where((q) => q.status == QuizStatus.completed)
                .fold(0.0, (s, q) => s + q.percentage) /
            completed;

    return ListView(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.lg),
      children: [
        // Summary banner
        _SummaryBanner(
          total: quizzes.length,
          upcoming: quizzes
              .where((q) => q.status == QuizStatus.upcoming)
              .length,
          completed: completed,
          avgScore: avgPct,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Grouped cards
        for (final entry in grouped.entries) ...[
          _GroupHeader(
              subject: entry.key, color: entry.value.first.subjectColor),
          const SizedBox(height: AppSpacing.xs),
          ...entry.value.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: QuizTile(
                    quiz: q, onTap: () => onTap(q)),
              )),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

// ── Summary banner ────────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.total,
    required this.upcoming,
    required this.completed,
    required this.avgScore,
  });
  final int total;
  final int upcoming;
  final int completed;
  final double avgScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
        ),
        borderRadius: AppRadius.roundedXl,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFAB47BC).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BCell(value: '$total', label: 'Total'),
          _BDiv(),
          _BCell(value: '$upcoming', label: 'Upcoming'),
          _BDiv(),
          _BCell(value: '$completed', label: 'Done'),
          _BDiv(),
          _BCell(
              value: '${avgScore.round()}%', label: 'Avg Score'),
        ],
      ),
    );
  }
}

class _BCell extends StatelessWidget {
  const _BCell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: AppTypography.titleMedium.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700)),
        Text(label,
            style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.70))),
      ],
    );
  }
}

class _BDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 32,
        color: Colors.white.withValues(alpha: 0.25),
      );
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.subject, required this.color});
  final String subject;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.sm),
        Text(subject,
            style: AppTypography.labelMedium.copyWith(
                color: AppColors.onSurface, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── Reusable quiz tile ────────────────────────────────────────────────────────

class QuizTile extends StatelessWidget {
  const QuizTile({super.key, required this.quiz, required this.onTap});
  final MockQuiz quiz;
  final VoidCallback onTap;

  String _fmtDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final isCompleted = quiz.status == QuizStatus.completed;
    final isUpcoming = quiz.status == QuizStatus.upcoming;

    final scoreColor = !isCompleted
        ? AppColors.onSurfaceVariant
        : quiz.percentage >= 80
            ? AppColors.success
            : quiz.percentage >= 60
                ? AppColors.warning
                : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(
            color: isUpcoming
                ? quiz.subjectColor.withValues(alpha: 0.30)
                : AppColors.outlineVariant,
            width: isUpcoming ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: quiz.subjectColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.roundedLg,
            ),
            child: Icon(Icons.quiz_outlined,
                color: quiz.subjectColor, size: 22),
          ),
          title: Text(
            quiz.title,
            style: AppTypography.titleSmall
                .copyWith(color: AppColors.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${_fmtDate(quiz.scheduledDate)}  ·  ${quiz.durationMinutes} min  ·  ${quiz.totalMarks} marks',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          trailing: isCompleted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.12),
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(
                        '${quiz.obtainedMarks}/${quiz.totalMarks}',
                        style: AppTypography.labelMedium.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(quiz.grade,
                        style: AppTypography.labelSmall.copyWith(
                            color: scoreColor,
                            fontWeight: FontWeight.w700)),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: quiz.subjectColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text('Upcoming',
                      style: AppTypography.labelSmall.copyWith(
                          color: quiz.subjectColor,
                          fontWeight: FontWeight.w600)),
                ),
        ),
      ),
    );
  }
}
