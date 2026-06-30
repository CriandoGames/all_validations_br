import 'dart:convert';
import 'dart:typed_data';

import 'crypt_algorithm.dart';

/// Envelope imutável que carrega **todos os dados** necessários para decifrar
/// uma mensagem — independente do algoritmo usado.
///
/// ## Uso normal (via CryptUtil)
///
/// Na esmagadora maioria dos casos você nunca constrói um [EncryptedPayload]
/// diretamente. Os métodos de [CryptUtil] o criam e retornam para você:
///
/// ```dart
/// // Cifrar
/// final payload = CryptUtil.encryptAesGcm(utf8.encode('segredo'));
///
/// // Decifrar — mesmo payload, qualquer algoritmo
/// final plain = CryptUtil.decryptAny(payload);
///
/// // Persistir
/// final b64 = payload.toBase64();
/// final restored = EncryptedPayload.fromBase64(b64);
/// ```
///
/// ## Construção manual (interop com sistemas externos)
///
/// Use o construtor diretamente quando o ciphertext e as chaves vêm de
/// **fora da lib** — por exemplo, de uma API ou de variáveis de ambiente
/// (Flavors, `.env`):
///
/// ```dart
/// // API retorna ciphertext AES-CBC em base64; key e IV vêm do Flavors
/// final payload = EncryptedPayload(
///   algorithm:  CryptAlgorithm.aesCbc,
///   ciphertext: base64.decode(responseBody),
///   key:        utf8.encode(Flavors.aesKey),   // 16 ou 32 bytes
///   nonce:      utf8.encode(Flavors.aesIv),    // 16 bytes — IV do CBC
///   tag:        Uint8List(0),                  // CBC não produz tag
///   aad:        Uint8List(0),                  // sem AAD
/// );
///
/// final plain = CryptUtil.decryptAesCbc(payload);
/// ```
///
/// ## Campos e seus papéis por algoritmo
///
/// | Campo       | ChaCha20-Poly1305 | AES-GCM   | AES-CBC   | AES-CTR   |
/// |-------------|-------------------|-----------|-----------|-----------|
/// | [ciphertext]| dados cifrados    | idem      | idem      | idem      |
/// | [key]       | 32 bytes          | 16 ou 32  | 16 ou 32  | 16 ou 32  |
/// | [nonce]     | 12 bytes          | 12 bytes  | IV 16 b   | ICB 16 b  |
/// | [tag]       | 16 bytes (Poly)   | 16 bytes  | vazia     | vazia     |
/// | [aad]       | opcional          | opcional  | ignorado  | ignorado  |
///
/// ## Serialização
///
/// [toJson] / [fromJson] — integra com qualquer camada HTTP/storage.
/// [toBase64] / [fromBase64] — string única; ideal para headers ou SharedPreferences.
///
/// Todos os campos de bytes são codificados em **base64-standard** no JSON.
class EncryptedPayload {
  /// Dados cifrados. Tamanho variável; múltiplo de 16 bytes no CBC.
  final Uint8List ciphertext;

  /// Chave simétrica usada na cifragem.
  ///
  /// Tamanhos válidos: **16 bytes** (AES-128 / ChaCha20 não usa) ou
  /// **32 bytes** (AES-256 / ChaCha20-Poly1305).
  ///
  /// ⚠️ Nunca exponha a chave em logs ou respostas de API.
  final Uint8List key;

  /// Tag de autenticação (MAC).
  ///
  /// - **ChaCha20-Poly1305**: 16 bytes (Poly1305).
  /// - **AES-GCM**: 16 bytes.
  /// - **AES-CBC / AES-CTR**: vazia (`Uint8List(0)`) — esses modos não
  ///   produzem MAC; use HMAC-SHA256 separado se precisar de integridade.
  final Uint8List tag;

  /// Nonce, IV ou bloco de contador inicial — depende do algoritmo:
  ///
  /// - **ChaCha20-Poly1305 / AES-GCM**: nonce de **12 bytes**. Nunca reutilize
  ///   o mesmo nonce com a mesma chave.
  /// - **AES-CBC**: IV de **16 bytes** (gerado aleatoriamente ou fornecido
  ///   externamente, ex.: `Flavors.aesIv`).
  /// - **AES-CTR**: bloco de contador inicial (**ICB**) de **16 bytes**
  ///   (uint128 big-endian, conforme NIST SP 800-38A F.5).
  final Uint8List nonce;

  /// Dados autenticados adicionais (*Additional Authenticated Data*).
  ///
  /// - **ChaCha20-Poly1305 / AES-GCM**: incluídos na tag — protegem metadados
  ///   (ex.: ID do usuário, versão do protocolo) sem cifrá-los.
  /// - **AES-CBC / AES-CTR**: ignorados (esses modos não suportam AAD).
  ///
  /// Passe `Uint8List(0)` quando não houver AAD.
  final Uint8List aad;

  /// Algoritmo utilizado na cifragem.
  ///
  /// Determina qual método de [CryptUtil] deve ser usado para decifrar.
  /// [CryptUtil.decryptAny] usa este campo para despachar automaticamente.
  ///
  /// Payloads desserializados de JSON sem o campo `algorithm` assumem
  /// [CryptAlgorithm.chacha20Poly1305] (compatibilidade retroativa).
  final CryptAlgorithm algorithm;

  /// Cria um [EncryptedPayload] com os campos fornecidos.
  ///
  /// [tag] e [aad] são opcionais e assumem `Uint8List(0)` por padrão —
  /// útil para modos não autenticados (AES-CBC, AES-CTR) e payloads
  /// sem AAD.
  ///
  /// **Uso normal:** prefira os métodos de [CryptUtil] — eles preenchem
  /// todos os campos corretamente.
  ///
  /// **Interop com sistemas externos:** preencha manualmente quando o
  /// ciphertext e as chaves vierem de fora da lib (veja exemplos na
  /// documentação da classe):
  ///
  /// ```dart
  /// final payload = EncryptedPayload(
  ///   algorithm:  CryptAlgorithm.aesCbc,
  ///   ciphertext: base64.decode(responseBody),
  ///   key:        utf8.encode(Flavors.aesKey),
  ///   nonce:      utf8.encode(Flavors.aesIv),
  ///   // tag e aad omitidos → Uint8List(0) automaticamente
  /// );
  /// ```
  EncryptedPayload({
    required this.ciphertext,
    required this.key,
    required this.nonce,
    Uint8List? tag,
    Uint8List? aad,
    this.algorithm = CryptAlgorithm.chacha20Poly1305,
  })  : tag = tag ?? Uint8List(0),
        aad = aad ?? Uint8List(0);

  /// Serializa para `Map<String, dynamic>` compatível com `jsonEncode`.
  ///
  /// Todos os campos de bytes são codificados em base64-standard.
  ///
  /// ```dart
  /// final json = payload.toJson();
  /// // {'algorithm': 'aes-gcm', 'ciphertext': '...', 'key': '...', ...}
  /// ```
  Map<String, dynamic> toJson() => {
        'algorithm': algorithm.value,
        'ciphertext': base64.encode(ciphertext),
        'key': base64.encode(key),
        'tag': base64.encode(tag),
        'nonce': base64.encode(nonce),
        'aad': base64.encode(aad),
      };

  /// Reconstrói um [EncryptedPayload] a partir de um `Map` JSON.
  ///
  /// O campo `algorithm` é opcional para compatibilidade com payloads
  /// gerados antes da versão 4.4.0 — se ausente, assume
  /// [CryptAlgorithm.chacha20Poly1305].
  ///
  /// Lança [ArgumentError] se `algorithm` contiver um valor desconhecido.
  factory EncryptedPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedPayload(
      algorithm: CryptAlgorithm.fromString(
        (json['algorithm'] as String?) ?? 'chacha20-poly1305',
      ),
      ciphertext: base64.decode(json['ciphertext'] as String),
      key: base64.decode(json['key'] as String),
      tag: base64.decode(json['tag'] as String),
      nonce: base64.decode(json['nonce'] as String),
      aad: base64.decode(json['aad'] as String),
    );
  }

  /// Serializa o payload completo como uma **string base64 única**.
  ///
  /// Internamente, produz JSON → UTF-8 → base64. Ideal para persistir em
  /// `SharedPreferences`, transmitir em um header HTTP ou armazenar em
  /// um campo de texto simples.
  ///
  /// ```dart
  /// final token = payload.toBase64();
  /// // Mais tarde:
  /// final restored = EncryptedPayload.fromBase64(token);
  /// ```
  String toBase64() => base64.encode(utf8.encode(jsonEncode(toJson())));

  /// Reconstrói um [EncryptedPayload] a partir de uma string produzida
  /// por [toBase64].
  ///
  /// Lança [FormatException] se [encoded] não for base64 válido ou o JSON
  /// interno estiver malformado.
  factory EncryptedPayload.fromBase64(String encoded) {
    final json = jsonDecode(utf8.decode(base64.decode(encoded)));
    return EncryptedPayload.fromJson(json as Map<String, dynamic>);
  }

  @override
  String toString() => 'EncryptedPayload(algorithm: ${algorithm.value}, '
      'ciphertext: ${ciphertext.length} bytes, '
      'key: ${key.length} bytes, tag: ${tag.length} bytes, '
      'nonce: ${nonce.length} bytes, aad: ${aad.length} bytes)';
}
