// file_card.dart
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;

import '../../notesApiServices/Notes/hive_note_service.dart';
import '../../notesApiServices/Notes/note_local.dart';
import '../../notesApiServices/Notes/note_sync_service.dart';
import '../full_screen_image_viewer.dart';
import 'action_button.dart';
import 'rename_file_dialog.dart';

class FileCard extends StatelessWidget {
  final NoteLocal note;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  const FileCard({super.key, required this.note, this.onDelete, this.onRename});

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc':
      case 'docx': return Icons.description;
      case 'ppt':
      case 'pptx': return Icons.slideshow;
      case 'xls':
      case 'xlsx': return Icons.table_chart;
      case 'png':
      case 'jpg':
      case 'jpeg': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }

  // Future<void> _openFile(BuildContext context) async {
  //   final ext = note.fileName?.split('.').last.toLowerCase() ?? '';
  //   final isImage = ['png', 'jpg', 'jpeg'].contains(ext);
  //   Uint8List? bytes = note.fileBytes;
  //
  //   try {
  //     if (!kIsWeb && bytes == null && note.fileUrl != null) {
  //       final file = File(note.fileUrl!);
  //       if (await file.exists()) {
  //         bytes = await file.readAsBytes();
  //       } else {
  //         bytes = null;
  //       }
  //     }
  //
  //     if (bytes == null && !isImage) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Cannot open this file')),
  //       );
  //       return;
  //     }
  //
  //     if (isImage) {
  //       if (bytes != null) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (_) => FullScreenImageViewer(
  //               imageBytes: bytes!,
  //               title: note.fileName ?? 'Image',
  //             ),
  //           ),
  //         );
  //       } else if (!kIsWeb && note.fileUrl != null) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Image file missing')),
  //         );
  //       }
  //       return;
  //     }
  //
  //     // Open non-image file
  //     if (!kIsWeb && note.fileUrl != null) {
  //       final tempDir = await getTemporaryDirectory();
  //       final tempFile = File('${tempDir.path}/${note.fileName}');
  //       await tempFile.writeAsBytes(bytes!);
  //       await OpenFile.open(tempFile.path);
  //     } else if (kIsWeb && bytes != null) {
  //       final blob = html.Blob([bytes]);
  //       final url = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor = html.document.createElement('a') as html.AnchorElement
  //         ..href = url
  //         ..download = note.fileName ?? 'file'
  //         ..style.display = 'none';
  //       html.document.body?.children.add(anchor);
  //       anchor.click();
  //       html.document.body?.children.remove(anchor);
  //       html.Url.revokeObjectUrl(url);
  //     }
  //
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to open file: $e')),
  //     );
  //   }
  // }
  Future<void> _openFile(BuildContext context) async {
    final ext = note.fileName?.split('.').last.toLowerCase() ?? '';
    final isImage = ['png', 'jpg', 'jpeg'].contains(ext);

    // --- Ensure bytes are cached ---
    await HiveNoteService.cacheFileBytes(note);
    final bytes = note.fileBytes;

    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open this file')),
      );
      return;
    }

    if (isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            imageBytes: bytes,
            title: note.fileName ?? 'Image',
          ),
        ),
      );
      return;
    }

    if (!kIsWeb) {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${note.fileName}');
      await tempFile.writeAsBytes(bytes, flush: true);
      await OpenFile.open(tempFile.path);
    } else {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..download = note.fileName ?? 'file'
        ..style.display = 'none';
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }


  Future<void> _downloadFile(BuildContext context) async {
    try {
      // --- Ensure bytes are cached ---
      await HiveNoteService.cacheFileBytes(note);
      final bytes = note.fileBytes;

      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file data to download')),
        );
        return;
      }

      if (kIsWeb) {
        // Web: trigger browser download
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..download = note.fileName ?? 'file'
          ..style.display = 'none';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded: ${note.fileName}')),
        );
      } else {
        // Mobile/Desktop: save to temp folder
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${note.fileName}');
        await tempFile.writeAsBytes(bytes, flush: true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved to: ${tempFile.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  void _deleteFile() async {
    // Use the centralized delete method
    note.isDeleted = true;
    note.isDirty = true;
    note.isSyncing = false;

    final box = Hive.box<NoteLocal>('noteBox');
    await box.put(note.localId, note);

    // Trigger sync
    NoteSyncService().syncNow().catchError((e) {
      print("⚠️ File delete sync failed: $e");
    });

    if (onDelete != null) onDelete!();
  }

  // Future<void> _downloadFile(BuildContext context) async {
  //   try {
  //     final bytes = note.fileBytes;
  //     if (bytes == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('No file data to download')),
  //       );
  //       return;
  //     }
  //
  //     if (kIsWeb) {
  //       // Web: trigger browser download
  //       final blob = html.Blob([bytes]);
  //       final url = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor = html.document.createElement('a') as html.AnchorElement
  //         ..href = url
  //         ..download = note.fileName ?? 'file'
  //         ..style.display = 'none';
  //       html.document.body?.children.add(anchor);
  //       anchor.click();
  //       html.document.body?.children.remove(anchor);
  //       html.Url.revokeObjectUrl(url);
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('File downloaded: ${note.fileName}')),
  //       );
  //     } else {
  //       // Mobile/Desktop: save to temporary directory (or Downloads folder if you want)
  //       final tempDir = await getTemporaryDirectory();
  //       final tempFile = File('${tempDir.path}/${note.fileName}');
  //       await tempFile.writeAsBytes(bytes);
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('File saved to: ${tempFile.path}')),
  //       );
  //
  //       // Optional: open the file after saving
  //       // await OpenFile.open(tempFile.path);
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to download file: $e')),
  //     );
  //   }
  // }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => RenameFileDialog(
        initialName: note.fileName ?? 'Untitled',
        onRename: (newName) async {
          note.fileName = newName;
          note.isDirty = true;
          note.isSyncing = false;

          final box = Hive.box<NoteLocal>('noteBox');
          await box.put(note.localId, note);

          // Trigger sync
          NoteSyncService().syncNow().catchError((e) {
            print("⚠️ File rename sync failed: $e");
          });

          if (onRename != null) onRename!();
        },
        accentColor: Colors.orangeAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = note.fileName?.split('.').last ?? '';
    final isImage = ['png', 'jpg', 'jpeg'].contains(ext);
    final imageProvider =
    isImage && note.fileBytes != null ? MemoryImage(note.fileBytes!) : null;

    return Card(
      color: const Color(0xFF1A1F3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 4,
      shadowColor: Colors.black45,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openFile(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              isImage && imageProvider != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: imageProvider,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(_getFileIcon(ext), size: 50, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.fileName ?? 'Untitled',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('.$ext file',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
             // ActionButton(icon: Icons.open_in_new_rounded, color: Colors.blueAccent, onPressed: () => _openFile(context)),
              ActionButton(
                  icon: Icons.edit,
                  color: Colors.orangeAccent,
                  onPressed: () => _showRenameDialog(context)),
              ActionButton(
                  icon: Icons.file_download,
                  color: Colors.greenAccent,
                  onPressed: () => _downloadFile(context)),
              ActionButton(icon: Icons.delete, color: Colors.redAccent, onPressed: _deleteFile),
            ],
          ),
        ),
      ),
    );
  }
}
