/// Exceção lançada quando a autenticação falha durante a decriptação.
///
/// Isso indica que os dados foram corrompidos ou adulterados, ou que
/// a chave/nonce fornecidos estão incorretos.
class CryptException implements Exception {
  final String message;

  const CryptException([this.message = 'Autenticação falhou.']);

  @override
  String toString() => 'CryptException: $message';
}
