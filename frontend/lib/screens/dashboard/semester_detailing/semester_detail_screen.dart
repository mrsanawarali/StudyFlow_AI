import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../clippers/top_pattern_clipper.dart';
import '../../../notesApiServices/Subjects/hive_subject_service.dart';
import '../../../notesApiServices/Subjects/subject_api_service.dart';
import '../../../notesApiServices/Subjects/subject_local.dart';
import '../../../notesApiServices/Subjects/subject_sync_manager.dart';
import 'chapter_screen.dart';
import 'package:untitled/config.dart';

class SemesterDetailScreen extends StatefulWidget {
  final String semesterTitle;
  final String semesterLocalId;
  final String? semesterServerId;

  const SemesterDetailScreen({
    super.key,
    required this.semesterTitle,
    required this.semesterLocalId,
    this.semesterServerId,
  });

  @override
  State<SemesterDetailScreen> createState() => _SemesterDetailScreenState();
}

class _SemesterDetailScreenState extends State<SemesterDetailScreen> {
  List<SubjectLocal> subjects = [];
  bool loading = true;
  static const String API_BASE_IP = AppConfig.baseUrl; // <- update this when your IP changes

  late final SubjectApiService apiService;
  late final SubjectSyncManager syncManager;

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    apiService = SubjectApiService(baseUrl: '$API_BASE_IP/subjects');
    syncManager = SubjectSyncManager(api: apiService);
    _loadSubjects();
  }

  List<SubjectLocal> _getLocalSubjects() {
    return HiveSubjectService.getAll()
        .where((s) => !s.isDeleted && s.semesterLocalId == widget.semesterLocalId)
        .toList();
  }

  Future<void> _hydrateSubjectsFromServerIfNeeded() async {
    final localSubjects = _getLocalSubjects();
    if (localSubjects.isNotEmpty || widget.semesterServerId == null) return;

    try {
      print("🌍 Hive empty — fetching subjects from server...");
      final remoteSubjects = await apiService.fetchSubjects(widget.semesterServerId!);

      for (var sub in remoteSubjects) {
        final localSub = SubjectLocal(
          localId: "local_${DateTime.now().millisecondsSinceEpoch}_${sub.id}",
          serverId: sub.id,
          semesterLocalId: widget.semesterLocalId,
          semesterId: sub.semesterId,
          title: sub.title,
          courseCode: sub.courseCode,
          instructor: sub.instructor,
          createdAt: sub.createdAt,
          isSynced: true,
          isDeleted: false,
        );
        await HiveSubjectService.addOrUpdate(localSub);
      }
      print("✅ Subjects hydration complete.");
    } catch (e) {
      print("❌ Failed to hydrate subjects: $e");
    }
  }

  Future<void> _loadSubjects() async {
    safeSetState(() => loading = true);

    subjects = _getLocalSubjects();
    safeSetState(() => loading = false);

    await _hydrateSubjectsFromServerIfNeeded();

    subjects = _getLocalSubjects();
    safeSetState(() {});

    try {
      await syncManager.syncAll();
    } catch (_) {}

    subjects = _getLocalSubjects();
    safeSetState(() {});
  }

  void _showSubjectDialog({SubjectLocal? subject}) {
    final isEditing = subject != null;
    final nameController = TextEditingController(text: subject?.title ?? '');
    final codeController = TextEditingController(text: subject?.courseCode ?? '');
    final instructorController = TextEditingController(text: subject?.instructor ?? '');

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
                  const SizedBox(height: 25),
                  _field(Icons.school, 'Subject Name', nameController),
                  const SizedBox(height: 12),
                  _field(Icons.code, 'Course Code', codeController),
                  const SizedBox(height: 12),
                  _field(Icons.person, 'Instructor', instructorController),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          label: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Save', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) return;
                            final now = DateTime.now();

                            if (isEditing) {
                              subject!
                                ..title = nameController.text.trim()
                                ..courseCode = codeController.text.trim()
                                ..instructor = instructorController.text.trim()
                                ..isSynced = false
                                ..semesterId ??= widget.semesterServerId;
                              await HiveSubjectService.addOrUpdate(subject);
                            } else {
                              final newSubject = SubjectLocal(
                                localId: 'local_${now.millisecondsSinceEpoch}',
                                semesterLocalId: widget.semesterLocalId,
                                semesterId: widget.semesterServerId,
                                title: nameController.text.trim(),
                                courseCode: codeController.text.trim(),
                                instructor: instructorController.text.trim(),
                                createdAt: now,
                                isSynced: false,
                                isDeleted: false,
                              );
                              await HiveSubjectService.addOrUpdate(newSubject);
                            }

                            subjects = _getLocalSubjects();
                            safeSetState(() {});

                            try {
                              await syncManager.syncAll();
                            } catch (_) {}

                            subjects = _getLocalSubjects();
                            safeSetState(() {});

                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  )
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
                      isEditing ? 'Edit Subject' : 'Add Subject',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(IconData icon, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1F3F),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  void _deleteSubject(SubjectLocal subject) {
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
                  const SizedBox(height: 25),
                  Text(
                    'Delete "${subject.title}"?',
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
                          ),
                          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white70)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
                          onPressed: () async {
                            subject
                              ..isDeleted = true
                              ..isSynced = false;
                            await HiveSubjectService.addOrUpdate(subject);

                            subjects = _getLocalSubjects();
                            safeSetState(() {});

                            try {
                              await syncManager.syncAll();
                            } catch (_) {}

                            subjects = _getLocalSubjects();
                            safeSetState(() {});

                            Navigator.pop(context);
                          },
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
                      'Delete Subject',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
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

  void _openChapters(SubjectLocal subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChapterScreen(
          subjectTitle: subject.title,
          subjectLocalId: subject.localId,
          semesterLocalId: widget.semesterLocalId,
          subjectServerId: subject.serverId,
        ),
      ),
    );
  }

  Widget _circularIcon(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(color: const Color(0xFF0A0F2C), shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, size: 18, color: color),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: Text(widget.semesterTitle, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF1B2660),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
          ? Center(
        child: Text(
          "No subjects added yet.",
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final s = subjects[index];
          return Card(
            color: const Color(0xFF1A1F3F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.school, color: Colors.white70),
              title: Text(
                s.title,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (s.courseCode.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.assignment, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(s.courseCode, style: GoogleFonts.poppins(color: Colors.white70)),
                      ],
                    ),
                  if (s.instructor.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(s.instructor, style: GoogleFonts.poppins(color: Colors.white70)),
                      ],
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _circularIcon(Icons.edit, Colors.blueAccent, () => _showSubjectDialog(subject: s)),
                  _circularIcon(Icons.delete, Colors.red, () => _deleteSubject(s)),
                ],
              ),
              onTap: () => _openChapters(s),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubjectDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
