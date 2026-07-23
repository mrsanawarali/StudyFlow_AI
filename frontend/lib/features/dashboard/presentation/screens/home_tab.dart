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
// Design tokens — consistent across header, nav dock, cards
// ─────────────────────────────────────────────────────────────────────────────
const Color _kNavy     = Color(0xFF0F1C38);
const Color _kSurface  = Color(0xFF131F3D);
const Color _kAccent   = Color(0xFF2563EB);
const Color _kBorder   = Color(0xFF1F2E50);
const Color _kSkyBlue  = Color(0xFF93C5FD);
const Color _kTeal     = Color(0xFF50E3C2);

// ─────────────────────────────────────────────────────────────────────────────
// Verse data — add more entries here; the widget rotates through them
// ─────────────────────────────────────────────────────────────────────────────
const _kVerses = [
  (arabic: 'رَّبِّ زِدْنِي عِلْمًا',
   urdu:   'اے میرے رب! میرے علم میں اضافہ فرما۔'),
  (arabic: 'وَمَا أُوتِيتُم مِّنَ الْعِلْمِ إِلَّا قَلِيلًا',
   urdu:   'اور تمہیں علم سے بہت کم دیا گیا ہے۔'),
  (arabic: 'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
   urdu:   'پڑھو اپنے رب کے نام سے جس نے پیدا کیا۔'),
];

/// Phase 2C — Premium Home Tab.
/// Header redesign — no business logic changes, all data from [MockDashboardData].
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {

  // ── Entrance ────────────────────────────────────────────────────────────
  late final AnimationController _enterCtrl;
  late final Animation<double> _headerFade, _headerSlide;
  late final Animation<double> _contentFade;

  // ── Scroll-driven collapse ───────────────────────────────────────────────
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  // ── Verse auto-rotation ──────────────────────────────────────────────────
  late final AnimationController _verseCtrl; // drives fade-out/in
  late final Animation<double> _verseFade;
  int _verseIndex = 0;

  // ── Dual wave animation ──────────────────────────────────────────────────
  late final AnimationController _waveBg;   // slow
  late final AnimationController _waveFg;   // slightly faster

  // ── Bell pulse ───────────────────────────────────────────────────────────
  late final AnimationController _bellCtrl;
  late final Animation<double> _bellScale;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();

    // Entrance
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _headerFade = _iv(0.00, 0.55);
    _headerSlide = Tween<double>(begin: -16.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.55, curve: Curves.easeOut)));
    _contentFade = _iv(0.40, 1.00);

    // Verse rotation — fade out at 0→0.5, fade in at 0.5→1.0
    _verseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _verseFade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _verseCtrl, curve: Curves.easeInOut));

    // Waves
    _waveBg = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 4200))..repeat();
    _waveFg = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2800))..repeat();

    // Bell
    _bellCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _bellScale = Tween<double>(begin: 1.0, end: 1.10).animate(
        CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));

    // Scroll listener for collapse
    _scrollCtrl.addListener(() {
      final raw = _scrollCtrl.offset.clamp(0.0, 130.0);
      if ((raw - _scrollOffset).abs() > 0.5) {
        setState(() => _scrollOffset = raw);
      }
    });

    // Schedule verse rotation every 5.5 s
    _scheduleVerseRotation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });
  }

  void _scheduleVerseRotation() {
    Future.delayed(const Duration(milliseconds: 5500), () {
      if (!mounted) return;
      _verseCtrl.forward(from: 0.0).then((_) {
        if (!mounted) return;
        setState(() => _verseIndex = (_verseIndex + 1) % _kVerses.length);
        _scheduleVerseRotation();
      });
    });
  }

  Animation<double> _iv(double s, double e) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  @override
  void dispose() {
    _enterCtrl.dispose();
    _verseCtrl.dispose();
    _waveBg.dispose();
    _waveFg.dispose();
    _bellCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Collapse factor 0.0 (expanded) → 1.0 (collapsed) ───────────────────
  double get _cf => (_scrollOffset / 130.0).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final user          = MockDashboardData.user;
    final activeSubject = MockDashboardData.subjects.first;
    final topPad        = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [_enterCtrl, _verseCtrl, _waveBg, _waveFg, _bellCtrl]),
        builder: (context, _) {
          // Header height collapses: 210 → 86 (including topPad)
          final headerH = (topPad + 210.0 - _cf * 124.0).clamp(
              topPad + 86.0, topPad + 210.0);

          return CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // ── Premium collapsing header ────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(
                  minH: topPad + 68,
                  maxH: headerH,
                  child: _PremiumHeader(
                    user: user,
                    greeting: _greeting,
                    cf: _cf,
                    headerFade: _headerFade.value,
                    headerSlide: _headerSlide.value,
                    verse: _kVerses[_verseIndex],
                    verseFade: _verseFade.value,
                    waveBgT: _waveBg.value,
                    waveFgT: _waveFg.value,
                    bellScale: _bellScale.value,
                    topPad: topPad,
                  ),
                ),
              ),

              // ── Dashboard body ───────────────────────────────────
              SliverToBoxAdapter(
                child: Opacity(
                  opacity: _contentFade.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      // Premium search bar
                      _PremiumSearchBar(),
                      const SizedBox(height: AppSpacing.xl),

                      // Overview
                      _SectionTitle(title: 'Overview', onSeeAll: () {}),
                      const SizedBox(height: AppSpacing.md),
                      _StatsGrid(),
                      const SizedBox(height: AppSpacing.xl),

                      // Continue studying
                      _SectionTitle(
                          title: 'Continue Studying', onSeeAll: () {}),
                      const SizedBox(height: AppSpacing.md),
                      ContinueStudyingCard(subject: activeSubject),
                      const SizedBox(height: AppSpacing.xl),

                      // Quick actions
                      _SectionTitle(title: 'Quick Actions'),
                      const SizedBox(height: AppSpacing.md),
                      const QuickActionsGrid(),
                      const SizedBox(height: AppSpacing.xl),

                      // Timetable
                      _SectionTitle(
                          title: "Today's Timetable", onSeeAll: () {}),
                      const SizedBox(height: AppSpacing.md),
                      TimetableSection(
                          entries: MockDashboardData.todayTimetable),
                      const SizedBox(height: AppSpacing.xl),

                      // Deadlines
                      _SectionTitle(
                          title: 'Upcoming Deadlines', onSeeAll: () {}),
                      const SizedBox(height: AppSpacing.sm),
                      ...MockDashboardData.upcomingAssignments
                          .take(3)
                          .map((a) => DeadlineCard(assignment: a)),
                      const SizedBox(height: AppSpacing.xl),

                      // Recent notes
                      _SectionTitle(
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
                      _SectionTitle(title: 'AI Study Assistant'),
                      const SizedBox(height: AppSpacing.md),
                      const AIAssistantCard(),
                      const SizedBox(height: AppSpacing.xl),

                      // Weekly progress
                      _SectionTitle(title: 'Weekly Progress'),
                      const SizedBox(height: AppSpacing.md),
                      const WeeklyProgressChart(),
                      const SizedBox(height: AppSpacing.xl),

                      // Recent activity
                      _SectionTitle(
                          title: 'Recent Activity', onSeeAll: () {}),
                      const SizedBox(height: AppSpacing.md),
                      ActivityTimeline(
                          entries: MockDashboardData.recentActivity),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SliverPersistentHeader delegate
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    required this.minH,
    required this.maxH,
    required this.child,
  });
  final double minH;
  final double maxH;
  final Widget child;

  @override double get minExtent => minH;
  @override double get maxExtent => maxH;

  @override
  Widget build(BuildContext ctx, double shrink, bool overlaps) => child;

  @override
  bool shouldRebuild(_HeaderDelegate old) =>
      old.minH != minH || old.maxH != maxH;
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium collapsing header
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({
    required this.user,
    required this.greeting,
    required this.cf,
    required this.headerFade,
    required this.headerSlide,
    required this.verse,
    required this.verseFade,
    required this.waveBgT,
    required this.waveFgT,
    required this.bellScale,
    required this.topPad,
  });

  final MockUser user;
  final String   greeting;
  final double   cf;           // collapse factor 0→1
  final double   headerFade, headerSlide;
  final ({String arabic, String urdu}) verse;
  final double   verseFade;
  final double   waveBgT, waveFgT;
  final double   bellScale;
  final double   topPad;

  @override
  Widget build(BuildContext context) {
    // Verse area fades out as user scrolls
    final verseOpacity = (1.0 - cf * 2.2).clamp(0.0, 1.0);

    return Stack(
      children: [
        // ── Dark navy background ────────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kNavy, Color(0xFF192448)],
              ),
            ),
          ),
        ),

        // ── Ambient glow orbs ───────────────────────────────────────
        Positioned(
          top: -10, left: -20,
          child: _GlowOrb(
              size: 160, color: _kAccent.withOpacity(0.13)),
        ),
        Positioned(
          top: 10, right: -24,
          child: _GlowOrb(
              size: 120, color: _kTeal.withOpacity(0.07)),
        ),

        // ── Content ─────────────────────────────────────────────────
        Positioned.fill(
          child: Opacity(
            opacity: headerFade,
            child: Transform.translate(
              offset: Offset(0, headerSlide),
              child: Padding(
                padding: EdgeInsets.only(
                  top: topPad + 12,
                  left: 20, right: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Section 1 — Verse (fades on collapse)
                    Opacity(
                      opacity: verseOpacity * verseFade
                          .clamp(0.0, 1.0)
                          .toDouble(),
                      child: _VerseArea(verse: verse),
                    ),

                    SizedBox(height: 14 * (1 - cf * 0.8)),

                    // Section 2 — Greeting row
                    _GreetingRow(
                      user: user,
                      greeting: greeting,
                      bellScale: bellScale,
                      compact: cf > 0.6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Dual animated wave at bottom edge ───────────────────────
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: _DualWave(
            bgPhase: waveBgT,
            fgPhase: waveFgT,
            cf: cf,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Verse area — centred, no card, fading cross-rotation
// ─────────────────────────────────────────────────────────────────────────────
class _VerseArea extends StatelessWidget {
  const _VerseArea({required this.verse});
  final ({String arabic, String urdu}) verse;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Small book icon
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: _kAccent.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: _kSkyBlue,
            size: 14,
          ),
        ),
        const SizedBox(height: 6),

        // Arabic verse — centred RTL
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            verse.arabic,
            textAlign: TextAlign.center,
            style: AppTypography.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 1.55,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 3),

        // Urdu translation
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            verse.urdu,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.52),
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting row
// ─────────────────────────────────────────────────────────────────────────────
class _GreetingRow extends StatelessWidget {
  const _GreetingRow({
    required this.user,
    required this.greeting,
    required this.bellScale,
    required this.compact,
  });
  final MockUser user;
  final String   greeting;
  final double   bellScale;
  final bool     compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(initials: user.avatarInitials),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.58),
                  fontSize: compact ? 9 : 11,
                  fontWeight: FontWeight.w500,
                ),
                child: Text('$greeting 👋'),
              ),
              const SizedBox(height: 1),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 14 : 17,
                  letterSpacing: 0.1,
                ),
                child: Text(user.name),
              ),
              if (!compact) ...[
                const SizedBox(height: 1),
                Text(
                  user.semester,
                  style: AppTypography.labelSmall.copyWith(
                    color: _kSkyBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        _BellButton(scale: bellScale),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withOpacity(0.42),
            blurRadius: 12, spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.22), width: 1.5),
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

// ─────────────────────────────────────────────────────────────────────────────
// Bell button
// ─────────────────────────────────────────────────────────────────────────────
class _BellButton extends StatefulWidget {
  const _BellButton({required this.scale});
  final double scale;
  @override
  State<_BellButton> createState() => _BellButtonState();
}
class _BellButtonState extends State<_BellButton> {
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
          scale: _pressed ? 0.87 : widget.scale,
          duration: const Duration(milliseconds: 110),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.14), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white, size: 18),
              ),
              Positioned(
                top: 7, right: 7,
                child: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: _kNavy, width: 1.2),
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
// Dual animated wave
// ─────────────────────────────────────────────────────────────────────────────
class _DualWave extends StatelessWidget {
  const _DualWave({
    required this.bgPhase,
    required this.fgPhase,
    required this.cf,
  });
  final double bgPhase, fgPhase, cf;

  @override
  Widget build(BuildContext context) {
    // Wave height shrinks slightly on collapse
    final waveH = (28.0 - cf * 12.0).clamp(16.0, 28.0);

    return SizedBox(
      height: waveH + 6,
      child: Stack(
        children: [
          // Background wave — slow, slightly lighter
          CustomPaint(
            size: Size(double.infinity, waveH + 6),
            painter: _WavePainter(
              phase: bgPhase,
              amplitude: waveH * 0.55,
              color: Colors.white.withOpacity(0.07),
              speed: 1.0,
            ),
          ),
          // Foreground wave — faster, more opaque, fills background
          CustomPaint(
            size: Size(double.infinity, waveH + 6),
            painter: _WavePainter(
              phase: fgPhase,
              amplitude: waveH * 0.70,
              color: AppColors.background,
              speed: 1.35,
              fill: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.phase,
    required this.amplitude,
    required this.color,
    required this.speed,
    this.fill = false,
  });
  final double phase;
  final double amplitude;
  final Color  color;
  final double speed;
  final bool   fill;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(0, size.height);

    // Two full sine cycles across the width
    const steps = 120;
    for (int i = 0; i <= steps; i++) {
      final x = size.width * i / steps;
      final t = (i / steps) * 2 * math.pi * speed
          + phase * 2 * math.pi;
      final y = (size.height - amplitude) + math.sin(t) * amplitude * 0.5;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.phase != phase || old.amplitude != amplitude;
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient glow orb
// ─────────────────────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium search bar
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumSearchBar extends StatefulWidget {
  @override
  State<_PremiumSearchBar> createState() => _PremiumSearchBarState();
}
class _PremiumSearchBarState extends State<_PremiumSearchBar> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: GestureDetector(
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _focused
                    ? _kAccent.withOpacity(0.55)
                    : AppColors.outlineVariant,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _focused
                      ? _kAccent.withOpacity(0.12)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _focused ? 14 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: _focused
                      ? _kAccent
                      : AppColors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search notes, subjects, assignments...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('⌘K',
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium section title — replaces the flat SectionHeader
// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 3, height: 16,
            decoration: BoxDecoration(
              color: _kAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.1,
              ),
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all',
                    style: AppTypography.labelSmall.copyWith(
                      color: _kAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      color: _kAccent, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats grid with entrance animation
// ─────────────────────────────────────────────────────────────────────────────
class _StatsGrid extends StatefulWidget {
  @override
  State<_StatsGrid> createState() => _StatsGridState();
}
class _StatsGridState extends State<_StatsGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<double>> _slides;

  static const _cards = [
    (label: 'Subjects',    value: '5',  icon: Icons.layers_outlined,
     color: Color(0xFF2563EB)),
    (label: 'Notes',       value: '63', icon: Icons.description_outlined,
     color: Color(0xFF50E3C2)),
    (label: 'Assignments', value: '12', icon: Icons.assignment_outlined,
     color: Color(0xFFFFA726)),
    (label: 'Quizzes',     value: '8',  icon: Icons.quiz_outlined,
     color: Color(0xFFAB47BC)),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _fades = List.generate(4, (i) {
      final s = 0.10 * i;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _ctrl,
              curve: Interval(s, s + 0.45, curve: Curves.easeOut)));
    });
    _slides = List.generate(4, (i) {
      final s = 0.10 * i;
      return Tween<double>(begin: 18.0, end: 0.0).animate(
          CurvedAnimation(parent: _ctrl,
              curve: Interval(s, s + 0.45, curve: Curves.easeOut)));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.30,
          ),
          itemCount: _cards.length,
          itemBuilder: (_, i) {
            final c = _cards[i];
            return Opacity(
              opacity: _fades[i].value,
              child: Transform.translate(
                offset: Offset(0, _slides[i].value),
                child: _PremiumStatCard(
                  label: c.label,
                  value: c.value,
                  icon: c.icon,
                  color: c.color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium stat card
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumStatCard extends StatefulWidget {
  const _PremiumStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  State<_PremiumStatCard> createState() => _PremiumStatCardState();
}
class _PremiumStatCardState extends State<_PremiumStatCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp:   (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: widget.color.withOpacity(0.12), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.10),
                  blurRadius: 16, spreadRadius: 0,
                  offset: const Offset(0, 4)),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.value,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 22, height: 1.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
