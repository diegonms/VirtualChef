import 'package:flutter/material.dart';

/// Tema Material 3. As cores geradas pelo ColorScheme garantem contraste
/// adequado entre texto e fundo (RF10).
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFFB4441C));

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    // Áreas de toque de no mínimo 48x48 (RF10).
    materialTapTargetSize: MaterialTapTargetSize.padded,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(64, 48)),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
