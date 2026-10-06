import 'package:flutter/material.dart';

import '../providers/favorites_provider.dart';
import '../widgets/saved_meals_view.dart';

/// Receitas favoritadas (RF05).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: const SavedMealsView<FavoritesProvider>(
        emptyIcon: Icons.star_border,
        emptyMessage: 'Você ainda não favoritou nenhuma receita.\n'
            'Toque na estrela na tela de detalhes para favoritar.',
        removeIcon: Icons.star,
        removeTooltip: 'Remover dos favoritos',
        removedMessage: 'removida dos favoritos',
      ),
    );
  }
}
