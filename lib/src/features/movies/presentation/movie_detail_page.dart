import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/account_states.dart';
import '../domain/movie.dart';
import 'providers/movies_providers.dart';
import 'widgets/movie_card.dart';
import 'widgets/rating_sheet.dart';

/// Detalhe do filme com as ações autenticadas:
/// favoritar, avaliar e remover avaliação.
class MovieDetailPage extends ConsumerWidget {
  const MovieDetailPage({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: MoviePoster(url: movie.backdropUrl() ?? movie.posterUrl()),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Hero(
                            tag: 'poster-${movie.id}',
                            child: MoviePoster(url: movie.posterUrl(size: 'w342')),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie.title, style: theme.textTheme.titleLarge),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.event,
                            text: 'Lançamento: ${formatReleaseDate(movie.releaseDate)}',
                          ),
                          _InfoRow(
                            icon: Icons.star_rate_rounded,
                            text: 'Média TMDB: ${movie.voteAverage.toStringAsFixed(1)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _AccountActions(movieId: movie.id),
                const SizedBox(height: 20),
                Text('Sinopse', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(movie.overview.isEmpty ? 'Sinopse indisponível.' : movie.overview),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ]),
    );
  }
}

/// Bloco que consome `movieAccountControllerProvider(movieId)`
/// e trata carregando / erro / dados.
class _AccountActions extends ConsumerWidget {
  const _AccountActions({required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = movieAccountControllerProvider(movieId);
    final asyncStates = ref.watch(provider);

    return switch (asyncStates) {
      AsyncValue(:final value?) => _ActionsContent(movieId: movieId, states: value),
      AsyncValue(:final error?) => Card(
          child: ListTile(
            leading: const Icon(Icons.error_outline),
            title: Text(error.toString()),
            trailing: IconButton(
              tooltip: 'Tentar novamente',
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(provider),
            ),
          ),
        ),
      _ => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
    };
  }
}

class _ActionsContent extends ConsumerWidget {
  const _ActionsContent({required this.movieId, required this.states});

  final int movieId;
  final AccountStates states;

  /// Executa a ação e mostra SnackBar de sucesso ou erro.
  Future<void> _perform(
    BuildContext context,
    Future<String> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    try {
      final message = await action();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: errorColor));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover avaliação?'),
        content: Text('Sua nota ${states.rating!.toStringAsFixed(1)} será apagada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await _perform(
        context,
        () => ref.read(movieAccountControllerProvider(movieId).notifier).deleteRating(),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(movieAccountControllerProvider(movieId).notifier);
    final busy = states.isSaving;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Minha conta', style: theme.textTheme.titleMedium),
                const Spacer(),
                if (busy)
                  const SizedBox(
                      width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 12),
            // --- Favorito -------------------------------------------------
            states.favorite
                ? FilledButton.tonalIcon(
                    onPressed: busy ? null : () => _perform(context, notifier.toggleFavorite),
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    label: const Text('Nos favoritos (toque para remover)'),
                  )
                : OutlinedButton.icon(
                    onPressed: busy ? null : () => _perform(context, notifier.toggleFavorite),
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Adicionar aos favoritos'),
                  ),
            const SizedBox(height: 8),
            // --- Avaliação ------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () async {
                            final value =
                                await showRatingSheet(context, initial: states.rating);
                            if (value != null && context.mounted) {
                              await _perform(context, () => notifier.rate(value));
                            }
                          },
                    icon: const Icon(Icons.star_rounded),
                    label: Text(states.isRated
                        ? 'Minha nota: ${states.rating!.toStringAsFixed(1)}'
                        : 'Avaliar filme'),
                  ),
                ),
                if (states.isRated) ...[
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: 'Remover avaliação',
                    onPressed: busy ? null : () => _confirmDelete(context, ref),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
