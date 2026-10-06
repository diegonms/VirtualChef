# ChefVirtual — Catálogo de Receitas

Aplicativo Flutter para explorar receitas do mundo todo, buscar por nome ou
ingrediente, favoritar receitas e marcar as que você já preparou.

Projeto somativo da disciplina **Desenvolvimento Mobile Híbrido** (BSI).

## Tema e configuração

| Item | Escolha |
|------|---------|
| Tema | Receitas culinárias |
| API | [TheMealDB](https://www.themealdb.com/api.php) (gratuita, sem cadastro) |
| Persistência | Local — `shared_preferences` |
| Login | Local — cadastro/login salvo no aparelho (senha com hash SHA-256) |
| "Consumidos" | Receitas **preparadas** |

### Endpoints usados

| Uso | Endpoint |
|-----|----------|
| Catálogo paginado (RF01) | `search.php?f={letra}`: cada página é uma letra inicial (a, b, c…) |
| Busca por nome (RF08) | `search.php?s={nome}` |
| Busca por ingrediente (RF08) | `filter.php?i={ingrediente}` (em inglês, ex.: `chicken`) |
| Detalhes (RF03) | `lookup.php?i={id}` |

## Como executar

1. Instale o Flutter SDK: https://docs.flutter.dev/get-started/install
2. Na pasta do projeto, gere as pastas de plataforma (os arquivos existentes não são sobrescritos):
   ```bash
   flutter create . --project-name chef_virtual --platforms=android,ios,web
   ```
3. Instale as dependências e rode:
   ```bash
   flutter pub get
   flutter run
   ```
4. Testes e análise estática:
   ```bash
   flutter test
   flutter analyze
   ```

> **Android (build release):** confirme que `android/app/src/main/AndroidManifest.xml`
> tem `<uses-permission android:name="android.permission.INTERNET"/>`, porque sem
> essa permissão o APK de release não acessa a API.

## Estrutura

```
lib/
├── main.dart                     # Providers + AuthGate (navegação condicional)
├── theme.dart                    # Tema Material 3, áreas de toque ≥ 48dp
├── models/meal.dart              # Modelo Meal / Ingredient
├── services/
│   ├── meal_api_service.dart     # Cliente HTTP do TheMealDB + erros amigáveis
│   └── local_storage_service.dart# shared_preferences (usuários, sessão, listas)
├── providers/
│   ├── auth_provider.dart        # Sessão / login / cadastro
│   ├── meal_collection_provider.dart # Base: lista persistida por usuário
│   ├── favorites_provider.dart   # Favoritos
│   └── cooked_provider.dart      # Receitas preparadas ("consumidos")
├── screens/
│   ├── login_screen.dart
│   ├── catalog_screen.dart       # Grade + Carregar Mais + Busca
│   ├── meal_detail_screen.dart
│   ├── favorites_screen.dart
│   └── cooked_screen.dart
└── widgets/
    ├── meal_card.dart
    ├── meal_image.dart           # Imagem com placeholder
    ├── saved_meals_view.dart     # Lista reativa (favoritos/preparadas)
    └── feedback_views.dart       # Loading, erro, vazio
```

## Requisitos funcionais

| RF | Descrição | Implementado | Arquivo principal |
|----|-----------|--------------|-------------------|
| RF01 | Catálogo em GridView + "Carregar Mais" + placeholder | Sim | `lib/screens/catalog_screen.dart` |
| RF02 | Navegação para detalhes com Navigator | Sim | `lib/screens/meal_detail_screen.dart` (`MealDetailScreen.open`) |
| RF03 | Detalhes via segunda requisição | Sim | `lib/screens/meal_detail_screen.dart` |
| RF04 | Favoritos com Provider | Sim | `lib/providers/favorites_provider.dart` |
| RF05 | Tela de favoritos reativa | Sim | `lib/screens/favorites_screen.dart` |
| RF06 | Persistência local | Sim | `lib/services/local_storage_service.dart` |
| RF07 | Login local + receitas preparadas | Sim | `lib/providers/auth_provider.dart`, `lib/screens/cooked_screen.dart` |
| RF08 | Busca com TextField + botão "Buscar" | Sim | `lib/screens/catalog_screen.dart` (`_search`) |
| RF09 | CircularProgressIndicator + erros amigáveis (FutureBuilder) | Sim | `lib/widgets/feedback_views.dart` |
| RF10 | Acessibilidade (Semantics, contraste, fonte, toque) | Sim | `lib/widgets/meal_card.dart`, `lib/theme.dart` |

### Acessibilidade (RF10): o que foi feito

- Cards, imagens e placeholders têm rótulos para TalkBack/VoiceOver; todo `IconButton` tem `tooltip`.
- Títulos de seção marcados com `Semantics(header: true)`; mensagens de erro com `liveRegion`.
- A altura dos cards da grade é calculada a partir de `MediaQuery.textScalerOf`, então o layout não quebra com fonte grande.
- Cores do `ColorScheme.fromSeed` (Material 3) com contraste adequado; botões com altura mínima de 48dp.
