import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal.dart';
import '../providers/auth_provider.dart';
import '../services/meal_api_service.dart';
import '../widgets/feedback_views.dart';
import '../widgets/meal_card.dart';
import 'cooked_screen.dart';
import 'favorites_screen.dart';
import 'meal_detail_screen.dart';

enum SearchMode { name, ingredient }

/// Tela principal: catálogo paginado (RF01) + busca (RF08).
///
/// O TheMealDB não tem paginação, então cada "página" corresponde às
/// receitas de uma letra inicial: a, b, c... "Carregar Mais" busca a próxima.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  static const _letters = 'abcdefghijklmnopqrstuvwxyz';

  final _meals = <Meal>[];
  int _nextLetterIndex = 0;
  late Future<void> _initialLoad;
  bool _isLoadingMore = false;

  final _searchController = TextEditingController();
  SearchMode _searchMode = SearchMode.name;
  bool _isSearching = false;

  bool get _hasMore => _nextLetterIndex < _letters.length;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadNextPage();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Busca a próxima letra que tenha receitas e as adiciona à lista.
  /// Se a requisição falhar, a letra não avança e pode ser tentada de novo.
  Future<void> _loadNextPage() async {
    final api = context.read<MealApiService>();
    while (_hasMore) {
      final page = await api.fetchByFirstLetter(_letters[_nextLetterIndex]);
      _nextLetterIndex++;
      if (page.isNotEmpty) {
        _meals.addAll(page);
        return;
      }
    }
  }

  void _retryInitialLoad() {
    setState(() => _initialLoad = _loadNextPage());
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    try {
      await _loadNextPage();
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _showMessage('Digite algo para buscar.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSearching = true);
    final api = context.read<MealApiService>();
    try {
      final results = _searchMode == SearchMode.name
          ? await api.searchByName(query)
          : await api.filterByIngredient(query);
      if (!mounted) return;
      if (results.isEmpty) {
        _showMessage('Nenhuma receita encontrada para "$query".');
        return;
      }
      MealDetailScreen.open(context, results.first);
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openDetails(Meal meal) => MealDetailScreen.open(context, meal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChefVirtual'),
        actions: [
          IconButton(
            tooltip: 'Favoritos',
            icon: const Icon(Icons.star),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Receitas preparadas',
            icon: const Icon(Icons.check_circle),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CookedScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView(label: 'Carregando receitas');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: friendlyErrorMessage(snapshot.error),
              onRetry: _retryInitialLoad,
            );
          }
          return _buildCatalog(context);
        },
      ),
    );
  }

  Widget _buildCatalog(BuildContext context) {
    // A altura dos cards cresce junto com a fonte do sistema (RF10),
    // para que o nome da receita nunca seja cortado.
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final cardHeight = 150 + 2 * 20 * textScale + 24;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildSearchBar(context)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: cardHeight,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _meals.length,
            itemBuilder: (context, index) {
              final meal = _meals[index];
              return MealCard(meal: meal, onTap: () => _openDetails(meal));
            },
          ),
        ),
        SliverToBoxAdapter(child: _buildLoadMore(context)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final byName = _searchMode == SearchMode.name;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: byName
                  ? 'Buscar receita pelo nome'
                  : 'Buscar por ingrediente (em inglês)',
              hintText: byName ? 'Ex.: Lasagne' : 'Ex.: chicken',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<SearchMode>(
                segments: const [
                  ButtonSegment(
                    value: SearchMode.name,
                    label: Text('Nome'),
                    icon: Icon(Icons.menu_book),
                  ),
                  ButtonSegment(
                    value: SearchMode.ingredient,
                    label: Text('Ingrediente'),
                    icon: Icon(Icons.egg),
                  ),
                ],
                selected: {_searchMode},
                onSelectionChanged: (selection) =>
                    setState(() => _searchMode = selection.first),
              ),
              ElevatedButton.icon(
                onPressed: _isSearching ? null : _search,
                icon: _isSearching
                    ? const ButtonSpinner(label: 'Buscando')
                    : const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          Text(
            '${_meals.length} receitas carregadas',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (_hasMore)
            ElevatedButton.icon(
              onPressed: _isLoadingMore ? null : _loadMore,
              icon: _isLoadingMore
                  ? const ButtonSpinner(label: 'Carregando mais receitas')
                  : const Icon(Icons.expand_more),
              label: Text(_isLoadingMore ? 'Carregando...' : 'Carregar Mais'),
            )
          else
            Text(
              'Você chegou ao fim do catálogo!',
              style: theme.textTheme.titleMedium,
            ),
        ],
      ),
    );
  }
}
