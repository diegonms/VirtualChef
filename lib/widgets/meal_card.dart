import 'package:flutter/material.dart';

import '../models/meal.dart';
import 'meal_image.dart';

/// Item da grade do catálogo: imagem + nome da receita.
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, required this.onTap});

  final Meal meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // O leitor de tela anuncia o card inteiro como um único botão.
    return Semantics(
      button: true,
      label: 'Receita ${meal.name}. Toque para ver os detalhes.',
      onTap: onTap,
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: MealImage(url: meal.thumbnailUrl, mealName: meal.name),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  meal.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
