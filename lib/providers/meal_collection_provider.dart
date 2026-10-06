import 'package:flutter/foundation.dart';

import '../models/meal.dart';
import '../services/local_storage_service.dart';

/// Coleção de receitas do usuário logado, persistida localmente (RF04–RF07).
///
/// Base comum de [FavoritesProvider] e [CookedProvider]: cada usuário tem
/// a sua própria lista, salva sob a chave `<prefixo>_<usuário>`.
abstract class MealCollectionProvider extends ChangeNotifier {
  MealCollectionProvider(this._storage, this._keyPrefix);

  final LocalStorageService _storage;
  final String _keyPrefix;

  String? _username;
  final Map<String, Meal> _meals = {};

  /// Itens mais recentes primeiro.
  List<Meal> get meals => _meals.values.toList().reversed.toList();

  bool contains(String mealId) => _meals.containsKey(mealId);

  String get _storageKey => '${_keyPrefix}_$_username';

  /// Chamado pelo ChangeNotifierProxyProvider sempre que a sessão muda.
  void setUser(String? username) {
    if (username == _username) return;
    _username = username;
    _meals.clear();
    if (username == null) return;
    for (final meal in _storage.readMeals(_storageKey)) {
      _meals[meal.id] = meal;
    }
  }

  Future<void> toggle(Meal meal) async {
    if (_meals.remove(meal.id) == null) {
      _meals[meal.id] = meal;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String mealId) async {
    if (_meals.remove(mealId) == null) return;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    if (_username == null) return;
    await _storage.saveMeals(_storageKey, _meals.values.toList());
  }
}
