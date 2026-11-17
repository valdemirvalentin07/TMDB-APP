import 'package:flutter/material.dart';

/// Bottom sheet para escolher a nota: 0,5 a 10,0 em passos de 0,5.
/// Retorna a nota escolhida ou `null` se cancelado.
Future<double?> showRatingSheet(BuildContext context, {double? initial}) {
  return showModalBottomSheet<double>(
    context: context,
    showDragHandle: true,
    builder: (_) => _RatingSheet(initial: initial ?? 5.0),
  );
}

class _RatingSheet extends StatefulWidget {
  const _RatingSheet({required this.initial});

  final double initial;

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  late double _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sua avaliação', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              _value.toStringAsFixed(1).replaceAll('.', ','),
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: _value,
              min: 0.5,
              max: 10.0,
              divisions: 19, // (10 - 0,5) / 0,5 = 19 passos
              label: _value.toStringAsFixed(1),
              onChanged: (v) => setState(() => _value = (v * 2).round() / 2),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('0,5'), Text('10,0')],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, _value),
              icon: const Icon(Icons.check),
              label: const Text('Salvar avaliação'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }
}
