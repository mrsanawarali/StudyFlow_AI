import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';
import 'package:untitled/features/timetable/data/mock_timetable_data.dart';

/// Phase 2I — Premium Timetable Tab.
class TimetableTab extends StatefulWidget {
  const TimetableTab({super.key});

  @override
  State<TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab>
    with SingleTickerProviderStateMixin {
  int _selectedDay = DateTime.now().weekday; // 1=Mon…7=Sun

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classes = MockTimetableData.forDay(_selectedDay);
    final nextClass = MockTimetableData.nextClass;
    final currentClass = MockTimetableData.currentClass;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroGreeting(),
                  const SizedBox(height: AppSpacing.lg),
                  _StatsRow(),
                  const SizedBox(height: AppSpacing.xl),
                  if (nextClass != null || currentClass != null) ...[
                    SectionHeader(title: currentClass != null
                        ? 'Now in Class' : 'Next Class'),
                    const SizedBox(height: AppSpacing.md),
                    _NextClassCard(
                      cls: currentClass ?? nextClass!,
                      isCurrent: currentClass != null,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  SectionHeader(title: 'Weekly Schedule'),
                  const SizedBox(height: AppSpacing.md),
                  _WeekStrip(
                    selected: _selectedDay,
                    onSelect: (d) => setState(() => _selectedDay = d),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DayTimeline(classes: classes),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: 'Attendance'),
                  const SizedBox(height: AppSpacing.md),
                  _AttendanceSection(),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: 'Weekly Study Hours'),
                  const SizedBox(height: AppSpacing.md),
                  _StudyHoursChart(),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                      title: 'Upcoming Deadlines', onSeeAll: () {}),
                  const SizedBox(height: AppSpacing.sm),
                  _DeadlinesSection(),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: AppSpacing.md),
                  _QuickActions(),
                  const SizedBox(height: AppSpacing.xl),
                  _FreeTimeSuggestion(),
                  const SizedBox(height: AppSpacing.md),
                  _AIInsightCard(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: AppSpacing.lg,
      title: Text('Timetable',
          style: AppTypography.titleLarge
              .copyWith(color: AppColors.onSurface)),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded, color: AppColors.secondary),
          onPressed: () {},
          tooltip: 'Add class',
        ),
      ],
    );
  }
}

// ── Hero Greeting ─────────────────────────────────────────────────────────────
class _HeroGreeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todayCount = MockTimetableData.todayClasses.length;
    final now = DateTime.now();
    final dayName = ['Monday','Tuesday','Wednesday',
        'Thursday','Friday','Saturday','Sunday'][now.weekday - 1];

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
                  Text(dayName,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.75))),
                  const SizedBox(height: AppSpacing.xs),
                  Text(todayCount == 0
                      ? 'No classes today 🎉'
                      : '$todayCount classes today',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${MockTimetableData.pendingAssignments} pending assignments',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.70))),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.15),
                borderRadius: AppRadius.roundedXl,
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: AppColors.onPrimary, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.class_outlined,
            value: '${MockTimetableData.totalClassesThisWeek}',
            label: 'Classes',
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          _StatChip(
            icon: Icons.how_to_reg_outlined,
            value: '${MockTimetableData.overallAttendance.round()}%',
            label: 'Attend.',
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.xs),
          _StatChip(
            icon: Icons.schedule_outlined,
            value: '${MockTimetableData.totalStudyHoursThisWeek.round()}h',
            label: 'Study',
            color: const Color(0xFFFFA726),
          ),
          const SizedBox(width: AppSpacing.xs),
          _StatChip(
            icon: Icons.assignment_outlined,
            value: '${MockTimetableData.pendingAssignments}',
            label: 'Tasks',
            color: const Color(0xFFAB47BC),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(value,
                style: AppTypography.titleSmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            Text(label,
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ── Next / Current Class Card ─────────────────────────────────────────────────
class _NextClassCard extends StatelessWidget {
  const _NextClassCard({required this.cls, required this.isCurrent});
  final MockClass cls;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    final minsLeft = isCurrent
        ? cls.endMinutes - nowMins
        : cls.startMinutes - nowMins;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: cls.color.withValues(alpha: 0.08),
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: cls.color.withValues(alpha: 0.35), width: 1.5),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cls.color.withValues(alpha: 0.15),
                borderRadius: AppRadius.roundedLg,
              ),
              child: Icon(
                isCurrent ? Icons.play_circle_outline_rounded
                    : Icons.access_time_rounded,
                color: cls.color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cls.subject,
                      style: AppTypography.titleSmall.copyWith(
                          color: AppColors.onSurface),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${cls.startTime} – ${cls.endTime}  ·  ${cls.room}',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(isCurrent ? 'Ends in' : 'Starts in',
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant)),
                Text('${minsLeft}m',
                    style: AppTypography.titleMedium.copyWith(
                        color: cls.color, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Week Strip ────────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (ctx, i) {
          final day = i + 1;
          final isSelected = selected == day;
          final isToday = today == day;
          final hasClasses = MockTimetableData.forDay(day).isNotEmpty;

          return GestureDetector(
            onTap: () => onSelect(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(
                  color: isSelected ? AppColors.primary
                      : isToday ? AppColors.secondary
                      : AppColors.outlineVariant,
                  width: isToday && !isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_days[i],
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? AppColors.onPrimary
                            : AppColors.onSurfaceVariant,
                      )),
                  const SizedBox(height: 2),
                  Text('${i + 1}',
                      style: AppTypography.titleSmall.copyWith(
                        color: isSelected ? AppColors.onPrimary
                            : AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 3),
                  Container(
                    width: 5, height: 5,
                    decoration: BoxDecoration(
                      color: hasClasses
                          ? (isSelected ? AppColors.onPrimary.withValues(alpha: 0.70)
                              : AppColors.secondary)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Day Timeline ──────────────────────────────────────────────────────────────
class _DayTimeline extends StatelessWidget {
  const _DayTimeline({required this.classes});
  final List<MockClass> classes;

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.roundedXl,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Icon(Icons.free_breakfast_outlined,
                  color: AppColors.success, size: 36),
              const SizedBox(height: AppSpacing.sm),
              Text('Free day! 🎉',
                  style: AppTypography.titleSmall.copyWith(
                      color: AppColors.onSurface)),
              Text('No classes scheduled.',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    final nowMins = DateTime.now().hour * 60 + DateTime.now().minute;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: List.generate(classes.length, (i) {
          final cls = classes[i];
          final isActive = cls.startMinutes <= nowMins &&
              cls.endMinutes > nowMins;
          final isPast = cls.endMinutes <= nowMins;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time column
                SizedBox(
                  width: 50,
                  child: Column(
                    children: [
                      Text(cls.startTime,
                          style: AppTypography.labelSmall.copyWith(
                            color: isActive
                                ? cls.color
                                : AppColors.onSurfaceVariant,
                            fontWeight: isActive
                                ? FontWeight.w700 : FontWeight.w400,
                          )),
                      Container(
                        width: 2,
                        height: 52,
                        color: isActive
                            ? cls.color.withValues(alpha: 0.40)
                            : AppColors.outlineVariant,
                        margin: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 24),
                      ),
                      Text(cls.endTime,
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 9)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Class card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? cls.color.withValues(alpha: 0.10)
                          : isPast
                              ? AppColors.surfaceVariant
                              : AppColors.surface,
                      borderRadius: AppRadius.roundedXl,
                      border: Border.all(
                        color: isActive
                            ? cls.color.withValues(alpha: 0.40)
                            : AppColors.outlineVariant,
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isPast
                                ? AppColors.outline
                                : cls.color,
                            borderRadius: AppRadius.roundedFull,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(cls.subject,
                                        style: AppTypography.titleSmall
                                            .copyWith(
                                          color: isPast
                                              ? AppColors.onSurfaceVariant
                                              : AppColors.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cls.color,
                                        borderRadius: AppRadius.roundedFull,
                                      ),
                                      child: Text('Now',
                                          style: AppTypography.labelSmall
                                              .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 9,
                                          )),
                                    ),
                                ],
                              ),
                              Text(
                                '${cls.room}  ·  ${cls.professor}',
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Attendance Section ────────────────────────────────────────────────────────
class _AttendanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: MockTimetableData.attendance.map((rec) {
            final pct = rec.percentage;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                              color: rec.color, shape: BoxShape.circle)),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(rec.subject,
                            style: AppTypography.labelMedium.copyWith(
                                color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('${rec.attended}/${rec.totalClasses}',
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onSurfaceVariant)),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: rec.isSafe
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: AppRadius.roundedFull,
                        ),
                        child: Text('${pct.round()}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: rec.isSafe
                                  ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: AppRadius.roundedFull,
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: rec.color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          rec.isSafe ? rec.color : AppColors.error),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Study Hours Bar Chart ─────────────────────────────────────────────────────
class _StudyHoursChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hours = MockTimetableData.weeklyStudyHours;
    final labels = MockTimetableData.weekDayLabels;
    final maxH = hours.reduce((a, b) => a > b ? a : b);
    final todayIdx = DateTime.now().weekday - 1;
    final total = hours.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${total.toStringAsFixed(1)}h this week',
                    style: AppTypography.labelMedium.copyWith(
                        color: AppColors.onSurfaceVariant)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.10),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text('This week',
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondary)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final frac = maxH > 0 ? hours[i] / maxH : 0.0;
                  final isToday = i == todayIdx;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isToday)
                        Text('${hours[i].toStringAsFixed(0)}h',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            )),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        width: 26,
                        height: frac * 68 + 4,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.secondary
                              : AppColors.secondary.withValues(alpha: 0.25),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(5)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(labels[i],
                          style: AppTypography.labelSmall.copyWith(
                            color: isToday
                                ? AppColors.secondary
                                : AppColors.onSurfaceVariant,
                            fontWeight: isToday
                                ? FontWeight.w700 : FontWeight.w400,
                            fontSize: 9,
                          )),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upcoming Deadlines ────────────────────────────────────────────────────────
class _DeadlinesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: MockTimetableData.upcomingDeadlines.map((d) {
        final daysLeft = d.dueDate.difference(DateTime.now()).inDays;
        final dueText = daysLeft == 0 ? 'Today'
            : daysLeft == 1 ? 'Tomorrow'
            : 'In ${daysLeft}d';
        final typeIcon = d.type == 'quiz'
            ? Icons.quiz_outlined : Icons.assignment_outlined;
        final dueColor = daysLeft <= 1
            ? AppColors.error
            : daysLeft <= 3
                ? AppColors.warning
                : AppColors.onSurfaceVariant;

        return Container(
          margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.roundedXl,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            leading: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: d.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.roundedMd,
              ),
              child: Icon(typeIcon, color: d.color, size: 18),
            ),
            title: Text(d.title,
                style: AppTypography.titleSmall.copyWith(
                    color: AppColors.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(d.subject,
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant)),
            trailing: Text(dueText,
                style: AppTypography.labelMedium.copyWith(
                    color: dueColor, fontWeight: FontWeight.w700)),
          ),
        );
      }).toList(),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  static const _actions = [
    _QA(Icons.add_circle_outline_rounded, 'Add Class',
        Color(0xFF4A90E2)),
    _QA(Icons.notifications_outlined, 'Reminder',
        Color(0xFFFFA726)),
    _QA(Icons.self_improvement_outlined, 'Study Session',
        Color(0xFF50E3C2)),
    _QA(Icons.auto_awesome_outlined, 'AI Planner',
        Color(0xFFAB47BC)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: _actions.map((a) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: GestureDetector(
              onTap: () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.12),
                      borderRadius: AppRadius.roundedXl,
                      border: Border.all(
                          color: a.color.withValues(alpha: 0.25)),
                    ),
                    child: Icon(a.icon, color: a.color, size: 22),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(a.label,
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurface, fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class _QA {
  const _QA(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}

// ── Free Time Suggestion ──────────────────────────────────────────────────────
class _FreeTimeSuggestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.06),
          borderRadius: AppRadius.roundedXl,
          border: Border.all(
              color: AppColors.success.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: AppRadius.roundedLg,
              ),
              child: const Icon(Icons.free_breakfast_outlined,
                  color: AppColors.success, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Free Time: 11:30 – 13:00',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      )),
                  Text('1.5 hours — perfect for Data Structures revision',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: AppRadius.roundedLg,
                ),
                child: Text('Plan',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI Study Insight Card ─────────────────────────────────────────────────────
class _AIInsightCard extends StatelessWidget {
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
                  child: Text('AI Study Insight',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.20),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text('Beta',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '📊 Your attendance in Software Engineering is at 75% — '
              'exactly the minimum. Attend the next 2 classes to build a safety buffer.\n\n'
              '⏰ You study best between 14:00–17:00 based on your history. '
              'Schedule your Data Structures revision during that window today.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _AIBtn('Generate Plan', Icons.calendar_today_outlined),
                const SizedBox(width: AppSpacing.sm),
                _AIBtn('More Insights', Icons.insights_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AIBtn extends StatelessWidget {
  const _AIBtn(this.label, this.icon);
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.onPrimary.withValues(alpha: 0.12),
            borderRadius: AppRadius.roundedLg,
            border: Border.all(
                color: AppColors.onPrimary.withValues(alpha: 0.20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                  size: 14),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(label,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
