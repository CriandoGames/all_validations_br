# Guias de migração

## Da 5.0.1 para a 5.0.2

A 5.0.2 incorpora duas alterações incompatíveis de `all_br_validations`
1.0.2 e remove a validação PIX duplicada do agregador.

### Chaves PIX

```dart
// Antes
final tipo = HelperUtil.validatePixKey(chave); // String?

// Agora
final resultado = AllValidations.validatePixKey(chave);
final tipo = resultado.successValue; // PixKeyType
```

Mapeamento: `'CPF'` → `PixKeyType.cpf`, `'CNPJ'` → `PixKeyType.cnpj`,
`'Celular'` → `PixKeyType.phone`, `'Email'` → `PixKeyType.email` e
`'Chave Aleatória'` → `PixKeyType.random`.

`HelperUtil.maskPixKey` continua disponível e usa essa API tipada internamente.

### Verificação estrita de tipo

`BrZod.type<T>()` não realiza mais coerção:

```dart
BrZod().type<int>().build(123);   // válido
BrZod().type<int>().build('123'); // inválido
```

## Da 4.5.2 para a 5.0.0

A versão 5 transforma o pacote monolítico em um toolkit agregador. As
implementações passam a viver em cinco pacotes especializados, enquanto
`all_validations_br` preserva a fachada pública, os imports históricos e o
`HelperUtil`.

## Migração recomendada

Para aplicações que usam somente a API pública, a primeira etapa é alterar a
versão sem trocar o import:

```yaml
dependencies:
  all_validations_br: ^5.0.0
```

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

Execute `flutter pub get`, `flutter analyze` e seus testes. As cinco
dependências especializadas são instaladas automaticamente.

## O que continua funcionando

- O barrel `all_validations_br.dart` e seus símbolos públicos.
- Os imports `validation.dart`, `br_zod.dart`, `br_logger.dart`, `crypt.dart` e
  `regions_validations.dart`.
- `AllValidations`, `BrZod`, `Contract`, máscaras, formatadores, modelos,
  `Result`, logger e algoritmos crypto históricos.
- `HelperUtil`, inclusive métodos depreciados necessários para migração.
- Leitura e decifragem de payloads crypto históricos.

Os imports históricos de validação, BrZod, logger e regiões agora emitem aviso
de depreciação. Eles não possuem remoção programada nesta versão.

## Breaking changes e impactos comportamentais

### Deep imports privados

Imports em `package:all_validations_br/src/...` não são preservados. Troque-os
por um barrel público ou pelo pacote especializado:

| Antes | Depois recomendado |
|---|---|
| `all_validations_br/src/validator/...` | `package:all_br_validations/all_br_validations.dart` |
| `all_validations_br/src/masks/...` | `package:all_br_forms/all_br_forms.dart` |
| `all_validations_br/src/result/...` | `package:all_result/all_result.dart` |
| `all_validations_br/src/logger/...` | `package:all_logger/all_logger.dart` |
| `all_validations_br/src/crypt/...` | `package:all_crypto/all_crypto.dart` |

### Logger em release

Na 4.5.2, `BrDevelopmentFilter` permitia `warning` e níveis superiores em
release. Na 5.0.0, `BrLogger()` bloqueia todos os logs em release por padrão.
Para manter logs de erro em produção, habilite-os conscientemente:

```dart
final log = BrLogger(
  filter: const BrDevelopmentFilter(
    allowInRelease: true,
    minLevelProduction: BrLogLevel.error,
  ),
);
```

Os printers também exibem ícones por padrão. Se testes, arquivos ou parsers
dependem do texto exato, use `showIcons: false`.

### Criptografia

`CryptUtil` e `EncryptedPayload` continuam disponíveis para ler dados antigos.
Os atalhos que serializam a chave junto do ciphertext estão depreciados. Para
novos dados, use `AllCrypto`/`CryptEnvelope` e mantenha a chave em keychain, KMS
ou cofre externo.

## Migração modular opcional

Projetos novos podem instalar somente o módulo necessário. Em uma migração
gradual:

1. Identifique os símbolos usados.
2. Adicione o pacote indicado na tabela do README.
3. Troque apenas o import.
4. Execute analyzer e testes.
5. Remova o agregador quando nenhum import dele permanecer.

`HelperUtil` não possui substituto único. Migre cada uso para a API
especializada indicada em sua referência.
