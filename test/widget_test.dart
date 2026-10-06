import 'package:chef_virtual/main.dart';
import 'package:chef_virtual/models/meal.dart';
import 'package:chef_virtual/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Meal.fromApi', () {
    test('lê ingredientes e ignora campos vazios', () {
      final meal = Meal.fromApi({
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken Casserole',
        'strCategory': 'Chicken',
        'strArea': 'Japanese',
        'strMealThumb': '',
        'strTags': 'Meat, Casserole',
        'strIngredient1': 'soy sauce',
        'strMeasure1': '3/4 cup',
        'strIngredient2': '',
        'strMeasure2': ' ',
        'strIngredient3': null,
      });

      expect(meal.id, '52772');
      expect(meal.thumbnailUrl, isNull);
      expect(meal.tags, ['Meat', 'Casserole']);
      expect(meal.ingredients, hasLength(1));
      expect(meal.ingredients.first.measure, '3/4 cup');
    });

    test('toJson/fromJson preserva o resumo', () {
      const meal = Meal(id: '1', name: 'Bolo', category: 'Dessert');
      final restored = Meal.fromJson(meal.toJson());
      expect(restored.id, '1');
      expect(restored.name, 'Bolo');
      expect(restored.category, 'Dessert');
    });
  });

  testWidgets('exibe o login quando não há sessão salva', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ChefVirtualApp(storage: LocalStorageService(prefs)));

    expect(find.text('ChefVirtual'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
