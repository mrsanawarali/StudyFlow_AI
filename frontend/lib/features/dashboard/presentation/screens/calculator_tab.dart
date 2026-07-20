import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';
import 'package:untitled/features/grades/data/mock_grades_data.dart';

/// Phase 2J — Premium Grade Calculator Tab.
class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});

  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab>
    with TickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();

  @override
  void dispose() {
    _tab.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 1,
              titleSpacing: AppSpacing.lg,
              title: Text('Grade Calculator',
                  style: AppTypography.titleLarge
                      .copyWith(color: AppColors.onSurface)),
              bottom: TabBar(
                controller: _tab,
                labelStyle: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w700),
                unselectedLabelStyle: AppTypography.labelMedium,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                tabs: const [
                  Tab(text: 'Semester'),
                  Tab(text: 'CGPA'),
                  Tab(text: 'Predictor'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tab,
            children: const [
              _SemesterTab(),
              _CGPATab(),
              _PredictorTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Semester GPA Tab ──────────────────────────────────────────────────────────
class _SemesterTab extends StatelessWidget {
  const _SemesterTab();

  double _projectedGPA() {
    double weighted = 0;
    int credits = 0;
    for (final s in MockGradesData.currentSubjects) {
      final gp = MockGradesData.gradePointsFrom(s.currentPercentage);
      weighted += gp * s.creditHours;
      credits += s.creditHours;
    }
    return credits == 0 ? 0 : weighted / credits;
  }

  @override
  Widget build(BuildContext context) {
    final gpa = _projectedGPA();
    final subjects = MockGradesData.currentSubjects;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // GPA hero card
        _GPAHeroCard(gpa: gpa, label: 'Projected Semester GPA',
            color: AppColors.secondary),
        const SizedBox(height: AppSpacing.xl),

        // Subject grade list
        SectionHeader(title: 'Subject Grades'),
        const SizedBox(height: AppSpacing.md),
        ...subjects.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _SubjectGradeCard(subject: s),
        )),
        const SizedBox(height: AppSpacing.xl),

        // Grade distribution chart
        SectionHeader(title: 'Grade Distribution'),
        const SizedBox(height: AppSpacing.md),
        _GradeDistributionChart(subjects: subjects),
        const SizedBox(height: AppSpacing.xl),

        // Academic insights
        _AcademicInsightsCard(gpa: gpa),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ── CGPA Tab ──────────────────────────────────────────────────────────────────
class _CGPATab extends StatelessWidget {
  const _CGPATab();

  @override
  Widget build(BuildContext context) {
    final cgpa = MockGradesData.cgpa;
    final records = MockGradesData.semesterRecords;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _GPAHeroCard(gpa: cgpa, label: 'Cumulative GPA',
            color: AppColors.primary),
        const SizedBox(height: AppSpacing.md),
        // Credit hours
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Total Credits',
                value: '${MockGradesData.totalCreditHours}',
                icon: Icons.school_outlined,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                label: 'Semesters',
                value: '${records.length}',
                icon: Icons.calendar_today_outlined,
                color: const Color(0xFFFFA726),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        SectionHeader(title: 'Semester Records'),
        const SizedBox(height: AppSpacing.md),
        ...records.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _SemesterRecordRow(record: r),
        )),
        const SizedBox(height: AppSpacing.xl),

        SectionHeader(title: 'GPA Trend'),
        const SizedBox(height: AppSpacing.md),
        _GPATrendChart(records: records),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ── Required Marks Predictor Tab ─────────────────────────────────────────────
class _PredictorTab extends StatefulWidget {
  const _PredictorTab();

  @override
  State<_PredictorTab> createState() => _PredictorTabState();
}

class _PredictorTabState extends State<_PredictorTab> {
  String _selectedSubjectId = MockGradesData.currentSubjects.first.id;
  double _targetGrade = 80; // target percentage

  MockSubjectGrade get _subject =>
      MockGradesData.currentSubjects.firstWhere(
          (s) => s.id == _selectedSubjectId);

  double get _requiredFinal {
    final s = _subject;
    final earned = s.midMarks + s.assignmentMarks + s.quizMarks;
    final possible = s.midTotal + s.assignmentTotal + s.quizTotal + s.finalTotal;
    final target = (_targetGrade / 100) * possible;
    final required = target - earned;
    return required.clamp(0, s.finalTotal);
  }

  @override
  Widget build(BuildContext context) {
    final subject = _subject;
    final required = _requiredFinal;
    final isPossible = required <= subject.finalTotal;
    final requiredPct = (required / subject.finalTotal * 100).clamp(0, 100);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Info banner
        Container(
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: AppRadius.roundedXl,
            border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.info, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Select a subject and target grade to see the minimum final exam marks required.',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurface, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Subject picker
        Text('Select Subject',
            style: AppTypography.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        ...MockGradesData.currentSubjects.map((s) {
          final isSelected = s.id == _selectedSubjectId;
          return GestureDetector(
            onTap: () => setState(() => _selectedSubjectId = s.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? s.color.withValues(alpha: 0.12)
                    : AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(
                  color: isSelected ? s.color : AppColors.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                          color: s.color, shape: BoxShape.circle)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                      child: Text(s.name,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.onSurface,
                          ))),
                  Text(s.code,
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xl),

        // Target slider
        Text('Target Grade: ${_targetGrade.round()}%',
            style: AppTypography.titleSmall.copyWith(
                color: AppColors.onSurface, fontWeight: FontWeight.w700)),
        Slider(
          value: _targetGrade,
          min: 50, max: 100, divisions: 50,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.primary.withValues(alpha: 0.15),
          onChanged: (v) => setState(() => _targetGrade = v),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Result card
        Container(
          decoration: BoxDecoration(
            color: isPossible
                ? AppColors.success.withValues(alpha: 0.06)
                : AppColors.error.withValues(alpha: 0.06),
            borderRadius: AppRadius.roundedXl,
            border: Border.all(
              color: isPossible
                  ? AppColors.success.withValues(alpha: 0.30)
                  : AppColors.error.withValues(alpha: 0.30),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                isPossible
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                color: isPossible ? AppColors.success : AppColors.error,
                size: 36,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                isPossible ? 'Achievable! 🎯' : 'Not Achievable ❌',
                style: AppTypography.titleMedium.copyWith(
                  color: isPossible ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isPossible
                    ? 'You need ${required.toStringAsFixed(1)} / ${subject.finalTotal.toStringAsFixed(0)} (${requiredPct.toStringAsFixed(0)}%) in the final exam'
                    : 'You cannot achieve ${_targetGrade.round()}% — maximum possible is below target',
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurface, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: AppRadius.roundedFull,
                child: LinearProgressIndicator(
                  value: requiredPct / 100,
                  backgroundColor: (isPossible
                      ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isPossible ? AppColors.success : AppColors.error),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Current marks breakdown
        _MarksBreakdown(subject: subject),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ── GPA Hero Card ─────────────────────────────────────────────────────────────
class _GPAHeroCard extends StatelessWidget {
  const _GPAHeroCard({
    required this.gpa,
    required this.label,
    required this.color,
  });
  final double gpa;
  final String label;
  final Color color;

  String get _letter => MockGradesData.letterGradeFrom(gpa / 4.0 * 100);

  String get _message {
    if (gpa >= 3.7) return 'Dean\'s List territory! 🏆';
    if (gpa >= 3.3) return 'Great academic standing 🎉';
    if (gpa >= 3.0) return 'Good standing — keep pushing! 👍';
    if (gpa >= 2.5) return 'Satisfactory — room to improve 📚';
    return 'Needs improvement — seek support 💪';
  }

  Color get _gpaColor {
    if (gpa >= 3.7) return AppColors.success;
    if (gpa >= 3.0) return AppColors.secondary;
    if (gpa >= 2.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.70)],
        ),
        borderRadius: AppRadius.roundedXl,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.80))),
                const SizedBox(height: AppSpacing.xs),
                Text(gpa.toStringAsFixed(2),
                    style: AppTypography.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: AppSpacing.xs),
                Text(_message,
                    style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.80))),
              ],
            ),
          ),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(_letter,
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subject Grade Card ────────────────────────────────────────────────────────
class _SubjectGradeCard extends StatelessWidget {
  const _SubjectGradeCard({required this.subject});
  final MockSubjectGrade subject;

  @override
  Widget build(BuildContext context) {
    final pct = subject.currentPercentage;
    final letter = MockGradesData.letterGradeFrom(pct);
    final gp = MockGradesData.gradePointsFrom(pct);
    final Color gradeColor = pct >= 85
        ? AppColors.success
        : pct >= 70
            ? AppColors.secondary
            : pct >= 55
                ? AppColors.warning
                : AppColors.error;

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
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: subject.color, shape: BoxShape.circle)),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(subject.name,
                    style: AppTypography.titleSmall.copyWith(
                        color: AppColors.onSurface),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text('$letter  ${gp.toStringAsFixed(2)}',
                    style: AppTypography.labelSmall.copyWith(
                      color: gradeColor,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _MarkCell('Mid',
                  '${subject.midMarks.toStringAsFixed(0)}/${subject.midTotal.toStringAsFixed(0)}',
                  AppColors.secondary),
              _MarkCell('Assign',
                  '${subject.assignmentMarks.toStringAsFixed(0)}/${subject.assignmentTotal.toStringAsFixed(0)}',
                  AppColors.warning),
              _MarkCell('Quiz',
                  '${subject.quizMarks.toStringAsFixed(0)}/${subject.quizTotal.toStringAsFixed(0)}',
                  const Color(0xFFAB47BC)),
              _MarkCell('Final',
                  subject.finalMarks != null
                      ? '${subject.finalMarks!.toStringAsFixed(0)}/${subject.finalTotal.toStringAsFixed(0)}'
                      : '—/${subject.finalTotal.toStringAsFixed(0)}',
                  AppColors.error),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.roundedFull,
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: subject.color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(subject.color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 3),
          Text('${pct.toStringAsFixed(1)}% current score',
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _MarkCell extends StatelessWidget {
  const _MarkCell(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant, fontSize: 9)),
          Text(value,
              style: AppTypography.labelMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Grade Distribution Chart (Canvas) ────────────────────────────────────────
class _GradeDistributionChart extends StatelessWidget {
  const _GradeDistributionChart({required this.subjects});
  final List<MockSubjectGrade> subjects;

  @override
  Widget build(BuildContext context) {
    final Map<String, int> dist = {};
    for (final s in subjects) {
      final l = MockGradesData.letterGradeFrom(s.currentPercentage);
      dist[l] = (dist[l] ?? 0) + 1;
    }

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
          Text('Grade Distribution',
              style: AppTypography.titleSmall.copyWith(
                  color: AppColors.onSurface, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MockGradesData.gradeScale
                .where((g) => dist.containsKey(g.letter))
                .map((g) {
              final count = dist[g.letter] ?? 0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('$count',
                      style: AppTypography.labelSmall.copyWith(
                          color: g.color, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    width: 36,
                    height: count * 40.0,
                    decoration: BoxDecoration(
                      color: g.color.withValues(alpha: 0.80),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(g.letter,
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Semester Record Row ───────────────────────────────────────────────────────
class _SemesterRecordRow extends StatelessWidget {
  const _SemesterRecordRow({required this.record});
  final MockSemesterRecord record;

  @override
  Widget build(BuildContext context) {
    final Color gpaColor = record.gpa >= 3.7
        ? AppColors.success
        : record.gpa >= 3.0
            ? AppColors.secondary
            : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: record.color.withValues(alpha: 0.12),
            borderRadius: AppRadius.roundedMd,
          ),
          child: Center(
            child: Text(record.id.split('-').last,
                style: AppTypography.labelMedium.copyWith(
                    color: record.color, fontWeight: FontWeight.w700)),
          ),
        ),
        title: Text(record.name,
            style: AppTypography.titleSmall.copyWith(
                color: AppColors.onSurface)),
        subtitle: Text(
            '${record.academicYear}  ·  ${record.creditHours} credits',
            style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: gpaColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.roundedFull,
          ),
          child: Text(record.gpa.toStringAsFixed(2),
              style: AppTypography.titleSmall.copyWith(
                  color: gpaColor, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// ── GPA Trend Chart ───────────────────────────────────────────────────────────
class _GPATrendChart extends StatelessWidget {
  const _GPATrendChart({required this.records});
  final List<MockSemesterRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const SizedBox.shrink();
    final maxGPA = 4.0;
    final width = MediaQuery.of(context).size.width - AppSpacing.lg * 2 -
        AppSpacing.md * 2;
    final stepX = width / (records.length - 1).clamp(1, 99);

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
          Text('GPA Trend',
              style: AppTypography.titleSmall.copyWith(
                  color: AppColors.onSurface, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            child: CustomPaint(
              size: Size(width, 140),
              painter: _TrendPainter(records: records, maxGPA: maxGPA),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: records.map((r) => Text(
              r.id.split('-').last,
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant, fontSize: 9),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.records, required this.maxGPA});
  final List<MockSemesterRecord> records;
  final double maxGPA;

  @override
  void paint(Canvas canvas, Size size) {
    if (records.length < 2) return;
    final stepX = size.width / (records.length - 1);
    final points = List.generate(records.length, (i) {
      final x = i * stepX;
      final y = size.height - (records[i].gpa / maxGPA) * size.height * 0.85 - 10;
      return Offset(x, y);
    });

    // Area fill
    final areaPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(points.last.dx, size.height);
    areaPath.close();
    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [
            AppColors.secondary.withValues(alpha: 0.25),
            AppColors.secondary.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots + labels
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, Paint()..color = AppColors.secondary);
      canvas.drawCircle(
          points[i], 3, Paint()..color = AppColors.surface);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) => false;
}

// ── Mini Stat Card ────────────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.roundedMd,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTypography.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700)),
              Text(label,
                  style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Marks Breakdown ───────────────────────────────────────────────────────────
class _MarksBreakdown extends StatelessWidget {
  const _MarksBreakdown({required this.subject});
  final MockSubjectGrade subject;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Midterm', subject.midMarks, subject.midTotal, AppColors.secondary),
      ('Assignments', subject.assignmentMarks, subject.assignmentTotal,
          AppColors.warning),
      ('Quizzes', subject.quizMarks, subject.quizTotal,
          const Color(0xFFAB47BC)),
      ('Final Exam', subject.finalMarks ?? 0, subject.finalTotal,
          AppColors.error),
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
          Text('${subject.name} — Current Marks',
              style: AppTypography.titleSmall.copyWith(
                  color: AppColors.onSurface, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),
          ...items.map((item) {
            final pct = item.$3 == 0 ? 0.0 : item.$2 / item.$3;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.$1,
                          style: AppTypography.labelMedium.copyWith(
                              color: AppColors.onSurface)),
                      Text(
                        item.$1 == 'Final Exam' && subject.finalMarks == null
                            ? 'Pending'
                            : '${item.$2.toStringAsFixed(0)} / ${item.$3.toStringAsFixed(0)}',
                        style: AppTypography.labelMedium.copyWith(
                            color: item.$4, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: AppRadius.roundedFull,
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: item.$4.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(item.$4),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Academic Insights Card ────────────────────────────────────────────────────
class _AcademicInsightsCard extends StatelessWidget {
  const _AcademicInsightsCard({required this.gpa});
  final double gpa;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: AppRadius.roundedXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.20),
                  borderRadius: AppRadius.roundedLg,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: AppColors.tertiary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Academic Insights',
                    style: AppTypography.titleSmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.20),
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text('AI',
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.tertiary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '📈 Your projected GPA of ${gpa.toStringAsFixed(2)} is '
            '${gpa >= MockGradesData.cgpa ? "above" : "below"} your CGPA of '
            '${MockGradesData.cgpa.toStringAsFixed(2)}.\n\n'
            '⚠️  Software Engineering is your weakest subject at '
            '${MockGradesData.currentSubjects[3].currentPercentage.toStringAsFixed(0)}%. '
            'Focusing here could lift your GPA by up to +0.15 points.\n\n'
            '✅  Database Systems is performing excellently at '
            '${MockGradesData.currentSubjects[2].currentPercentage.toStringAsFixed(0)}% — keep it up!',
            style: AppTypography.bodySmall.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
                height: 1.6),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.12),
                borderRadius: AppRadius.roundedLg,
                border: Border.all(
                    color: AppColors.onPrimary.withValues(alpha: 0.20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insights_rounded,
                      color: AppColors.tertiary, size: 16),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Get Full AI Academic Report',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
