import 'package:flutter/material.dart';

/// Foto da receita com placeholder para quando não há imagem
/// ou o download falha (RF01) — a tela nunca quebra.
class MealImage extends StatelessWidget {
  const MealImage({
    super.key,
    required this.url,
    required this.mealName,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final String mealName;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null) return _Placeholder(mealName: mealName);

    return Image.network(
      imageUrl,
      fit: fit,
      semanticLabel: 'Foto da receita $mealName',
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) =>
          _Placeholder(mealName: mealName),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.mealName});

  final String mealName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      image: true,
      label: 'Imagem indisponível para $mealName',
      child: ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.restaurant,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
