import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal.dart';
import '../providers/cooked_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/meal_api_service.dart';
import '../widgets/feedback_views.dart';
import '../widgets/meal_image.dart';

/// Detalhes completos da receita (RF02/RF03), com favoritar (RF04)
/// e marcar como preparada (RF07).
class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key, required this.meal});

  /// Resumo recebido da lista; os detalhes completos vêm de uma
  /// segunda requisição ao endpoint `lookup.php`.
  final Meal meal;

  static Future<void> open(BuildContext context, Meal meal) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
    );
  }

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  late Future<Meal> _details;

  @override
  void initState() {
    super.initState();
    _details = _loadDetails();
  }

  Future<Meal> _loadDetails() async {
    final meal =
        await context.read<MealApiService>().fetchById(widget.meal.id);
    if (meal == null) {
      throw const ApiException('Receita não encontrada.');
    }
    return meal;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Meal>(
      future: _details,
      builder: (context, snapshot) {
        // Enquanto carrega, usamos o resumo para já mostrar o título.
        final meal = snapshot.data ?? widget.meal;

        final Widget body;
        if (snapshot.connectionState != ConnectionState.done) {
          body = const LoadingView(label: 'Carregando detalhes da receita');
        } else if (snapshot.hasError) {
          body = ErrorView(
            message: friendlyErrorMessage(snapshot.error),
            onRetry: () => setState(() => _details = _loadDetails()),
          );
        } else {
          body = _MealDetails(meal: meal);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(meal.name, overflow: TextOverflow.ellipsis),
            actions: [_FavoriteButton(meal: meal)],
          ),
          body: body,
        );
      },
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<FavoritesProvider>().contains(meal.id);
    return IconButton(
      tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      isSelected: isFavorite,
      icon: const Icon(Icons.star_border),
      selectedIcon: const Icon(Icons.star),
      onPressed: () => context.read<FavoritesProvider>().toggle(meal),
    );
  }
}

class _CookedButton extends StatelessWidget {
  const _CookedButton({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final isCooked = context.watch<CookedProvider>().contains(meal.id);
    void toggle() => context.read<CookedProvider>().toggle(meal);

    return isCooked
        ? FilledButton.icon(
            onPressed: toggle,
            icon: const Icon(Icons.check_circle),
            label: const Text('Já preparei! Toque para desmarcar'),
          )
        : OutlinedButton.icon(
            onPressed: toggle,
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Marcar como preparada'),
          );
  }
}

class _MealDetails extends StatelessWidget {
  const _MealDetails({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: MealImage(url: meal.thumbnailUrl, mealName: meal.name),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(meal.name, style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (meal.category != null)
                    Chip(
                      avatar: const Icon(Icons.category, size: 18),
                      label: Text('Categoria: ${meal.category}'),
                    ),
                  if (meal.area != null)
                    Chip(
                      avatar: const Icon(Icons.public, size: 18),
                      label: Text('Origem: ${meal.area}'),
                    ),
                  for (final tag in meal.tags) Chip(label: Text('#$tag')),
                ],
              ),
              const SizedBox(height: 16),
              _CookedButton(meal: meal),
              const SizedBox(height: 24),
              _SectionTitle('Ingredientes (${meal.ingredients.length})'),
              const SizedBox(height: 8),
              for (final ingredient in meal.ingredients)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          [ingredient.measure, ingredient.name]
                              .where((part) => part.isNotEmpty)
                              .join(' — '),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const _SectionTitle('Modo de preparo'),
              const SizedBox(height: 8),
              Text(
                meal.instructions ?? 'Instruções indisponíveis.',
                style: theme.textTheme.bodyLarge,
              ),
              if (meal.youtubeUrl != null) ...[
                const SizedBox(height: 24),
                const _SectionTitle('Vídeo da receita'),
                const SizedBox(height: 8),
                SelectableText(meal.youtubeUrl!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
