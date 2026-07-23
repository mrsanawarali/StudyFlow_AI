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
import 'package:untitled/features/dashboard/presentation/widgets/deadline_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/recent_note_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';
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

  // ScrollController — no longer used for collapse; kept for future needs
  final ScrollController _scrollCtrl = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    final user          = MockDashboardData.user;
    final topPad        = MediaQuery.of(context).padding.top;

    // Fixed extents.
    // Expanded  = topPad + verse(~72) + gap(10) + greeting(56) + wave(22) = ~160
    // Collapsed = topPad + greeting row (56) + small bottom pad (16) = ~72
    const double kExpandedContent  = 165.0;
    const double kCollapsedContent = 72.0;
    final double minH = topPad + kCollapsedContent;
    final double maxH = topPad + kExpandedContent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [_enterCtrl, _verseCtrl, _waveBg, _waveFg, _bellCtrl]),
        builder: (context, _) {
          return CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // ── Premium collapsing header ────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _HeaderDelegate(
                  minH: minH,
                  maxH: maxH,
                  // Build-time animation values passed via the delegate.
                  // shrinkOffset drives the collapse; animation values
                  // drive the entrance/verse/wave/bell effects.
                  headerFade:  _headerFade.value,
                  headerSlide: _headerSlide.value,
                  verse:       _kVerses[_verseIndex],
                  verseFade:   _verseFade.value,
                  waveBgT:     _waveBg.value,
                  waveFgT:     _waveFg.value,
                  bellScale:   _bellScale.value,
                  user:        user,
                  greeting:    _greeting,
                  topPad:      topPad,
                ),
              ),

              // ── Dashboard body ───────────────────────────────────
              SliverToBoxAdapter(
                child: Opacity(
                  opacity: _contentFade.value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar — slight downward offset so it sits below the wave
                      Transform.translate(
                        offset: const Offset(0, 8),
                        child: _PremiumSearchBar(),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // TODAY'S FOCUS
                      _SectionTitle(title: "Today's Focus"),
                      const SizedBox(height: AppSpacing.md),
                      const _TodaysFocusSection(),
                      const SizedBox(height: AppSpacing.xl),

                      // TODAY'S TIMETABLE
                      _SectionTitle(
                          title: "Today's Timetable", onSeeAll: () {}),
                      const SizedBox(height: AppSpacing.md),
                      const _PremiumTimetableTable(),
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
// SliverPersistentHeader delegate — fixed extents, shrinkOffset drives collapse
// ─────────────────────────────────────────────────────────────────────────────
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    required this.minH,
    required this.maxH,
    required this.headerFade,
    required this.headerSlide,
    required this.verse,
    required this.verseFade,
    required this.waveBgT,
    required this.waveFgT,
    required this.bellScale,
    required this.user,
    required this.greeting,
    required this.topPad,
  });

  final double minH;
  final double maxH;
  final double headerFade;
  final double headerSlide;
  final ({String arabic, String urdu}) verse;
  final double verseFade;
  final double waveBgT;
  final double waveFgT;
  final double bellScale;
  final MockUser user;
  final String greeting;
  final double topPad;

  @override double get minExtent => minH;
  @override double get maxExtent => maxH;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) {
    // cf: 0 = fully expanded, 1 = fully collapsed
    final cf = (shrinkOffset / (maxH - minH)).clamp(0.0, 1.0);
    return ClipRect(
      child: _PremiumHeader(
        user: user,
        greeting: greeting,
        cf: cf,
        headerFade: headerFade,
        headerSlide: headerSlide,
        verse: verse,
        verseFade: verseFade,
        waveBgT: waveBgT,
        waveFgT: waveFgT,
        bellScale: bellScale,
        topPad: topPad,
      ),
    );
  }

  @override
  bool shouldRebuild(_HeaderDelegate old) =>
      old.headerFade  != headerFade  ||
      old.headerSlide != headerSlide ||
      old.verseFade   != verseFade   ||
      old.waveBgT     != waveBgT     ||
      old.waveFgT     != waveFgT     ||
      old.bellScale   != bellScale   ||
      old.verse       != verse;
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

  // Smooth eased interpolation helper
  static double _ease(double t) =>
      t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;

  @override
  Widget build(BuildContext context) {
    // ── Collapse curves ────────────────────────────────────────────
    // Verse fades out in the first 55 % of scroll travel
    final verseCf   = (cf / 0.55).clamp(0.0, 1.0);
    final verseAlpha = (1.0 - _ease(verseCf)) *
        verseFade.clamp(0.0, 1.0);

    // Wave fades + shrinks in first 70 %
    final waveCf    = (cf / 0.70).clamp(0.0, 1.0);
    final waveAlpha = (1.0 - _ease(waveCf)).clamp(0.0, 1.0);

    // Greeting translates upward only after verse starts collapsing (30 %+)
    final greetCf   = ((cf - 0.25) / 0.75).clamp(0.0, 1.0);
    // Max upward shift equals the verse+gap height that was freed (~82 dp)
    final greetShift = _ease(greetCf) * 82.0;

    // Font sizes interpolate smoothly
    final greetingFontSize = 11.0 - greetCf * 2.0;   // 11 → 9
    final nameFontSize     = 17.0 - greetCf * 3.0;   // 17 → 14
    final showSemester     = cf < 0.75;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // ── Background gradient ─────────────────────────────────
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

        // ── Ambient glow orbs ───────────────────────────────────
        Positioned(
          top: -10, left: -20,
          child: _GlowOrb(size: 160, color: _kAccent.withOpacity(0.13)),
        ),
        Positioned(
          top: 10, right: -24,
          child: _GlowOrb(size: 120, color: _kTeal.withOpacity(0.07)),
        ),

        // ── Verse — fades and physically shrinks upward ─────────
        Positioned(
          top: topPad + 10,
          left: 20, right: 20,
          child: Opacity(
            opacity: headerFade * verseAlpha,
            child: Transform.translate(
              offset: Offset(0, headerSlide - _ease(verseCf) * 10),
              child: _VerseArea(verse: verse),
            ),
          ),
        ),

        // ── Greeting row — always visible, shifts up smoothly ───
        Positioned(
          // Starts below the verse area; translates up as verse collapses
          top: topPad + 90 - greetShift,
          left: 20, right: 20,
          child: Opacity(
            opacity: headerFade,
            child: Transform.translate(
              offset: Offset(0, headerSlide * (1 - greetCf)),
              child: _GreetingRow(
                user: user,
                greeting: greeting,
                bellScale: bellScale,
                greetingFontSize: greetingFontSize,
                nameFontSize: nameFontSize,
                showSemester: showSemester,
              ),
            ),
          ),
        ),

        // ── Dual wave — fades out on collapse ───────────────────
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: Opacity(
            opacity: waveAlpha,
            child: _DualWave(
              bgPhase: waveBgT,
              fgPhase: waveFgT,
              cf: waveCf,
            ),
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
    required this.greetingFontSize,
    required this.nameFontSize,
    required this.showSemester,
  });
  final MockUser user;
  final String   greeting;
  final double   bellScale;
  final double   greetingFontSize;   // interpolated: 11 → 9
  final double   nameFontSize;       // interpolated: 17 → 14
  final bool     showSemester;

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
              Text(
                '$greeting 👋',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.58),
                  fontSize: greetingFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                user.name,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: nameFontSize,
                  letterSpacing: 0.1,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: showSemester
                    ? Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          user.semester,
                          style: AppTypography.labelSmall.copyWith(
                            color: _kSkyBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
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
// TODAY'S FOCUS — staggered animated task cards
// ─────────────────────────────────────────────────────────────────────────────

class _TodaysFocusSection extends StatefulWidget {
  const _TodaysFocusSection();

  @override
  State<_TodaysFocusSection> createState() => _TodaysFocusSectionState();
}

class _TodaysFocusSectionState extends State<_TodaysFocusSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;
  late final List<Animation<double>> _slides;

  // Track done state locally (UI only)
  final List<bool> _done = List.generate(
      MockDashboardData.todayFocus.length, (_) => false);

  static Color _priorityColor(FocusPriority p) {
    switch (p) {
      case FocusPriority.assignment: return const Color(0xFFF97316);
      case FocusPriority.quiz:       return const Color(0xFF7C3AED);
      case FocusPriority.reading:    return const Color(0xFF2563EB);
      case FocusPriority.ai:         return const Color(0xFF059669);
    }
  }

  static String _priorityLabel(FocusPriority p) {
    switch (p) {
      case FocusPriority.assignment: return 'Assignment';
      case FocusPriority.quiz:       return 'Quiz';
      case FocusPriority.reading:    return 'Reading';
      case FocusPriority.ai:         return 'AI Pick';
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 720));

    final n = MockDashboardData.todayFocus.length;
    _fades = List.generate(n, (i) {
      final s = i * 0.10;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, s + 0.45, curve: Curves.easeOut)));
    });
    _slides = List.generate(n, (i) {
      final s = i * 0.10;
      return Tween<double>(begin: 20.0, end: 0.0).animate(CurvedAnimation(
          parent: _ctrl,
          curve: Interval(s, s + 0.45, curve: Curves.easeOut)));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = MockDashboardData.todayFocus;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Column(
        children: List.generate(tasks.length, (i) {
          final task  = tasks[i];
          final color = _priorityColor(task.priority);
          return Opacity(
            opacity: _fades[i].value,
            child: Transform.translate(
              offset: Offset(0, _slides[i].value),
              child: Padding(
                padding: EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: i < tasks.length - 1 ? 10 : 0),
                child: _FocusTaskCard(
                  task: task,
                  color: color,
                  label: _priorityLabel(task.priority),
                  isDone: _done[i],
                  onToggle: () => setState(() => _done[i] = !_done[i]),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Single focus task card ─────────────────────────────────────────────────
class _FocusTaskCard extends StatefulWidget {
  const _FocusTaskCard({
    required this.task,
    required this.color,
    required this.label,
    required this.isDone,
    required this.onToggle,
  });
  final MockFocusTask task;
  final Color color;
  final String label;
  final bool isDone;
  final VoidCallback onToggle;

  @override
  State<_FocusTaskCard> createState() => _FocusTaskCardState();
}

class _FocusTaskCardState extends State<_FocusTaskCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onToggle();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1.0,
          duration: const Duration(milliseconds: 110),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.055),
                  blurRadius: 12, offset: const Offset(0, 3)),
                BoxShadow(
                  color: widget.color.withOpacity(0.06),
                  blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                // Left accent line
                Container(
                  width: 4,
                  height: 68,
                  decoration: BoxDecoration(
                    color: widget.isDone
                        ? widget.color.withOpacity(0.30)
                        : widget.color,
                    borderRadius: const BorderRadius.only(
                      topLeft:    Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Icon chip
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.task.icon,
                      color: widget.isDone
                          ? widget.color.withOpacity(0.40)
                          : widget.color,
                      size: 18),
                ),
                const SizedBox(width: 12),

                // Text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Priority badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.color.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.label,
                                style: AppTypography.labelSmall.copyWith(
                                  color: widget.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (widget.task.time != null) ...[
                              const SizedBox(width: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 10,
                                      color: AppColors.onSurfaceVariant
                                          .withOpacity(0.70)),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.task.time!,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.onSurfaceVariant
                                          .withOpacity(0.70),
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.task.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: widget.isDone
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            decoration: widget.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.task.subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Checkbox
                GestureDetector(
                  onTap: widget.onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: widget.isDone
                          ? widget.color
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.isDone
                            ? widget.color
                            : AppColors.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: widget.isDone
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 13)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM TIMETABLE TABLE
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumTimetableTable extends StatefulWidget {
  const _PremiumTimetableTable();

  @override
  State<_PremiumTimetableTable> createState() =>
      _PremiumTimetableTableState();
}

class _PremiumTimetableTableState extends State<_PremiumTimetableTable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<double>(begin: 16.0, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final entries = MockDashboardData.todayTimetable;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.outlineVariant, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16, offset: const Offset(0, 4)),
                  BoxShadow(
                    color: _kAccent.withOpacity(0.04),
                    blurRadius: 20, offset: const Offset(0, 6)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Table header ──────────────────────────────
                    _TableHeader(),
                    const Divider(height: 1, thickness: 1,
                        color: Color(0xFFEFF0F2)),

                    // ── Table rows ────────────────────────────────
                    ...List.generate(entries.length, (i) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TableRow(entry: entries[i], isEven: i.isEven),
                        if (i < entries.length - 1)
                          const Divider(height: 1, thickness: 1,
                              indent: 16, endIndent: 16,
                              color: Color(0xFFF3F4F6)),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header row ──────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          // Teacher col — 26 %
          Expanded(
            flex: 26,
            child: _HeaderCell(label: 'Teacher',
                icon: Icons.person_outline_rounded),
          ),
          // Subject col — 30 %
          Expanded(
            flex: 30,
            child: _HeaderCell(label: 'Subject',
                icon: Icons.book_outlined),
          ),
          // Time col — 24 %
          Expanded(
            flex: 24,
            child: _HeaderCell(label: 'Time',
                icon: Icons.access_time_rounded),
          ),
          // Room col — 20 %
          Expanded(
            flex: 20,
            child: _HeaderCell(label: 'Room',
                icon: Icons.meeting_room_outlined),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12,
            color: AppColors.onSurfaceVariant.withOpacity(0.70)),
        const SizedBox(width: 4),
        Text(label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            )),
      ],
    );
  }
}

// ── Data row ─────────────────────────────────────────────────────────────────
class _TableRow extends StatelessWidget {
  const _TableRow({required this.entry, required this.isEven});
  final MockTimetableEntry entry;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    final isActive = entry.isActive;
    final bg = isActive
        ? _kAccent.withOpacity(0.05)
        : (isEven ? AppColors.surface : const Color(0xFFFAFAFC));

    return Container(
      color: bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Active blue indicator bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 3,
            height: 62,
            color: isActive ? _kAccent : Colors.transparent,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 13, vertical: 12),
              child: Row(
                children: [
                  // Teacher (26 %)
                  Expanded(
                    flex: 26,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar circle with initials
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: entry.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              entry.professorInitials,
                              style: AppTypography.labelSmall.copyWith(
                                color: entry.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.professor,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subject (30 %)
                  Expanded(
                    flex: 30,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 3, height: 28,
                          decoration: BoxDecoration(
                            color: entry.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            entry.subject,
                            style: AppTypography.bodySmall.copyWith(
                              color: isActive
                                  ? _kAccent
                                  : AppColors.onSurface,
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time (24 %)
                  Expanded(
                    flex: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.startTime,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          entry.endTime,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Room (20 %)
                  Expanded(
                    flex: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? _kAccent.withOpacity(0.10)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.room,
                        style: AppTypography.labelSmall.copyWith(
                          color: isActive
                              ? _kAccent
                              : AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
