import 'package:dio/dio.dart';

/// Erro de domínio com mensagem pronta para exibir ao usuário.
class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  /// Converte erros do Dio/TMDB em mensagens amigáveis.
  factory AppException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final tmdbMessage =
        data is Map<String, dynamic> ? data['status_message'] as String? : null;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException('Tempo de conexão esgotado. Tente novamente.');
      case DioExceptionType.connectionError:
        return const AppException('Sem conexão com a internet.');
      default:
        break;
    }

    return switch (status) {
      401 => AppException(
          tmdbMessage ?? 'Não autorizado. Verifique o token ou faça login novamente.',
          statusCode: 401,
        ),
      404 => AppException(tmdbMessage ?? 'Recurso não encontrado.', statusCode: 404),
      429 => const AppException('Muitas requisições. Aguarde um instante.', statusCode: 429),
      _ => AppException(
          tmdbMessage ?? 'Erro inesperado (${status ?? 'sem status'}).',
          statusCode: status,
        ),
    };
  }

  @override
  String toString() => message;
}

/// Executa uma requisição e converte qualquer falha em [AppException].
Future<T> guardRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw AppException.fromDio(e);
  } on AppException {
    rethrow;
  } catch (_) {
    throw const AppException('Falha ao processar a resposta do servidor.');
  }
}
