import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_provider.dart';
import 'providers/cooked_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/catalog_screen.dart';
import 'screens/login_screen.dart';
import 'services/local_storage_service.dart';
import 'services/meal_api_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ChefVirtualApp(storage: LocalStorageService(prefs)));
}

class ChefVirtualApp extends StatelessWidget {
  const ChefVirtualApp({super.key, required this.storage});

  final LocalStorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MealApiService>(create: (_) => MealApiService()),
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        // As listas acompanham o usuário logado: ao trocar de sessão,
        // o ProxyProvider carrega os dados do novo usuário.
        ChangeNotifierProxyProvider<AuthProvider, FavoritesProvider>(
          create: (_) => FavoritesProvider(storage),
          update: (_, auth, favorites) => favorites!..setUser(auth.username),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CookedProvider>(
          create: (_) => CookedProvider(storage),
          update: (_, auth, cooked) => cooked!..setUser(auth.username),
        ),
      ],
      child: MaterialApp(
        title: 'ChefVirtual',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Navegação condicional (RF07): o catálogo só aparece após o login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.select<AuthProvider, bool>(
      (auth) => auth.isLoggedIn,
    );
    return isLoggedIn ? const CatalogScreen() : const LoginScreen();
  }
}
