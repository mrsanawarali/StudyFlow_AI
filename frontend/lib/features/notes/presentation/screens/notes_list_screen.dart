import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/notes/data/mock_notes_data.dart';
import '../widgets/note_card.dart';

/// Phase 2F — Notes List Screen with search, filter, grid/list toggle.
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen>
    with SingleTickerProviderStateMixin {
  // View state
  NoteViewMode _viewMode = NoteViewMode.grid;
  String _searchQuery = '';
  String? _selectedSubject; // null = all
  bool _showFavoritesOnly = false;

  // Filtered list
  List<MockNote> get _filtered {
    var list = _searchQuery.isNotEmpty
        ? MockNotesData.search(_searchQuery)
        : List<MockNote>.from(MockNotesData.allNotes);

    if (_selectedSubject != null) {
      list = list.where((n) => n.subject == _selectedSubject).toList();
    }
    if (_showFavoritesOnly) {
      list = list.where((n) => n.isFavorite).toList();
    }
    // Pinned first
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..forward();

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Notes',
              style: AppTypography.titleLarge
                  .copyWith(color: AppColors.onSurface),
            ),
            actions: [
              // Grid/List toggle
              IconButton(
                icon: Icon(
                  _viewMode == NoteViewMode.grid
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  color: AppColors.secondary,
                ),
                onPressed: () => setState(() {
                  _viewMode = _viewMode == NoteViewMode.grid
                      ? NoteViewMode.list
                      : NoteViewMode.grid;
                }),
              ),
              // Create new note
              IconButton(
                icon: const Icon(Icons.add_rounded,
                    color: AppColors.secondary),
                onPressed: () =>
                    context.push(RoutePaths.noteCreate),
              ),
            ],
          ),
        ],
        body: FadeTransition(
          opacity: _fadeCtrl,
          child: CustomScrollView(
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: _SearchBar(
                    onChanged: (v) =>
                        setState(() => _searchQuery = v),
                  ),
                ),
              ),

              // Subject filter chips
              SliverToBoxAdapter(
                child: _SubjectFilter(
                  subjects: MockNotesData.allSubjects,
                  selected: _selectedSubject,
                  onSelected: (s) =>
                      setState(() => _selectedSubject = s),
                ),
              ),

              // Favorites toggle + count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${notes.length} note${notes.length == 1 ? '' : 's'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() =>
                            _showFavoritesOnly = !_showFavoritesOnly),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _showFavoritesOnly
                                ? AppColors.secondary.withValues(alpha: 0.12)
                                : AppColors.surfaceVariant,
                            borderRadius: AppRadius.roundedFull,
                            border: _showFavoritesOnly
                                ? Border.all(
                                    color: AppColors.secondary.withValues(alpha: 0.30))
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showFavoritesOnly
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 13,
                                color: _showFavoritesOnly
                                    ? AppColors.secondary
                                    : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Saved',
                                style: AppTypography.labelSmall.copyWith(
                                  color: _showFavoritesOnly
                                      ? AppColors.secondary
                                      : AppColors.onSurfaceVariant,
                                  fontWeight: _showFavoritesOnly
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Notes content
              notes.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary
                                      .withValues(alpha: 0.10),
                                  borderRadius: AppRadius.roundedXl,
                                ),
                                child: const Icon(
                                    Icons.description_outlined,
                                    color: AppColors.secondary,
                                    size: 32),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No results for "$_searchQuery"'
                                    : 'No notes yet',
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Tap + to add your first note',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _viewMode == NoteViewMode.grid
                      ? SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: AppSpacing.sm,
                              mainAxisSpacing: AppSpacing.sm,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => NoteCard(
                                note: notes[i],
                                onTap: () => context.push(
                                  RoutePaths.noteDetailPath(notes[i].id),
                                ),
                                isGrid: true,
                              ),
                              childCount: notes.length,
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => NoteCard(
                                note: notes[i],
                                onTap: () => context.push(
                                  RoutePaths.noteDetailPath(notes[i].id),
                                ),
                                isGrid: false,
                              ),
                              childCount: notes.length,
                            ),
                          ),
                        ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.noteCreate),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
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
          const Icon(Icons.search_rounded,
              color: AppColors.onSurfaceVariant, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _ctrl,
              onChanged: widget.onChanged,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Search notes, subjects, tags...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                widget.onChanged('');
              },
              child: const Icon(Icons.close_rounded,
                  color: AppColors.onSurfaceVariant, size: 16),
            ),
        ],
      ),
    );
  }
}

// ── Subject filter chips ──────────────────────────────────────────────────────

class _SubjectFilter extends StatelessWidget {
  const _SubjectFilter({
    required this.subjects,
    required this.selected,
    required this.onSelected,
  });

  final List<String> subjects;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: subjects.length + 1,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.xs),
        itemBuilder: (ctx, i) {
          final isAll = i == 0;
          final label = isAll ? 'All' : subjects[i - 1];
          final isSelected = isAll ? selected == null : selected == label;

          return GestureDetector(
            onTap: () => onSelected(isAll ? null : label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: AppRadius.roundedFull,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                ),
              ),
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
