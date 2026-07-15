import 'hive_note_service.dart';
import 'note_api_service.dart';
import 'note_local.dart';

class NoteSyncManager {
  bool _isSyncing = false;

  // -------------------------
  // MAIN SYNC ALL
  // -------------------------
  Future<void> syncAll() async {
    if (_isSyncing) {
      print("⚠️ Sync already in progress...");
      return;
    }

    _isSyncing = true;

    try {
      // 1️⃣ Sync deletions first
      final deletedNotes = HiveNoteService.getDeletedNotes();
      for (var note in deletedNotes) {
        await _deleteSingleNoteSafe(note);
      }

      // 2️⃣ Sync new notes
      final unsyncedNotes = HiveNoteService.getUnsyncedNotes();
      for (var note in unsyncedNotes) {
        await _syncSingleNoteSafe(note);
      }

      // 3️⃣ Sync updated notes
      final updatedNotes = HiveNoteService.getUpdatedNotes();
      for (var note in updatedNotes) {
        await _updateSingleNoteSafe(note);
      }
    } finally {
      _isSyncing = false;
      print("🕒 Sync completed.");
    }
  }

  // -------------------------
  // NEW NOTE SYNC
  // -------------------------
  Future<void> _syncSingleNoteSafe(NoteLocal note) async {
    if (note.isSynced || note.isDeleted || note.isSyncing) return;

    note.isSyncing = true;
    await HiveNoteService.saveNote(note);

    try {
      final ids = await NoteApiService.addNotes([note]);

      if (ids.isEmpty) throw Exception("Server returned no ID");

      // Only mark as synced if API call succeeded
      note.serverId = ids.first;
      note.isSynced = true;
      note.isDirty = false;

      print("✅ Synced new note ${note.localId}");
    } catch (e) {
      // Keep dirty for retry
      note.isDirty = true;
      note.isSynced = false;
      print("❌ Failed to sync new note ${note.localId}: $e");
    } finally {
      note.isSyncing = false;
      await HiveNoteService.saveNote(note);
    }
  }

  // -------------------------
  // UPDATE EXISTING NOTE
  // -------------------------
  Future<void> _updateSingleNoteSafe(NoteLocal note) async {
    if (note.isDeleted || note.isSyncing) return;

    // Treat as new note if never synced
    if (note.serverId == null) {
      return _syncSingleNoteSafe(note);
    }

    note.isSyncing = true;
    await HiveNoteService.saveNote(note);

    try {
      await NoteApiService.updateNoteTitleOrContent(note);

      // Only mark as clean if API call succeeded
      note.isDirty = false;
      note.isSynced = true;
      print("✅ Updated note ${note.localId}");
    } catch (e) {
      // Keep dirty for retry
      note.isDirty = true;
      note.isSynced = false;
      print("❌ Failed to update note ${note.localId}: $e");
    } finally {
      note.isSyncing = false;
      await HiveNoteService.saveNote(note);
    }
  }

  // -------------------------
  // DELETE NOTE SYNC
  // -------------------------
  Future<void> _deleteSingleNoteSafe(NoteLocal note) async {
    if (note.isSyncing) return;

    note.isSyncing = true;
    await HiveNoteService.saveNote(note);

    try {
      if (note.serverId != null) {
        // Attempt server delete
        await NoteApiService.deleteNote(note);
        print("🗑 Deleted on server: ${note.localId}");
      } else {
        print("ℹ️ Note ${note.localId} never synced, only local delete needed.");
      }

      // Delete locally if server deletion successful or never synced
      await HiveNoteService.deleteNote(note);
      print("🗑 Removed locally: ${note.localId}");
    } catch (e) {
      // Keep note flagged for retry
      note.isDeleted = true;
      note.isDirty = true;
      print("⚠️ Failed to delete ${note.localId}: $e");
    } finally {
      note.isSyncing = false;
      await HiveNoteService.saveNote(note);
    }
  }

  // -------------------------
  // IMMEDIATE SYNC FOR SINGLE NOTE
  // -------------------------
  Future<void> syncSingleNoteImmediately(NoteLocal note) async {
    if (note.isDeleted || note.isSyncing) return;

    note.isSyncing = true;
    await HiveNoteService.saveNote(note);

    try {
      if (note.isSynced == true && note.serverId != null && note.isDirty == true) {
        // Update existing note
        await NoteApiService.updateNoteTitleOrContent(note);
        // Only mark as synced if no exception
        note.isDirty = false;
        note.isSynced = true;
        print("✅ Immediate update succeeded for ${note.localId}");
      } else if (!note.isSynced || note.serverId == null) {
        // Add new note
        final ids = await NoteApiService.addNotes([note]);
        if (ids.isEmpty) throw Exception("No server ID returned");

        note.serverId = ids.first;
        note.isSynced = true;
        note.isDirty = false;
        print("✅ Immediate sync succeeded for ${note.localId}");
      }
    } catch (e) {
      // Failed → keep dirty and unsynced for retry
      note.isDirty = true;
      note.isSynced = false;
      print("⚠️ Immediate sync failed for ${note.localId}: $e");
    } finally {
      note.isSyncing = false;
      await HiveNoteService.saveNote(note);
    }
  }
}



// import 'hive_note_service.dart';
// import 'note_api_service.dart';
// import 'note_local.dart';
//
// class NoteSyncManager {
//   bool _isSyncing = false;
//
//   Future<void> syncAll() async {
//     if (_isSyncing) return;
//     _isSyncing = true;
//
//     try {
//       final unsynced = HiveNoteService.getUnsyncedNotes();
//       for (var note in unsynced) {
//         await _syncSingleNoteSafe(note);
//       }
//     } finally {
//       _isSyncing = false;
//     }
//   }
//
//   Future<void> _syncSingleNoteSafe(note) async {
//     // Validate
//     if (note.isSynced || note.isDeleted || note.isSyncing) return;
//
//     note.isSyncing = true;
//     await HiveNoteService.saveNote(note);
//
//     try {
//       final ids = await NoteApiService.addNotes([note]);
//       if (ids.isNotEmpty) {
//         note.serverId = ids.first;
//         note.isSynced = true;
//         note.isDirty = false;
//       }
//     } catch (_) {
//       // fail silently or mark as unsynced
//     } finally {
//       note.isSyncing = false;
//       await HiveNoteService.saveNote(note);
//     }
//   }
//
//   Future<void> syncSingleNoteImmediately(NoteLocal note) async {
//     if (note.isSynced || note.isDeleted || note.isSyncing) return;
//
//     note.isSyncing = true;
//     await HiveNoteService.saveNote(note);
//
//     try {
//       final ids = await NoteApiService.addNotes([note]);
//       if (ids.isNotEmpty) {
//         note.serverId = ids.first;
//         note.isSynced = true;
//         note.isDirty = false;
//       }
//     } catch (_) {
//       // ignore or mark as unsynced
//     } finally {
//       note.isSyncing = false;
//       await HiveNoteService.saveNote(note);
//     }
//   }
//
//
// }
//
//
//
//
//
// // import 'dart:math';
// // import 'package:hive/hive.dart';
// // import 'package:uuid/uuid.dart';
// //
// // import 'hive_note_service.dart';
// // import 'note_api_service.dart';
// // import 'note_local.dart';
// //
// // class NoteSyncManager {
// //   bool _isSyncing = false;
// //
// //   Future<void> syncAll() async {
// //     if (_isSyncing) return;
// //     _isSyncing = true;
// //     try {
// //       await _syncUnsynced();
// //       await _syncUpdated();
// //       await _syncDeleted();
// //     } catch (e) {
// //       print("⚠️ Note sync failed: $e");
// //     } finally {
// //       _isSyncing = false;
// //     }
// //   }
// //
// //   Future<void> _syncUnsynced() async {
// //     final unsynced = HiveNoteService.getUnsyncedNotes()
// //         .where((n) => !n.isSyncing)
// //         .toList();
// //
// //     await Future.wait(unsynced.map((note) => _trySyncNoteWithRetry(note)));
// //   }
// //
// //   Future<void> _syncUpdated() async {
// //     final updated = HiveNoteService.getUpdatedNotes()
// //         .where((n) => !n.isSyncing)
// //         .toList();
// //
// //     for (var note in updated) {
// //       if (note.isSynced && note.serverId != null) {
// //         await _tryUpdateNoteWithRetry(note);
// //       } else {
// //         await _trySyncNoteWithRetry(note);
// //       }
// //     }
// //   }
// //
// //   Future<void> _syncDeleted() async {
// //     final deleted = HiveNoteService.getDeletedNotes()
// //         .where((n) => !n.isSyncing)
// //         .toList();
// //
// //     await Future.wait(deleted.map((note) => _tryDeleteNoteWithRetry(note)));
// //   }
// //
// //   // Future<void> _trySyncNoteWithRetry(NoteLocal note, {int maxRetries = 3}) async {
// //   //   note.isSyncing = true;
// //   //   await HiveNoteService.saveNote(note);
// //   //
// //   //   int attempt = 0;
// //   //   while (attempt < maxRetries) {
// //   //     try {
// //   //       final ids = await NoteApiService.addNotes([note]);
// //   //       if (ids.isNotEmpty) {
// //   //         // Update note properly
// //   //         note.serverId = ids.first;
// //   //         note.isSynced = true;
// //   //         note.isDirty = false;
// //   //         note.isSyncing = false;
// //   //
// //   //         await HiveNoteService.saveNote(note);
// //   //         print("✅ Synced note: ${note.localId} (serverId=${note.serverId})");
// //   //         return;
// //   //       } else {
// //   //         throw Exception("No server ID returned");
// //   //       }
// //   //     } catch (e) {
// //   //       attempt++;
// //   //       print("⚠️ Retry #$attempt failed for note ${note.localId}: $e");
// //   //       await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
// //   //     }
// //   //   }
// //   //
// //   //   note.isSyncing = false;
// //   //   await HiveNoteService.saveNote(note);
// //   //   print("❌ Failed to sync note after $maxRetries attempts: ${note.localId}");
// //   // }
// //   Future<void> _trySyncNoteWithRetry(NoteLocal note, {int maxRetries = 3}) async {
// //     // --- 1. Validate note ---
// //     bool isValid(String? s) => s != null && s.isNotEmpty;
// //
// //     if (!isValid(note.semesterId) ||
// //         !isValid(note.subjectId) ||
// //         !isValid(note.chapterId) ||
// //         !isValid(note.userId) ||
// //         !isValid(note.type)) {
// //       print("❌ Invalid note ${note.localId}, skipping sync.");
// //       note.isSyncing = false;
// //       await HiveNoteService.saveNote(note);
// //       return;
// //     }
// //
// //     // For file notes, validate presence of file
// //     if ((note.type == "image" || note.type == "file") &&
// //         ((note.fileBytes == null || note.fileBytes!.isEmpty) &&
// //             (note.fileUrl == null || note.fileUrl!.isEmpty))) {
// //       print("❌ File note ${note.localId} missing fileBytes and fileUrl, skipping sync.");
// //       note.isSyncing = false;
// //       await HiveNoteService.saveNote(note);
// //       return;
// //     }
// //
// //     note.isSyncing = true;
// //     await HiveNoteService.saveNote(note);
// //
// //     int attempt = 0;
// //     while (attempt < maxRetries) {
// //       try {
// //         final ids = await NoteApiService.addNotes([note]);
// //
// //         if (ids.isNotEmpty && ids.first.isNotEmpty) {
// //           note.serverId = ids.first;
// //           note.isSynced = true;
// //           note.isDirty = false;
// //           note.isSyncing = false;
// //           await HiveNoteService.saveNote(note);
// //           print("✅ Synced note: ${note.localId} (serverId=${note.serverId})");
// //           return;
// //         } else {
// //           throw Exception("No server ID returned");
// //         }
// //       } catch (e) {
// //         attempt++;
// //         print("⚠️ Retry #$attempt failed for note ${note.localId}: $e");
// //         await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
// //       }
// //     }
// //
// //     // Mark note as failed (not syncing, not synced)
// //     note.isSyncing = false;
// //     await HiveNoteService.saveNote(note);
// //     print("❌ Failed to sync note after $maxRetries attempts: ${note.localId}");
// //   }
// //
// //
// //   Future<void> _tryUpdateNoteWithRetry(NoteLocal note, {int maxRetries = 3}) async {
// //     if (note.serverId == null) {
// //       await _trySyncNoteWithRetry(note);
// //       return;
// //     }
// //
// //     note.isSyncing = true;
// //     await HiveNoteService.saveNote(note);
// //
// //     int attempt = 0;
// //     while (attempt < maxRetries) {
// //       try {
// //         await NoteApiService.updateNoteTitleOrContent(note);
// //         note.isDirty = false;
// //         note.isSyncing = false;
// //         await HiveNoteService.saveNote(note);
// //         print("✅ Updated note synced: ${note.localId}");
// //         return;
// //       } catch (e) {
// //         attempt++;
// //         print("⚠️ Retry #$attempt failed to update note ${note.localId}: $e");
// //         await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
// //       }
// //     }
// //
// //     note.isSyncing = false;
// //     await HiveNoteService.saveNote(note);
// //     print("❌ Failed to update note after $maxRetries attempts: ${note.localId}");
// //   }
// //
// //
// //   Future<void> _tryDeleteNoteWithRetry(NoteLocal note, {int maxRetries = 3}) async {
// //     note.isSyncing = true;
// //     await HiveNoteService.saveNote(note);
// //
// //     int attempt = 0;
// //     while (attempt < maxRetries) {
// //       try {
// //         // Delete from server if it exists there
// //         if (note.serverId != null) {
// //           await NoteApiService.deleteNote(note);
// //           print("🗑 Deleted note on server: ${note.localId}");
// //         }
// //
// //         // Always delete locally after server deletion attempt
// //         await HiveNoteService.deleteNote(note);
// //         print("🗑 Removed note locally: ${note.localId}");
// //         return;
// //       } catch (e) {
// //         attempt++;
// //         print("⚠️ Retry #$attempt failed to delete note ${note.localId}: $e");
// //         await Future.delayed(Duration(seconds: pow(2, attempt).toInt()));
// //       }
// //     }
// //
// //     // If max retries reached, just mark it not syncing so it can retry later
// //     note.isSyncing = false;
// //     await HiveNoteService.saveNote(note);
// //     print("❌ Failed to delete note after $maxRetries attempts: ${note.localId}");
// //   }
// //
// //   // HYDRATE HIVE FROM SERVER
// //   // Future<void> hydrateFromServer(String chapterId, String chapterLocalId) async {
// //   //   final box = HiveNoteService.getNoteBox();
// //   //
// //   //   final serverNotes = await NoteApiService.getNotes(chapterId);
// //   //
// //   //   for (var sn in serverNotes) {
// //   //     // Create proper NoteLocal from server JSON
// //   //     final note = NoteLocal(
// //   //       localId: sn.localId?.isNotEmpty == true ? sn.localId : const Uuid().v4(),
// //   //       serverId: sn.serverId,
// //   //       chapterId: sn.chapterId,
// //   //       chapterLocalId: chapterLocalId,
// //   //       semesterId: sn.semesterId,
// //   //       subjectId: sn.subjectId,
// //   //       semesterLocalId: sn.semesterLocalId,
// //   //       subjectLocalId: sn.subjectLocalId,
// //   //       userId: sn.userId,
// //   //
// //   //       type: sn.type,
// //   //       title: sn.title,
// //   //       content: sn.content,
// //   //
// //   //       fileName: sn.fileName,
// //   //       fileUrl: sn.fileUrl,      // 👈 SUPER IMPORTANT
// //   //       fileBytes: null,          // 👈 Do NOT download file here
// //   //
// //   //       createdAt: sn.createdAt,
// //   //       isSynced: true,
// //   //       isDirty: false,
// //   //       isDeleted: false,
// //   //       isSyncing: false,
// //   //     );
// //   //
// //   //     // Guarantee unique localId to avoid overwrite
// //   //     if (box.containsKey(note.localId)) {
// //   //       note.localId = const Uuid().v4();
// //   //     }
// //   //
// //   //     await box.put(note.localId, note);
// //   //   }
// //   //
// //   //   print("✅ Hydrated ${serverNotes.length} notes from server for chapter $chapterId");
// //   // }
// //
// //   Future<void> hydrateFromServer(String chapterId, String chapterLocalId) async {
// //     final serverNotes = await NoteApiService.getNotes(chapterId); // your API call
// //
// //     final box = Hive.box<NoteLocal>('noteBox');
// //
// //     for (var sn in serverNotes) {
// //       final localNote = NoteLocal(
// //         localId: sn.localId ?? const Uuid().v4(),
// //         chapterLocalId: chapterLocalId,
// //         chapterId: sn.chapterId,
// //         semesterId: sn.semesterId,
// //         subjectId: sn.subjectId,
// //         semesterLocalId: sn.semesterLocalId,
// //         subjectLocalId: sn.subjectLocalId,
// //         userId: sn.userId,
// //         type: sn.type,
// //         fileName: sn.fileName,
// //         fileUrl: sn.fileUrl, // keep URL for lazy download
// //         createdAt: sn.createdAt,
// //         isDirty: false,
// //         isSyncing: false,
// //         fileBytes: null, // will download on demand
// //       );
// //
// //       if (!box.containsKey(localNote.localId)) {
// //         await box.put(localNote.localId, localNote);
// //       }
// //     }
// //   }
// //
// //
// // }
