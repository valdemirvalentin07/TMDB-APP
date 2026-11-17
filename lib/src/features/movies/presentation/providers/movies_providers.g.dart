// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movies_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(moviesRepository)
final moviesRepositoryProvider = MoviesRepositoryProvider._();

final class MoviesRepositoryProvider
    extends
        $FunctionalProvider<
          MoviesRepository,
          MoviesRepository,
          MoviesRepository
        >
    with $Provider<MoviesRepository> {
  MoviesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moviesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moviesRepositoryHash();

  @$internal
  @override
  $ProviderElement<MoviesRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MoviesRepository create(Ref ref) {
    return moviesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoviesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoviesRepository>(value),
    );
  }
}

String _$moviesRepositoryHash() => r'a5d95cc7f30bf4b5ac7123f99e12cac48e1d75b2';

@ProviderFor(UpcomingController)
final upcomingControllerProvider = UpcomingControllerProvider._();

final class UpcomingControllerProvider
    extends $AsyncNotifierProvider<UpcomingController, UpcomingState> {
  UpcomingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingControllerHash();

  @$internal
  @override
  UpcomingController create() => UpcomingController();
}

String _$upcomingControllerHash() =>
    r'2ccc20726e90066d9bd3c6662a6c87e3ec8ec4e5';

abstract class _$UpcomingController extends $AsyncNotifier<UpcomingState> {
  FutureOr<UpcomingState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UpcomingState>, UpcomingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UpcomingState>, UpcomingState>,
              AsyncValue<UpcomingState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(MovieAccountController)
final movieAccountControllerProvider = MovieAccountControllerFamily._();

final class MovieAccountControllerProvider
    extends $AsyncNotifierProvider<MovieAccountController, AccountStates> {
  MovieAccountControllerProvider._({
    required MovieAccountControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'movieAccountControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movieAccountControllerHash();

  @override
  String toString() {
    return r'movieAccountControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MovieAccountController create() => MovieAccountController();

  @override
  bool operator ==(Object other) {
    return other is MovieAccountControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movieAccountControllerHash() =>
    r'afec9e8e939196960ccf19317cd9be40cccc92af';

final class MovieAccountControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MovieAccountController,
          AsyncValue<AccountStates>,
          AccountStates,
          FutureOr<AccountStates>,
          int
        > {
  MovieAccountControllerFamily._()
    : super(
        retry: null,
        name: r'movieAccountControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MovieAccountControllerProvider call(int movieId) =>
      MovieAccountControllerProvider._(argument: movieId, from: this);

  @override
  String toString() => r'movieAccountControllerProvider';
}

abstract class _$MovieAccountController extends $AsyncNotifier<AccountStates> {
  late final _$args = ref.$arg as int;
  int get movieId => _$args;

  FutureOr<AccountStates> build(int movieId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AccountStates>, AccountStates>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AccountStates>, AccountStates>,
              AsyncValue<AccountStates>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
