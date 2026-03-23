import 'dart:io';

import 'package:flutter/foundation.dart';

import 'ngrok_api.dart';

class ApiConfig {
  static String? _baseUrl;

  static Future<void> init() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _baseUrl = await NgrokApi.getPublicUrl();
    } else {
      _baseUrl = 'http://127.0.0.1:3000';
    }
  }

  static String get baseUrl {
    if (_baseUrl == null) {
      throw Exception(
        'ApiConfig not initialized. Call ApiConfig.init() first.',
      );
    }
    return _baseUrl!;
  }
}
