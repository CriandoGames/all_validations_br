import 'dart:async';

import 'result.dart';

/// Extension em `Future<Result<F, S>>` para encadeamento assíncrono.
///
/// Permite railway-oriented programming com operações async sem aninhamento
/// de `then` e `await` manuais:
///
/// ```dart
/// await Result.tryAsync(() => http.get(uri))
///   .then(checkStatus)
///   .mapAsync(parseBody)
///   .fold(
///     (err)  => showError(err),
///     (data) => updateUI(data),
///   );
/// ```
extension FutureResult<F, S> on Future<Result<F, S>> {
  /// `true` se o resultado for [Success].
  Future<bool> get isSuccess => then((r) => r.isSuccess);

  /// `true` se o resultado for [Failure].
  Future<bool> get isFailure => then((r) => r.isFailure);

  /// Transforma o valor de [Success] (async).
  Future<Result<F, T>> mapAsync<T>(FutureOr<T> Function(S success) fn) =>
      then((r) => r.mapAsync(fn));

  /// Transforma o valor de [Failure] (async).
  Future<Result<T, S>> mapFailureAsync<T>(FutureOr<T> Function(F failure) fn) =>
      then((r) => r.mapFailureAsync(fn));

  /// Flatmap async — próximo passo pode falhar.
  Future<Result<F, T>> thenAsync<T>(
          FutureOr<Result<F, T>> Function(S success) fn) =>
      then((r) => r.thenAsync(fn));

  /// Flatmap async do lado [Failure].
  Future<Result<T, S>> thenFailureAsync<T>(
          FutureOr<Result<T, S>> Function(F failure) fn) =>
      then((r) => r.thenFailureAsync(fn));

  /// Colapsa Success e Failure num único tipo (async).
  Future<T> foldAsync<T>(
    FutureOr<T> Function(F failure) onFailure,
    FutureOr<T> Function(S success) onSuccess,
  ) =>
      then((r) => r.foldAsync(onFailure, onSuccess));

  /// Transforma ambos os lados (async).
  Future<Result<TF, TS>> eitherAsync<TF, TS>(
    FutureOr<TF> Function(F failure) onFailure,
    FutureOr<TS> Function(S success) onSuccess,
  ) =>
      then((r) => r.eitherAsync(onFailure, onSuccess));

  /// Inverte Success ↔ Failure.
  Future<Result<S, F>> swap() => then((r) => r.swap());

  /// Converte um [Failure] em [Success] (async).
  Future<Result<F, S>> recoverAsync(FutureOr<S> Function(F failure) fn) =>
      then((r) => r.recoverAsync(fn));

  /// Side-effect no [Success] sem alterar o Result (async).
  Future<Result<F, S>> tapAsync(FutureOr<void> Function(S success) fn) =>
      then((r) => r.tapAsync(fn));

  /// Side-effect no [Failure] sem alterar o Result (async).
  Future<Result<F, S>> tapFailureAsync(FutureOr<void> Function(F failure) fn) =>
      then((r) => r.tapFailureAsync(fn));

  /// Retorna o valor de [Success] ou [defaultValue] se for [Failure].
  Future<S> getOrElse(S defaultValue) => then((r) => r.getOrElse(defaultValue));

  /// Retorna o valor de [Success] ou o resultado de [fn] se for [Failure].
  Future<S> getOrCall(S Function(F failure) fn) => then((r) => r.getOrCall(fn));

  /// Retorna o valor de [Success] como [S?], ou `null` se for [Failure].
  Future<S?> toNullable() => then((r) => r.toNullable());
}

/// Extensões async adicionadas diretamente no [Result] para uso com Future.
extension ResultAsync<F, S> on Result<F, S> {
  /// Transforma o [Success] de forma assíncrona.
  Future<Result<F, T>> mapAsync<T>(FutureOr<T> Function(S success) fn) async {
    return fold(
      (f) => Failure<F, T>(f),
      (s) async => Success<F, T>(await fn(s)),
    );
  }

  /// Transforma o [Failure] de forma assíncrona.
  Future<Result<T, S>> mapFailureAsync<T>(
      FutureOr<T> Function(F failure) fn) async {
    return fold(
      (f) async => Failure<T, S>(await fn(f)),
      (s) => Success<T, S>(s),
    );
  }

  /// Flatmap assíncrono — próximo passo pode falhar.
  Future<Result<F, T>> thenAsync<T>(
      FutureOr<Result<F, T>> Function(S success) fn) async {
    return fold(
      (f) => Failure<F, T>(f),
      (s) => fn(s),
    );
  }

  /// Flatmap assíncrono do lado [Failure].
  Future<Result<T, S>> thenFailureAsync<T>(
      FutureOr<Result<T, S>> Function(F failure) fn) async {
    return fold(
      (f) => fn(f),
      (s) => Success<T, S>(s),
    );
  }

  /// Colapsa Success e Failure num único tipo (async).
  Future<T> foldAsync<T>(
    FutureOr<T> Function(F failure) onFailure,
    FutureOr<T> Function(S success) onSuccess,
  ) {
    return fold(
      (f) => Future.value(onFailure(f)),
      (s) => Future.value(onSuccess(s)),
    );
  }

  /// Transforma ambos os lados de forma assíncrona.
  Future<Result<TF, TS>> eitherAsync<TF, TS>(
    FutureOr<TF> Function(F failure) onFailure,
    FutureOr<TS> Function(S success) onSuccess,
  ) async {
    return fold(
      (f) async => Failure<TF, TS>(await onFailure(f)),
      (s) async => Success<TF, TS>(await onSuccess(s)),
    );
  }

  /// Recupera um [Failure] de forma assíncrona.
  Future<Result<F, S>> recoverAsync(FutureOr<S> Function(F failure) fn) async {
    return fold(
      (f) async => Success<F, S>(await fn(f)),
      (s) => Success<F, S>(s),
    );
  }

  /// Side-effect no [Success] de forma assíncrona.
  Future<Result<F, S>> tapAsync(FutureOr<void> Function(S value) fn) async {
    if (isSuccess) await fn(successValue);
    return this;
  }

  /// Side-effect no [Failure] de forma assíncrona.
  Future<Result<F, S>> tapFailureAsync(
      FutureOr<void> Function(F value) fn) async {
    if (isFailure) await fn(failureValue);
    return this;
  }
}
// tryAsync e tryAsyncTyped estão como static methods em Result diretamente.
