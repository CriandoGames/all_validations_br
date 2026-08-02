# Auditoria do patch 5.0.1

Escopo validado: correções críticas e médias solicitadas para
`all_br_validations`, `all_logger` e `all_validations_br`, além da correção
documental suplementar solicitada para `all_result`. Nenhuma publicação, tag,
release ou push foi realizada.

## all_br_validations

- Commit inicial: `1b945802aa918973b3bb86d4f1a42f9ffed22526`
- Commit final local: `f49bfbf930c62ada70f559a451206587ce3ea642`
- Versão anterior: `1.0.0`
- Versão preparada: `1.0.1`
- Testes antes: regressão de telefone confirmou 7 falhas de permissividade/divergência; os 5 comparadores ordenáveis lançaram `NoSuchMethodError` para tipos incompatíveis.
- Testes depois: 23 testes isolados novos e suíte completa com 739 testes aprovados.
- Analyzer: aprovado, sem issues.
- Cobertura: 951/1151 linhas, 82,62%.
- Dartdoc: aprovado, 0 warnings e 0 errors.
- Publish dry-run: aprovado, 0 warnings.

## all_logger

- Commit inicial: `a32ff332119277cebdaaa953ee2a9f50f66b278f`
- Commit final local: `32539f0dd37d51fc0f7e55f70735d00185fee1cf`
- Versão anterior: `1.0.0`
- Versão preparada: `1.0.1`
- Testes antes: os casos `maxRecords: 0` e `maxRecords: -1` falharam porque o construtor aceitava ambos.
- Testes depois: 6 testes isolados de `BrMemoryOutput` e suíte completa com 36 testes aprovados.
- Analyzer: aprovado, sem issues.
- Cobertura: 118/151 linhas, 78,15%.
- Dartdoc: aprovado, 0 warnings e 0 errors.
- Publish dry-run: aprovado, 0 warnings.

## all_result

- Commit inicial: `85054a222f2c1560c5488de76328bcc876ca289d`
- Commit final local: `c82ffd7e2a4ece6381d187086c3c0b97606ac61a`
- Versão anterior: `1.0.0`
- Versão preparada: `1.0.1`
- Testes antes: a regressão documental falhou porque o comentário de `FutureResult` usava o método nativo `Future.then` e não continha a composição pretendida com `flatMapAsync`.
- Testes depois: teste isolado aprovado e suíte completa com 70 testes aprovados.
- Analyzer: aprovado, sem issues.
- Cobertura: 109/141 linhas, 77,30%.
- Dartdoc: aprovado, 0 warnings e 0 errors; o exemplo gerado usa `flatMapAsync(checkStatus)`.
- Publish dry-run: aprovado, 0 warnings.

## all_validations_br

- Commit inicial: `f2ab179172b93ee26d15f62c2447cae2501b7079`
- Commit final local: `b711a3cc86a2799206f41605b102e96e61a9ac8a` (implementação em `6ce5d60`; relatório adicionado no commit seguinte).
- Versão anterior: `5.0.0`
- Versão preparada: `5.0.1`
- Testes antes: uma worktree temporária do commit inicial confirmou 4 falhas executadas (CNPJ não reconhecido, CNPJ devolvido sem máscara, valor desconhecido devolvido em aberto e `TypeError` para `exp` string). O teste de igualdade JWT não compilava por ausência de `referenceTime`, e o teste integrado confirmou a versão antiga permissiva de telefone.
- Testes depois: 12 regressões isoladas de `HelperUtil`, 1 teste integrado e suíte completa com 92 testes aprovados.
- Analyzer: aprovado, sem issues.
- Cobertura: 198/221 linhas, 89,59%.
- Dartdoc: aprovado com dartdoc 9.0.8, 0 errors. Permanecem 4 warnings de links do barrel legado `all_validations_br.crypt`.
- Publish dry-run: aprovado, 0 warnings e 2 hints esperados pelos overrides locais de `all_br_validations`/`all_logger` antes da publicação.

## Matriz das correções

| Problema | Pacote | Teste falhou antes | Corrigido | Versão |
|---|---|---:|---:|---:|
| telefone permissivo | all_br_validations | sim | sim | 1.0.1 |
| divergência entre fachadas | all_br_validations | sim | sim | 1.0.1 |
| comparadores lançando | all_br_validations | sim | sim | 1.0.1 |
| `maxRecords <= 0` | all_logger | sim | sim | 1.0.1 |
| exemplo assíncrono de `FutureResult` | all_result | sim | sim | 1.0.1 |
| Pix sem CNPJ | all_validations_br | sim | sim | 5.0.1 |
| máscara expondo dado | all_validations_br | sim | sim | 5.0.1 |
| JWT com `exp` incompatível | all_validations_br | sim | sim | 5.0.1 |
| CI integrado incompleto | repositório | N/A (inspeção do workflow) | sim | sem versão |

## Validação integrada

- `check_package_boundaries.dart`: aprovado.
- `analyze_all_packages.dart`: seis pacotes aprovados, sem alterações de formatação e sem issues.
- `test_all_packages.dart`: seis pacotes aprovados com cobertura.
- `check_examples.dart`: exemplos Dart e Flutter aprovados; testes de widget e `custom_lint` aprovados.
- `doc_all_packages.dart`: seis pacotes documentados, sem erros. Foram preservados warnings de links já existentes em documentação legada.
- `publish_dry_run_all.dart`: seis dry-runs aprovados; nenhum pacote foi publicado.
- Após a correção suplementar, `all_result 1.0.1` também foi revalidado isoladamente com formatação, analyzer, suíte, cobertura, dartdoc e publish dry-run.
- `git diff --check`: aprovado nos quatro pacotes alterados.

## Cobertura integrada

| Pacote | Linhas cobertas | Linhas instrumentadas | Cobertura |
|---|---:|---:|---:|
| all_result | 109 | 141 | 77,30% |
| all_crypto | 767 | 774 | 99,10% |
| all_logger | 118 | 151 | 78,15% |
| all_br_validations | 951 | 1151 | 82,62% |
| all_br_forms | 261 | 274 | 95,26% |
| all_validations_br | 198 | 221 | 89,59% |

## Problemas não corrigidos

- No Dart SDK 3.12.2 usado na revalidação, o `dart doc` embutido falhou internamente ao detectar o diretório do SDK (`type 'Null' is not a subtype of type 'String'`). O dartdoc 9.0.8 fixado no workflow concluiu normalmente com o Flutter SDK informado pelo CI; a execução manual equivalente também passou com `--sdk-dir` explícito.
- O dartdoc do agregador ainda informa 4 warnings de links relativos ao barrel legado `all_validations_br.crypt`; não houve erro de geração.
- Documentações legadas de alguns pacotes irmãos também produzem warnings de links relativos no dartdoc consolidado. Eles não pertencem ao escopo funcional deste patch.
- O workflow atualizado foi validado por seus scripts equivalentes locais. A execução agendada real só poderá ser confirmada após o workflow estar no GitHub.
- Disparo imediato entre repositórios exigiria coordenação externa ou segredo apropriado; esta possibilidade não foi configurada no código.

## Ordem manual futura de publicação

1. `all_result 1.0.1`
2. `all_br_validations 1.0.1`
3. `all_logger 1.0.1`
4. `all_validations_br 5.0.1`

O agregador deve ser publicado por último, pois exige
`all_br_validations >=1.0.1` e `all_logger >=1.0.1`.
