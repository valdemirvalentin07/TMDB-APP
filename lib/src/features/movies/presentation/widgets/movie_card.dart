import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/movie.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');

String formatReleaseDate(DateTime? date) =>
    date == null ? 'Data a confirmar' : _dateFormat.format(date);

/// Card com imagem, título e data de lançamento.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, required this.onTap});

  final Movie movie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'poster-${movie.id}',
                child: MoviePoster(url: movie.posterUrl(size: 'w342')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.event, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(formatReleaseDate(movie.releaseDate),
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoviePoster extends StatelessWidget {
  const MoviePoster({super.key, required this.url, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.movie_outlined, size: 40)),
    );
    if (url == null) return placeholder;
    return Image.network(
      url!,
      fit: fit,
      loadingBuilder: (_, child, progress) => progress == null ? child : placeholder,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
