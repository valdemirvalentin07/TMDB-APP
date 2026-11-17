import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb_app/src/features/movies/data/movies_repository.dart';
import 'package:tmdb_app/src/features/movies/domain/account_states.dart';
import 'package:tmdb_app/src/features/movies/domain/movie.dart';

void main() {
  group('Movie.fromJson', () {
    test('converte campos do /movie/upcoming', () {
      final movie = Movie.fromJson({
        'id': 42,
        'title': 'Filme Teste',
        'overview': 'Sinopse',
        'vote_average': 7.5,
        'poster_path': '/abc.jpg',
        'release_date': '2026-12-25',
      });
      expect(movie.id, 42);
      expect(movie.title, 'Filme Teste');
      expect(movie.releaseDate, DateTime(2026, 12, 25));
      expect(movie.posterUrl(), 'https://image.tmdb.org/t/p/w500/abc.jpg');
    });

    test('aceita data vazia e poster nulo', () {
      final movie = Movie.fromJson({'id': 1, 'title': 'X', 'release_date': ''});
      expect(movie.releaseDate, isNull);
      expect(movie.posterUrl(), isNull);
    });
  });

  group('AccountStates.fromJson', () {
    test('rated = false significa sem nota', () {
      final s = AccountStates.fromJson({'favorite': true, 'rated': false});
      expect(s.favorite, isTrue);
      expect(s.isRated, isFalse);
    });

    test('rated = {value} traz a nota', () {
      final s = AccountStates.fromJson({'favorite': false, 'rated': {'value': 8.5}});
      expect(s.rating, 8.5);
    });
  });

  group('Validação de nota (0,5 a 10,0, passo 0,5)', () {
    test('valores válidos', () {
      for (final v in [0.5, 1.0, 7.5, 10.0]) {
        expect(MoviesRepository.isValidRating(v), isTrue, reason: '$v');
      }
    });
    test('valores inválidos', () {
      for (final v in [0.0, 0.3, 7.25, 10.5]) {
        expect(MoviesRepository.isValidRating(v), isFalse, reason: '$v');
      }
    });
  });
}
