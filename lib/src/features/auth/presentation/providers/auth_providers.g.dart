// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'74a8c44ca1382351c172062d4835390910a9e2a4';

/// Estado global da sessão.
/// `null` = deslogado; `AuthSession` = logado.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Estado global da sessão.
/// `null` = deslogado; `AuthSession` = logado.
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthSession?> {
  /// Estado global da sessão.
  /// `null` = deslogado; `AuthSession` = logado.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthSession?>(value),
    );
  }
}

String _$authControllerHash() => r'35e48b968e778ae2b661fc63a012f06d213b27ea';

/// Estado global da sessão.
/// `null` = deslogado; `AuthSession` = logado.

abstract class _$AuthController extends $Notifier<AuthSession?> {
  AuthSession? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthSession?, AuthSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthSession?, AuthSession?>,
              AuthSession?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Estado do formulário de login (carregando / sucesso / erro).

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerProvider._();

/// Estado do formulário de login (carregando / sucesso / erro).
final class LoginControllerProvider
    extends $AsyncNotifierProvider<LoginController, void> {
  /// Estado do formulário de login (carregando / sucesso / erro).
  LoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @$internal
  @override
  LoginController create() => LoginController();
}

String _$loginControllerHash() => r'2ac1138604ef93f9dccb0a4d225fa0caa8100fe7';

/// Estado do formulário de login (carregando / sucesso / erro).

abstract class _$LoginController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
