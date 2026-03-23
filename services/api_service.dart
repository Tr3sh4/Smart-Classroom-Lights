import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/light.dart';
import 'api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<dynamic>> getLights() async {
    final response = await http.get(Uri.parse("$baseUrl/lights"));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body;
      } else if (body is Map<String, dynamic>) {
        if (body.containsKey('lights') && body['lights'] is List) {
          return body['lights'];
        }
        if (body.containsKey('data') && body['data'] is List) {
          return body['data'];
        }
        throw Exception('Unexpected lights payload format: missing array');
      } else {
        throw Exception('Unexpected lights payload type: ${body.runtimeType}');
      }
    } else {
      throw Exception('Failed to load lights (${response.statusCode})');
    }
  }

  static Future<void> toggleLight(String id) async {
    await http.post(Uri.parse("$baseUrl/lights/$id/toggle"));
  }

  static Future<void> setDim(String id, int level) async {
    await http.post(
      Uri.parse("$baseUrl/lights/$id/dim"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"dimLevel": level}),
    );
  }

  static Future<void> addLight(Light light) async {
    await http.post(
      Uri.parse("$baseUrl/lights"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(light.toJson()),
    );
  }

  static Future<void> updateLight(String id, Map<String, dynamic> data) async {
    await http.put(
      Uri.parse("$baseUrl/lights/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  static Future<void> deleteLight(String id) async {
    await http.delete(Uri.parse("$baseUrl/lights/$id"));
  }
}
