# TMDB App — PDM2

Aplicativo Flutter que consome a API **The Movie Database (TMDB)** com login do usuário,
listagem de próximos lançamentos, favoritos e avaliações.

Disciplina: Programação para Dispositivos Móveis 2 (PDM2).

## Funcionalidades e endpoints

| # | Funcionalidade | Método e endpoint | Onde na interface |
|---|---|---|---|
| 1 | Próximos lançamentos | `GET /movie/upcoming` | Tela inicial: grade com pôster, título e data de lançamento. Rolagem infinita e "puxar para atualizar". |
| 2 | Adicionar aos favoritos | `POST /account/{account_id}/favorite` | Detalhe do filme → botão **Adicionar aos favoritos** (toque de novo para remover). |
| 3 | Avaliar filme | `POST /movie/{movie_id}/rating` | Detalhe do filme → **Avaliar filme** → slider de 0,5 a 10,0 (passo 0,5) → **Salvar avaliação**. |
| 4 | Remover avaliação | `DELETE /movie/{movie_id}/rating` | Detalhe do filme → ícone de lixeira ao lado da nota → confirmar. |

Endpoints de apoio:

| Uso | Endpoint |
|---|---|
| Login (passo 1) | `GET /authentication/token/new` |
| Login (passo 2) | `POST /authentication/token/validate_with_login` |
| Login (passo 3) | `POST /authentication/session/new` |
| Obter `account_id` | `GET /account?session_id=...` |
| Estado atual do filme (favorito/nota) | `GET /movie/{movie_id}/account_states` |
| Logout | `DELETE /authentication/session` |

## Arquitetura

Organização por *feature*, em camadas. A interface não acessa a API diretamente.

```
lib/
├── main.dart                     # inicializa SharedPreferences e ProviderScope
└── src/
    ├── app.dart                  # MaterialApp + AuthGate (login x home)
    ├── core/
    │   ├── config/env.dart       # token lido via --dart-define (fora do código)
    │   ├── errors/app_exception.dart       # tradução de erros HTTP/Dio
    │   ├── providers/core_providers.dart   # Dio (Bearer) e SharedPreferences
    │   └── widgets/error_view.dart
    └── features/
        ├── auth/
        │   ├── data/auth_repository.dart   # chamadas HTTP de login + sessão salva
        │   ├── domain/auth_session.dart    # modelos tipados
        │   └── presentation/               # providers Riverpod + LoginPage
        └── movies/
            ├── data/movies_repository.dart # upcoming, favorite, rating
            ├── domain/                     # Movie, MoviePage, AccountStates, TmdbStatus
            └── presentation/               # providers + UpcomingPage + MovieDetailPage
```

Fluxo: **View (Widget)** → **Provider/Notifier (Riverpod)** → **Repository (Dio)** → **TMDB**.

### Gerenciamento de estado (Riverpod + codegen)

- `AuthController`: sessão global (`null` = deslogado), persistida em `SharedPreferences`.
- `LoginController`: estado do formulário (`AsyncLoading` / `AsyncData` / `AsyncError`).
- `UpcomingController`: lista paginada (`AsyncValue<UpcomingState>`), com `refresh` e `loadMore`.
- `MovieAccountController(movieId)`: favorito e nota do usuário para um filme.
  Durante uma operação o estado fica `isSaving` (botões desabilitados e indicador de progresso).
  Em caso de erro o estado anterior é restaurado.

### Tratamento de erros e feedback

- Todos os erros do Dio passam por `AppException.fromDio`: timeout, sem conexão, 401, 404, 429 e
  mensagens do próprio TMDB (`status_message`).
- Telas mostram **loading** (indicador), **erro** (mensagem + "Tentar novamente") e **sucesso**.
- Operações (favoritar, avaliar, remover) mostram **SnackBar** de sucesso ou erro.
- Resposta 401 em operação autenticada encerra a sessão e volta para o login.

## Credenciais (não versionadas)

O token **não** está no código. Ele é passado na compilação via `--dart-define-from-file`.

1. Crie conta em <https://www.themoviedb.org/> e gere a chave em
   **Configurações → API**. Copie o **API Read Access Token** (token longo).
2. Copie o arquivo de exemplo:
   ```bash
   cp env.example.json env.json
   ```
3. Cole o token em `env.json`:
   ```json
   { "TMDB_READ_TOKEN": "eyJhbGciOi..." }
   ```
   `env.json` está no `.gitignore`.

## Como rodar

```bash
flutter pub get
dart run build_runner build
flutter run --dart-define-from-file=env.json
```

Testes unitários (modelos e validação da nota):

```bash
flutter test
```

## Como testar cada endpoint

1. **Login**: entre com usuário e senha da sua conta TMDB.
   (Contas criadas só com Google/Apple precisam definir uma senha no site antes.)
2. **Upcoming**: a tela inicial carrega `GET /movie/upcoming` (região BR, pt-BR).
   Role até o fim para carregar a próxima página. Puxe para baixo para atualizar.
3. **Favorito**: toque num filme → **Adicionar aos favoritos**.
   Aparece "Adicionado aos favoritos" e o botão muda para coração preenchido.
   Confira em `https://www.themoviedb.org/u/SEU_USUARIO/favorites`.
4. **Avaliar**: **Avaliar filme** → escolha a nota → **Salvar avaliação**.
   Aparece "Avaliação X registrada" e o botão mostra "Minha nota: X".
   Avaliar de novo atualiza a nota (status 12 do TMDB).
5. **Remover avaliação**: toque na lixeira → **Remover**. Aparece "Avaliação removida".
6. **Erros**: desligue a internet e tente qualquer ação. Aparece mensagem de erro
   e o estado anterior é mantido.

## Tecnologias

Flutter 3.47 · Dart 3.13 · flutter_riverpod 3 + riverpod_generator · Dio 5 ·
shared_preferences · intl
