# CryptUtil — Criptografia Autenticada

`CryptUtil` implementa **ChaCha20-Poly1305** (RFC 8439) em Dart puro, sem dependências externas. O algoritmo é AEAD (_Authenticated Encryption with Associated Data_): garante **confidencialidade** e **integridade** em uma única operação. Qualquer adulteração nos dados — seja no ciphertext, na tag ou no nonce — é detectada automaticamente.

---

## Uso básico — texto

```dart
import 'package:all_validations_br/all_validations_br.dart';

// 1. Gera uma chave de 32 bytes (guarde em armazenamento seguro)
final key = CryptUtil.generateKey();

// 2. Criptografa
final payload = CryptUtil.encryptText('Dados sensíveis', key: key);

// 3. Decriptografa
final texto = CryptUtil.decryptText(payload);
print(texto); // 'Dados sensíveis'
```

---

## Uso básico — bytes

```dart
final data = [1, 2, 3, 4, 5];
final key  = CryptUtil.generateKey();

final payload            = CryptUtil.encryptBytes(data, key: key);
final List<int> restored = CryptUtil.decryptBytes(payload);
```

---

## Serialização (armazenamento / transmissão)

O `EncryptedPayload` pode ser serializado para JSON ou para uma string base64 compacta.

```dart
// Serializa como string base64 (ideal para SharedPreferences, banco, API)
final encoded = CryptUtil.encryptToBase64('secreto', key: key);

// Restaura e decriptografa
final original = CryptUtil.decryptFromBase64(encoded);

// Ou via JSON
final json     = payload.toJson();          // Map<String, dynamic>
final payload2 = EncryptedPayload.fromJson(json);
```

---

## Com AAD (Additional Authenticated Data)

AAD é autenticado mas **não cifrado** — útil para vincular metadados ao ciphertext.
Se o AAD for alterado na decriptação, um `CryptException` é lançado.

```dart
import 'dart:convert';

final aad     = utf8.encode('user_id:42');
final payload = CryptUtil.encryptText('dado privado', key: key, aad: aad);

// Decriptografa normalmente (AAD está no payload)
final texto = CryptUtil.decryptText(payload);
```

---

## Detecção de adulteração

```dart
try {
  final texto = CryptUtil.decryptText(payload);
} on CryptException catch (e) {
  // Dados corrompidos ou chave/nonce incorretos
  print(e); // CryptException: Tag de autenticação inválida.
}
```

---

## Referência da API

| Método | Descrição |
|--------|-----------|
| `CryptUtil.encryptText(text, {key?, nonce?, aad?})` | Cifra uma String e retorna `EncryptedPayload` |
| `CryptUtil.decryptText(payload)` | Decifra e retorna a String original |
| `CryptUtil.encryptBytes(bytes, {key?, nonce?, aad?})` | Cifra bytes e retorna `EncryptedPayload` |
| `CryptUtil.decryptBytes(payload)` | Decifra e retorna `List<int>` |
| `CryptUtil.encryptToBase64(text, {key?, nonce?, aad?})` | Cifra e serializa como String base64 |
| `CryptUtil.decryptFromBase64(encoded)` | Deserializa e decifra de String base64 |
| `CryptUtil.generateKey()` | Gera chave de 32 bytes (`Random.secure`) |
| `CryptUtil.generateNonce()` | Gera nonce de 12 bytes (`Random.secure`) |

---

## Boas práticas

- **Armazene a chave** em `flutter_secure_storage` ou equivalente — nunca em `SharedPreferences` em texto puro.
- **Não reutilize** o mesmo par `(key, nonce)` para dados diferentes. Por padrão, um nonce aleatório é gerado a cada chamada.
- **Trate `CryptException`** sempre — indica dados adulterados ou chave incorreta.

---

← [Voltar ao README](../README.md)
