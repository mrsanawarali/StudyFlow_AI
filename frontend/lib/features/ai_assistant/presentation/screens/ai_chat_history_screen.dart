import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/ai_assistant/data/mock_ai_data.dart';

/// Phase 2K — Chat History Screen.
class AIChatHistoryScreen extends StatelessWidget {
  const AIChatHistoryScreen({super.key});

  String _fmt(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    if (d.inDays == 1) return 'Yesterday';
    return '${d.inDays}d ago';
  }

  IconData _iconForType(String type) => switch (type) {
        'summarize' => Icons.summarize_outlined,
        'explain' => Icons.lightbulb_outline_rounded,
        'quiz' => Icons.quiz_outlined,
        'flashcards' => Icons.style_outlined,
        'planner' => Icons.calendar_today_outlined,
        _ => Icons.chat_bubble_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final sessions = MockAIData.chatHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Chat History',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.secondary),
            onPressed: () => context.push(RoutePaths.aiChatNew),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: sessions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.roundedXl,
                      ),
                      child: const Icon(Icons.chat_outlined,
                          color: AppColors.tertiary, size: 36),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('No chats yet',
                        style: AppTypography.titleSmall.copyWith(
                            color: AppColors.onSurface)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Start a conversation with StudyFlow AI.',
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: sessions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (ctx, i) {
                final s = sessions[i];
                return GestureDetector(
                  onTap: () => context.push(
                    RoutePaths.aiChatPath(s.id),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.roundedXl,
                      border:
                          Border.all(color: AppColors.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: s.color.withValues(alpha: 0.12),
                            borderRadius: AppRadius.roundedLg,
                          ),
                          child: Icon(_iconForType(s.actionType),
                              color: s.color, size: 24),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(s.title,
                                        style: AppTypography.titleSmall
                                            .copyWith(
                                                color: AppColors.onSurface),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  Text(_fmt(s.updatedAt),
                                      style: AppTypography.labelSmall
                                          .copyWith(
                                              color: AppColors
                                                  .onSurfaceVariant)),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(s.lastMessage,
                                  style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.onSurfaceVariant),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: s.color
                                          .withValues(alpha: 0.10),
                                      borderRadius: AppRadius.roundedFull,
                                    ),
                                    child: Text(
                                      s.actionType[0].toUpperCase() +
                                          s.actionType.substring(1),
                                      style: AppTypography.labelSmall
                                          .copyWith(
                                              color: s.color,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text('${s.messageCount} messages',
                                      style: AppTypography.labelSmall
                                          .copyWith(
                                              color: AppColors
                                                  .onSurfaceVariant,
                                              fontSize: 9)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.outline, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.aiChatNew),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text('New Chat',
            style: AppTypography.labelLarge
                .copyWith(color: AppColors.onPrimary)),
      ),
    );
  }
}
