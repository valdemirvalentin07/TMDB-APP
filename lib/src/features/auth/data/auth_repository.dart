import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/auth_session.dart';

/// Comunicação com os endpoints de autenticação do TMDB
/// e persistência local da sessão.
class AuthRepository {
  AuthRepository(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  static const _kSessionId = 'tmdb_session_id';
  static const _kAccountId = 'tmdb_account_id';
  static const _kUsername = 'tmdb_username';

  /// Fluxo de login:
  /// 1. GET  /authentication/token/new
  /// 2. POST /authentication/token/validate_with_login
  /// 3. POST /authentication/session/new
  /// 4. GET  /account (para obter o account_id)
  Future<AuthSession> login(String username, String password) {
    return guardRequest(() async {
      final tokenResp = await _dio.get('/authentication/token/new');
      final requestToken = tokenResp.data['request_token'] as String;

      await _dio.post(
        '/authentication/token/validate_with_login',
        data: {
          'username': username,
          'password': password,
          'request_token': requestToken,
        },
      );

      final sessionResp = await _dio.post(
        '/authentication/session/new',
        data: {'request_token': requestToken},
      );
      final sessionId = sessionResp.data['session_id'] as String;

      final account = await fetchAccount(sessionId);

      final session = AuthSession(
        sessionId: sessionId,
        accountId: account.id,
        username: account.username,
      );
      await _save(session);
      return session;
    });
  }

  Future<AccountModel> fetchAccount(String sessionId) {
    return guardRequest(() async {
      final resp = await _dio.get(
        '/account',
        queryParameters: {'session_id': sessionId},
      );
      return AccountModel.fromJson(resp.data as Map<String, dynamic>);
    });
  }

  /// Encerra a sessão no TMDB (melhor esforço) e limpa os dados locais.
  Future<void> logout(String sessionId) async {
    try {
      await _dio.delete(
        '/authentication/session',
        data: {'session_id': sessionId},
      );
    } on DioException {
      // Mesmo se falhar no servidor, a sessão local é removida.
    }
    await _prefs.remove(_kSessionId);
    await _prefs.remove(_kAccountId);
    await _prefs.remove(_kUsername);
  }

  AuthSession? loadSavedSession() {
    final sessionId = _prefs.getString(_kSessionId);
    final accountId = _prefs.getInt(_kAccountId);
    final username = _prefs.getString(_kUsername);
    if (sessionId == null || accountId == null) return null;
    return AuthSession(
      sessionId: sessionId,
      accountId: accountId,
      username: username ?? '',
    );
  }

  Future<void> _save(AuthSession s) async {
    await _prefs.setString(_kSessionId, s.sessionId);
    await _prefs.setInt(_kAccountId, s.accountId);
    await _prefs.setString(_kUsername, s.username);
  }
}
