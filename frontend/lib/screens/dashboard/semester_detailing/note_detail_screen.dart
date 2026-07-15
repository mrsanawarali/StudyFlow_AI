import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../notesApiServices/Notes/hive_note_service.dart';
import '../../../notesApiServices/Notes/note_api_service.dart';
import '../../../notesApiServices/Notes/note_local.dart';
import '../../../notesApiServices/Notes/note_sync_service.dart';
import '../../widgets/file_card.dart';
import '../../widgets/note_card.dart';

class NoteDetailScreen extends StatefulWidget {
  final String chapterLocalId;
  final String? chapterId;
  final String? semesterId;
  final String? subjectId;
  final String semesterLocalId;
  final String subjectLocalId;
  final String chapterTitle;
  final String currentUserId;

  const NoteDetailScreen({
    super.key,
    required this.chapterLocalId,
    required this.chapterTitle,
    required this.currentUserId,
    required this.chapterId,
    required this.semesterId,
    required this.subjectId,
    required this.semesterLocalId,
    required this.subjectLocalId,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final NoteSyncService noteSyncService;
  bool _loading = true;

  /// Keep track of already hydrated chapters
  static final Set<String> _hydratedChapters = {};

  @override
  void initState() {
    super.initState();
    noteSyncService = NoteSyncService();
    _loadNotes();
  }

  // ---------------------------
  // ADD TEXT NOTE
  void _addTextNote() async {
    try {
      final newNote = NoteLocal(
        localId: const Uuid().v4(),
        chapterLocalId: widget.chapterLocalId,
        chapterId: widget.chapterId,
        semesterId: widget.semesterId,
        subjectId: widget.subjectId,
        semesterLocalId: widget.semesterLocalId,
        subjectLocalId: widget.subjectLocalId,
        userId: widget.currentUserId,
        type: "text",
        title: '',       // optional: empty by default
        content: '',     // optional: empty by default
        createdAt: DateTime.now(),
        isDirty: true,
        isSyncing: false,
      );

      // Save locally in Hive
      final box = Hive.box<NoteLocal>('noteBox');
      await box.put(newNote.localId, newNote);
      print("📝 Added text note locally: ${newNote.localId}");

      // Sync immediately all dirty notes
      await noteSyncService.syncNow();

      if (!mounted) return;
      setState(() {});

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add text note: $e')),
      );
    }
  }

  // ---------------------------
  // ADD FILE OR IMAGE NOTE
  Future<void> _addFileNote({bool imagesOnly = false}) async {
    try {
      List<NoteLocal> newNotes = [];

      if (imagesOnly && !kIsWeb) {
        final images = await ImagePicker().pickMultiImage(imageQuality: 75);
        if (images != null) {
          for (final img in images) {
            try {
              final bytes = await img.readAsBytes();
              if (bytes.isEmpty) continue;

              newNotes.add(NoteLocal(
                localId: const Uuid().v4(),
                chapterLocalId: widget.chapterLocalId,
                chapterId: widget.chapterId,
                semesterId: widget.semesterId,
                subjectId: widget.subjectId,
                semesterLocalId: widget.semesterLocalId,
                subjectLocalId: widget.subjectLocalId,
                userId: widget.currentUserId,
                type: "image",
                fileName: img.name,
                fileBytes: bytes,
                fileUrl: img.path,
                createdAt: DateTime.now(),
                isDirty: true,
                isSyncing: false,
              ));
            } catch (_) {
              continue;
            }
          }
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: imagesOnly ? FileType.image : FileType.any,
          withData: true,
        );
        if (result != null) {
          for (final file in result.files) {
            if (file.bytes == null && file.path == null) continue;

            newNotes.add(NoteLocal(
              localId: const Uuid().v4(),
              chapterLocalId: widget.chapterLocalId,
              chapterId: widget.chapterId,
              semesterId: widget.semesterId,
              subjectId: widget.subjectId,
              semesterLocalId: widget.semesterLocalId,
              subjectLocalId: widget.subjectLocalId,
              userId: widget.currentUserId,
              type: imagesOnly ? "image" : "file",
              fileName: file.name,
              fileBytes: file.bytes,
              fileUrl: !kIsWeb ? file.path : null,
              createdAt: DateTime.now(),
              isDirty: true,
              isSyncing: false,
            ));
          }
        }
      }

      final box = Hive.box<NoteLocal>('noteBox');
      for (var note in newNotes) {
        await box.put(note.localId, note);
        print("📦 Added file note: ${note.localId} (${note.fileName})");

        // Sync each file/image immediately
        await noteSyncService.syncSingle(note);
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files/images: $e')),
      );
    }
  }

  // ---------------------------
  // PASTE SCREENSHOT
  Future<void> _pasteScreenshot() async {
    try {
      final bytes = await Pasteboard.image;
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image found in clipboard')),
        );
        return;
      }

      final note = NoteLocal(
        localId: const Uuid().v4(),
        chapterLocalId: widget.chapterLocalId,
        chapterId: widget.chapterId,
        semesterId: widget.semesterId,
        subjectId: widget.subjectId,
        semesterLocalId: widget.semesterLocalId,
        subjectLocalId: widget.subjectLocalId,
        userId: widget.currentUserId,
        type: "image",
        fileName: 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
        fileBytes: bytes,
        createdAt: DateTime.now(),
        isDirty: true,
        isSyncing: false,
      );

      final box = Hive.box<NoteLocal>('noteBox');
      await box.put(note.localId, note);
      print("📸 Pasted screenshot note: ${note.localId}");

      // Sync immediately
      await noteSyncService.syncSingle(note);

      if (!mounted) return;
      setState(() {});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screenshot pasted!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Clipboard error: $e')),
      );
    }
  }

  // ---------------------------
  // DELETE NOTE
  void _deleteNote(NoteLocal note) async {
    try {
      // Mark note as deleted locally
      note.isDeleted = true;
      note.isDirty = true;
      note.isSyncing = false;

      final box = Hive.box<NoteLocal>('noteBox');
      await box.put(note.localId, note); // persist deletion

      print("🗑️ Note marked deleted locally: ${note.localId}");

      // Sync immediately all dirty notes
      await noteSyncService.syncNow();

      if (!mounted) return;
      setState(() {});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note: $e')),
      );
    }
  }

  // ---------------------------
  // LOAD NOTES
  Future<void> _loadNotes() async {
    if (_hydratedChapters.contains(widget.chapterLocalId)) {
      setState(() => _loading = false);
      return;
    }

    final box = HiveNoteService.getNoteBox();
    final localNotes = box.values
        .where((n) => n.chapterLocalId == widget.chapterLocalId && !n.isDeleted)
        .toList();

    if (localNotes.isEmpty && widget.chapterId != null) {
      final remoteNotes = await NoteApiService.getNotes(widget.chapterId!);

      for (var rn in remoteNotes) {
        if (rn.serverId == null) continue;
        if (box.values.any((x) => x.serverId == rn.serverId)) continue;

        final note = NoteLocal(
          localId: "local_${DateTime.now().millisecondsSinceEpoch}_${rn.serverId}",
          serverId: rn.serverId,
          chapterLocalId: widget.chapterLocalId,
          chapterId: rn.chapterId,
          semesterId: rn.semesterId,
          subjectId: rn.subjectId,
          semesterLocalId: widget.semesterLocalId,
          subjectLocalId: widget.subjectLocalId,
          userId: rn.userId,
          type: rn.type,
          fileName: rn.fileName,
          fileUrl: rn.type == "file" ? rn.fileUrl : rn.imageUrl,
          fileBytes: null,
          createdAt: rn.createdAt,
          isDirty: false,
          isDeleted: false,
          isSyncing: false,
        );

        await HiveNoteService.addOrUpdate(note);
      }
    }

    _hydratedChapters.add(widget.chapterLocalId);
    setState(() => _loading = false);
  }

  // ---------------------------
  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: Text(widget.chapterTitle),
        backgroundColor: const Color(0xFF1A1F3F),
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveNoteService.getNoteBox().listenable(),
        builder: (context, Box<NoteLocal> box, _) {
          final notes = box.values
              .where((n) => n.chapterLocalId == widget.chapterLocalId && !n.isDeleted)
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notes.isEmpty) {
            return const Center(
              child: Text('No notes yet.', style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              if (note.type == "text") {
                return NoteCard(
                  key: ValueKey(note.localId),
                  note: note,
                  onDelete: () => _deleteNote(note),
                );
              } else {
                return FileCard(
                  note: note,
                  onDelete: () => _deleteNote(note),
                  onRename: () {
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        overlayColor: Colors.black.withOpacity(0.3),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.note_add),
            label: 'Add Text Note',
            onTap: _addTextNote,
          ),
          SpeedDialChild(
            child: const Icon(Icons.attach_file),
            label: 'Add File Note',
            onTap: () => _addFileNote(imagesOnly: false),
          ),
          SpeedDialChild(
            child: const Icon(Icons.image),
            label: 'Add Image Note',
            onTap: () => _addFileNote(imagesOnly: true),
          ),
          SpeedDialChild(
            child: const Icon(Icons.paste),
            label: 'Paste Screenshot',
            onTap: _pasteScreenshot,
          ),
        ],
      ),
    );
  }
}





// // note_detail_screen.dart
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
// import 'package:pasteboard/pasteboard.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import '../../../notesApiServices/Notes/hive_note_service.dart';
// import '../../../notesApiServices/Notes/note_api_service.dart';
// import '../../../notesApiServices/Notes/note_local.dart';
// import '../../../notesApiServices/Notes/note_sync_service.dart';
// import '../../widgets/file_card.dart';
// import '../../widgets/note_card.dart';
//
//
// class NoteDetailScreen extends StatefulWidget {
//   final String chapterLocalId;
//   final String? chapterId;
//   final String? semesterId;
//   final String? subjectId;
//   final String semesterLocalId;
//   final String subjectLocalId;
//   final String chapterTitle;
//   final String currentUserId;
//
//
//   const NoteDetailScreen({
//     super.key,
//     required this.chapterLocalId,
//     required this.chapterTitle,
//     required this.currentUserId,
//     required this.chapterId,
//     required this.semesterId,
//     required this.subjectId,
//     required this.semesterLocalId,
//     required this.subjectLocalId,
//
//   });
//
//   @override
//   State<NoteDetailScreen> createState() => _NoteDetailScreenState();
// }
//
// class _NoteDetailScreenState extends State<NoteDetailScreen> {
//   late final NoteSyncService noteSyncService;
//   bool _loading = true;
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Initialize NoteSyncService first
//     noteSyncService = NoteSyncService();
//     _loadNotes();
//   }
//
//   // ---------------------------
// // ---------------------------
// // ADD TEXT NOTE
// // ---------------------------
//   void _addTextNote() async {
//     try {
//       final newNote = NoteLocal(
//         localId: const Uuid().v4(),
//         chapterLocalId: widget.chapterLocalId,
//         chapterId: widget.chapterId,
//         semesterId: widget.semesterId,
//         subjectId: widget.subjectId,
//         semesterLocalId: widget.semesterLocalId,
//         subjectLocalId: widget.subjectLocalId,
//         userId: widget.currentUserId,
//         type: "text",
//         createdAt: DateTime.now(),
//         isDirty: true,
//         isSyncing: false, // Let sync manager handle syncing
//       );
//
//       // Save to Hive safely
//       final box = Hive.box<NoteLocal>('noteBox');
//       if (!box.containsKey(newNote.localId)) {
//         await box.put(newNote.localId, newNote);
//         print("📝 Added text note: ${newNote.localId}");
//       }
//
//       await noteSyncService.syncNow(); // safe sync
//       setState(() {});
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add text note: $e')),
//       );
//     }
//   }
//
//
// // ---------------------------
// // ADD FILE OR IMAGE NOTE
// // ---------------------------
//   Future<void> _addFileNote({bool imagesOnly = false}) async {
//     try {
//       List<NoteLocal> newNotes = [];
//
//       // Pick images on mobile only
//       if (imagesOnly && !kIsWeb) {
//         final images = await ImagePicker().pickMultiImage(
//           imageQuality: 75, // compress images to 75% quality
//         );
//         if (images != null) {
//           for (final img in images) {
//             try {
//               final bytes = await img.readAsBytes();
//               if (bytes.isEmpty) continue; // skip empty files
//
//               final note = NoteLocal(
//                 localId: const Uuid().v4(),
//                 chapterLocalId: widget.chapterLocalId,
//                 chapterId: widget.chapterId,
//                 semesterId: widget.semesterId,
//                 subjectId: widget.subjectId,
//                 semesterLocalId: widget.semesterLocalId,
//                 subjectLocalId: widget.subjectLocalId,
//                 userId: widget.currentUserId,
//                 type: "image",
//                 fileName: img.name,
//                 fileBytes: bytes,
//                 fileUrl: img.path,
//                 createdAt: DateTime.now(),
//                 isDirty: true,
//                 isSyncing: false,
//               );
//               newNotes.add(note);
//             } catch (_) {
//               continue; // skip problematic image
//             }
//           }
//         }
//       } else {
//         // Pick files/images using FilePicker
//         final result = await FilePicker.platform.pickFiles(
//           allowMultiple: true,
//           type: imagesOnly ? FileType.image : FileType.any,
//           withData: true,
//         );
//
//         if (result != null) {
//           for (final file in result.files) {
//             if (file.bytes == null && file.path == null) continue; // skip invalid files
//
//             final note = NoteLocal(
//               localId: const Uuid().v4(),
//               chapterLocalId: widget.chapterLocalId,
//               chapterId: widget.chapterId,
//               semesterId: widget.semesterId,
//               subjectId: widget.subjectId,
//               semesterLocalId: widget.semesterLocalId,
//               subjectLocalId: widget.subjectLocalId,
//               userId: widget.currentUserId,
//               type: imagesOnly ? "image" : "file",
//               fileName: file.name,
//               fileBytes: file.bytes, // may be null on mobile for large files
//               fileUrl: !kIsWeb ? file.path : null,
//               createdAt: DateTime.now(),
//               isDirty: true,
//               isSyncing: false,
//             );
//             newNotes.add(note);
//           }
//         }
//       }
//
//       final box = Hive.box<NoteLocal>('noteBox');
//
//       for (var note in newNotes) {
//         if (!box.containsKey(note.localId)) {
//           await box.put(note.localId, note);
//           print("📦 Added file note: ${note.localId} (${note.fileName})");
//         }
//       }
//
//       // Trigger sync safely
//       await noteSyncService.syncNow();
//       setState(() {});
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking files/images: $e')),
//       );
//     }
//   }
//
//
// // ---------------------------
// // PASTE SCREENSHOT
// // ---------------------------
//   Future<void> _pasteScreenshot() async {
//     try {
//       final bytes = await Pasteboard.image;
//       if (bytes == null || bytes.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No image found in clipboard')),
//         );
//         return;
//       }
//
//       final note = NoteLocal(
//         localId: const Uuid().v4(),
//         chapterLocalId: widget.chapterLocalId,
//         chapterId: widget.chapterId,
//         semesterId: widget.semesterId,
//         subjectId: widget.subjectId,
//         semesterLocalId: widget.semesterLocalId,
//         subjectLocalId: widget.subjectLocalId,
//         userId: widget.currentUserId,
//         type: "image",
//         fileName: 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
//         fileBytes: bytes,
//         createdAt: DateTime.now(),
//         isDirty: true,
//         isSyncing: false,
//       );
//
//       final box = Hive.box<NoteLocal>('noteBox');
//       if (!box.containsKey(note.localId)) {
//         await box.put(note.localId, note);
//         print("📸 Pasted screenshot note: ${note.localId}");
//       }
//
//       await noteSyncService.syncNow();
//       setState(() {});
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Screenshot pasted!')),
//       );
//
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Clipboard error: $e')),
//       );
//     }
//   }
//
//   // ---------------------------
//   // DELETE NOTE (WORKS NOW)
//   // ---------------------------
// // DELETE NOTE (WORKS WITH SYNC)
//   void _deleteNote(NoteLocal note) async {
//     try {
//       // Mark the note as deleted locally
//       note.isDeleted = true;
//       note.isDirty = true;
//       note.isSyncing = false;
//
//       final box = Hive.box<NoteLocal>('noteBox');
//       await box.put(note.localId, note); // persist deletion flag
//
//       // Trigger sync via NoteSyncService
//       await noteSyncService.syncNow();
//
//       setState(() {});
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Note marked for deletion.')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete note: $e')),
//       );
//     }
//   }
//
//   Future<void> _loadNotes() async {
//     setState(() => _loading = true);
//
//     final box = HiveNoteService.getNoteBox();
//
//     // -----------------------------
//     // Skip hydration if any local notes exist for this chapter
//     // -----------------------------
//     final localNotes = box.values
//         .where((n) => n.chapterLocalId == widget.chapterLocalId && !n.isDeleted)
//         .toList();
//
//     if (localNotes.isNotEmpty) {
//       setState(() => _loading = false);
//       return;
//     }
//
//     print("🌍 Hydrating notes from server for chapter: ${widget.chapterId}");
//
//     try {
//       // -----------------------------
//       // Fetch notes from server
//       // -----------------------------
//       final remoteNotes = await NoteApiService.getNotes(widget.chapterId!);
//       print("📥 Server returned ${remoteNotes.length} notes");
//
//       for (var rn in remoteNotes) {
//         final serverId = rn.serverId;
//         if (serverId == null) continue; // skip invalid notes
//
//         // Avoid duplicates
//         final alreadyExists = box.values.any((x) => x.serverId == serverId);
//         if (alreadyExists) continue;
//
//         final hydrated = NoteLocal(
//           localId: "local_${DateTime.now().millisecondsSinceEpoch}_$serverId",
//           serverId: serverId,
//           type: rn.type,
//           title: rn.title,
//           content: rn.content,
//           userId: rn.userId,
//           chapterId: rn.chapterId,
//           chapterLocalId: widget.chapterLocalId,
//           semesterId: rn.semesterId,
//           subjectId: rn.subjectId,
//           semesterLocalId: widget.semesterLocalId,
//           subjectLocalId: widget.subjectLocalId,
//           fileName: rn.fileName,
//           fileUrl: rn.type == "file" ? rn.fileUrl : rn.imageUrl, // <- pick the right field
//           fileBytes: null,
//           createdAt: rn.createdAt,
//           isDirty: false,
//           isDeleted: false,
//         );
//
//         await HiveNoteService.addOrUpdate(hydrated);
//         print("   ➕ Hydrated note: ${hydrated.serverId}");
//
//       }
//
//
//       print("✅ Notes hydration complete.");
//     } catch (e) {
//       print("❌ Hydration failed: $e");
//     }
//
//     setState(() => _loading = false);
//
//     // -----------------------------
//     // Optional: sync after hydration
//     // -----------------------------
//     await noteSyncService.syncNow();
//   }
//
//
//
//   // ---------------------------
//   // UI
//   // ---------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0F2C),
//       appBar: AppBar(
//         title: Text(widget.chapterTitle),
//         backgroundColor: const Color(0xFF1A1F3F),
//         foregroundColor: Colors.white,
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: HiveNoteService.getNoteBox().listenable(),
//         builder: (context, Box<NoteLocal> box, _) {
//           final notes = box.values
//               .where((n) => n.chapterLocalId == widget.chapterLocalId && !n.isDeleted)
//               .toList()
//             ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // FCFS ORDER
//
//           if (notes.isEmpty) {
//             return const Center(
//               child: Text('No notes yet.', style: TextStyle(color: Colors.white)),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: notes.length,
//             itemBuilder: (context, index) {
//               final note = notes[index];
//
//               if (note.type == "text") {
//                 return NoteCard(
//                   key: ValueKey(note.localId),
//                   note: note,
//                   onDelete: () => _deleteNote(note),
//                 );
//               } else {
//                 return FileCard(
//                   note: note,
//                   onDelete: () => _deleteNote(note),
//                   onRename: () => setState(() {}),
//                 );
//               }
//             },
//           );
//         },
//       ),
//
//       floatingActionButton: SpeedDial(
//         icon: Icons.add,
//         activeIcon: Icons.close,
//         backgroundColor: Colors.blueAccent,
//         foregroundColor: Colors.white,
//         overlayColor: Colors.black.withOpacity(0.3),
//         children: [
//           SpeedDialChild(
//             child: const Icon(Icons.note_add),
//             label: 'Add Text Note',
//             onTap: _addTextNote,
//           ),
//           SpeedDialChild(
//             child: const Icon(Icons.attach_file),
//             label: 'Add File Note',
//             onTap: () => _addFileNote(imagesOnly: false),
//           ),
//           SpeedDialChild(
//             child: const Icon(Icons.image),
//             label: 'Add Image Note',
//             onTap: () => _addFileNote(imagesOnly: true),
//           ),
//           SpeedDialChild(
//             child: const Icon(Icons.paste),
//             label: 'Paste Screenshot',
//             onTap: _pasteScreenshot,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
