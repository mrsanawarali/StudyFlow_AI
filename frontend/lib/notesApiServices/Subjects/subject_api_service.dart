import 'dart:convert';
import 'package:http/http.dart' as http;
import 'subject.dart';

class SubjectApiService {
  final String baseUrl;

  SubjectApiService({required this.baseUrl});

  Future<List<Subject>> fetchSubjects(String semesterId) async {
    final res = await http.get(Uri.parse('$baseUrl/$semesterId'));

    if (res.statusCode != 200) throw Exception("Failed to load subjects");

    final List data = json.decode(res.body);
    return data.map((e) => Subject.fromJson(e)).toList();
  }

  Future<Subject> addSubject(Subject subject) async {
    if (subject.semesterId == null) {
      throw Exception("Cannot add subject: semesterId is null");
    }

    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "semesterId": subject.semesterId,
        "title": subject.title,
        "courseCode": subject.courseCode,
        "instructor": subject.instructor,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to add subject: ${res.body}");
    }

    return Subject.fromJson(json.decode(res.body));
  }


  Future<Subject> updateSubject(Subject subject) async {
    final res = await http.put(
      Uri.parse('$baseUrl/${subject.id}'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": subject.title,
        "courseCode": subject.courseCode,
        "instructor": subject.instructor,
      }),
    );

    if (res.statusCode != 200) throw Exception("Failed to update subject");

    return Subject.fromJson(json.decode(res.body));
  }

  Future<void> deleteSubject(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));

    if (res.statusCode != 200) throw Exception("Failed to delete subject");
  }
}
