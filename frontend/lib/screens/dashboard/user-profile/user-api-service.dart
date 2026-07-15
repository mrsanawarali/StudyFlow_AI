import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled/config.dart';

class UserApiService {
  static const String baseUrl = AppConfig.baseUrl;

  static Future<Map<String, dynamic>?> getUser(String firebaseUid) async {
    try {
      final url = Uri.parse("$baseUrl/user-data/$firebaseUid");
      final res = await http.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        print("getUser failed: ${res.statusCode} ${res.body}");
        return null;
      }
    } catch (e) {
      print("getUser exception: $e");
      return null;
    }
  }


  static Future<bool> updateUser(
      String firebaseUid, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$firebaseUid"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );
    return res.statusCode == 200;
  }

  static Future<bool> addBookmark(String firebaseUid, String itemId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/$firebaseUid/user-data/bookmark"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"itemId": itemId}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> removeBookmark(
      String firebaseUid, String itemId) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/$firebaseUid/user-data/bookmark/$itemId"),
    );
    return res.statusCode == 200;
  }
}
