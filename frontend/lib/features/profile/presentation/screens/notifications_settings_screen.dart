import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  final Map<String, bool> _settings = {
    'class_reminders': true,
    'assignment_due': true,
    'quiz_reminders': true,
    'ai_suggestions': false,
    'weekly_summary': true,
    'study_streak': true,
    'push_all': true,
  };

  static const _items = [
    ('Class Reminders', 'Get notified 15 min before class',
        Icons.class_outlined, 'class_reminders', Color(0xFF4A90E2)),
    ('Assignment Due', 'Deadline reminders for assignments',
        Icons.assignment_outlined, 'assignment_due', Color(0xFFFFA726)),
    ('Quiz Reminders', 'Upcoming quiz notifications',
        Icons.quiz_outlined, 'quiz_reminders', Color(0xFFAB47BC)),
    ('AI Suggestions', 'Smart study tips from AI',
        Icons.auto_awesome_outlined, 'ai_suggestions', Color(0xFF50E3C2)),
    ('Weekly Summary', 'Sunday progress digest',
        Icons.summarize_outlined, 'weekly_summary', Color(0xFF4CAF50)),
    ('Study Streak', 'Streak break warnings',
        Icons.local_fire_department_outlined, 'study_streak',
        Color(0xFFEF5350)),
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
        title: Text('Notifications',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Master toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedXl,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: SwitchListTile(
              value: _settings['push_all']!,
              onChanged: (v) => setState(() {
                _settings['push_all'] = v;
              }),
              title: Text('All Notifications',
                  style: AppTypography.titleSmall
                      .copyWith(color: AppColors.onSurface)),
              subtitle: Text('Master toggle for all notifications',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onSurfaceVariant)),
              activeColor: AppColors.primary,
              secondary: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedMd,
                ),
                child: const Icon(Icons.notifications_rounded,
                    color: AppColors.primary, size: 18),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (_settings['push_all']!)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedXl,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: _items.map((item) {
                  final (label, sub, icon, key, color) = item;
                  return SwitchListTile(
                    value: _settings[key]!,
                    onChanged: (v) =>
                        setState(() => _settings[key] = v),
                    title: Text(label,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.onSurface)),
                    subtitle: Text(sub,
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant)),
                    activeColor: AppColors.primary,
                    secondary: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    dense: true,
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
