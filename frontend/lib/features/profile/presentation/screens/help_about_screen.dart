import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    ('How do I add a new note?',
        'Tap the + button on the Notes screen or use the Quick Actions from the Home tab.'),
    ('Can I use StudyFlow AI offline?',
        'Yes! Notes, assignments and quizzes are available offline. AI features require an internet connection.'),
    ('How do I sync my data?',
        'Your data syncs automatically when connected. You can also manually trigger sync from Settings → Storage & Data.'),
    ('How accurate is the AI?',
        'The AI is powered by a large language model and provides helpful study assistance. Always verify important information.'),
    ('How do I calculate my CGPA?',
        'Go to the Calculator tab and select the CGPA section. Your semester records are automatically displayed.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Help & Support',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Contact banner
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary,
                    Color(0xFF2868B2)],
              ),
              borderRadius: AppRadius.roundedXl,
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need help?',
                          style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                          'Contact our support team or browse the FAQs below.',
                          style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70)),
                    ],
                  ),
                ),
                const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 40),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('Frequently Asked Questions',
              style: AppTypography.titleMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),

          ..._faqs.map((faq) => _FAQItem(q: faq.$1, a: faq.$2)),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  const _FAQItem({required this.q, required this.a});
  final String q;
  final String a;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: ExpansionTile(
        title: Text(widget.q,
            style: AppTypography.titleSmall
                .copyWith(color: AppColors.onSurface)),
        trailing: Icon(
          _expanded ? Icons.remove_rounded : Icons.add_rounded,
          color: AppColors.secondary, size: 18,
        ),
        onExpansionChanged: (v) => setState(() => _expanded = v),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: Text(widget.a,
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant, height: 1.6)),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('About StudyFlow AI',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // App logo + info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: AppRadius.roundedXl,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.15),
                      borderRadius: AppRadius.roundedXl,
                    ),
                    child: const Icon(Icons.auto_stories_rounded,
                        color: AppColors.onPrimary, size: 44),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('StudyFlow AI',
                      style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w800)),
                  Text('Version 1.0.0 — Phase 2L',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onPrimary
                              .withValues(alpha: 0.70))),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                      'Transform Your Study Journey',
                      style: AppTypography.titleSmall.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedXl,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About',
                      style: AppTypography.titleSmall.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                      'StudyFlow AI is a premium student productivity platform '
                      'designed to help university students organise, study, and excel. '
                      'Built with Flutter, powered by AI, and inspired by the best '
                      'productivity tools — Notion, Linear, Google Classroom and more.',
                      style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurface, height: 1.6)),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Features',
                      style: AppTypography.titleSmall.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  ...['📚 Semester & Subject Management',
                    '📝 Smart Notes with AI Actions',
                    '📋 Assignment & Quiz Tracking',
                    '🤖 AI Study Assistant',
                    '📊 Grade Calculator & GPA Tracker',
                    '📅 Timetable & Attendance Tracker',
                  ].map((f) => Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppSpacing.xs),
                    child: Text(f,
                        style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurface,
                            height: 1.5)),
                  )),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Made with ❤️ for students everywhere',
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
