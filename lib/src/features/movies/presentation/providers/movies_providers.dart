import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/movies_repository.dart';
import '../../domain/account_states.dart';
import '../../domain/movie.dart';

part 'movies_providers.g.dart';

@Riverpod(keepAlive: true)
MoviesRepository moviesRepository(Ref ref) {
  return MoviesRepository(ref.watch(dioProvider));
}

// ---------------------------------------------------------------------------
// Upcoming (lista paginada)
// ---------------------------------------------------------------------------

class UpcomingState {
  const UpcomingState({
    required this.movies,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool get hasMore => page < totalPages;

  UpcomingState copyWith({
    List<Movie>? movies,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearError = false,
  }) {
    return UpcomingState(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}

@riverpod
class UpcomingController extends _$UpcomingController {
  @override
  Future<UpcomingState> build() async {
    final first = await ref.read(moviesRepositoryProvider).fetchUpcoming();
    return UpcomingState(
      movies: first.results,
      page: first.page,
      totalPages: first.totalPages,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    try {
      final next = await ref
          .read(moviesRepositoryProvider)
          .fetchUpcoming(page: current.page + 1);
      if (!ref.mounted) return;

      // Evita duplicados que o TMDB às vezes repete entre páginas.
      final ids = current.movies.map((m) => m.id).toSet();
      state = AsyncData(current.copyWith(
        movies: [...current.movies, ...next.results.where((m) => ids.add(m.id))],
        page: next.page,
        totalPages: next.totalPages,
        isLoadingMore: false,
      ));
    } on AppException catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(current.copyWith(isLoadingMore: false, loadMoreError: e.message));
    }
  }
}

// ---------------------------------------------------------------------------
// Ações do usuário sobre um filme (favoritar / avaliar / remover avaliação)
// ---------------------------------------------------------------------------

@riverpod
class MovieAccountController extends _$MovieAccountController {
  @override
  Future<AccountStates> build(int movieId) async {
    final session = _requireSession(watch: true);
    return ref.read(moviesRepositoryProvider).fetchAccountStates(
          movieId: movieId,
          sessionId: session.sessionId,
        );
  }

  /// Adiciona (ou remove) o filme dos favoritos. Retorna mensagem de feedback.
  Future<String> toggleFavorite() async {
    return _run((current, session) async {
      final newValue = !current.favorite;
      await ref.read(moviesRepositoryProvider).setFavorite(
            accountId: session.accountId,
            sessionId: session.sessionId,
            movieId: movieId,
            favorite: newValue,
          );
      return (
        current.copyWith(favorite: newValue),
        newValue ? 'Adicionado aos favoritos' : 'Removido dos favoritos',
      );
    });
  }

  /// Registra/atualiza a nota (0,5 a 10,0).
  Future<String> rate(double value) async {
    return _run((current, session) async {
      final status = await ref.read(moviesRepositoryProvider).addRating(
            movieId: movieId,
            sessionId: session.sessionId,
            value: value,
          );
      final verb = status.code == 12 ? 'atualizada' : 'registrada';
      return (
        current.copyWith(rating: value),
        'Avaliação ${value.toStringAsFixed(1)} $verb',
      );
    });
  }

  /// Remove a avaliação existente.
  Future<String> deleteRating() async {
    return _run((current, session) async {
      await ref.read(moviesRepositoryProvider).deleteRating(
            movieId: movieId,
            sessionId: session.sessionId,
          );
      return (current.copyWith(clearRating: true), 'Avaliação removida');
    });
  }

  /// Executa uma operação mantendo os dados na tela (`isSaving`)
  /// e restaurando o estado anterior em caso de erro.
  Future<String> _run(
    Future<(AccountStates, String)> Function(AccountStates current, AuthSession session)
        action,
  ) async {
    final current = state.requireValue;
    final session = _requireSession();

    state = AsyncData(current.copyWith(isSaving: true));
    try {
      final (updated, message) = await action(current, session);
      if (ref.mounted) state = AsyncData(updated.copyWith(isSaving: false));
      return message;
    } on AppException catch (e) {
      if (ref.mounted) state = AsyncData(current.copyWith(isSaving: false));
      if (e.statusCode == 401) {
        await ref.read(authControllerProvider.notifier).logout();
        throw const AppException('Sessão expirada. Faça login novamente.');
      }
      rethrow;
    }
  }

  AuthSession _requireSession({bool watch = false}) {
    final session = watch
        ? ref.watch(authControllerProvider)
        : ref.read(authControllerProvider);
    if (session == null) {
      throw const AppException('Faça login para usar esta função.', statusCode: 401);
    }
    return session;
  }
}
