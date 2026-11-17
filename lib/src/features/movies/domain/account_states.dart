/// Estado do filme na conta do usuário (`GET /movie/{id}/account_states`).
class AccountStates {
  const AccountStates({
    required this.favorite,
    this.rating,
    this.isSaving = false,
  });

  final bool favorite;

  /// Nota dada pelo usuário (0,5 a 10,0) ou `null` se não avaliou.
  final double? rating;

  /// `true` enquanto uma operação (favoritar/avaliar) está em andamento.
  final bool isSaving;

  bool get isRated => rating != null;

  AccountStates copyWith({
    bool? favorite,
    double? rating,
    bool clearRating = false,
    bool? isSaving,
  }) {
    return AccountStates(
      favorite: favorite ?? this.favorite,
      rating: clearRating ? null : (rating ?? this.rating),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  /// O campo `rated` vem como `false` ou como `{ "value": 8.5 }`.
  factory AccountStates.fromJson(Map<String, dynamic> json) {
    final rated = json['rated'];
    return AccountStates(
      favorite: json['favorite'] as bool? ?? false,
      rating: rated is Map ? (rated['value'] as num?)?.toDouble() : null,
    );
  }
}

/// Resposta padrão das operações de escrita do TMDB.
/// status_code: 1 = criado, 12 = atualizado, 13 = removido.
class TmdbStatus {
  const TmdbStatus({required this.code, required this.message});

  final int code;
  final String message;

  factory TmdbStatus.fromJson(Map<String, dynamic> json) {
    return TmdbStatus(
      code: json['status_code'] as int? ?? 0,
      message: json['status_message'] as String? ?? '',
    );
  }
}
