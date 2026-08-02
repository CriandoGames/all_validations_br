# Guia de migração

## Sem alteração imediata

Atualize para `all_validations_br: ^5.0.0` e mantenha o import atual. As APIs públicas históricas continuam reexportadas e cobertas por testes de compilação.

## Migração modular

1. Identifique os símbolos usados.
2. Adicione o pacote especializado na versão indicada na tabela do README.
3. Troque somente o import.
4. Execute analyzer e testes.
5. Remova o agregador quando nenhum import legado permanecer.

| Antes | Depois |
|---|---|
| `all_validations_br.dart` para `AllValidations` | `all_br_validations.dart` |
| `all_validations_br.dart` para `CpfMask` | `all_br_forms.dart` |
| `crypt.dart` | `all_crypto.dart` |
| `br_logger.dart` | `all_logger.dart` |
| `all_validations_br.dart` para `Result` | `all_result.dart` |

## Crypto: payload legado para envelope v2

O formato histórico `EncryptedPayload` não possui versão e suas serializações
incluem a chave. Ele continua legível pelo barrel antigo, mas não deve ser
gerado para novos dados.

```dart
final legacy = EncryptedPayload.fromBase64(oldToken);
final migrated = AllCrypto.migrateLegacy(legacy);

await saveEnvelope(migrated.envelope.toBase64());
await saveKeyInVault(migrated.key);
```

`CryptEnvelope.currentVersion` é `2`; versões ausentes, futuras ou
desconhecidas são rejeitadas. Se o token legado circulou fora de armazenamento
confiável, trate a chave embutida como comprometida e recifre com uma chave
nova. Para novos dados, use diretamente `AllCrypto.encryptText(..., key:)`.

`HelperUtil` não possui substituto único. Migre validação PIX para `all_br_validations`, formatação para `BrFormatter`, crypto/hash para `all_crypto` e JWT para uma biblioteca que valide assinatura. Os demais helpers permanecem compatíveis no agregador até uma decisão major futura.

O comportamento histórico de telefone foi preservado: `BrZod.phone()` aceita assinante cru com 8 ou 9 dígitos, além de formatos com DDD, enquanto `Contract.isPhoneNumber` exige uma regra canônica com DDD. Essa diferença possui teste dedicado para evitar uma mudança silenciosa de contrato.
