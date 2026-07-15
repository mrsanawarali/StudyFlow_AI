import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../notesApiServices/Notes/note_local.dart';
import '../full_screen_image_viewer.dart';

import 'package:dio/dio.dart';

import '../widgets/action_button.dart';

class PublicFileCard extends StatelessWidget {
  final NoteLocal note;
  const PublicFileCard({super.key, required this.note});

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _openFile(BuildContext context) async {
    final ext = note.fileName?.split('.').last.toLowerCase() ?? '';
    final isImage = ['png', 'jpg', 'jpeg'].contains(ext);

    try {
      if (isImage && note.imageUrl != null) {
        final bytes = (await Dio().get<List<int>>(note.imageUrl!,
            options: Options(responseType: ResponseType.bytes)))
            .data;
        if (bytes != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FullScreenImageViewer(
                    imageBytes: Uint8List.fromList(bytes),
                    title: note.fileName ?? 'Image',
                  )));
        }
      } else if (note.fileUrl != null) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${note.fileName}';
        final file = File(filePath);

        if (!await file.exists()) {
          final bytes = (await Dio().get<List<int>>(note.fileUrl!,
              options: Options(responseType: ResponseType.bytes)))
              .data;
          if (bytes != null) await file.writeAsBytes(bytes);
        }

        await OpenFile.open(filePath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file: $e')));
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    if (note.fileUrl == null) return;

    try {
      final bytes = (await Dio().get<List<int>>(note.fileUrl!,
          options: Options(responseType: ResponseType.bytes)))
          .data;
      if (bytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${note.fileName}';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File saved to: $filePath')),
      );

      // Optional: open the file immediately
      await OpenFile.open(filePath);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = note.fileName?.split('.').last ?? '';
    final isImage = ['png', 'jpg', 'jpeg'].contains(ext);
    final imageProvider = isImage && note.imageUrl != null
        ? NetworkImage(note.imageUrl!) // thumbnail from URL
        : null;

    return Card(
      color: const Color(0xFF1A1F3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openFile(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (isImage && imageProvider != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: imageProvider,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Icon(_getFileIcon(ext), size: 50, color: Colors.white70),
              const SizedBox(width: 12),
              Expanded(
                child: Text(note.fileName ?? 'Untitled',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
             // ActionButton(icon: Icons.open_in_new_rounded, color: Colors.blueAccent, onPressed: () => _openFile(context)),
              ActionButton(
                  icon: Icons.file_download,
                  color: Colors.greenAccent,
                  onPressed: () => _downloadFile(context)),
            ],
          ),
        ),
      ),
    );
  }
}
