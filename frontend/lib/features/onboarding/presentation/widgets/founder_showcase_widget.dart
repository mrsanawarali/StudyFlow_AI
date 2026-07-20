import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/splash/presentation/widgets/app_logo_widget.dart';
import 'package:untitled/features/splash/presentation/widgets/particle_layer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen founder showcase — onboarding page 5
// ─────────────────────────────────────────────────────────────────────────────

/// Premium founder showcase — App Store editorial style.
///
/// The real founder PNG (`assets/founder/sanawar_mockup1.png`) is the primary
/// visual. A phone mockup widget is overlaid over the founder's hand position
/// with a slight rotation for a realistic promotional look. The phone screen
/// cycles through Dashboard → AI Assistant → Profile every 3 seconds using
/// [AnimatedSwitcher] with a combined fade + slide transition.
class FounderShowcaseWidget extends StatefulWidget {
  const FounderShowcaseWidget({
    super.key,
    required this.particleController,
    required this.onGetStarted,
  });

  final AnimationController particleController;
  final VoidCallback? onGetStarted;

  @override
  State<FounderShowcaseWidget> createState() => _FounderShowcaseWidgetState();
}

class _FounderShowcaseWidgetState extends State<FounderShowcaseWidget>
    with TickerProviderStateMixin {
  // ── Entrance (runs once, 1500 ms) ─────────────────────────────────────────
  late final AnimationController _enterCtrl;

  // ── Looping float for stat cards ─────────────────────────────────────────
  late final AnimationController _floatCtrl;

  // ── Looping pulse for background glow ────────────────────────────────────
  late final AnimationController _pulseCtrl;

  // ── Entrance animation values ─────────────────────────────────────────────
  late final Animation<double> _bgFade;
  late final Animation<double> _figFade;
  late final Animation<double> _figSlide;
  late final Animation<double> _card1Fade, _card1Slide;
  late final Animation<double> _card2Fade, _card2Slide;
  late final Animation<double> _card3Fade;
  late final Animation<double> _quoteFade, _quoteSlide;
  late final Animation<double> _ctaFade, _ctaScale;

  // ── Phone screen cycler ───────────────────────────────────────────────────
  static const _screens = ['dashboard', 'ai_assistant', 'profile'];
  int _screenIndex = 0;
  Timer? _screenTimer;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    _bgFade     = _a(0.00, 0.25);
    _figFade    = _a(0.12, 0.48);
    _figSlide   = _s(0.12, 0.48, b: 24.0);
    _card1Fade  = _a(0.38, 0.62);
    _card1Slide = _s(0.38, 0.62, b: -18.0);
    _card2Fade  = _a(0.48, 0.70);
    _card2Slide = _s(0.48, 0.70, b: 18.0);
    _card3Fade  = _a(0.52, 0.74);
    _quoteFade  = _a(0.65, 0.85);
    _quoteSlide = _s(0.65, 0.85, b: 14.0);
    _ctaFade    = _a(0.78, 1.00);
    _ctaScale   = Tween<double>(begin: 0.80, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.78, 1.00, curve: Curves.elasticOut)));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });

    // Start phone screen cycling after 1 s so the entrance animation settles
    _screenTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _screenIndex = (_screenIndex + 1) % _screens.length;
        });
      }
    });
  }

  Animation<double> _a(double s, double e) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  Animation<double> _s(double s, double e, {double b = 16.0}) =>
      Tween<double>(begin: b, end: 0.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  double _fy(double phase, {double amp = 5.0}) =>
      amp * math.sin((_floatCtrl.value + phase) % 1.0 * math.pi);

  @override
  void dispose() {
    _screenTimer?.cancel();
    _enterCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_enterCtrl, _floatCtrl, _pulseCtrl]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Background glow ───────────────────────────────────────────
        Opacity(
          opacity: _bgFade.value,
          child: Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPainter(pulseT: _pulseCtrl.value),
            ),
          ),
        ),

        // ── Particle layer ─────────────────────────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: ParticleLayer(controller: widget.particleController),
          ),
        ),

        // ── Main layout ────────────────────────────────────────────────
        Positioned.fill(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                _buildTopBranding(),

                // ── Illustration area ────────────────────────────────
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Founder PNG + phone overlay
                      Opacity(
                        opacity: _figFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _figSlide.value),
                          child: _FounderWithPhone(
                            screenIndex: _screenIndex,
                          ),
                        ),
                      ),

                      // Feature badge — left, mid area
                      Positioned(
                        bottom: h * 0.22,
                        left: w * 0.01,
                        child: Opacity(
                          opacity: _card1Fade.value,
                          child: Transform.translate(
                            offset: Offset(_card1Slide.value, _fy(0.0)),
                            child: const _FeatureBadge(
                              emoji: '🤖',
                              label: 'AI Powered Learning',
                            ),
                          ),
                        ),
                      ),

                      // Feature badge — right, slightly lower
                      Positioned(
                        bottom: h * 0.13,
                        right: w * 0.01,
                        child: Opacity(
                          opacity: _card2Fade.value,
                          child: Transform.translate(
                            offset: Offset(-_card2Slide.value, _fy(0.5)),
                            child: const _FeatureBadge(
                              emoji: '🎓',
                              label: 'Built for Students',
                            ),
                          ),
                        ),
                      ),

                      // App Store badge — very bottom centre
                      Positioned(
                        bottom: h * 0.02,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Opacity(
                            opacity: _card3Fade.value,
                            child: Transform.translate(
                              offset: Offset(0, _fy(0.75)),
                              child: const _AppStoreBadge(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Quote card ───────────────────────────────────────
                Opacity(
                  opacity: _quoteFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _quoteSlide.value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: const _QuoteCard(),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── CTA button ───────────────────────────────────────
                Opacity(
                  opacity: _ctaFade.value,
                  child: Transform.scale(
                    scale: _ctaScale.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: _GetStartedButton(
                          onPressed: widget.onGetStarted),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBranding() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28, height: 28,
            child: FittedBox(
                fit: BoxFit.contain, child: const AppLogoWidget()),
          ),
          const SizedBox(width: 10),
          Text('StudyFlow AI',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.95),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Founder PNG + phone overlay composite
// ─────────────────────────────────────────────────────────────────────────────

/// Lays the real founder PNG as the primary visual, then overlays a premium
/// phone mockup widget positioned over the founder's right hand area.
/// The phone is rotated ~8° counter-clockwise for a natural held look and
/// sized ~25% larger than what the painter had before.
class _FounderWithPhone extends StatelessWidget {
  const _FounderWithPhone({required this.screenIndex});

  final int screenIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.52;

        // Phone size — large enough to fully cover the baked-in white phone
        // in the PNG but not tall enough to reach the founder's face
        final phoneW = w * 0.46;
        final phoneH = phoneW * 2.05;

        // Position directly over the background white phone in the PNG:
        // shifted right so phone sits in the hand area, not on the chest
        final phoneDx = w * 0.18;   // moved right for natural hand alignment
        final phoneDy = h * 0.08;   // starting just below the face

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── Background glow behind the founder ─────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: _FounderGlowPainter(),
                ),
              ),

              // ── Founder PNG (transparent cutout) ────────────────────
              Positioned.fill(
                child: Image.asset(
                  'assets/founder/sanawar_mockup1.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),
              ),

              // ── Flutter phone mockup — straight, covers background phone ──
              Positioned(
                left: w / 2 + phoneDx - phoneW / 2,
                top: h / 2 + phoneDy - phoneH / 2,
                child: _PhoneMockup(
                  width: phoneW,
                  height: phoneH,
                  screenIndex: screenIndex,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Soft glow behind the founder image
// ─────────────────────────────────────────────────────────────────────────────

class _FounderGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.50;

    // Large soft body halo
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.44,
      Paint()
        ..shader = RadialGradient(colors: [
          AppColors.secondary.withValues(alpha: 0.18),
          AppColors.secondary.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(
            center: Offset(cx, cy), radius: size.width * 0.44)),
    );

    // Tighter purple accent glow
    canvas.drawCircle(
      Offset(cx * 1.12, cy * 0.88),
      size.width * 0.22,
      Paint()
        ..shader = RadialGradient(colors: [
          AppColors.tertiary.withValues(alpha: 0.12),
          AppColors.tertiary.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(
            center: Offset(cx * 1.12, cy * 0.88),
            radius: size.width * 0.22)),
    );
  }

  @override
  bool shouldRepaint(_FounderGlowPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium phone mockup with cycling screen
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup({
    required this.width,
    required this.height,
    required this.screenIndex,
  });

  final double width;
  final double height;
  final int screenIndex;

  @override
  Widget build(BuildContext context) {
    final cr = width * 0.12;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // ── Phone body shadow ───────────────────────────────────────
          Positioned(
            left: 3, top: 6,
            child: Container(
              width: width, height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cr),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 20, spreadRadius: 2),
                ],
              ),
            ),
          ),

          // ── Phone outer shell ───────────────────────────────────────
          Container(
            width: width, height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cr),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A3870), Color(0xFF0D1228)],
              ),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.60),
                width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.35),
                  blurRadius: 18, spreadRadius: 1),
              ],
            ),
          ),

          // ── Screen bezel ────────────────────────────────────────────
          Positioned(
            left: width * 0.05,
            top: height * 0.03,
            right: width * 0.05,
            bottom: height * 0.03,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cr * 0.75),
              child: _CyclingAppScreen(screenIndex: screenIndex),
            ),
          ),

          // ── Dynamic island / notch ──────────────────────────────────
          Positioned(
            top: height * 0.013,
            left: width * 0.30,
            right: width * 0.30,
            child: Container(
              height: height * 0.022,
              decoration: BoxDecoration(
                color: const Color(0xFF080C1A),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // ── Power button ─────────────────────────────────────────────
          Positioned(
            right: -width * 0.03,
            top: height * 0.24,
            child: Container(
              width: width * 0.03,
              height: height * 0.08,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2E5C),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // ── Volume buttons ───────────────────────────────────────────
          Positioned(
            left: -width * 0.03,
            top: height * 0.20,
            child: Column(
              children: [
                Container(
                  width: width * 0.03, height: height * 0.06,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2E5C),
                    borderRadius: BorderRadius.circular(3)),
                ),
                SizedBox(height: height * 0.015),
                Container(
                  width: width * 0.03, height: height * 0.06,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2E5C),
                    borderRadius: BorderRadius.circular(3)),
                ),
              ],
            ),
          ),

          // ── Home indicator ────────────────────────────────────────────
          Positioned(
            bottom: height * 0.015,
            left: width * 0.30,
            right: width * 0.30,
            child: Container(
              height: height * 0.006,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cycling app screen widget
// ─────────────────────────────────────────────────────────────────────────────

/// Cycles through Dashboard → AI Assistant → Profile every 3 seconds.
/// Uses [AnimatedSwitcher] with a combined fade + upward-slide transition
/// so the switch feels like a live running app.
class _CyclingAppScreen extends StatelessWidget {
  const _CyclingAppScreen({required this.screenIndex});

  final int screenIndex;

  static const _labels = ['Dashboard', 'AI Assistant', 'Profile'];

  static const _icons = [
    Icons.dashboard_rounded,
    Icons.auto_awesome_rounded,
    Icons.person_rounded,
  ];

  static const _accents = [
    AppColors.secondary,
    AppColors.tertiary,
    Color(0xFF9B59B6),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0F2C),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          // Slide up + fade
          final slideAnim = Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnim, child: child),
          );
        },
        child: _AppScreenContent(
          key: ValueKey(screenIndex),
          label: _labels[screenIndex],
          icon: _icons[screenIndex],
          accent: _accents[screenIndex],
          index: screenIndex,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual app screen content
// ─────────────────────────────────────────────────────────────────────────────

class _AppScreenContent extends StatelessWidget {
  const _AppScreenContent({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.index,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0F2C),
            Color.lerp(const Color(0xFF0A0F2C), accent, 0.12)!,
          ],
        ),
      ),
      child: Column(
        children: [
          // Status bar
          _buildStatusBar(accent),
          // Screen-specific content
          Expanded(child: _buildScreenBody()),
          // Bottom nav
          _buildBottomNav(accent),
        ],
      ),
    );
  }

  Widget _buildStatusBar(Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Text('9:41',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 8,
              fontWeight: FontWeight.w700)),
          const Spacer(),
          Icon(Icons.signal_cellular_alt, color: Colors.white.withValues(alpha: 0.80), size: 8),
          const SizedBox(width: 2),
          Icon(Icons.wifi, color: Colors.white.withValues(alpha: 0.80), size: 8),
          const SizedBox(width: 2),
          Icon(Icons.battery_full, color: Colors.white.withValues(alpha: 0.80), size: 8),
        ],
      ),
    );
  }

  Widget _buildScreenBody() {
    switch (index) {
      case 0:
        return _DashboardBody();
      case 1:
        return _AIAssistantBody();
      case 2:
        return _ProfileBody();
      default:
        return _DashboardBody();
    }
  }

  Widget _buildBottomNav(Color accent) {
    final items = [
      Icons.home_rounded,
      Icons.auto_awesome_rounded,
      Icons.book_rounded,
      Icons.person_rounded,
    ];
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = (index == 0 && i == 0) ||
              (index == 1 && i == 1) ||
              (index == 2 && i == 3);
          return Icon(items[i],
            size: 14,
            color: active
                ? accent
                : Colors.white.withValues(alpha: 0.35));
        }),
      ),
    );
  }
}

// ── Dashboard screen ─────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Text('Dashboard',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 11, fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.secondary, AppColors.tertiary])),
              child: Center(
                child: Text('S',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 8, fontWeight: FontWeight.w800))),
            ),
          ]),
          const SizedBox(height: 6),
          // Progress ring row
          Row(children: [
            _MiniRing(value: 0.72, color: AppColors.tertiary, label: '72%'),
            const SizedBox(width: 6),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MiniCard(label: 'Semester 3', value: '8 Subjects',
                    color: AppColors.secondary),
                const SizedBox(height: 4),
                _MiniCard(label: 'Due Today', value: '3 Tasks',
                    color: AppColors.tertiary),
              ],
            )),
          ]),
          const SizedBox(height: 6),
          // Recent activity
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Notes',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.70),
                      fontSize: 7, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                for (final t in ['Calculus Ch.4', 'Physics Lab'])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(children: [
                      Icon(Icons.notes_rounded,
                          color: AppColors.secondaryLight.withValues(alpha: 0.80),
                          size: 8),
                      const SizedBox(width: 4),
                      Text(t,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontSize: 7)),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Assistant screen ──────────────────────────────────────────────────────

class _AIAssistantBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome_rounded,
                color: AppColors.tertiary, size: 11),
            const SizedBox(width: 4),
            Text('AI Assistant',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          // Chat messages
          _ChatBubble(text: 'Summarize my Calculus notes',
              isUser: true),
          const SizedBox(height: 4),
          _ChatBubble(
              text: 'Sure! Here\'s a summary of Chapter 4: Derivatives...',
              isUser: false),
          const SizedBox(height: 4),
          _ChatBubble(text: 'Generate a quiz on Chapter 5',
              isUser: true),
          const Spacer(),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.35))),
            child: Row(children: [
              Expanded(child: Text('Ask anything...',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 7))),
              Icon(Icons.send_rounded, color: AppColors.tertiary, size: 10),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Profile screen ───────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.tertiary]),
              boxShadow: [
                BoxShadow(color: AppColors.secondary.withValues(alpha: 0.40),
                    blurRadius: 8)]),
            child: const Center(child: Text('S',
              style: TextStyle(color: Colors.white,
                  fontSize: 14, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(height: 4),
          Text('Sanawar Ali',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.95),
                fontSize: 10, fontWeight: FontWeight.w700)),
          Text('Computer Science · Semester 3',
            style: TextStyle(color: AppColors.secondaryLight.withValues(alpha: 0.75),
                fontSize: 7)),
          const SizedBox(height: 8),
          // Stats row
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _ProfileStat(value: '3.8', label: 'GPA'),
            _ProfileStat(value: '24', label: 'Subjects'),
            _ProfileStat(value: '14🔥', label: 'Streak'),
          ]),
          const SizedBox(height: 8),
          // Settings tiles
          for (final item in ['Settings', 'Notifications', 'About'])
            Container(
              margin: const EdgeInsets.only(bottom: 3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
              child: Row(children: [
                Text(item,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 7)),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.35), size: 8),
              ]),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Micro widgets used inside phone screens
// ─────────────────────────────────────────────────────────────────────────────

class _MiniRing extends StatelessWidget {
  const _MiniRing(
      {required this.value, required this.color, required this.label});
  final double value;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36, height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(36, 36),
            painter: _RingPainter(value: value, color: color)),
          Text(label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.90),
                fontSize: 7, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    canvas.drawCircle(c, r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2, value * 2 * math.pi, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.value != value;
}

class _MiniCard extends StatelessWidget {
  const _MiniCard(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.30))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65),
                fontSize: 6))),
          const SizedBox(width: 4),
          Text(value,
            style: TextStyle(color: color, fontSize: 6,
                fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        constraints: const BoxConstraints(maxWidth: 110),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.secondary.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: isUser
              ? null
              : Border.all(color: AppColors.tertiary.withValues(alpha: 0.30))),
        child: Text(text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: isUser ? 0.95 : 0.80),
            fontSize: 6.5)),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
          style: TextStyle(color: AppColors.tertiary,
              fontSize: 10, fontWeight: FontWeight.w800)),
        Text(label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.55),
              fontSize: 6)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background ambient glow painter
// ─────────────────────────────────────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter({required this.pulseT});
  final double pulseT;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _g(canvas, Offset(w * 0.50, h * 0.22), w * (0.38 + pulseT * 0.04),
        AppColors.secondary.withValues(alpha: 0.14 + pulseT * 0.04));
    _g(canvas, Offset(w * 0.82, h * 0.72), w * 0.22,
        AppColors.tertiary.withValues(alpha: 0.10));
    _g(canvas, Offset(w * 0.12, h * 0.55), w * 0.18,
        AppColors.secondaryLight.withValues(alpha: 0.07));
  }

  void _g(Canvas canvas, Offset c, double r, Color color) =>
      canvas.drawCircle(c, r,
          Paint()
            ..shader = RadialGradient(
                    colors: [color, color.withValues(alpha: 0.0)])
                .createShader(Rect.fromCircle(center: c, radius: r)));

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.pulseT != pulseT;
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI widgets (feature badge, app store badge, quote, CTA)
// ─────────────────────────────────────────────────────────────────────────────

/// Small premium glass pill badge — replaces the old stat cards.
/// Positioned in the lower half of the illustration so it doesn't obscure
/// the founder's face.
class _FeatureBadge extends StatelessWidget {
  const _FeatureBadge({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.secondaryLight.withValues(alpha: 0.32),
                width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.22),
                  blurRadius: 10),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppStoreBadge extends StatelessWidget {
  const _AppStoreBadge();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.tertiary.withValues(alpha: 0.25),
              AppColors.secondary.withValues(alpha: 0.20),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.50), width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: AppColors.tertiary.withValues(alpha: 0.28),
                  blurRadius: 12),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: AppColors.tertiary, size: 14),
              const SizedBox(width: 5),
              Text('4.9  App of the Year',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.14), width: 1.0),
          ),
          child: Row(
            children: [
              // ── Circular profile photo ─────────────────────────────
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.60),
                    width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.35),
                      blurRadius: 10),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/founder/sanawar_mockup2.jpeg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // ── Name + role block ──────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SANAWAR ALI',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6)),
                    Text('Flutter Developer',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondaryLight.withValues(alpha: 0.80),
                        fontSize: 10)),
                    Text('Founder • StudyFlow AI',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.60),
                        fontSize: 10)),
                  ],
                ),
              ),

              // ── Verified badge ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.tertiary.withValues(alpha: 0.28),
                    AppColors.secondary.withValues(alpha: 0.22),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.tertiary.withValues(alpha: 0.50))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded,
                        color: AppColors.tertiary, size: 10),
                    const SizedBox(width: 3),
                    Text('Verified',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.w700,
                        fontSize: 9)),
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

class _GetStartedButton extends StatefulWidget {
  const _GetStartedButton({this.onPressed});
  final VoidCallback? onPressed;
  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sc;

  @override
  void initState() {
    super.initState();
    _sc = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
        reverseDuration: const Duration(milliseconds: 150),
        lowerBound: 0.95, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _sc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (widget.onPressed != null) _sc.reverse(); },
      onTapUp: (_) => _sc.forward(),
      onTapCancel: () => _sc.forward(),
      child: AnimatedBuilder(
        animation: _sc,
        builder: (_, child) => Transform.scale(scale: _sc.value, child: child),
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: [AppColors.secondary, AppColors.tertiary]),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.50),
                blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(28),
              splashColor: Colors.white.withValues(alpha: 0.18),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Get Started',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
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
