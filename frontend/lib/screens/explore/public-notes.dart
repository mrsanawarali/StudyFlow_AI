import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:untitled/screens/explore/public-file-card.dart';
import 'package:untitled/screens/explore/public-note-card.dart';
import '../../notesApiServices/Notes/note_local.dart';
import 'package:untitled/config.dart';

class PublicNoteDetailScreen extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;

  const PublicNoteDetailScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
  });

  @override
  State<PublicNoteDetailScreen> createState() => _PublicNoteDetailScreenState();
}

class _PublicNoteDetailScreenState extends State<PublicNoteDetailScreen> {
  late Future<List<NoteLocal>> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
  }

  Future<List<NoteLocal>> _fetchNotes() async {
    try {
      final response = await Dio().get(
        '${AppConfig.baseUrl}/notes/${widget.chapterId}',
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) {
          return NoteLocal.fromJson(json);
        }).toList()
          ..sort((a, b) =>
              (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                  .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          ); // FCFS
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        title: Text(widget.chapterTitle),
        backgroundColor: const Color(0xFF1A1F3F),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<NoteLocal>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notes available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final notes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              if (note.type == "text") {
                return PublicNoteCard(note: note);
              } else {
                return PublicFileCard(note: note);
              }
            },
          );
        },
      ),
    );
  }
}
