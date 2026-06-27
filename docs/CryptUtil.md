# CryptUtil — Criptografia Autenticada

`CryptUtil` implementa **ChaCha20-Poly1305** (RFC 8439) em Dart puro, sem dependências externas. O algoritmo é AEAD (_Authenticated Encryption with Associated Data_): confidencialidade + integridade em uma única operação. Qualquer adulteração — no ciphertext, na tag ou no AAD — é detectada automaticamente na decriptação.

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Como funciona

```
plaintext + key(32B) + nonce(12B) ──► ChaCha20 ──► ciphertext
ciphertext + AAD + key            ──► Poly1305 ──► tag(16B)

Resultado armazenado: EncryptedPayload { ciphertext, key, nonce, tag, aad }
```

- **ChaCha20** cifra o plaintext em stream usando key + nonce.
- **Poly1305** gera uma tag de autenticação de 16 bytes sobre o ciphertext e o AAD.
- Na decriptação, a tag é recalculada e comparada em **tempo constante** — qualquer diferença lança `CryptException` antes de devolver qualquer byte.

---

## Uso básico — texto

```dart
// 1. Gera chave segura de 32 bytes (Random.secure)
final key = CryptUtil.generateKey();

// 2. Criptografa — nonce aleatório gerado automaticamente
final payload = CryptUtil.encryptText('Dados sensíveis', key: key);

// 3. Decriptografa
final texto = CryptUtil.decryptText(payload);
print(texto); // 'Dados sensíveis'
```

Se `key` for omitido, uma chave aleatória é gerada internamente e embutida no payload — útil para proteger dados sem gerenciar a chave manualmente (veja [padrão chave embutida](#chave-embutida-no-payload) abaixo).

---

## Uso básico — bytes

```dart
final data = Uint8List.fromList([1, 2, 3, 4, 5]);
final key  = CryptUtil.generateKey();

final payload            = CryptUtil.encryptBytes(data, key: key);
final List<int> restored = CryptUtil.decryptBytes(payload);
```

`encryptBytes` aceita qualquer `List<int>` — inclusive `Uint8List`.

---

## Serialização e armazenamento

### Via base64 (string única — recomendado para persistência)

`encryptToBase64` é um atalho para `encryptText(...).toBase64()`:

```dart
// Cifra e serializa como uma única string
final encoded = CryptUtil.encryptToBase64('secreto', key: key);
// ex: 'eyJjaXBoZXJ0ZXh0IjoiL...' (JSON embutido em base64)

// Armazene `encoded` onde quiser (SharedPreferences, banco, API...)

// Restaura e decifra
final original = CryptUtil.decryptFromBase64(encoded);
```

> `decryptFromBase64` lança `FormatException` se `encoded` não for base64 válido,
> e `CryptException` se os dados forem adulterados.

### Via JSON (para APIs e bancos relacionais)

```dart
// Serializa como Map com todos os campos em base64
final Map<String, dynamic> json = payload.toJson();
// {
//   'ciphertext': '<base64>',
//   'key':        '<base64>',
//   'tag':        '<base64>',
//   'nonce':      '<base64>',
//   'aad':        '<base64>',
// }

// Restaura a partir do Map
final payload2 = EncryptedPayload.fromJson(json);
final texto    = CryptUtil.decryptText(payload2);
```

### Direto no EncryptedPayload

`toBase64` e `fromBase64` também estão disponíveis diretamente no `EncryptedPayload`:

```dart
final encoded  = payload.toBase64();
final restored = EncryptedPayload.fromBase64(encoded);
```

---

## Chave embutida no payload

> **Ponto de atenção:** por padrão, o `EncryptedPayload` armazena a chave junto com o ciphertext. Quem tiver acesso ao payload serializado (`toBase64` / `toJson`) **também tem acesso à chave**.

Isso é intencional para o caso de uso mais comum — proteger dados em repouso no próprio dispositivo:

```dart
// Padrão ─ chave gerada e embutida automaticamente
final encoded = CryptUtil.encryptToBase64('dado local');
// Armazene em SharedPreferences, Hive, SQLite...
// Quem acessa o storage local acessa o dado cifrado E a chave.
// A proteção real vem do sistema operacional (sandbox do app).
```

Para cenários onde key e ciphertext **precisam ficar separados** (ex: chave no keychain, ciphertext no banco), gerencie explicitamente:

```dart
// Padrão com chave separada
final key = CryptUtil.generateKey();
// Armazene `key` em flutter_secure_storage / keychain

final payload = CryptUtil.encryptText('dado', key: key);
// Armazene apenas o ciphertext, tag e nonce (sem a chave)
final semChave = {
  'ciphertext': base64.encode(payload.ciphertext),
  'tag':        base64.encode(payload.tag),
  'nonce':      base64.encode(payload.nonce),
};

// Para decriptografar: recupere a chave do keychain e reconstrua o payload
final payloadReconstruido = EncryptedPayload(
  ciphertext: base64.decode(semChave['ciphertext']!),
  key:        key,  // recuperada do keychain
  tag:        base64.decode(semChave['tag']!),
  nonce:      base64.decode(semChave['nonce']!),
  aad:        Uint8List(0),
);
final texto = CryptUtil.decryptText(payloadReconstruido);
```

---

## Com AAD (Additional Authenticated Data)

AAD é **autenticado mas não cifrado** — útil para vincular metadados ao ciphertext sem expô-los cifrados. Se o AAD for alterado depois da cifragem, um `CryptException` é lançado na decriptação.

```dart
import 'dart:convert';

// Exemplo: vincular o ciphertext a um usuário específico
final aad     = utf8.encode('user_id:42');
final payload = CryptUtil.encryptText('dado privado', key: key, aad: aad);

// O AAD fica armazenado no payload e é reutilizado automaticamente na decriptação
final texto = CryptUtil.decryptText(payload); // OK

// Se alguém alterar o AAD no payload armazenado → CryptException
```

Casos de uso para AAD: identificador de usuário, versão do schema, ID de sessão — qualquer metadado que não deve ser cifrado, mas que deve garantir que o payload só seja aceito no contexto correto.

---

## Detecção de adulteração

```dart
try {
  final texto = CryptUtil.decryptText(payload);
  print(texto);
} on CryptException catch (e) {
  print(e.message);
  // 'Tag de autenticação inválida. Os dados podem ter sido
  //  corrompidos ou a chave está incorreta.'
} on FormatException catch (e) {
  // Apenas em decryptFromBase64 — base64 malformado
  print('Base64 inválido: $e');
}
```

A comparação da tag usa **tempo constante** (`constantTimeCompare`) — sem vazamento de informação via timing attack.

---

## EncryptedPayload — estrutura completa

```dart
class EncryptedPayload {
  final Uint8List ciphertext; // dados cifrados
  final Uint8List key;        // chave de 32 bytes
  final Uint8List tag;        // tag Poly1305 de 16 bytes
  final Uint8List nonce;      // nonce de 12 bytes
  final Uint8List aad;        // AAD (vazio se não usado)
}
```

| Método | Descrição |
|--------|-----------|
| `toJson()` | Serializa para `Map<String, dynamic>` com campos em base64 |
| `fromJson(map)` | Deserializa de `Map<String, dynamic>` |
| `toBase64()` | Serializa para string base64 (JSON embutido) |
| `fromBase64(encoded)` | Deserializa de string base64 |
| `toString()` | `EncryptedPayload(ciphertext: N bytes, key: 32 bytes, ...)` |

---

## CryptException

```dart
class CryptException implements Exception {
  final String message; // mensagem descritiva
  // default: 'Autenticação falhou.'
}

// Mensagem gerada pelo algoritmo quando a tag falha:
// 'Tag de autenticação inválida. Os dados podem ter sido
//  corrompidos ou a chave está incorreta.'

try {
  CryptUtil.decryptText(payload);
} on CryptException catch (e) {
  print(e);         // 'CryptException: Tag de autenticação inválida...'
  print(e.message); // só a mensagem, sem o prefixo
}
```

---

## Exceções possíveis

| Situação | Exceção |
|----------|---------|
| Chave com tamanho ≠ 32 bytes | `ArgumentError` |
| Nonce com tamanho ≠ 12 bytes | `ArgumentError` |
| Ciphertext adulterado ou chave errada | `CryptException` |
| `decryptFromBase64` com base64 inválido | `FormatException` |

---

## Referência da API — CryptUtil

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `encryptText(text, {key?, nonce?, aad?})` | `EncryptedPayload` | Cifra String (UTF-8) |
| `decryptText(payload)` | `String` | Decifra e retorna String |
| `encryptBytes(bytes, {key?, nonce?, aad?})` | `EncryptedPayload` | Cifra `List<int>` |
| `decryptBytes(payload)` | `List<int>` | Decifra e retorna bytes |
| `encryptToBase64(text, {key?, nonce?, aad?})` | `String` | Atalho: `encryptText(...).toBase64()` |
| `decryptFromBase64(encoded)` | `String` | Atalho: `EncryptedPayload.fromBase64(e)` + `decryptText` |
| `generateKey()` | `Uint8List` | Chave segura de 32 bytes (`Random.secure`) |
| `generateNonce()` | `Uint8List` | Nonce seguro de 12 bytes (`Random.secure`) |

---

## Constantes do algoritmo

| Constante | Valor | Descrição |
|-----------|-------|-----------|
| `ChaCha20Poly1305.keyLength` | `32` | Tamanho obrigatório da chave (bytes) |
| `ChaCha20Poly1305.nonceLength` | `12` | Tamanho obrigatório do nonce (bytes) |
| `ChaCha20Poly1305.tagLength` | `16` | Tamanho da tag Poly1305 (bytes) |

---

## Boas práticas

- **Chave em local seguro** — use `flutter_secure_storage` / keychain / TEE. Nunca em `SharedPreferences` em texto puro.
- **Não reutilize (key, nonce)** — um nonce repetido com a mesma chave quebra a confidencialidade do ChaCha20. O `generateNonce()` automático por padrão elimina esse risco.
- **Trate `CryptException` sempre** — decriptação sem `try/catch` em `CryptException` pode deixar dados adulterados passarem silenciosamente se você não verificar o retorno.
- **AAD para contexto** — vincule o payload ao contexto de uso (ex: `userId`, `sessionId`) para evitar que um payload válido seja reutilizado em outro contexto.
- **Overhead por payload** — além do ciphertext, cada payload carrega 32 (key) + 12 (nonce) + 16 (tag) = 60 bytes extras mais o AAD. Considere ao armazenar muitos payloads pequenos.

---

← [Voltar ao README](../README.md)
