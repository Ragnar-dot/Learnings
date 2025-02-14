import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastEmail', email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastEmail');
  }
}
