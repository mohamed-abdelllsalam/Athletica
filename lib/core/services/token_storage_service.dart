import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  TokenStorageService._();
  static final TokenStorageService instance = TokenStorageService._();

  static const String _tokenKey = 'athletica_jwt';
  static const String _legacyTokenKey = 'auth_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _roleKey = 'user_role';
  static const String _clientIdKey = 'client_id';
  static const String _trainerIdKey = 'trainer_id';
  static const String _profileCompleteKey = 'is_profile_complete';
  static const String _sessionStartedKey = 'auth_session_started_at';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _sessionStartedKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<DateTime?> getSessionStartedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_sessionStartedKey);
    return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
  }

  Future<String?> getToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) return token;
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(_legacyTokenKey);
    if (legacyToken != null) {
      await _secureStorage.write(key: _tokenKey, value: legacyToken);
      await prefs.remove(_legacyTokenKey);
    }
    return legacyToken;
  }

  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<void> saveClientId(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientIdKey, clientId);
  }

  Future<String?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clientIdKey);
  }

  Future<void> saveTrainerId(String trainerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trainerIdKey, trainerId);
  }

  Future<String?> getTrainerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_trainerIdKey);
  }

  Future<void> saveProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileCompleteKey, true);
  }

  Future<bool> isProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileCompleteKey) ?? false;
  }

  Future<void> clearProfileComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileCompleteKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _tokenKey);
    await prefs.remove(_legacyTokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_clientIdKey);
    await prefs.remove(_trainerIdKey);
    await prefs.remove(_profileCompleteKey);
    await prefs.remove(_sessionStartedKey);
  }
}
