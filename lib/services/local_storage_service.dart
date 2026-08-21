import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _lastCityKey = 'last_searched_city';

  // Save last searched city
  static Future<void> saveLastCity(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastCityKey, cityName);
    } catch (e) {
      throw Exception('Failed to save city: $e');
    }
  }

  // Get last searched city
  static Future<String?> getLastCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastCityKey);
    } catch (e) {
      throw Exception('Failed to retrieve city: $e');
    }
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
}
