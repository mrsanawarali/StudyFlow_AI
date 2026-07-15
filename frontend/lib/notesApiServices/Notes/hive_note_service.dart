import 'package:hive/hive.dart';
import 'note_local.dart';
import 'hive_note_helper.dart';
import 'package:http/http.dart' as http;


class HiveNoteService {
  static Box<NoteLocal> get _box => HiveNoteHelper.getNoteBox();

  // Just save note exactly as it is
  static Future<void> saveNote(NoteLocal note) async {
    await _box.put(note.localId, note);
  }

  static List<NoteLocal> getAll() => _box.values.toList();

  static List<NoteLocal> getUnsyncedNotes() =>
      _box.values.where((n) => n.serverId == null && !n.isDeleted).toList();

  static List<NoteLocal> getUpdatedNotes() =>
      _box.values.where((n) => n.serverId != null && n.isDirty && !n.isDeleted).toList();

  static List<NoteLocal> getDeletedNotes() =>
      _box.values.where((n) => n.isDeleted).toList();

  static Future<void> deleteNote(NoteLocal note) async =>
      await _box.delete(note.localId);

  static void printAll() {
    final notes = _box.values.toList();
    if (notes.isEmpty) {
      print("📦 No notes in Hive.");
      return;
    }

    print("📦 Hive Notes (${notes.length} total):");
    for (var note in notes) {
      print("""
                  ----------------------------------
                  Local ID: ${note.localId}
                  Server ID: ${note.serverId}
                  Type: ${note.type}
                  Title: ${note.title}
                  Content: ${note.content}
                  FileName: ${note.fileName}
                  FileUrl: ${note.fileUrl}
                  IsSynced: ${note.isSynced}
                  IsDeleted: ${note.isDeleted}
                  IsDirty: ${note.isDirty}
                  CreatedAt: ${note.createdAt}
                  ----------------------------------
                  """);
    }
  }

  static const String noteBoxName = 'noteBox';

  static Box<NoteLocal> getNoteBox() {
    return Hive.box<NoteLocal>(noteBoxName);
  }

  // Add new or update existing note (used by hydration & sync)
  static Future<void> addOrUpdate(NoteLocal note) async {
    // 1️⃣ If a note with same localId exists → update it
    if (_box.containsKey(note.localId)) {
      await _box.put(note.localId, note);
      return;
    }

    // 2️⃣ Find existing by serverId (nullable) using a simple loop to avoid
    //    firstWhere/orElse null typing issues.
    NoteLocal? existing;
    for (final n in _box.values) {
      if (n.serverId != null && n.serverId == note.serverId) {
        existing = n;
        break;
      }
    }

    if (existing != null) {
      // keep original localId for UI stability
      note.localId = existing.localId;
      await _box.put(existing.localId, note);
      return;
    }

    // 3️⃣ Otherwise → brand new note
    await _box.put(note.localId, note);
  }

  /// Lazy download & cache bytes for hydrated notes
  static Future<void> cacheFileBytes(NoteLocal note) async {
    if (note.fileBytes != null || note.fileUrl == null) return;

    try {
      if (note.fileUrl!.startsWith('http')) {
        final response = await http.get(Uri.parse(note.fileUrl!));
        if (response.statusCode == 200) {
          note.fileBytes = response.bodyBytes;
          await _box.put(note.localId, note); // persist downloaded bytes
        }
      }
    } catch (e) {
      print("⚠️ Failed to cache file bytes for ${note.fileName}: $e");
    }
  }

}



