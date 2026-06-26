import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'algorithms/chacha20_poly1305.dart';
import 'models/encrypted_payload.dart';

export 'models/crypt_exception.dart';
export 'models/encrypted_payload.dart';

/// Utilitário de criptografia baseado em ChaCha20-Poly1305 (RFC 8439).
///
/// Implementação Dart pura, sem dependências externas.
/// Fornece criptografia autenticada (AEAD) — confidencialidade + integridade
/// em uma única operação.
///
/// ## Uso básico
///
/// ```dart
/// // Gera uma chave segura (guarde-a em armazenamento seguro)
/// final key = CryptUtil.generateKey();
///
/// // Criptografa
/// final payload = CryptUtil.encryptText('Dados sensíveis', key: key);
///
/// // Decriptografa
/// final texto = CryptUtil.decryptText(payload);
/// print(texto); // 'Dados sensíveis'
/// ```
///
/// ## Serialização
///
/// ```dart
/// // Salva como string base64 (útil para SharedPreferences, banco, etc.)
/// final encoded = payload.toBase64();
///
/// // Restaura
/// final restored = EncryptedPayload.fromBase64(encoded);
/// final texto = CryptUtil.decryptText(restored);
/// ```
///
/// ## Com AAD (Additional Authenticated Data)
///
/// AAD é autenticado mas não cifrado — garante que metadados não foram adulterados.
///
/// ```dart
/// final aad = utf8.encode('user_id:42');
/// final payload = CryptUtil.encryptText('segredo', key: key, aad: aad);
/// final texto = CryptUtil.decryptText(payload); // OK
/// ```
///
/// ## Segurança
///
/// - **Nunca reutilize** o mesmo par (key, nonce) para dados diferentes.
///   O método gera um nonce aleatório por padrão.
/// - **Armazene a chave** em local seguro (`flutter_secure_storage`, keychain, etc.).
/// - **Verifique [CryptException]** ao decriptografar — indica dados adulterados.
class CryptUtil {
  CryptUtil._();

  // ---------------------------------------------------------------------------
  // Texto
  // ---------------------------------------------------------------------------

  /// Criptografa [text] e retorna um [EncryptedPayload].
  ///
  /// - [key]   : chave de 32 bytes. Se omitida, gera uma chave aleatória.
  /// - [nonce] : nonce de 12 bytes. Se omitido, gera um nonce aleatório.
  /// - [aad]   : dados adicionais autenticados (opcional, não cifrados).
  ///
  /// O texto é codificado em UTF-8 antes da cifragem.
  static EncryptedPayload encryptText(
    String text, {
    Uint8List? key,
    Uint8List? nonce,
    List<int>? aad,
  }) {
    return encryptBytes(
      utf8.encode(text),
      key: key,
      nonce: nonce,
      aad: aad,
    );
  }

  /// Decriptografa [payload] e retorna a string original.
  ///
  /// Lança [CryptException] se os dados forem inválidos ou adulterados.
  static String decryptText(EncryptedPayload payload) {
    return utf8.decode(decryptBytes(payload));
  }

  // ---------------------------------------------------------------------------
  // Bytes
  // ---------------------------------------------------------------------------

  /// Criptografa [bytes] e retorna um [EncryptedPayload].
  ///
  /// - [key]   : chave de 32 bytes. Se omitida, gera uma chave aleatória.
  /// - [nonce] : nonce de 12 bytes. Se omitido, gera um nonce aleatório.
  /// - [aad]   : dados adicionais autenticados (opcional, não cifrados).
  static EncryptedPayload encryptBytes(
    List<int> bytes, {
    Uint8List? key,
    Uint8List? nonce,
    List<int>? aad,
  }) {
    final resolvedKey = key ?? generateKey();
    final resolvedNonce = nonce ?? generateNonce();
    final resolvedAad = aad != null ? Uint8List.fromList(aad) : Uint8List(0);

    final cipher = ChaCha20Poly1305(
      key: resolvedKey,
      nonce: resolvedNonce,
      aad: resolvedAad,
    );

    return cipher.encrypt(bytes);
  }

  /// Decriptografa [payload] e retorna os bytes originais.
  ///
  /// Lança [CryptException] se os dados forem inválidos ou adulterados.
  static List<int> decryptBytes(EncryptedPayload payload) {
    final cipher = ChaCha20Poly1305(
      key: payload.key,
      nonce: payload.nonce,
      aad: payload.aad,
    );

    return cipher.decrypt(payload);
  }

  // ---------------------------------------------------------------------------
  // Conveniência — Base64
  // ---------------------------------------------------------------------------

  /// Criptografa [text] e retorna o payload serializado como string base64.
  ///
  /// Atalho para `encryptText(...).toBase64()`.
  /// Útil para armazenar dados cifrados como string única.
  ///
  /// ```dart
  /// final encoded = CryptUtil.encryptToBase64('secreto', key: key);
  /// // Armazena `encoded` onde quiser...
  /// final original = CryptUtil.decryptFromBase64(encoded);
  /// ```
  static String encryptToBase64(
    String text, {
    Uint8List? key,
    Uint8List? nonce,
    List<int>? aad,
  }) {
    return encryptText(text, key: key, nonce: nonce, aad: aad).toBase64();
  }

  /// Decriptografa um payload base64 gerado por [encryptToBase64].
  ///
  /// Lança [CryptException] se os dados forem inválidos ou adulterados.
  /// Lança [FormatException] se [encoded] não for um base64 válido.
  static String decryptFromBase64(String encoded) {
    return decryptText(EncryptedPayload.fromBase64(encoded));
  }

  // ---------------------------------------------------------------------------
  // Geração de chaves
  // ---------------------------------------------------------------------------

  /// Gera uma chave criptograficamente segura de 32 bytes.
  ///
  /// Use [Random.secure] — adequado para chaves de criptografia.
  /// Armazene a chave gerada em local seguro.
  static Uint8List generateKey() => _randomBytes(ChaCha20Poly1305.keyLength);

  /// Gera um nonce criptograficamente seguro de 12 bytes.
  ///
  /// Um novo nonce é gerado automaticamente em cada chamada de [encryptText]
  /// e [encryptBytes]. Use este método apenas se precisar fixar o nonce.
  ///
  /// **Atenção:** nunca reutilize o mesmo nonce com a mesma chave.
  static Uint8List generateNonce() =>
      _randomBytes(ChaCha20Poly1305.nonceLength);

  // ---------------------------------------------------------------------------
  // Privado
  // ---------------------------------------------------------------------------

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }
}
