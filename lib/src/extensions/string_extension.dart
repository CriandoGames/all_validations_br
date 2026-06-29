/// Extensão em [String?] com getters para verificação de nulidade, vazio e truncagem.
///
/// Opera sobre strings nullable sem precisar de null-checks manuais.
///
/// ## Exemplo
///
/// ```dart
/// String? nome = null;
/// nome.isNullOrEmpty;                // true
/// nome.isNotNullOrEmpty;             // false
///
/// String? apelido = '   ';
/// apelido.isNullOrEmpty;             // false — tem conteúdo (espaços)
/// apelido.isNullOrEmptyWithSpace;    // true  — vazio após trim
/// apelido.isNotNullOrEmptyWithSpace; // false
///
/// 'texto longo demais'.truncate(5);  // 'texto...'
/// ```
extension StringExtension on String? {
  // ── Nulidade / vazio ───────────────────────────────────────────────────────

  /// Retorna `true` se a string for `null` ou `''` (vazia literal).
  ///
  /// Espaços em branco **não** são considerados vazios.
  /// Use [isNullOrEmptyWithSpace] para isso.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Inverso de [isNullOrEmpty].
  ///
  /// Retorna `true` se a string tiver ao menos um caractere (espaço inclusive).
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Retorna `true` se a string for `null`, `''` ou contiver apenas espaços.
  ///
  /// Equivalente a `null` ou `trim().isEmpty`.
  bool get isNullOrEmptyWithSpace => this == null || this!.trim().isEmpty;

  /// Inverso de [isNullOrEmptyWithSpace].
  ///
  /// Retorna `true` se a string, após trim, tiver ao menos um caractere.
  bool get isNotNullOrEmptyWithSpace => !isNullOrEmptyWithSpace;

  // ── Truncagem ──────────────────────────────────────────────────────────────

  /// Trunca a string ao máximo de [maxLength] caracteres.
  ///
  /// Se a string for mais longa que [maxLength], retorna os primeiros
  /// `maxLength` caracteres seguidos de `'...'`.
  ///
  /// Retorna a própria string se for `null` ou já couber no limite.
  ///
  /// ```dart
  /// 'Flutter é incrível'.truncate(7);  // 'Flutter...'
  /// 'Dart'.truncate(10);               // 'Dart'
  /// null.truncate(5);                  // null
  /// ```
  String? truncate(int maxLength) {
    if (this == null || this!.length <= maxLength) return this;
    return '${this!.substring(0, maxLength)}...';
  }
}
