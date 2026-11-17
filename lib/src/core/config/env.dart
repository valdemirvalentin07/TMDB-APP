/// Configuração lida em tempo de compilação.
///
/// O token NÃO fica no código-fonte: ele é injetado com
/// `flutter run --dart-define-from-file=env.json`.
/// O arquivo `env.json` está no `.gitignore` (veja `env.example.json`).
abstract final class Env {
  static const tmdbReadToken = String.fromEnvironment('TMDB_READ_TOKEN');

  static bool get hasToken => tmdbReadToken.isNotEmpty;

  static const tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  static const language = 'pt-BR';
  static const region = 'BR';
}
