import 'dart:async';

typedef Lazy<T> = T Function();

/// Representa o resultado de uma operação que pode falhar.
///
/// - [Failure] → algo deu errado (convenção: lado esquerdo)
/// - [Success] → operação concluída (convenção: lado direito)
///
/// Inspirado no Either monad (programação funcional) e no tipo `Result` de
/// Rust, Swift e Kotlin Arrow — amplamente reconhecido no mercado.
///
/// ### Criando um Result
/// ```dart
/// Result<String, int> parse(String s) {
///   final n = int.tryParse(s);
///   if (n == null) return Result.failure('Não é um número: $s');
///   return Result.success(n);
/// }
/// ```
///
/// ### Encadeando (railway-oriented)
/// ```dart
/// parse('42')
///   .map((n) => n * 2)
///   .fold(
///     (err)   => print('Erro: $err'),
///     (value) => print('Valor: $value'),
///   );
/// ```
sealed class Result<F, S> {
  const Result();

  // ── Criação ──────────────────────────────────────────────────────────────

  /// Cria um [Success] com [value].
  ///
  /// ```dart
  /// Result.success(42)                    // inferência de tipo
  /// Result.success<String, int>(42)       // tipo explícito
  /// ```
  static Result<F, S> success<F, S>(S value) => Success(value);

  /// Cria um [Failure] com [error].
  ///
  /// ```dart
  /// Result.failure('erro')                // inferência de tipo
  /// Result.failure<String, int>('erro')   // tipo explícito
  /// ```
  static Result<F, S> failure<F, S>(F error) => Failure(error);

  /// Cria um [Success] se [test] for `true`, senão um [Failure].
  ///
  /// ```dart
  /// Result.cond(cpf.length == 11, cpf, 'CPF deve ter 11 dígitos');
  /// ```
  static Result<F, S> cond<F, S>(bool test, S success, F failure) =>
      test ? Success(success) : Failure(failure);

  /// Versão lazy de [cond] — os valores só são avaliados se necessário.
  static Result<F, S> condLazy<F, S>(
    bool test,
    Lazy<S> success,
    Lazy<F> failure,
  ) =>
      test ? Success(success()) : Failure(failure());

  /// Executa [fn] e captura qualquer [Exception] ou [Error], retornando-o
  /// como [Failure] mapeado via [onError].
  ///
  /// ```dart
  /// final result = Result.guard(
  ///   () => jsonDecode(raw),
  ///   onError: (e) => 'JSON inválido: $e',
  /// );
  /// ```
  static Result<F, S> guard<F, S>(
    S Function() fn, {
    required F Function(Object error) onError,
  }) {
    try {
      return Success(fn());
    } catch (e) {
      return Failure(onError(e));
    }
  }

  /// Versão tipada de [guard]: captura apenas exceções do tipo [E].
  ///
  /// ```dart
  /// Result.guardTyped<FormatException, int>(
  ///   () => int.parse(value),
  ///   onError: (e) => 'Formato inválido',
  /// );
  /// ```
  static Result<F, S> guardTyped<E extends Object, F, S>(
    S Function() fn, {
    required F Function(E error) onError,
  }) {
    try {
      return Success(fn());
    } on E catch (e) {
      return Failure(onError(e));
    }
  }

  /// Executa [fn] async e captura qualquer exceção, mapeando via [onError].
  ///
  /// Principal ponto de integração com HTTP, banco de dados e qualquer
  /// operação assíncrona que pode lançar exceção.
  ///
  /// ```dart
  /// final result = await Result.tryAsync(
  ///   () => http.get(Uri.parse('...')),
  ///   onError: (e, _) => AppError('Requisição falhou: $e'),
  /// );
  ///
  /// result
  ///   .then(checkStatus)
  ///   .fold(
  ///     (err)  => showError(err.message),
  ///     (resp) => updateUI(resp),
  ///   );
  /// ```
  static Future<Result<F, S>> tryAsync<F, S>(
    Future<S> Function() fn, {
    required F Function(Object error, StackTrace stack) onError,
  }) async {
    try {
      return Success(await fn());
    } catch (e, st) {
      return Failure(onError(e, st));
    }
  }

  /// Versão tipada de [tryAsync]: captura apenas exceções do tipo [E].
  ///
  /// ```dart
  /// final result = await Result.tryAsyncTyped<HttpException, AppError, Data>(
  ///   () => fetchData(),
  ///   onError: (e, _) => AppError(e.message),
  /// );
  /// ```
  static Future<Result<F, S>> tryAsyncTyped<E extends Object, F, S>(
    Future<S> Function() fn, {
    required F Function(E error, StackTrace stack) onError,
  }) async {
    try {
      return Success(await fn());
    } on E catch (e, st) {
      return Failure(onError(e, st));
    }
  }

  // ── Estado ───────────────────────────────────────────────────────────────

  /// `true` se este resultado é um [Success].
  bool get isSuccess => this is Success<F, S>;

  /// `true` se este resultado é um [Failure].
  bool get isFailure => this is Failure<F, S>;

  /// Acessa o valor de sucesso. Lança [StateError] se for [Failure].
  ///
  /// Prefira verificar [isSuccess] antes, ou use [fold] / [getOrElse].
  S get successValue => fold(
        (_) => throw StateError('successValue acessado em um Failure. '
            'Verifique isSuccess antes ou use fold/getOrElse.'),
        (s) => s,
      );

  /// Acessa o valor de falha. Lança [StateError] se for [Success].
  ///
  /// Prefira verificar [isFailure] antes, ou use [fold].
  F get failureValue => fold(
        (f) => f,
        (_) => throw StateError('failureValue acessado em um Success. '
            'Verifique isFailure antes ou use fold.'),
      );

  // ── Transformações ───────────────────────────────────────────────────────

  /// Colapsa Success e Failure num único tipo [T].
  ///
  /// ```dart
  /// final msg = result.fold(
  ///   (err)   => 'Erro: $err',
  ///   (value) => 'Ok: $value',
  /// );
  /// ```
  T fold<T>(T Function(F failure) onFailure, T Function(S success) onSuccess);

  /// Transforma o valor de [Success] sem alterar um [Failure].
  ///
  /// ```dart
  /// result.map((user) => user.name);
  /// ```
  Result<F, T> map<T>(T Function(S success) fn);

  /// Transforma o valor de [Failure] sem alterar um [Success].
  Result<T, S> mapFailure<T>(T Function(F failure) fn);

  /// Flatmap — transforma [Success] numa nova operação que pode falhar.
  ///
  /// ```dart
  /// validateCPF(cpf).then((_) => validateEmail(email));
  /// ```
  Result<F, T> then<T>(Result<F, T> Function(S success) fn);

  /// Flatmap do lado [Failure].
  Result<T, S> thenFailure<T>(Result<T, S> Function(F failure) fn);

  /// Transforma ambos os lados (bimap).
  Result<TF, TS> either<TF, TS>(
    TF Function(F failure) onFailure,
    TS Function(S success) onSuccess,
  );

  /// Inverte Success ↔ Failure.
  Result<S, F> swap();

  // ── Helpers de extração ──────────────────────────────────────────────────

  /// Retorna o valor de [Success] ou [defaultValue] se for [Failure].
  ///
  /// ```dart
  /// final name = result.getOrElse('Desconhecido');
  /// ```
  S getOrElse(S defaultValue) => fold((_) => defaultValue, (s) => s);

  /// Retorna o valor de [Success] ou o resultado de [fn] se for [Failure].
  S getOrCall(S Function(F failure) fn) => fold(fn, (s) => s);

  /// Retorna o valor de [Success] como [S?], ou `null` se for [Failure].
  S? toNullable() => fold((_) => null, (s) => s);

  // ── Side-effects ─────────────────────────────────────────────────────────

  /// Executa [fn] com o valor de [Success] sem alterar o Result.
  /// Útil para logging, analytics, etc.
  ///
  /// ```dart
  /// result.tap((user) => log('Usuário criado: ${user.id}'));
  /// ```
  Result<F, S> tap(void Function(S success) fn) {
    fold((_) {}, fn);
    return this;
  }

  /// Executa [fn] com o valor de [Failure] sem alterar o Result.
  Result<F, S> tapFailure(void Function(F failure) fn) {
    fold(fn, (_) {});
    return this;
  }

  // ── Recover ──────────────────────────────────────────────────────────────

  /// Converte um [Failure] em [Success] via [fn]. Um [Success] passa intacto.
  ///
  /// ```dart
  /// result.recover((err) => UserDto.empty());
  /// ```
  Result<F, S> recover(S Function(F failure) fn) =>
      fold((f) => Success(fn(f)), (_) => this);

  // ── Equality ─────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) => fold(
        (f) => other is Failure<F, S> && f == other.value,
        (s) => other is Success<F, S> && s == other.value,
      );

  @override
  int get hashCode => fold(
        (f) => Object.hash('Failure', f),
        (s) => Object.hash('Success', s),
      );
}

// ── Subtipos ─────────────────────────────────────────────────────────────────

/// Representa uma falha. Convencionalmente carrega o erro.
final class Failure<F, S> extends Result<F, S> {
  final F value;

  const Failure(this.value);

  @override
  T fold<T>(T Function(F failure) onFailure, T Function(S success) onSuccess) =>
      onFailure(value);

  @override
  Result<F, T> map<T>(T Function(S success) fn) => Failure<F, T>(value);

  @override
  Result<T, S> mapFailure<T>(T Function(F failure) fn) =>
      Failure<T, S>(fn(value));

  @override
  Result<F, T> then<T>(Result<F, T> Function(S success) fn) =>
      Failure<F, T>(value);

  @override
  Result<T, S> thenFailure<T>(Result<T, S> Function(F failure) fn) => fn(value);

  @override
  Result<TF, TS> either<TF, TS>(
    TF Function(F failure) onFailure,
    TS Function(S success) onSuccess,
  ) =>
      Failure<TF, TS>(onFailure(value));

  @override
  Result<S, F> swap() => Success<S, F>(value);

  @override
  String toString() => 'Failure($value)';
}

/// Representa um sucesso. Carrega o valor resultante.
final class Success<F, S> extends Result<F, S> {
  final S value;

  const Success(this.value);

  @override
  T fold<T>(T Function(F failure) onFailure, T Function(S success) onSuccess) =>
      onSuccess(value);

  @override
  Result<F, T> map<T>(T Function(S success) fn) => Success<F, T>(fn(value));

  @override
  Result<T, S> mapFailure<T>(T Function(F failure) fn) => Success<T, S>(value);

  @override
  Result<F, T> then<T>(Result<F, T> Function(S success) fn) => fn(value);

  @override
  Result<T, S> thenFailure<T>(Result<T, S> Function(F failure) fn) =>
      Success<T, S>(value);

  @override
  Result<TF, TS> either<TF, TS>(
    TF Function(F failure) onFailure,
    TS Function(S success) onSuccess,
  ) =>
      Success<TF, TS>(onSuccess(value));

  @override
  Result<S, F> swap() => Failure<S, F>(value);

  @override
  String toString() => 'Success($value)';
}
