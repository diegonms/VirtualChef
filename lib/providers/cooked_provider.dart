import '../services/local_storage_service.dart';
import 'meal_collection_provider.dart';

/// Receitas que o usuário já preparou — os itens "consumidos" do RF07.
class CookedProvider extends MealCollectionProvider {
  CookedProvider(LocalStorageService storage) : super(storage, 'cooked');
}
