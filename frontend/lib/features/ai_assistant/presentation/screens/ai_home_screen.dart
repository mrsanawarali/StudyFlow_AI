import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/ai_assistant/data/mock_ai_data.dart';

/// Phase 2K — AI Assistant Home Screen.
class AIHomeScreen extends StatefulWidget {
  const AIHomeScreen({super.key});

  @override
  State<AIHomeScreen> createState() => _AIHomeScreenState();
}

class _AIHomeScreenState extends State<AIHomeScreen>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeCtrl,
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────
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
              title: Text('AI Study Assistant',
                  style: AppTypography.titleLarge
                      .copyWith(color: AppColors.onSurface)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history_rounded,
                      color: AppColors.secondary),
                  onPressed: () =>
                      context.push(RoutePaths.aiChatHistory),
                  tooltip: 'Chat History',
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero banner
                    _HeroBanner(),
                    const SizedBox(height: AppSpacing.xl),

                    // Quick prompt input
                    _QuickPrompt(),
                    const SizedBox(height: AppSpacing.xl),

                    // AI Actions grid
                    Text('What would you like to do?',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: AppSpacing.md),
                    _ActionsGrid(),
                    const SizedBox(height: AppSpacing.xl),

                    // Suggested topics
                    Text('Suggested Topics',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: AppSpacing.md),
                    _SuggestedTopics(),
                    const SizedBox(height: AppSpacing.xl),

                    // Recent chats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Chats',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            )),
                        TextButton(
                          onPressed: () =>
                              context.push(RoutePaths.aiChatHistory),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero),
                          child: Text('See all',
                              style: AppTypography.labelMedium
                                  .copyWith(color: AppColors.secondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...MockAIData.chatHistory.take(3).map((s) =>
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm),
                          child: _RecentChatTile(
                            session: s,
                            onTap: () => context.push(
                              RoutePaths.aiChatPath(s.id),
                            ),
                          ),
                        )),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
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
            color: AppColors.primary.withValues(alpha: 0.28),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.20),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text('Powered by StudyFlow AI',
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Study Smarter\nwith AI',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    )),
                const SizedBox(height: AppSpacing.xs),
                Text(
                    'Summarize, explain, quiz and plan —\nall in one place.',
                    style: AppTypography.bodySmall.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.75),
                        height: 1.5)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.18),
              borderRadius: AppRadius.roundedXl,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.tertiary, size: 40),
          ),
        ],
      ),
    );
  }
}

// ── Quick Prompt ──────────────────────────────────────────────────────────────
class _QuickPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RoutePaths.aiChatNew),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedFull,
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_outlined,
                color: AppColors.tertiary, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text('Ask me anything...',
                  style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant)),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.roundedFull,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.onPrimary, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Actions Grid ──────────────────────────────────────────────────────────────
class _ActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = MockAIData.actions;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.9,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemBuilder: (ctx, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: () => context.push(
            RoutePaths.aiChatNew,
            extra: {'actionId': a.id, 'prompt': a.prompt},
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedXl,
              border: Border.all(
                  color: a.color.withValues(alpha: 0.30)),
              boxShadow: [
                BoxShadow(
                  color: a.color.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: a.color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: Icon(a.icon, color: a.color, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title,
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(a.subtitle,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Suggested Topics ──────────────────────────────────────────────────────────
class _SuggestedTopics extends StatelessWidget {
  static const _topics = [
    'AVL Trees', 'SQL Joins', 'Deadlocks', 'TCP/IP',
    'SDLC Models', 'Paging', 'Graph BFS/DFS', 'Normalisation',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: _topics.map((t) {
        return GestureDetector(
          onTap: () => context.push(
            RoutePaths.aiChatNew,
            extra: {'prompt': 'Explain $t in simple terms.'},
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedFull,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_outlined,
                    color: AppColors.tertiary, size: 13),
                const SizedBox(width: 4),
                Text(t,
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurface)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Recent Chat Tile ──────────────────────────────────────────────────────────
class _RecentChatTile extends StatelessWidget {
  const _RecentChatTile({required this.session, required this.onTap});
  final MockChatSession session;
  final VoidCallback onTap;

  String _fmt(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          leading: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: session.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.roundedLg,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                color: session.color, size: 20),
          ),
          title: Text(session.title,
              style: AppTypography.titleSmall.copyWith(
                  color: AppColors.onSurface),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(session.lastMessage,
              style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(_fmt(session.updatedAt),
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }
}
