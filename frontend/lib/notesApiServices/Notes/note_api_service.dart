import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'note_local.dart';
import 'package:untitled/config.dart';

class NoteApiService {
  static const String API_BASE_IP = AppConfig.baseUrl;
  static const String notesBaseUrl = "$API_BASE_IP/notes";
  static const String uploadBaseUrl = "$API_BASE_IP/upload";

  // -----------------------------
  // ADD NOTE(S)
  // -----------------------------
  static Future<List<String>> addNotes(List<NoteLocal> notes) async {
    final ids = <String>[];

    final textNotes = notes.where((n) => n.type == "text").toList();
    final fileNotes = notes.where((n) => n.type == "image" || n.type == "file").toList();

    for (var note in textNotes) {
      final id = await _sendTextNote(note);
      if (id != null) ids.add(id);
    }

    if (fileNotes.isNotEmpty) {
      final results = await _sendFileNotes(fileNotes);
      ids.addAll(results);
    }

    return ids;
  }
  static Future<String?> _sendTextNote(NoteLocal note) async {
    try {
      final response = await http.post(
        Uri.parse(notesBaseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "semesterId": note.semesterId,
          "subjectId": note.subjectId,
          "chapterId": note.chapterId,
          "userId": note.userId,
          "type": "text",
          "title": note.title ?? "",
          "content": note.content ?? "",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("📤 Server response for text note ${note.localId}: ${response.body}");
        final data = jsonDecode(response.body);
        return data["id"] ?? data["_id"];
      } else {
        print("❌ Server error for text note ${note.localId}: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception sending text note ${note.localId}: $e");
      return null;
    }
  }

  static Future<List<String>> _sendFileNotes(List<NoteLocal> notes) async {
    final uploadedIds = <String>[];

    for (var note in notes) {
      try {
        if ((note.fileBytes == null || note.fileBytes!.isEmpty) &&
            (note.fileUrl == null || note.fileUrl!.isEmpty)) {
          print("⚠️ Skipping file note ${note.localId}, no file data.");
          continue;
        }

        final request = http.MultipartRequest('POST', Uri.parse(uploadBaseUrl));
        request.fields["semesterId"] = note.semesterId ?? "";
        request.fields["subjectId"] = note.subjectId ?? "";
        request.fields["chapterId"] = note.chapterId ?? "";
        request.fields["userId"] = note.userId ?? "";
        request.fields["title[]"] = note.title ?? note.fileName ?? "Untitled";

        if (note.fileBytes != null && note.fileBytes!.isNotEmpty) {
          final mimeType = lookupMimeType(note.fileName ?? "") ?? "application/octet-stream";
          final split = mimeType.split("/");
          request.files.add(http.MultipartFile.fromBytes(
            'files',
            note.fileBytes!,
            filename: note.fileName ?? "file",
            contentType: MediaType(split[0], split[1]),
          ));
        } else if (note.fileUrl != null && note.fileUrl!.isNotEmpty) {
          final file = File(note.fileUrl!);
          final mimeType = lookupMimeType(file.path) ?? "application/octet-stream";
          final split = mimeType.split("/");
          request.files.add(await http.MultipartFile.fromPath(
            'files',
            file.path,
            filename: note.fileName ?? file.path.split("/").last,
            contentType: MediaType(split[0], split[1]),
          ));
        }

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          print("📤 Server response for file note ${note.localId}: ${response.body}");
          final savedNotes = data["savedNotes"] as List<dynamic>? ?? [];
          for (var n in savedNotes) {
            final serverId = n["_id"]?.toString() ?? n["id"]?.toString();
            if (serverId != null && serverId.isNotEmpty) uploadedIds.add(serverId);
          }
        } else {
          print("❌ Server error for file note ${note.localId}: ${response.body}");
        }
      } catch (e) {
        print("❌ Exception uploading file note ${note.localId}: $e");
      }
    }

    return uploadedIds;
  }

  // -----------------------------
  // UPDATE NOTE
  // -----------------------------
  static Future<void> updateNoteTitleOrContent(NoteLocal note) async {
    if (note.serverId == null) throw Exception("Cannot update note without serverId");

    final body = <String, dynamic>{};
    if (note.type == "text") {
      body["title"] = note.title ?? "";
      body["content"] = note.content ?? "";
    } else if (note.type == "image" || note.type == "file") {
      body["title"] = note.title ?? "";
    }

    try {
      final response = await http.put(
        Uri.parse("$notesBaseUrl/${note.serverId}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("✅ Updated note ${note.localId}. Server response: ${response.body}");
      } else {
        print("❌ Failed to update note ${note.localId}: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception updating note ${note.localId}: $e");
    }
  }

  // -----------------------------
  // DELETE NOTE
  // -----------------------------
  static Future<void> deleteNote(NoteLocal note) async {
    if (note.serverId == null) return;

    try {
      final res = await http.delete(Uri.parse("$notesBaseUrl/${note.serverId}"));
      if (res.statusCode == 200) {
        print("✅ Deleted note ${note.localId} from server.");
      } else {
        print("❌ Failed to delete note ${note.localId} from server: ${res.body}");
      }
    } catch (e) {
      print("❌ Exception deleting note ${note.localId}: $e");
    }
  }

  // -----------------------------
  // GET NOTES
  // -----------------------------
  static Future<List<NoteLocal>> getNotes(String chapterId) async {
    try {
      final res = await http.get(Uri.parse("$notesBaseUrl/$chapterId"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        print("📥 Fetched ${data.length} notes from server for chapter $chapterId");
        return data.map((e) => NoteLocal.fromJson(e)).toList();
      } else {
        print("❌ Failed to fetch notes for chapter $chapterId: ${res.body}");
        return [];
      }
    } catch (e) {
      print("❌ Exception fetching notes for chapter $chapterId: $e");
      return [];
    }
  }
}


// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:mime/mime.dart';
// import 'package:http_parser/http_parser.dart';
// import 'note_local.dart';
// import 'package:untitled/config.dart';
//
// class NoteApiService {
//   static const String API_BASE_IP = AppConfig.baseUrl; // <- update this when your IP changes
//
//   static const String notesBaseUrl = "$API_BASE_IP/notes";
//   static const String uploadBaseUrl = "$API_BASE_IP/upload";
//
//   // -----------------------------
//   // ADD NOTE(S)
//   // -----------------------------
//   static Future<List<String>> addNotes(List<NoteLocal> notes) async {
//     final ids = <String>[];
//
//     // Separate text notes and file/image notes
//     final textNotes = notes.where((n) => n.type == "text").toList();
//     final fileNotes = notes.where((n) => n.type == "image" || n.type == "file").toList();
//
//     // Send text notes individually
//     for (var note in textNotes) {
//       final id = await _sendTextNote(note);
//       if (id != null) ids.add(id);
//     }
//
//     // Send all file/image notes together
//     if (fileNotes.isNotEmpty) {
//       final results = await _sendFileNotes(fileNotes);
//       ids.addAll(results);
//     }
//
//     return ids;
//   }
//
//   static Future<String?> _sendTextNote(NoteLocal note) async {
//     final response = await http.post(
//       Uri.parse(notesBaseUrl),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "semesterId": note.semesterId,
//         "subjectId": note.subjectId,
//         "chapterId": note.chapterId,
//         "userId": note.userId,
//         "type": "text",
//         "title": note.title ?? "",
//         "content": note.content ?? "",
//       }),
//     );
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = jsonDecode(response.body);
//       return data["id"] ?? data["_id"];
//     } else {
//       throw Exception("Failed to send text note: ${response.body}");
//     }
//   }
//
//   static Future<List<String>> _sendFileNotes(List<NoteLocal> notes) async {
//     final uploadedIds = <String>[];
//
//     for (var note in notes) {
//       try {
//         // Skip invalid notes
//         if ((note.fileBytes == null || note.fileBytes!.isEmpty) &&
//             (note.fileUrl == null || note.fileUrl!.isEmpty)) {
//           print("⚠️ Skipping file note ${note.localId}, no data to upload");
//           continue;
//         }
//
//         final request = http.MultipartRequest('POST', Uri.parse(uploadBaseUrl));
//
//         request.fields["semesterId"] = note.semesterId ?? "";
//         request.fields["subjectId"] = note.subjectId ?? "";
//         request.fields["chapterId"] = note.chapterId ?? "";
//         request.fields["userId"] = note.userId ?? "";
//
//         // Attach file
//         if (note.fileBytes != null && note.fileBytes!.isNotEmpty) {
//           final mimeType = lookupMimeType(note.fileName ?? "") ?? "application/octet-stream";
//           final split = mimeType.split("/");
//
//           request.files.add(
//             http.MultipartFile.fromBytes(
//               'files',
//               note.fileBytes!,
//               filename: note.fileName ?? "file",
//               contentType: MediaType(split[0], split[1]),
//             ),
//           );
//         } else if (note.fileUrl != null && note.fileUrl!.isNotEmpty) {
//           final file = File(note.fileUrl!);
//           final mimeType = lookupMimeType(file.path) ?? "application/octet-stream";
//           final split = mimeType.split("/");
//
//           request.files.add(
//             await http.MultipartFile.fromPath(
//               'files',
//               file.path,
//               filename: note.fileName ?? file.path.split("/").last,
//               contentType: MediaType(split[0], split[1]),
//             ),
//           );
//         }
//
//         // Add title
//         request.fields["title[]"] = note.title ?? note.fileName ?? "Untitled";
//
//         final streamed = await request.send();
//         final response = await http.Response.fromStream(streamed);
//
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           final data = jsonDecode(response.body);
//           final savedNotes = data["savedNotes"] as List<dynamic>? ?? [];
//
//           for (var n in savedNotes) {
//             // Use 'id' if '_id' is missing
//             final serverId = n["_id"]?.toString() ?? n["id"]?.toString();
//             if (serverId != null && serverId.isNotEmpty) {
//               uploadedIds.add(serverId);
//             } else {
//               print("⚠️ Note returned without ID: ${note.localId}");
//             }
//           }
//         } else {
//           throw Exception("Failed to upload file note: ${response.body}");
//         }
//       } catch (e) {
//         print("⚠️ Error uploading file note ${note.localId}: $e");
//         // Do not throw — just skip to next note
//       }
//     }
//
//     return uploadedIds;
//   }
//
//   static Future<void> updateNoteTitleOrContent(NoteLocal note) async {
//     if (note.serverId == null) throw Exception("Cannot update note without serverId");
//
//     final Map<String, dynamic> body = {};
//     if (note.type == "text") {
//       body["title"] = note.title ?? "";
//       body["content"] = note.content ?? "";
//     } else if (note.type == "image" || note.type == "file") {
//       body["title"] = note.title ?? "";
//     }
//
//     final response = await http.put(
//       Uri.parse("$notesBaseUrl/${note.serverId}"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode(body),
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception("Failed to update note: ${response.body}");
//     }
//   }
//
//   // -----------------------------
//   // DELETE NOTE
//   // -----------------------------
//   static Future<void> deleteNote(NoteLocal note) async {
//     if (note.serverId == null) return;
//
//     final res = await http.delete(Uri.parse("$notesBaseUrl/${note.serverId}"));
//     if (res.statusCode != 200) throw Exception("Failed to delete note: ${res.body}");
//   }
//
//   // -----------------------------
//   // GET NOTES FOR A CHAPTER
//   // -----------------------------
//   static Future<List<NoteLocal>> getNotes(String chapterId) async {
//     final res = await http.get(Uri.parse("$notesBaseUrl/$chapterId"));
//     if (res.statusCode == 200) {
//       final data = jsonDecode(res.body) as List;
//       return data.map((e) => NoteLocal.fromJson(e)).toList();
//     } else {
//       throw Exception("Failed to fetch notes: ${res.body}");
//     }
//   }
// }
