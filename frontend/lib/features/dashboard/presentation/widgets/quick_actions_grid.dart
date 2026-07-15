import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// 2 × 2 quick action grid.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const List<_QAction> _actions = [
    _QAction(
      icon: Icons.note_add_outlined,
      label: 'Add Note',
      color: Color(0xFF4A90E2),
    ),
    _QAction(
      icon: Icons.assignment_outlined,
      label: 'Add Assignment',
      color: Color(0xFFFFA726),
    ),
    _QAction(
      icon: Icons.event_outlined,
      label: 'Add Schedule',
      color: Color(0xFF50E3C2),
    ),
    _QAction(
      icon: Icons.document_scanner_outlined,
      label: 'Scan Notes',
      color: Color(0xFFAB47BC),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _actions
            .map((a) => Expanded(child: _QuickActionItem(action: a)))
            .toList(),
      ),
    );
  }
}

class _QAction {
  const _QAction({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.action});

  final _QAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.roundedXl,
                border: Border.all(
                  color: action.color.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(action.icon, color: action.color, size: 22),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              action.label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurface,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
