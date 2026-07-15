import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/config.dart';
import 'package:untitled/screens/dashboard/semester_detailing/semester_detail_screen.dart';
import '../../dialogs/semester_dialog.dart';
import '../../dialogs/delete_dialog.dart';
import '../../notesApiServices/Semesters/hive_semester_service.dart';
import '../../notesApiServices/Semesters/semester_api_service.dart';
import '../../notesApiServices/Semesters/semester_local.dart';
import '../../notesApiServices/Semesters/semester_sync_manager.dart';
import '../../notesApiServices/Semesters/semester_sync_service.dart';
import '../widgets/semester_card.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late final SemesterApiService apiService;
  late final SemesterSyncManager syncManager;
  late final SemesterSyncService syncService;
  late final String userId;


  List<SemesterLocal> semesters = [];
  bool loading = true;
  static const String API_BASE_IP = AppConfig.baseUrl; // <- update this when your IP changes

//  final String userId = 'testUser123';

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // User not logged in — handle accordingly (maybe redirect to login)
      print("❌ No user logged in!");
      // Optionally navigate to login
      return;
    }
    userId = currentUser.uid; // ✅ Use UID from Firebase
    apiService = SemesterApiService(baseUrl: '$API_BASE_IP/semesters');
    syncManager = SemesterSyncManager(api: apiService);
    syncService = SemesterSyncService(syncManager: syncManager);

    _loadSemesters();
  }

  Future<void> _hydrateFromServerIfNeeded() async {
    final local = HiveSemesterService.getAll().where((s) => !s.isDeleted).toList();
    if (local.isNotEmpty) return;

    try {
      print("🌍 Hive empty — fetching semesters from server...");
      final remote = await apiService.fetchSemesters(userId);

      for (var sem in remote) {
        final localSem = SemesterLocal(
          localId: "local_${DateTime.now().millisecondsSinceEpoch}_${sem.id}",
          serverId: sem.id,
          userId: sem.userId,
          title: sem.title,
          createdAt: sem.createdAt,
          isSynced: true,
          isDeleted: false,
        );
        await HiveSemesterService.addOrUpdate(localSem);
      }

      print("✅ Hydration complete.");
    } catch (e) {
      print("❌ Failed to hydrate semesters: $e");
    }
  }

  Future<void> _loadSemesters() async {
    setState(() => loading = true);

    // Load from local first
    semesters = HiveSemesterService.getAll().where((s) => !s.isDeleted).toList();
    setState(() => loading = false);

    // Hydrate from server if needed
    await _hydrateFromServerIfNeeded();

    // Refresh local UI after possible hydration
    semesters = HiveSemesterService.getAll().where((s) => !s.isDeleted).toList();
    setState(() {});

    // Sync unsynced local changes
    await _syncSemesters();
  }

  Future<void> _syncSemesters() async {
    try {
      await syncManager.syncAll();
    } catch (e) {
      print("⚠️ Semester sync failed: $e");
    }

    if (!mounted) return;
    semesters = HiveSemesterService.getAll().where((s) => !s.isDeleted).toList();
    setState(() {});
  }

  void _showSemesterDialog({SemesterLocal? semester}) {
    showDialog(
      context: context,
      builder: (_) => SemesterDialog(
        oldTitle: semester?.title,
        onSubmit: (text) async {
          final now = DateTime.now();

          if (semester == null) {
            final newSem = SemesterLocal(
              localId: 'local_${now.millisecondsSinceEpoch}',
              userId: userId,
              title: text,
              createdAt: now,
              isSynced: false,
            );
            await HiveSemesterService.addOrUpdate(newSem);
          } else {
            semester.title = text;
            semester.isSynced = false;
            await HiveSemesterService.addOrUpdate(semester);
          }

          if (!mounted) return;
          semesters = HiveSemesterService.getAll().where((s) => !s.isDeleted).toList();
          setState(() {});

          await _syncSemesters();

          if (!mounted) return;
          semesters = HiveSemesterService.getAll().where((s) => !s.isDeleted).toList();
          setState(() {});
        },
      ),
    );
  }

  void _confirmDelete(SemesterLocal semester) {
    showDialog(
      context: context,
      builder: (_) => DeleteSemesterDialog(
        title: semester.title,
        onDelete: () async {
          semester.isDeleted = true;
          semester.isSynced = false;
          await HiveSemesterService.addOrUpdate(semester);

          if (!mounted) return;
          semesters = HiveSemesterService.getAll().where((s) => !s.isDeleted).toList();
          setState(() {});

          await _syncSemesters();

          if (!mounted) return;
          semesters = HiveSemesterService.getAll().where((s) => !s.isDeleted).toList();
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0F2C),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'My Semesters',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3 / 2,
              ),
              itemCount: semesters.length + 1,
              itemBuilder: (context, index) {
                if (index < semesters.length) {
                  final sem = semesters[index];
                  return SemesterCard(
                    key: ValueKey(sem.localId),
                    title: sem.title,
                    onDelete: () => _confirmDelete(sem),
                    onEdit: () => _showSemesterDialog(semester: sem),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SemesterDetailScreen(
                            semesterTitle: sem.title,
                            semesterLocalId: sem.localId,
                            semesterServerId: sem.serverId,
                          ),
                        ),
                      );
                    },
                    color: Colors.white,
                    textColor: Colors.black87,
                    shadow: true,
                  );
                } else {
                  return GestureDetector(
                    onTap: () => _showSemesterDialog(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.white, size: 36),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
