import 'dart:convert';
import 'package:http/http.dart' as http;
import 'semester.dart';

class SemesterApiService {
  final String baseUrl;

  SemesterApiService({required this.baseUrl});

  Future<List<Semester>> fetchSemesters(String userId) async {
    final res = await http.get(Uri.parse("$baseUrl/$userId"));

    if (res.statusCode != 200) {
      throw Exception("Failed to load semesters");
    }

    final List data = json.decode(res.body);

    return data.map((e) => Semester.fromJson(e)).toList();
  }

  Future<Semester> addSemester(Semester semester) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": semester.userId,
        "title": semester.title,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to add semester: ${res.body}");
    }

    return Semester.fromJson(json.decode(res.body));
  }

  Future<Semester> updateSemester(Semester sem) async {
    final res = await http.put(
      Uri.parse("$baseUrl/${sem.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": sem.title}),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update semester");
    }

    return Semester.fromJson(json.decode(res.body));
  }

  Future<void> deleteSemester(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));

    if (res.statusCode != 200) {
      throw Exception("Failed to delete semester");
    }
  }
}
