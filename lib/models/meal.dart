/// Ingrediente de uma receita, com sua respectiva medida.
class Ingredient {
  const Ingredient({required this.name, required this.measure});

  final String name;
  final String measure;
}

/// Receita do TheMealDB.
///
/// Os endpoints de listagem/busca por letra e por nome retornam a receita
/// completa; o endpoint de filtro por ingrediente retorna apenas
/// id, nome e imagem — por isso a maioria dos campos é opcional.
class Meal {
  const Meal({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.category,
    this.area,
    this.instructions,
    this.youtubeUrl,
    this.tags = const [],
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? category;
  final String? area;
  final String? instructions;
  final String? youtubeUrl;
  final List<String> tags;
  final List<Ingredient> ingredients;

  /// Converte o JSON bruto da API (campos `strMeal`, `strIngredient1..20` etc.).
  factory Meal.fromApi(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = _clean(json['strIngredient$i']);
      if (name == null) continue;
      ingredients.add(
        Ingredient(name: name, measure: _clean(json['strMeasure$i']) ?? ''),
      );
    }

    return Meal(
      id: json['idMeal'].toString(),
      name: _clean(json['strMeal']) ?? 'Receita sem nome',
      thumbnailUrl: _clean(json['strMealThumb']),
      category: _clean(json['strCategory']),
      area: _clean(json['strArea']),
      instructions: _clean(json['strInstructions']),
      youtubeUrl: _clean(json['strYoutube']),
      tags: _clean(json['strTags'])
              ?.split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList() ??
          const [],
      ingredients: ingredients,
    );
  }

  /// Lê o resumo salvo localmente (favoritos / preparadas).
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      category: json['category'] as String?,
      area: json['area'] as String?,
    );
  }

  /// Salva apenas o resumo: os detalhes completos são buscados na API.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'thumbnailUrl': thumbnailUrl,
        'category': category,
        'area': area,
      };

  static String? _clean(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
