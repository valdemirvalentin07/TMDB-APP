import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env.dart';
import 'core/widgets/error_view.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/movies/presentation/upcoming_page.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ao deslogar (manual ou sessão expirada), volta para a raiz.
    ref.listen(authControllerProvider, (prev, next) {
      if (prev != null && next == null) {
        _navigatorKey.currentState?.popUntil((r) => r.isFirst);
      }
    });

    return MaterialApp(
      title: 'TMDB App',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF01B4E4), // azul TMDB
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF01B4E4),
        brightness: Brightness.dark,
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Env.hasToken) {
      return const Scaffold(
        body: ErrorView(
          message: 'Token TMDB não configurado.\n\n'
              'Crie o arquivo env.json (veja env.example.json) e rode:\n'
              'flutter run --dart-define-from-file=env.json',
        ),
      );
    }

    final session = ref.watch(authControllerProvider);
    return session == null ? const LoginPage() : const UpcomingPage();
  }
}
