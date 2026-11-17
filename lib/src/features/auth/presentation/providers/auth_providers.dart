import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_session.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(sharedPreferencesProvider),
  );
}

/// Estado global da sessão.
/// `null` = deslogado; `AuthSession` = logado.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthSession? build() {
    return ref.read(authRepositoryProvider).loadSavedSession();
  }

  void setSession(AuthSession session) => state = session;

  Future<void> logout() async {
    final session = state;
    if (session != null) {
      await ref.read(authRepositoryProvider).logout(session.sessionId);
    }
    state = null;
  }
}

/// Estado do formulário de login (carregando / sucesso / erro).
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> submit(String username, String password) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(username, password),
    );
    if (!ref.mounted) return;

    if (result case AsyncData(:final value)) {
      ref.read(authControllerProvider.notifier).setSession(value);
      state = const AsyncData(null);
    } else if (result case AsyncError(:final error, :final stackTrace)) {
      state = AsyncError(error, stackTrace);
    }
  }
}
