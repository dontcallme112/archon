import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageDataSource {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'current_user';
  static const _onboardingKey = 'onboarding_done';
  static const _favoritesKey = 'favorite_project_ids';

  final SharedPreferences _prefs;
  LocalStorageDataSource(this._prefs);

  // Auth token
  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);
  String? getToken() => _prefs.getString(_tokenKey);
  Future<void> clearToken() async => _prefs.remove(_tokenKey);
  bool get isLoggedIn => getToken() != null;

  // Current user cache
  Future<void> saveUser(Map<String, dynamic> user) =>
      _prefs.setString(_userKey, jsonEncode(user));

  Map<String, dynamic>? getCachedUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearUser() async => _prefs.remove(_userKey);

  // Onboarding
  Future<void> setOnboardingDone() => _prefs.setBool(_onboardingKey, true);
  bool get isOnboardingDone => _prefs.getBool(_onboardingKey) ?? false;

  // Favorites
  Future<void> saveFavoriteIds(List<String> ids) =>
      _prefs.setStringList(_favoritesKey, ids);

  List<String> getFavoriteIds() =>
      _prefs.getStringList(_favoritesKey) ?? [];

  Future<void> toggleFavoriteId(String id) async {
    final ids = getFavoriteIds();
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    await saveFavoriteIds(ids);
  }

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}