import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

/// Erro de comunicação com a API, já com uma mensagem amigável ao usuário.
class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Converte qualquer erro em uma mensagem que pode ser exibida na tela.
String friendlyErrorMessage(Object? error) {
  if (error is ApiException) return error.message;
  return 'Ocorreu um erro inesperado. Tente novamente.';
}

/// Cliente da API pública e gratuita do TheMealDB (https://www.themealdb.com).
class MealApiService {
  MealApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // A chave "1" é a chave pública de testes fornecida pelo próprio TheMealDB.
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const _timeout = Duration(seconds: 15);

  /// "Página" do catálogo: receitas cujo nome começa com [letter].
  Future<List<Meal>> fetchByFirstLetter(String letter) =>
      _getMeals('search.php', {'f': letter});

  Future<List<Meal>> searchByName(String name) =>
      _getMeals('search.php', {'s': name.trim()});

  /// A API espera o ingrediente em inglês, com "_" no lugar de espaços.
  Future<List<Meal>> filterByIngredient(String ingredient) => _getMeals(
        'filter.php',
        {'i': ingredient.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_')},
      );

  Future<Meal?> fetchById(String id) async {
    final meals = await _getMeals('lookup.php', {'i': id});
    return meals.isEmpty ? null : meals.first;
  }

  Future<List<Meal>> _getMeals(
    String endpoint,
    Map<String, String> params,
  ) async {
    final uri =
        Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: params);

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw ApiException(
          'O servidor de receitas está indisponível '
          '(erro ${response.statusCode}). Tente novamente mais tarde.',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      // Quando não há resultados a API devolve {"meals": null}.
      final meals = body['meals'];
      if (meals is! List) return [];
      return meals
          .cast<Map<String, dynamic>>()
          .map(Meal.fromApi)
          .toList(growable: false);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'A conexão demorou demais para responder. '
        'Verifique sua internet e tente novamente.',
      );
    } on FormatException {
      throw const ApiException(
        'Recebemos uma resposta inválida do servidor. Tente novamente.',
      );
    } catch (_) {
      throw const ApiException(
        'Não foi possível conectar ao servidor de receitas. '
        'Verifique sua conexão com a internet.',
      );
    }
  }
}
