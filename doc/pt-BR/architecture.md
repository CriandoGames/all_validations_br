# Arquitetura do ecossistema

As implementações foram separadas em cinco projetos irmãos de `all_validations_br`, dentro do diretório de trabalho `E:/pro/all`. Essa disposição substitui o `packages/` sugerido no plano original por autorização explícita do mantenedor e permite que cada pacote seja versionado/publicado de forma independente.

```text
all_br_forms ──────────> all_br_validations ──────> all_result

all_validations_br ────> all_br_forms
all_validations_br ────> all_br_validations
all_validations_br ────> all_crypto
all_validations_br ────> all_logger
all_validations_br ────> all_result
```

`all_crypto`, `all_logger` e `all_result` são Dart puros e independentes. `all_br_validations` é Dart puro e usa `all_result` para `ValidationNotifiable` e `ValidationResult`. `all_br_forms` depende de Flutter e usa `all_br_validations` em integrações sem duplicar regras. O agregador depende de todos e mantém apenas barrels, testes de compatibilidade, documentação, exemplo e `HelperUtil` legado.

Manifestos publicáveis usam versões hospedadas. `pubspec_overrides.yaml`, excluído dos pacotes, conecta os diretórios irmãos durante desenvolvimento e validação local.

## Responsabilidades e fronteiras

| Pacote | Runtime | Dependência do ecossistema | Responsabilidade pública |
|---|---|---|---|
| `all_result` | Dart | nenhuma | `Result<F, S>`, composição e operações assíncronas |
| `all_crypto` | Dart | nenhuma | cifras, hashes, MACs e `CryptEnvelope` v2 com chave externa |
| `all_logger` | Dart | nenhuma | níveis, filtros, printers e outputs |
| `all_br_validations` | Dart | `all_result` | regras brasileiras, formatadores, `BrZod` e `Contract` |
| `all_br_forms` | Flutter | `all_br_validations` | máscaras e integração de entrada Flutter |
| `all_validations_br` | Flutter | os cinco módulos | fachada mantida, compatibilidade e `HelperUtil` |

Pacotes especializados nunca importam o agregador. Os quatro pacotes Dart puros não importam Flutter. Regras de validação ficam em `all_br_validations`; máscaras podem moldar digitação, mas não copiam algoritmos de CPF/CNPJ. O root não contém implementações extraídas: seus barrels reexportam os módulos responsáveis.

## Superfície pública e compatibilidade

O barrel principal permanece disponível e não está depreciado. Imports históricos de assunto continuam compilando, mas apontam para entry points estreitos quando isso evita ampliar a superfície antiga. `br_zod.dart`, `br_logger.dart`, `validation.dart` e `regions_validations.dart` orientam a migração por mensagens acionáveis; nenhuma versão de remoção foi aprovada.

`HelperUtil` permanece somente no agregador porque mistura texto, datas, plataforma, JWT, PIX, UUID e helpers antigos de senha. Criar um `all_utils` apenas deslocaria essa falta de coesão. A migração é feita método a método e os riscos legados estão na política de segurança.

Na fronteira crypto, `AllCrypto` e `CryptEnvelope` v2 são o caminho recomendado:
o envelope é versionado e nunca contém a chave. `EncryptedPayload` continua
decodificando o formato histórico sem versão; somente seus pontos de
serialização com chave embutida permanecem depreciados para migração.

## Desenvolvimento e CI

Cada manifesto publicável usa constraints hospedadas, sem `path`. Overrides locais, sempre excluídos do archive, conectam os irmãos antes da publicação. O CI global verifica inventário, fronteiras, ciclos, imports, documentação, exemplos, segredos, analyzer, testes com cobertura, dartdoc e seis dry-runs. Os cinco repositórios já existem, mas precisam receber o estado local final antes que o checkout global reproduza esta validação.

O `all_observer` aparece exclusivamente no aplicativo `example/` para demonstrar reconstrução reativa de um resultado integrado. Ele não é arquitetura nem dependência de runtime dos pacotes; controller, observables, computeds, lints e descarte ficam confinados ao exemplo.
