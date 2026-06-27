# HelperUtil — Funções Avançadas e Utilitários

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## Manipulação de texto

```dart
HelperUtil.countWords('Flutter é incrível');            // 3
HelperUtil.removeHtmlTags('<p>Hello <b>World</b></p>'); // 'Hello World'
HelperUtil.capitalizeWords('olá mundo');                // 'Olá Mundo'
```

---

## Geração de strings e números

```dart
HelperUtil.generateRandomString(8);  // 'aB3xZ9mQ'
HelperUtil.generateRandomInt(1, 100); // número entre 1 e 100
```

---

## UUID

```dart
// UUID v3 — baseado em namespace e nome com MD5
HelperUtil.generateUUIDv3(namespace: '...', name: 'meu-valor');

// UUID v4 — aleatório
HelperUtil.generateUUIDv4();
// '550e8400-e29b-41d4-a716-446655440000'

// UUID v5 — baseado em namespace e nome com SHA-1
HelperUtil.generateUUIDv5(namespace: '...', name: 'meu-valor');
```

---

## JWT

```dart
// Decodifica o payload de um JWT
final payload = HelperUtil.decodeJWT(token);

// Verifica se o token está expirado
bool expirado = HelperUtil.isJwtExpired(token);

// Verifica se uma claim existe
bool temClaim = HelperUtil.hasJwtClaim(token, 'role');

// Obtém o valor de uma claim
dynamic valor = HelperUtil.getJwtClaim(token, 'role');
```

---

## Datas e horários

```dart
// Converte UTC → local e local → UTC
HelperUtil.convertUtcToLocal(dateTime);
HelperUtil.convertLocalToUtc(dateTime);

// Diferença entre datas
HelperUtil.daysBetween(DateTime(2026, 1, 1), DateTime(2026, 12, 31)); // 364

// Dias úteis entre datas
HelperUtil.businessDaysBetween(DateTime(2026, 6, 1), DateTime(2026, 6, 30));

// Cálculo de idade
HelperUtil.calculateAge(DateTime(1990, 5, 15)); // 36 (em 2026)
```

---

## Validação de data e maioridade

```dart
HelperUtil.isValidDate('31/02/2023'); // false
HelperUtil.isValidDate('15/06/2023'); // true
HelperUtil.isValidDate('2023-06-15'); // true

HelperUtil.isAdult(DateTime(2000, 1, 1));              // true
HelperUtil.isAdult(DateTime(2010, 1, 1));              // false
HelperUtil.isAdult(DateTime(2002, 1, 1), minAge: 21); // false
```

---

## Chaves PIX

```dart
// Valida e identifica o tipo da chave
HelperUtil.validatePixKey('992.864.791-74'); // 'CPF'
HelperUtil.validatePixKey('+5511912345678'); // 'Celular'
HelperUtil.validatePixKey('user@example.com'); // 'Email'
HelperUtil.validatePixKey('123e4567-e89b-4d3a-a456-426614174000'); // 'Chave Aleatória'
HelperUtil.validatePixKey('invalido'); // null

// Mascaramento
HelperUtil.maskPixKey('99286479174');       // '992.***.***-74'
HelperUtil.maskPixKey('+5511912345678');    // '+5511*****678'
HelperUtil.maskPixKey('user@example.com'); // 'us**@example.com'
```

---

## Informações do dispositivo

```dart
final info = HelperUtil.getDeviceInfo();
// { 'os': 'android', 'dartVersion': '3.x.x' }
```

---

← [Voltar ao README](../README.md)
