# all_validations_br

🇧🇷 Português | [🇺🇸 English](https://github.com/CriandoGames/all_validations_br/blob/main/README.en.md)

[![pub package](https://img.shields.io/pub/v/all_validations_br.svg)](https://pub.dev/packages/all_validations_br)
[![CI](https://github.com/CriandoGames/all_validations_br/actions/workflows/ecosystem-ci.yml/badge.svg)](https://github.com/CriandoGames/all_validations_br/actions/workflows/ecosystem-ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/CriandoGames/all_validations_br/blob/main/LICENSE)

O toolkit completo do ecossistema All para aplicações brasileiras em Flutter:
validações, formulários, `Result`, logging e criptografia em uma única
dependência, preservando também os imports históricos do pacote.

![all_validations_br toolkit](https://raw.githubusercontent.com/CriandoGames/all_validations_br/main/documentation/images/hero.png)

## Por que usar

`all_validations_br` é a porta de entrada para projetos Flutter que precisam de
vários módulos do ecossistema. Um único import disponibiliza regras brasileiras,
máscaras, contratos de resultado, logs estruturados e criptografia autenticada.

- Uma dependência para os cinco módulos oficiais.
- APIs especializadas mantidas em pacotes independentes e testáveis.
- Compatibilidade com projetos que já utilizam os imports históricos.
- Caminho de migração gradual para dependências menores.
- Exemplo Flutter integrado com cenários reais.

## O que está incluído

| Área | Pacote incluído | Principais recursos |
|---|---|---|
| Validações | [`all_br_validations`](https://pub.dev/packages/all_br_validations) `^1.0.0` | CPF, CNPJ, documentos, `BrZod`, `Contract`, formatadores e modelos BR |
| Formulários | [`all_br_forms`](https://pub.dev/packages/all_br_forms) `^1.0.0` | 24 máscaras e `TextInputFormatter`s para Flutter |
| Resultados | [`all_result`](https://pub.dev/packages/all_result) `^1.0.0` | `Result<F, S>`, composição síncrona e assíncrona |
| Logging | [`all_logger`](https://pub.dev/packages/all_logger) `^1.0.0` | níveis, filtros, cores, printers e outputs |
| Criptografia | [`all_crypto`](https://pub.dev/packages/all_crypto) `^1.0.1` | ChaCha20-Poly1305, AES-GCM, SHA-256, HMAC e envelope v2 |
| Compatibilidade | incluída no agregador | `HelperUtil` e barrels históricos |

Essas dependências são instaladas automaticamente. Não é necessário declará-las
separadamente ao usar o toolkit.

## Instalação

```yaml
dependencies:
  all_validations_br: ^4.6.0
```

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

## Uso rápido

### Validar e formatar dados brasileiros

```dart
final cpfValido = AllValidations.isCpf('529.982.247-25');
final documento = BrFormatter.formatCpf('52998224725');

final validator = BrZod().required().cpf().build;
final mensagem = validator('529.982.247-25'); // null: valor válido
```

### Máscara e validação no mesmo campo

```dart
TextFormField(
  inputFormatters: const [PhoneMask()],
  autovalidateMode: AutovalidateMode.onUserInteraction,
  validator: BrZod().required().phone().build,
)
```

A máscara controla a digitação; o `BrZod` valida o valor. Uma máscara, sozinha,
não comprova dígitos verificadores nem regras de domínio.

### Falhas explícitas com Result

```dart
Result<String, String> validateCustomer(String cpf) {
  final error = BrZod().required().cpf().build(cpf);
  return error == null
      ? Result.success<String, String>(cpf)
      : Result.failure<String, String>(error);
}

final message = validateCustomer('529.982.247-25').fold(
  (failure) => failure,
  (value) => 'CPF aceito: $value',
);
```

### Logging controlado por ambiente

```dart
final log = BrLogger(tag: 'Checkout');
log.info('pedido validado');
log.warning('gateway com latência elevada');
log.dispose();
```

O filtro padrão bloqueia logs em release. A liberação em produção precisa ser
explícita. O logger não remove dados sensíveis automaticamente.

### Criptografia autenticada com chave externa

```dart
final key = AllCrypto.generateKey(); // armazene em keychain, KMS ou cofre
final envelope = AllCrypto.encryptText('segredo', key: key);
final token = envelope.toBase64(); // nunca contém a chave

final restored = CryptEnvelope.fromBase64(token);
final plaintext = AllCrypto.decryptText(restored, key: key);
```

Para dados novos, prefira `AllCrypto` e `CryptEnvelope`. O pacote não fornece
cofre de chaves, KDF de senha, TLS ou autenticação de usuários.

## Toolkit completo ou módulos separados?

Use `all_validations_br` quando a aplicação é Flutter e utiliza vários módulos,
ou quando precisa manter compatibilidade enquanto migra. Em projetos novos que
usam apenas uma área, instale diretamente o pacote especializado. Projetos Dart
puros não devem instalar este agregador, pois `all_br_forms` adiciona Flutter ao
grafo de dependências.

| Se você precisa apenas de... | Instale diretamente |
|---|---|
| validações e regras brasileiras | `all_br_validations` |
| máscaras Flutter | `all_br_forms` |
| falhas tipadas | `all_result` |
| logging | `all_logger` |
| criptografia e hashes | `all_crypto` |

## Compatibilidade

O barrel principal e os imports históricos `validation.dart`, `br_zod.dart`,
`br_logger.dart`, `crypt.dart` e `regions_validations.dart` continuam
disponíveis. `HelperUtil` permanece no agregador para compatibilidade; prefira
as APIs especializadas em código novo.

## Exemplo integrado

O [aplicativo de exemplo](https://github.com/CriandoGames/all_validations_br/tree/main/example)
demonstra validações, máscaras, utilitários e criptografia. Execute com:

```bash
cd example
flutter pub get
flutter run
```

## Documentação

- [Arquitetura do ecossistema](https://github.com/CriandoGames/all_validations_br/blob/main/doc/pt-BR/architecture.md)
- [Como escolher um pacote](https://github.com/CriandoGames/all_validations_br/blob/main/doc/pt-BR/package-selection.md)
- [Guia de migração](https://github.com/CriandoGames/all_validations_br/blob/main/doc/pt-BR/migration-guide.md)
- [Referência do HelperUtil](https://github.com/CriandoGames/all_validations_br/blob/main/doc/pt-BR/helper-util.md)
- [Política de segurança](https://github.com/CriandoGames/all_validations_br/blob/main/SECURITY.md)
- [Como contribuir](https://github.com/CriandoGames/all_validations_br/blob/main/CONTRIBUTING.md)

Licença [MIT](https://github.com/CriandoGames/all_validations_br/blob/main/LICENSE).
