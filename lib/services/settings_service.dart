import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String darkModeKey = 'dark_mode';
  static const String dailyGoalKey = 'daily_goal';
  static const String lastLoginKey = 'last_login';

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, value);
  }

  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? false;
  }

  static Future<void> setDailyGoal(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(dailyGoalKey, value);
  }

  static Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(dailyGoalKey) ?? 10;
  }

  static Future<void> updateLastLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastLoginKey, DateTime.now().toIso8601String());
  }
}
