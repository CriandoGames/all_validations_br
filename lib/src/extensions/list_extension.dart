/// Extensão em [List<T>?] com getters para verificação de nulidade e vazio.
///
/// Opera sobre listas nullable sem null-checks manuais.
///
/// ## Exemplo
///
/// ```dart
/// List<String>? itens = null;
/// itens.isNullOrEmpty;    // true
/// itens.isNotNullOrEmpty; // false
///
/// List<int>? numeros = [];
/// numeros.isNullOrEmpty;  // true
///
/// List<int>? dados = [1, 2, 3];
/// dados.isNullOrEmpty;    // false
/// dados.isNotNullOrEmpty; // true
/// ```
extension ListExtension<T> on List<T>? {
  /// Retorna `true` se a lista for `null` ou não tiver elementos.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Retorna `true` se a lista não for `null` e tiver ao menos um elemento.
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
