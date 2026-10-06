import '../services/local_storage_service.dart';
import 'meal_collection_provider.dart';

/// Receitas favoritas do usuário (RF04/RF05).
class FavoritesProvider extends MealCollectionProvider {
  FavoritesProvider(LocalStorageService storage) : super(storage, 'favorites');
}
