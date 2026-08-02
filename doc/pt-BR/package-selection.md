# Como escolher um pacote

| Necessidade | Pacote |
|---|---|
| CPF, CNPJ, documentos, e-mail, URL, datas, `BrZod` ou `Contract` | `all_br_validations` |
| `TextInputFormatter`, máscaras e campos Flutter | `all_br_forms` |
| Cifras, hashes, HMAC e payloads criptográficos | `all_crypto` |
| Níveis, filtros, printers e outputs de log | `all_logger` |
| `Result<F, S>`, composição e operações assíncronas | `all_result` |
| Migração gradual ou todos os recursos | `all_validations_br` |

Projetos Dart sem Flutter não devem instalar o agregador nem `all_br_forms`. Instalar o módulo específico reduz o grafo de dependências e deixa clara a responsabilidade. Use o agregador quando a compatibilidade com imports existentes for mais importante que o tamanho do grafo.

`all_br_validations` é o core público de validações brasileiras. Aplicações e
bibliotecas podem adotá-lo diretamente como fundação para regras de domínio,
contratos, schemas e formatação. Sua API é versionada por SemVer, não depende de
Flutter e possui regras canônicas cobertas por testes. Isso permite construir
outros pacotes sobre ele sem depender do agregador de compatibilidade.

Essa garantia cobre o contrato de software documentado. Validar CPF, CNPJ ou
outro dado localmente não comprova identidade, titularidade ou existência em
uma fonte oficial.

## Decisão rápida

- Comece pelo módulo específico quando o projeto é novo.
- Use `all_validations_br` quando a aplicação já depende de múltiplos imports históricos ou precisa migrar gradualmente.
- Use `all_br_forms` somente na camada Flutter; valide o valor final com `all_br_validations` quando houver regra semântica.
- Não instale `all_crypto` para armazenar senhas; escolha uma biblioteca de derivação de senha apropriada.
- Em `all_crypto`, prefira `AllCrypto`/`CryptEnvelope` v2 e mantenha a chave
  fora do payload. Use `EncryptedPayload.fromJson`/`fromBase64` somente para
  ler dados legados.
- Não instale `all_logger` esperando redaction: sanitize CPF, token, cartão e chave antes de registrar.

## Imports focados

```dart
import 'package:all_result/all_result.dart';
import 'package:all_logger/all_logger.dart';
import 'package:all_br_validations/br_zod.dart';
import 'package:all_br_validations/validation.dart';
```

O `HelperUtil` não possui pacote substituto único. Consulte sua referência e migre apenas o método usado. O aplicativo reativo do diretório `example/` usa `all_observer` somente para demonstrar UI; consumidores do ecossistema não precisam dessa dependência.
