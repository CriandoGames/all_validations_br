/// Extensão em [bool?] com getters semânticos para leitura mais fluente.
///
/// Diferencia explicitamente entre `true`, `false` e `null`, sem lançar
/// exceções em valores nulos.
///
/// ## Exemplo
///
/// ```dart
/// bool? ativo = true;
///
/// if (ativo.isTrue) {
///   print('Ativo');
/// }
///
/// bool? bloqueado = null;
/// bloqueado.isTrue;  // false
/// bloqueado.isFalse; // false
/// ```
extension BoolExtension on bool? {
  /// Retorna `true` somente se o valor for literalmente `true`.
  ///
  /// `null` e `false` retornam `false`.
  bool get isTrue => this == true;

  /// Retorna `true` somente se o valor for literalmente `false`.
  ///
  /// `null` e `true` retornam `false`.
  bool get isFalse => this == false;
}
