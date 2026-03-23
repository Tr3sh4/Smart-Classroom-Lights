import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _inactivityKey = 'inactivity_seconds';
  static const String _costKwhKey = 'cost_per_kwh';

  static Future<void> saveSettings({
    required int inactivitySeconds,
    required double costPerKwh,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_inactivityKey, inactivitySeconds);
    await prefs.setDouble(_costKwhKey, costPerKwh);
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'inactivitySeconds': prefs.getInt(_inactivityKey) ?? 30,
      'costPerKwh': prefs.getDouble(_costKwhKey) ?? 12.0,
    };
  }
}
