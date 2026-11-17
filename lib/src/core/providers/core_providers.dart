import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env.dart';

part 'core_providers.g.dart';

/// Cliente HTTP único da aplicação.
/// O token de leitura (Bearer) é enviado em todas as requisições.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: Env.tmdbBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Authorization': 'Bearer ${Env.tmdbReadToken}',
        'Accept': 'application/json',
        'Content-Type': 'application/json;charset=utf-8',
      },
    ),
  );
}

/// SharedPreferences é inicializado no `main` e injetado via override.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('sharedPreferencesProvider deve ser sobrescrito no main.');
}
