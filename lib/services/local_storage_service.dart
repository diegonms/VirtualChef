import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

/// Persistência local (RF06/RF07) com shared_preferences.
///
/// Todo acesso ao armazenamento passa por aqui, então trocar para
/// Firebase/Supabase (bônus) significa substituir apenas esta classe.
class LocalStorageService {
  LocalStorageService(this._prefs);

  final SharedPreferences _prefs;

  static const _usersKey = 'users';
  static const _sessionKey = 'session_user';

  /// Usuários cadastrados: nome de usuário -> hash da senha.
  Map<String, String> readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  Future<void> saveUsers(Map<String, String> users) =>
      _prefs.setString(_usersKey, jsonEncode(users));

  String? readSessionUser() => _prefs.getString(_sessionKey);

  Future<void> saveSessionUser(String? username) => username == null
      ? _prefs.remove(_sessionKey)
      : _prefs.setString(_sessionKey, username);

  List<Meal> readMeals(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((item) => Meal.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMeals(String key, List<Meal> meals) => _prefs.setString(
        key,
        jsonEncode(meals.map((meal) => meal.toJson()).toList()),
      );
}
