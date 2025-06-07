import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyUserId = 'userId';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';
  static const String _keyProfilePhotoUrl = 'photo_url';
  static const String _keyDonePoints = 'donePoints';

  static Future<void> saveUser(
    String userID,
    String username,
    String email,
    String? photoUrl,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userID);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyEmail, email);
    if (photoUrl != null) {
      await prefs.setString(_keyProfilePhotoUrl, photoUrl);
    }
  }

  static Future<void> savePhotoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfilePhotoUrl, url);
  }

  static Future<String?> getPhotoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyProfilePhotoUrl);
  }

  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  static Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyProfilePhotoUrl);
    await prefs.remove(_keyDonePoints);
  }

  //point
  static Future<void> setDonePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDonePoints, points);
  }

  static Future<int> getDonePoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDonePoints) ?? 0;
  }

  //route request
  static const String _routeRequestCountKey = 'routeRequestCount';
  static Future<int> getRouteRequestCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_routeRequestCountKey) ?? 0;
  }

  static Future<void> setRouteRequestCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_routeRequestCountKey, count);
  }

  static Future<void> incrementRouteRequestCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_routeRequestCountKey) ?? 0;
    await prefs.setInt(_routeRequestCountKey, currentCount + 1);
  }
}
