import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chapter.dart';

class ChapterApiService {
  final String baseUrl;

  ChapterApiService({required this.baseUrl});

  /// Fetch all chapters for a subject
  Future<List<Chapter>> fetchChapters(String subjectId) async {
    final res = await http.get(Uri.parse('$baseUrl/$subjectId'));

    if (res.statusCode != 200) throw Exception("Failed to load chapters");

    final List data = json.decode(res.body);
    return data.map((e) => Chapter.fromJson(e)).toList();
  }

  /// Add a new chapter
  Future<Chapter> addChapter(Chapter chapter) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "semesterId": chapter.semesterId,
        "subjectId": chapter.subjectId,
        "title": chapter.title,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to add chapter: ${res.body}");
    }

    return Chapter.fromJson(json.decode(res.body));
  }

  /// Update an existing chapter
  Future<Chapter> updateChapter(Chapter chapter) async {
    final res = await http.put(
      Uri.parse('$baseUrl/${chapter.id}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": chapter.title,
      }),
    );

    if (res.statusCode != 200) throw Exception("Failed to update chapter");

    return Chapter.fromJson(json.decode(res.body));
  }

  /// Delete a chapter
  Future<void> deleteChapter(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));

    if (res.statusCode != 200) throw Exception("Failed to delete chapter");
  }
}
