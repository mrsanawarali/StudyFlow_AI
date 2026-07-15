// public_chapter_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled/screens/explore/public-notes.dart';
import 'package:untitled/config.dart';

class PublicChapterScreen extends StatefulWidget {
  final String subjectTitle;
  final String subjectId;
  final String semesterId;

  const PublicChapterScreen({
    super.key,
    required this.subjectTitle,
    required this.subjectId,
    required this.semesterId,
  });

  @override
  State<PublicChapterScreen> createState() => _PublicChapterScreenState();
}

class _PublicChapterScreenState extends State<PublicChapterScreen> {
  bool isLoading = true;
  List<dynamic> chapters = [];

  static const String API_BASE = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  Future<void> fetchChapters() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse("$API_BASE/chapters/${widget.subjectId}");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        setState(() {
          chapters = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Failed to load chapters: ${res.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching chapters: $e");
    }
  }

  void _openNotes(Map<String, dynamic> chapter) {
    // Safely extract chapter ID as string
    String chapterId;
    if (chapter['id'] is Map && chapter['id']['\$oid'] != null) {
      chapterId = chapter['id']['\$oid'];
    } else {
      chapterId = chapter['id'].toString();
    }

    // Navigate to PublicNoteDetailScreen with the correct chapterId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicNoteDetailScreen(
          chapterTitle: chapter['title'] ?? 'Untitled',
          chapterId: chapterId,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1B2660),
        title: Text(widget.subjectTitle),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : chapters.isEmpty
          ? const Center(
        child: Text(
          "No chapters available.",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "Chapters",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final title = chapter['title'] ?? 'Untitled';

                return Card(
                  color: const Color(0xFF1A1F3F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.menu_book, color: Colors.white70),
                    title: Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                    onTap: () => _openNotes(chapter),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
