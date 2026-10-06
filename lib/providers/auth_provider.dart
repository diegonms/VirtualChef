import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

/// Sessão do usuário com cadastro/login local (RF07 — baseline).
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._storage) : _username = _storage.readSessionUser();

  final LocalStorageService _storage;

  String? _username;
  bool _isLoading = false;
  String? _errorMessage;

  String? get username => _username;
  bool get isLoggedIn => _username != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) {
    final name = _normalize(username);
    return _authenticate(name, () async {
      final users = _storage.readUsers();
      if (users[name] != _hash(name, password)) {
        throw const _AuthError('Usuário ou senha inválidos.');
      }
    });
  }

  Future<bool> register(String username, String password) {
    final name = _normalize(username);
    return _authenticate(name, () async {
      final users = _storage.readUsers();
      if (users.containsKey(name)) {
        throw const _AuthError('Este usuário já existe. Faça login.');
      }
      users[name] = _hash(name, password);
      await _storage.saveUsers(users);
    });
  }

  Future<void> logout() async {
    _username = null;
    await _storage.saveSessionUser(null);
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _authenticate(
    String name,
    Future<void> Function() action,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simula a latência de um servidor real para que o feedback de
      // carregamento (RF09) seja visível. Remover ao migrar para Firebase Auth.
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await action();
      _username = name;
      await _storage.saveSessionUser(name);
      return true;
    } on _AuthError catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static String _normalize(String username) => username.trim().toLowerCase();

  // Nunca guardamos a senha em texto puro, nem localmente.
  static String _hash(String username, String password) =>
      sha256.convert(utf8.encode('$username:$password')).toString();
}

class _AuthError implements Exception {
  const _AuthError(this.message);

  final String message;
}
