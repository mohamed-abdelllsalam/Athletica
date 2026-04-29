import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  TokenStorageService._();
  static final TokenStorageService instance = TokenStorageService._();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _profileCompleteKey = 'is_profile_complete';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<void> saveProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileCompleteKey, true);
  }

  Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileCompleteKey) ?? false;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    // is_profile_complete is intentionally preserved — profile completion is
    // permanent and should survive logout/login on the same device.
  }
}
