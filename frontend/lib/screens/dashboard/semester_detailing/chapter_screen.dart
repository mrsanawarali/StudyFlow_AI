// lib/screens/chapter_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../clippers/top_pattern_clipper.dart';
import '../../../notesApiServices/Chapters/chapter_api_service.dart';
import '../../../notesApiServices/Chapters/chapter_local.dart';
import '../../../notesApiServices/Chapters/chapter_sync_manager.dart';
import '../../../notesApiServices/Chapters/hive_chapter_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/config.dart';
import 'note_detail_screen.dart';

class ChapterScreen extends StatefulWidget {
  final String subjectTitle;
  final String subjectLocalId;
  final String? subjectServerId;
  final String semesterLocalId;

  const ChapterScreen({
    super.key,
    required this.subjectTitle,
    required this.subjectLocalId,
    this.subjectServerId,
    required this.semesterLocalId,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  List<ChapterLocal> chapters = [];
  bool loading = true;
  static const String API_BASE_IP = AppConfig.baseUrl; // <- update this when your IP changes


  late final ChapterApiService apiService;
  late final ChapterSyncManager syncManager;
  late final String userId;


  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle user not logged in (optional: redirect to login)
      print("❌ No user logged in!");
      return;
    }
    userId = currentUser.uid; // ✅ Use Firebase UID
    apiService = ChapterApiService(baseUrl: '$API_BASE_IP/chapters');
    syncManager = ChapterSyncManager(api: apiService);
    _loadChapters();
  }

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  Future<void> _hydrateChaptersFromServerIfNeeded() async {
    // Get local chapters for this subject
    final localChapters = HiveChapterService.getAll()
        .where((c) => !c.isDeleted && c.subjectLocalId == widget.subjectLocalId)
        .toList();

    // If we already have local data, no need to hydrate
    if (localChapters.isNotEmpty) return;

    // If the subject hasn't been synced to server yet, can't fetch
    if (widget.subjectServerId == null) return;

    try {
      print("🌍 Hive empty — fetching chapters from server...");
      final remoteChapters = await apiService.fetchChapters(widget.subjectServerId!);

      for (var ch in remoteChapters) {
        final localChapter = ChapterLocal(
          localId: "local_${DateTime.now().millisecondsSinceEpoch}_${ch.id}",
          serverId: ch.id,
          semesterLocalId: widget.semesterLocalId,
          semesterId: ch.semesterId,
          subjectLocalId: widget.subjectLocalId,
          subjectId: ch.subjectId,
          title: ch.title,
          createdAt: ch.createdAt,
          isSynced: true,
          isDeleted: false,
        );

        await HiveChapterService.addOrUpdate(localChapter);
      }

      print("✅ Chapters hydration complete.");
    } catch (e) {
      print("❌ Failed to hydrate chapters: $e");
    }
  }


  Future<void> _loadChapters() async {
    safeSetState(() => loading = true);

    // Load local chapters first
    chapters = _getFilteredChapters();
    safeSetState(() => loading = false);

    // Hydrate from server if local is empty
    await _hydrateChaptersFromServerIfNeeded();

    // Reload after hydration
    chapters = _getFilteredChapters();
    safeSetState(() {});

    // Sync with backend
    try {
      await syncManager.syncAll();
    } catch (_) {}

    // Reload after sync
    chapters = _getFilteredChapters();
    safeSetState(() {});
  }


  List<ChapterLocal> _getFilteredChapters() {
    return HiveChapterService.getAll()
        .where((c) => !c.isDeleted && c.subjectLocalId == widget.subjectLocalId)
        .toList();
  }

  void _showChapterDialog({ChapterLocal? chapter}) {
    final isEditing = chapter != null;
    final titleController = TextEditingController(text: chapter?.title ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Chapter Title',
                      labelStyle: GoogleFonts.poppins(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF1A1F3F),
                      prefixIcon: const Icon(Icons.menu_book, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white70),
                          label: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) return;

                            final now = DateTime.now();

                            if (isEditing) {
                              chapter!
                                ..title = titleController.text.trim()
                                ..isSynced = false
                                ..subjectId ??= widget.subjectServerId;

                              await HiveChapterService.addOrUpdate(chapter);
                            } else {
                              final newChapter = ChapterLocal(
                                localId: 'local_${now.millisecondsSinceEpoch}',
                                semesterLocalId: widget.semesterLocalId,
                                subjectLocalId: widget.subjectLocalId,
                                subjectId: widget.subjectServerId,
                                title: titleController.text.trim(),
                                createdAt: now,
                                isSynced: false,
                                isDeleted: false,
                              );

                              await HiveChapterService.addOrUpdate(newChapter);
                            }

                            chapters = _getFilteredChapters();
                            safeSetState(() {});

                            try {
                              await syncManager.syncAll();
                            } catch (_) {}

                            chapters = _getFilteredChapters();
                            safeSetState(() {});

                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text(isEditing ? 'Save' : 'Add', style: GoogleFonts.poppins(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: TopPatternClipper(),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      isEditing ? 'Edit Chapter' : 'Add Chapter',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _deleteChapter(ChapterLocal chapter) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F2C),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 25,),
                  Text(
                    'Delete "${chapter.title}"?',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            chapter..isDeleted = true..isSynced = false;
                            await HiveChapterService.addOrUpdate(chapter);

                            chapters = _getFilteredChapters();
                            safeSetState(() {});

                            try {
                              await syncManager.syncAll();
                            } catch (_) {}

                            chapters = _getFilteredChapters();
                            safeSetState(() {});

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: -20,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: TopPatternClipper(),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Delete Chapter',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _circularIcon(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F3F),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: color),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  void _openNotes(ChapterLocal chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailScreen(
          chapterLocalId: chapter.localId,
          chapterId: chapter.serverId,
          semesterId: chapter.semesterId,
          subjectId: chapter.subjectId,
          chapterTitle: chapter.title,
          subjectLocalId: chapter.subjectLocalId,
          semesterLocalId: chapter.semesterLocalId,
          currentUserId: userId, // Replace with your actual user ID
        ),
      ),
    ).then((_) {
      // Reload chapters after returning from notes, in case of any changes
      chapters = _getFilteredChapters();
      safeSetState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(widget.subjectTitle, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF1B2660),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : chapters.isEmpty
          ? Center(child: Text("No chapters added yet.", style: GoogleFonts.poppins(color: Colors.white70)))
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Card(
            color: const Color(0xFF1A1F3F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.white70),
              title: Text(chapter.title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _circularIcon(Icons.edit, Colors.blueAccent, () => _showChapterDialog(chapter: chapter)),
                  _circularIcon(Icons.delete, Colors.red, () => _deleteChapter(chapter)),
                ],
              ),
              onTap: () => _openNotes(chapter),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChapterDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

