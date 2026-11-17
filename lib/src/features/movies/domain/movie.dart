import '../../../core/config/env.dart';

/// Filme retornado pelas listas do TMDB (ex.: `/movie/upcoming`).
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;

  String? posterUrl({String size = 'w500'}) =>
      posterPath == null ? null : '${Env.tmdbImageBaseUrl}/$size$posterPath';

  String? backdropUrl({String size = 'w780'}) =>
      backdropPath == null ? null : '${Env.tmdbImageBaseUrl}/$size$backdropPath';

  factory Movie.fromJson(Map<String, dynamic> json) {
    final rawDate = json['release_date'] as String?;
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? '') as String,
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate:
          (rawDate == null || rawDate.isEmpty) ? null : DateTime.tryParse(rawDate),
    );
  }
}

/// Página de resultados paginados do TMDB.
class MoviePage {
  const MoviePage({
    required this.page,
    required this.totalPages,
    required this.results,
  });

  final int page;
  final int totalPages;
  final List<Movie> results;

  factory MoviePage.fromJson(Map<String, dynamic> json) {
    return MoviePage(
      page: json['page'] as int,
      totalPages: json['total_pages'] as int,
      results: (json['results'] as List)
          .map((e) => Movie.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
