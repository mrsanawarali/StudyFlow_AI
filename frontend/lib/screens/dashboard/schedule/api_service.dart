// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/schedule_item.dart';
import 'package:untitled/config.dart';

class ApiService {
  // Your PC's local IP and Node.js backend port
  static const String _baseUrl  = AppConfig.baseUrl; // <- update this when your IP changes

  /// Fetch schedule items by userId and type
  static Future<List<ScheduleItem>> fetchSchedule(String userId,
      {required String type}) async {
    final url = Uri.parse('$_baseUrl/schedule/$userId?type=$type');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ScheduleItem.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to fetch schedule: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  /// Add a new schedule item
  static Future<ScheduleItem> addSchedule(ScheduleItem item) async {
    final url = Uri.parse('$_baseUrl/schedule');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return ScheduleItem.fromJson(data);
    } else {
      throw Exception(
          'Failed to add schedule item: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  /// Update an existing schedule item by ID
  static Future<ScheduleItem> updateSchedule(ScheduleItem item) async {
    if (item.id == null) {
      throw Exception('Cannot update item without an ID');
    }

    final url = Uri.parse('$_baseUrl/schedule/${item.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return ScheduleItem.fromJson(data);
    } else {
      throw Exception(
          'Failed to update schedule item: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  /// Delete a schedule item by ID
  static Future<void> deleteSchedule(String id) async {
    final url = Uri.parse('$_baseUrl/schedule/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete schedule item: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}
