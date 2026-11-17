import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/error_view.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/movie.dart';
import 'movie_detail_page.dart';
import 'providers/movies_providers.dart';
import 'widgets/movie_card.dart';

/// Lista de próximos lançamentos (GET /movie/upcoming).
class UpcomingPage extends ConsumerStatefulWidget {
  const UpcomingPage({super.key});

  @override
  ConsumerState<UpcomingPage> createState() => _UpcomingPageState();
}

class _UpcomingPageState extends ConsumerState<UpcomingPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 400) {
        ref.read(upcomingControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openDetail(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movie)),
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('A sessão TMDB deste aparelho será encerrada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sair')),
        ],
      ),
    );
    if (ok == true) await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = ref.watch(upcomingControllerProvider);
    final username = ref.watch(authControllerProvider)?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Próximos lançamentos'),
        actions: [
          if (username.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(child: Text('@$username')),
            ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: switch (upcoming) {
        AsyncValue(:final value?) => RefreshIndicator(
            onRefresh: () => ref.read(upcomingControllerProvider.notifier).refresh(),
            child: value.movies.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 200),
                    Center(child: Text('Nenhum lançamento encontrado.')),
                  ])
                : CustomScrollView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverGrid.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 0.52,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: value.movies.length,
                          itemBuilder: (_, i) => MovieCard(
                            movie: value.movies[i],
                            onTap: () => _openDetail(value.movies[i]),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _Footer(state: value)),
                    ],
                  ),
          ),
        AsyncValue(:final error?) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(upcomingControllerProvider),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({required this.state});

  final UpcomingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(state.loadMoreError!),
            TextButton(
              onPressed: () => ref.read(upcomingControllerProvider.notifier).loadMore(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}
