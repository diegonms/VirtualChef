import 'package:flutter/material.dart';

import '../providers/cooked_provider.dart';
import '../widgets/saved_meals_view.dart';

/// Receitas que o usuário já preparou — itens "consumidos" (RF07).
class CookedScreen extends StatelessWidget {
  const CookedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receitas preparadas')),
      body: const SavedMealsView<CookedProvider>(
        emptyIcon: Icons.restaurant_menu,
        emptyMessage: 'Nenhuma receita preparada ainda.\n'
            'Na tela de detalhes, toque em "Marcar como preparada".',
        removeIcon: Icons.remove_circle_outline,
        removeTooltip: 'Desmarcar como preparada',
        removedMessage: 'removida das preparadas',
      ),
    );
  }
}
