// public_subject_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'public_chapter_screen.dart'; // Make sure you create this screen
import 'package:untitled/config.dart';

class PublicSubjectScreen extends StatefulWidget {
  final String semesterTitle;
  final String semesterId;

  const PublicSubjectScreen({
    super.key,
    required this.semesterTitle,
    required this.semesterId,
  });

  @override
  State<PublicSubjectScreen> createState() => _PublicSubjectScreenState();
}

class _PublicSubjectScreenState extends State<PublicSubjectScreen> {
  bool isLoading = true;
  List<dynamic> subjects = [];

  static const String API_BASE = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      final url = Uri.parse("$API_BASE/subjects/${widget.semesterId}");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List;
        setState(() {
          subjects = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Failed to load subjects: ${res.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching subjects: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1B2660),
        title: Text(widget.semesterTitle),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : subjects.isEmpty
          ? const Center(
          child: Text(
            "No subjects available.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ))
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18),
              child: const Text(
                "Subjects",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final s = subjects[index];
                final title = s['title'] ?? 'Untitled';
                final courseCode = s['courseCode'] ?? '';
                final instructor = s['instructor'] ?? '';
                final subjectId = s['id']; // Make sure API returns `id`

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Card(
                    color: const Color(0xFF1A1F3F),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.school,
                          color: Colors.white70),
                      title: Text(
                        title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (courseCode.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.assignment,
                                    size: 16, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(courseCode,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14)),
                              ],
                            ),
                          if (instructor.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    size: 16, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(instructor,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14)),
                              ],
                            ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to chapter screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PublicChapterScreen(
                              subjectTitle: title,
                              subjectId: subjectId,
                              semesterId: widget.semesterId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: subjects.length,
            ),
          ),
        ],
      ),
    );
  }
}
