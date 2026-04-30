import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUserId = 'user_id';
  static const _keyUsername = 'username';
  static const _keyLoggedIn = 'is_logged_in';

  static Future<void> saveSession({
    required int userId,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyLoggedIn, true);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
