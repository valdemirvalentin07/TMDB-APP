import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/account_states.dart';
import '../domain/movie.dart';

/// Comunicação com os endpoints de filmes e conta do TMDB.
class MoviesRepository {
  MoviesRepository(this._dio);

  final Dio _dio;

  /// GET /movie/upcoming — próximos lançamentos.
  Future<MoviePage> fetchUpcoming({int page = 1}) {
    return guardRequest(() async {
      final resp = await _dio.get(
        '/movie/upcoming',
        queryParameters: {
          'language': Env.language,
          'region': Env.region,
          'page': page,
        },
      );
      return MoviePage.fromJson(resp.data as Map<String, dynamic>);
    });
  }

  /// GET /movie/{movie_id}/account_states — favorito/nota atuais do usuário.
  Future<AccountStates> fetchAccountStates({
    required int movieId,
    required String sessionId,
  }) {
    return guardRequest(() async {
      final resp = await _dio.get(
        '/movie/$movieId/account_states',
        queryParameters: {'session_id': sessionId},
      );
      return AccountStates.fromJson(resp.data as Map<String, dynamic>);
    });
  }

  /// POST /account/{account_id}/favorite — adiciona/remove dos favoritos.
  Future<TmdbStatus> setFavorite({
    required int accountId,
    required String sessionId,
    required int movieId,
    required bool favorite,
  }) {
    return guardRequest(() async {
      final resp = await _dio.post(
        '/account/$accountId/favorite',
        queryParameters: {'session_id': sessionId},
        data: {
          'media_type': 'movie',
          'media_id': movieId,
          'favorite': favorite,
        },
      );
      return TmdbStatus.fromJson(resp.data as Map<String, dynamic>);
    });
  }

  /// POST /movie/{movie_id}/rating — avalia (0,5 a 10,0, passo 0,5).
  Future<TmdbStatus> addRating({
    required int movieId,
    required String sessionId,
    required double value,
  }) {
    if (!isValidRating(value)) {
      throw const AppException('A nota deve ir de 0,5 a 10,0 em passos de 0,5.');
    }
    return guardRequest(() async {
      final resp = await _dio.post(
        '/movie/$movieId/rating',
        queryParameters: {'session_id': sessionId},
        data: {'value': value},
      );
      return TmdbStatus.fromJson(resp.data as Map<String, dynamic>);
    });
  }

  /// DELETE /movie/{movie_id}/rating — remove a avaliação.
  Future<TmdbStatus> deleteRating({
    required int movieId,
    required String sessionId,
  }) {
    return guardRequest(() async {
      final resp = await _dio.delete(
        '/movie/$movieId/rating',
        queryParameters: {'session_id': sessionId},
      );
      return TmdbStatus.fromJson(resp.data as Map<String, dynamic>);
    });
  }

  static bool isValidRating(double v) =>
      v >= 0.5 && v <= 10.0 && (v * 2) == (v * 2).roundToDouble();
}
