import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_typography.dart';

/// Standardised scaffold for StudyFlow AI screens.
///
/// Usage:
/// ```dart
/// AppScaffold(
///   title: 'My Notes',
///   body: NotesList(),
///   actions: [IconButtonCustom(icon: Icons.search, ...)],
/// )
/// ```
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.leading,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  /// When [true], shows the back arrow in the app bar.
  /// Defaults to [false] — use [Navigator.canPop] for auto-detection.
  final bool showBackButton;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        leading: leading ??
            (showBackButton || canPop
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  )
                : null),
        automaticallyImplyLeading: showBackButton || canPop,
        title: Text(
          title,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onPrimary,
          ),
        ),
        actions: actions,
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
