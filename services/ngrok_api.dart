import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

class NgrokApi {
  static Future<String?> getPublicUrl() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:4040/api/tunnels'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tunnels = data['tunnels'] as List;
        if (tunnels.isNotEmpty) {
          final httpsTunnel = tunnels.firstWhere(
            (t) => t['proto'] == 'https',
            orElse: () => tunnels[0],
          );
          return httpsTunnel['public_url'];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching ngrok URL: $e');
      }
    }
    return null;
  }
}
