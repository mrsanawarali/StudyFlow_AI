// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';
import 'package:untitled/features/dashboard/presentation/widgets/activity_timeline.dart';
import 'package:untitled/features/dashboard/presentation/widgets/ai_assistant_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/continue_studying_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/deadline_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/quick_actions_grid.dart';
import 'package:untitled/features/dashboard/presentation/widgets/recent_note_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';
import 'package:untitled/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/timetable_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/weekly_progress_chart.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens — match the nav dock and Continue Studying card
// ─────────────────────────────────────────────────────────────────────────────
const Color _kSurface  = Color(0xFF131F3D);
const Color _kAccent   = Color(0xFF2563EB);
const Color _kBorder   = Color(0xFF1F2E50);
const Color _kMuted    = Color(0xFF6B7A9C);
const Color _kVerseGlass = Color(0x18FFFFFF);

/// Phase 2C — Premium Home Tab.
///
/// Header is a compact dark-navy panel (≤ 180 dp tall) that contains:
///   • Quranic verse banner
///   • Greeting + bell
///   • Today's progress bar
///   • Custom curved bottom edge
///
/// All data comes from [MockDashboardData]. No backend calls.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  // Entrance animation
  late final AnimationController _enterCtrl;
  late final Animation<double> _verseFade, _verseSlide;
  late final Animation<double> _greetFade, _greetSlide;
  late final Animation<double> _progressFade;
  late final Animation<double> _progressBar;   // 0 → target

  // Parallax: driven by scroll offset
  double _scrollOffset = 0;

  // Bell pulse
  late final AnimationController _bellCtrl;
  late final Animation<double> _bellScale;

  // Progress fill (mock: 72 %)
  static const double _kProgressTarget = 0.72;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));

    _verseFade  = _iv(0.00, 0.40);
    _verseSlide = Tween<double>(begin: -10.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.40, curve: Curves.easeOut)));

    _greetFade  = _iv(0.25, 0.60);
    _greetSlide = Tween<double>(begin: 10.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.25, 0.60, curve: Curves.easeOut)));

    _progressFade = _iv(0.50, 0.80);
    _progressBar  = Tween<double>(begin: 0.0, end: _kProgressTarget).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.55, 1.00, curve: Curves.easeOut)));

    // Bell pulse — slow breathe
    _bellCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _bellScale = Tween<double>(begin: 1.0, end: 1.12).animate(
        CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });
  }

  Animation<double> _iv(double s, double e) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  @override
  void dispose() {
    _enterCtrl.dispose();
    _bellCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user          = MockDashboardData.user;
    final activeSubject = MockDashboardData.subjects.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification) {
            setState(() {
              _scrollOffset = (n.metrics.pixels).clamp(0.0, 120.0);
            });
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            // ── Premium header ────────────────────────────────────────
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: Listenable.merge([_enterCtrl, _bellCtrl]),
                builder: (_, __) => _DashboardHeader(
                  user: user,
                  greeting: _greeting,
                  scrollOffset: _scrollOffset,
                  verseFade:    _verseFade.value,
                  verseSlide:   _verseSlide.value,
                  greetFade:    _greetFade.value,
                  greetSlide:   _greetSlide.value,
                  progressFade: _progressFade.value,
                  progressVal:  _progressBar.value,
                  bellScale:    _bellScale.value,
                ),
              ),
            ),

            // ── Rest of dashboard content (UNCHANGED) ─────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: AppColors.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: AppColors.onSurfaceVariant,
                                size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Search notes, subjects, assignments...',
                              style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Overview stats
                  SectionHeader(title: 'Overview', onSeeAll: () {}),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.25,
                      children: const [
                        StatCard(
                          label: 'Subjects',
                          value: '5',
                          icon: Icons.layers_outlined,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          label: 'Notes',
                          value: '63',
                          icon: Icons.description_outlined,
                          color: Color(0xFF50E3C2),
                        ),
                        StatCard(
                          label: 'Assignments',
                          value: '12',
                          icon: Icons.assignment_outlined,
                          color: Color(0xFFFFA726),
                        ),
                        StatCard(
                          label: 'Quizzes',
                          value: '8',
                          icon: Icons.quiz_outlined,
                          color: Color(0xFFAB47BC),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Continue studying
                  SectionHeader(
                      title: 'Continue Studying', onSeeAll: () {}),
                  const SizedBox(height: AppSpacing.md),
                  ContinueStudyingCard(subject: activeSubject),
                  const SizedBox(height: AppSpacing.xl),

                  // Quick actions
                  SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: AppSpacing.md),
                  const QuickActionsGrid(),
                  const SizedBox(height: AppSpacing.xl),

                  // Today's timetable
                  SectionHeader(
                      title: "Today's Timetable", onSeeAll: () {}),
                  const SizedBox(height: AppSpacing.md),
                  TimetableSection(
                      entries: MockDashboardData.todayTimetable),
                  const SizedBox(height: AppSpacing.xl),

                  // Upcoming deadlines
                  SectionHeader(
                      title: 'Upcoming Deadlines', onSeeAll: () {}),
                  const SizedBox(height: AppSpacing.sm),
                  ...MockDashboardData.upcomingAssignments
                      .take(3)
                      .map((a) => DeadlineCard(assignment: a)),
                  const SizedBox(height: AppSpacing.xl),

                  // Recent notes
                  SectionHeader(
                      title: 'Recent Notes', onSeeAll: () {}),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      itemCount:
                          MockDashboardData.recentNotes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (ctx, i) => RecentNoteCard(
                          note: MockDashboardData.recentNotes[i]),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // AI Assistant
                  SectionHeader(title: 'AI Study Assistant'),
                  const SizedBox(height: AppSpacing.md),
                  const AIAssistantCard(),
                  const SizedBox(height: AppSpacing.xl),

                  // Weekly progress
                  SectionHeader(title: 'Weekly Progress'),
                  const SizedBox(height: AppSpacing.md),
                  const WeeklyProgressChart(),
                  const SizedBox(height: AppSpacing.xl),

                  // Recent activity
                  SectionHeader(
                      title: 'Recent Activity', onSeeAll: () {}),
                  const SizedBox(height: AppSpacing.md),
                  ActivityTimeline(
                      entries: MockDashboardData.recentActivity),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium compact dashboard header
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.user,
    required this.greeting,
    required this.scrollOffset,
    required this.verseFade,
    required this.verseSlide,
    required this.greetFade,
    required this.greetSlide,
    required this.progressFade,
    required this.progressVal,
    required this.bellScale,
  });

  final MockUser user;
  final String   greeting;
  final double   scrollOffset;  // 0–120, drives parallax
  final double   verseFade, verseSlide;
  final double   greetFade, greetSlide;
  final double   progressFade, progressVal;
  final double   bellScale;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    // Parallax: wave + content shift slightly with scroll
    final parallax = scrollOffset * 0.18;

    return ClipPath(
      clipper: _WaveClipper(scrollOffset: scrollOffset),
      child: Container(
        color: _kSurface,
        child: Stack(
          children: [
            // ── Ambient glows (non-interactive) ───────────────────
            Positioned(
              top: -30 + parallax * 0.4,
              left: -20,
              child: _GlowOrb(
                  size: 180,
                  color: _kAccent.withOpacity(0.12)),
            ),
            Positioned(
              top: 20 - parallax * 0.3,
              right: -30,
              child: _GlowOrb(
                  size: 140,
                  color: const Color(0xFF50E3C2).withOpacity(0.07)),
            ),

            // ── Content ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(
                top: topPad + 10,
                left: 20,
                right: 20,
                bottom: 28, // extra space for the wave
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section 1 — Verse banner
                  Opacity(
                    opacity: verseFade,
                    child: Transform.translate(
                      offset: Offset(0, verseSlide - parallax * 0.25),
                      child: const _VerseBanner(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Section 2 — Greeting row
                  Opacity(
                    opacity: greetFade,
                    child: Transform.translate(
                      offset: Offset(0, greetSlide - parallax * 0.15),
                      child: _GreetingRow(
                        user: user,
                        greeting: greeting,
                        bellScale: bellScale,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Section 3 — Progress
                  Opacity(
                    opacity: progressFade,
                    child: _ProgressSection(progress: progressVal),
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

// ─────────────────────────────────────────────────────────────────────────────
// Section 1 — Verse banner
// ─────────────────────────────────────────────────────────────────────────────

class _VerseBanner extends StatelessWidget {
  const _VerseBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _kVerseGlass,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.white.withOpacity(0.10), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withOpacity(0.14),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Book icon
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _kAccent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF93C5FD),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Arabic verse — right-to-left
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        'رَبِّ زِدْنِي عِلْمًا',
                        style: AppTypography.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Urdu translation
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        'اے میرے رب! میرے علم میں اضافہ فرما۔',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white.withOpacity(0.60),
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 2 — Greeting row
// ─────────────────────────────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({
    required this.user,
    required this.greeting,
    required this.bellScale,
  });

  final MockUser user;
  final String   greeting;
  final double   bellScale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with gradient border + glow
        _Avatar(initials: user.avatarInitials),

        const SizedBox(width: 12),

        // Greeting text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$greeting 👋',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                user.name,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                user.semester,
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF93C5FD),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Bell with pulse + unread dot
        _BellButton(scale: bellScale),
      ],
    );
  }
}

// ── Compact avatar ────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withOpacity(0.40),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── Bell button ───────────────────────────────────────────────────────────────

class _BellButton extends StatefulWidget {
  const _BellButton({required this.scale});
  final double scale;

  @override
  State<_BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<_BellButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp:   (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {},
        child: AnimatedScale(
          scale: _pressed ? 0.88 : widget.scale,
          duration: const Duration(milliseconds: 120),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.09),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.13),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              // Unread dot
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _kSurface, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section 3 — Today's progress bar
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.progress});
  final double progress; // 0.0 → 1.0

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toStringAsFixed(0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withOpacity(0.09), width: 1.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label row
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFF93C5FD),
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Today's Progress",
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Animated percentage counter
                  Text(
                    '$pct%',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              // Progress track
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 5,
                  color: Colors.white.withOpacity(0.10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF38BDF8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _kAccent.withOpacity(0.50),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Curved bottom-edge clipper with subtle parallax
// ─────────────────────────────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper({required this.scrollOffset});
  final double scrollOffset; // 0–120

  @override
  Path getClip(Size size) {
    // Subtle parallax: wave control-point shifts slightly with scroll
    final wave = 22.0 - scrollOffset * 0.06;

    final path = Path()
      ..lineTo(0, size.height - wave)
      ..cubicTo(
        size.width * 0.22, size.height + wave * 0.6,
        size.width * 0.55, size.height - wave * 1.4,
        size.width * 0.78, size.height - wave * 0.2,
      )
      ..cubicTo(
        size.width * 0.90, size.height + wave * 0.3,
        size.width * 0.96, size.height - wave * 0.5,
        size.width,        size.height - wave * 0.8,
      )
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) =>
      old.scrollOffset != scrollOffset;
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient soft glow orb (non-interactive background element)
// ─────────────────────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
