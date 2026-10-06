import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal.dart';
import '../providers/meal_collection_provider.dart';
import '../screens/meal_detail_screen.dart';
import 'feedback_views.dart';
import 'meal_image.dart';

/// Lista reativa de uma coleção do usuário (favoritos ou preparadas).
/// Atualiza sozinha quando um item é removido, via Provider (RF05).
class SavedMealsView<T extends MealCollectionProvider> extends StatelessWidget {
  const SavedMealsView({
    super.key,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.removeIcon,
    required this.removeTooltip,
    required this.removedMessage,
  });

  final IconData emptyIcon;
  final String emptyMessage;
  final IconData removeIcon;
  final String removeTooltip;

  /// Complemento da mensagem "<Receita> foi ..." exibida ao remover.
  final String removedMessage;

  @override
  Widget build(BuildContext context) {
    final meals = context.watch<T>().meals;
    if (meals.isEmpty) {
      return EmptyView(icon: emptyIcon, message: emptyMessage);
    }

    return ListView.separated(
      itemCount: meals.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final meal = meals[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.square(
              dimension: 56,
              child: MealImage(url: meal.thumbnailUrl, mealName: meal.name),
            ),
          ),
          title: Text(meal.name),
          subtitle: _subtitle(meal),
          onTap: () => MealDetailScreen.open(context, meal),
          trailing: IconButton(
            icon: Icon(removeIcon),
            tooltip: '$removeTooltip: ${meal.name}',
            onPressed: () => _remove(context, meal),
          ),
        );
      },
    );
  }

  Widget? _subtitle(Meal meal) {
    final parts = [meal.category, meal.area].whereType<String>();
    return parts.isEmpty ? null : Text(parts.join(' · '));
  }

  void _remove(BuildContext context, Meal meal) {
    final collection = context.read<T>();
    collection.remove(meal.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${meal.name} foi $removedMessage.'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => collection.toggle(meal),
          ),
        ),
      );
  }
}
