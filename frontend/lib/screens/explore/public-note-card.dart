import '../../notesApiServices/Notes/note_local.dart';
import 'package:flutter/material.dart';
class PublicNoteCard extends StatelessWidget {
  final NoteLocal note;

  const PublicNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null && note.title!.isNotEmpty)
              Text(note.title!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              note.content ?? '',
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
