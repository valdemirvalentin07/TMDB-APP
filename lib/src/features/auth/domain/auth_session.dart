/// Sessão autenticada do usuário no TMDB.
class AuthSession {
  const AuthSession({
    required this.sessionId,
    required this.accountId,
    required this.username,
  });

  final String sessionId;
  final int accountId;
  final String username;
}

/// Dados da conta retornados por `GET /account`.
class AccountModel {
  const AccountModel({required this.id, required this.username, this.name});

  final int id;
  final String username;
  final String? name;

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      name: json['name'] as String?,
    );
  }
}
