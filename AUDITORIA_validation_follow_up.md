# Validação test-first das pendências — `all_validations_br`

Data: 2026-08-01  
Branch: `audit/validation-follow-up`  
Commit inicial: `0e90991842fe48ea63a1f9d42f61c14cf99b2e82`  
Base de comparação solicitada: `e6eb4234c1148d057b435bd802815009fbd7e29a`

## Resumo

```text
Suspeitas analisadas: 12
Bugs confirmados: 11 (10 funcionais e 1 documental)
Bugs não confirmados: 0
Bugs corrigidos: 11
Testes antes: 1.197, todos passando
Testes depois: 1.258, todos passando (+61)
Analyzer: sem issues
Publish dry-run: aprovado com 0 avisos em cópia temporária limpa
```

A nova suíte tinha 60 testes na primeira reprodução completa: 38 falharam e
22 passaram antes da alteração da implementação. Após as correções, os 60
passaram. Um teste adicional passou a validar automaticamente todos os
literais de CNPJ do guia, levando a suíte específica a 61 testes.

O dry-run executado diretamente no worktree concluiu a validação do pacote,
mas retornou o aviso esperado de arquivos não commitados. Como commits não
foram autorizados, o conteúdo final foi copiado sem `.git` e sem artefatos para
uma pasta temporária: nessa cópia, `flutter pub publish --dry-run` terminou com
zero avisos e código de saída 0.

## Matriz de resultados

| Suspeita | Reproduzida | Teste falhou antes | Corrigida | Risco |
| --- | ---: | ---: | ---: | --- |
| `isTrue/isFalse` invertidos | Sim | Sim | Sim | Médio |
| RG aceita separador arbitrário | Sim | Sim | Sim | Baixo |
| CPF aceita lixo externo | Sim | Sim | Sim | Médio |
| CNPJ aceita lixo externo | Sim | Sim | Sim | Médio |
| CNH aceita lixo externo | Sim | Sim | Sim | Médio |
| RENAVAM aceita lixo externo | Sim | Sim | Sim | Médio |
| PIS aceita lixo externo | Sim | Sim | Sim | Médio |
| Título aceita lixo externo | Sim | Sim | Sim | Médio |
| `isDateTime` aceita data impossível | Sim | Sim | Sim | Médio |
| `BrZod.isDate` normaliza data inválida | Sim | Sim | Sim | Médio |
| Exemplos de CNPJ inválidos | Sim | Sim, por validação dos literais | Sim | Baixo |
| Arquivos fora do escopo alterados | Sim | Não se aplica: inspeção de diff | Sim | Baixo |

Os exemplos oficiais `12ABC34501DE35` e `12.ABC.345/01DE-35` já eram válidos.
O problema documental estava em outros exemplos apresentados como saídas de
geração/formatação, cujos DVs eram inventados.

## Evidência por bug

### 1. `Contract.isTrue` e `Contract.isFalse`

```text
Entrada: isTrue(true) e isFalse(false)
Resultado anterior: ambos adicionavam notificação
Resultado esperado: contrato válido e sem notificações
Causa raiz: isFalse notificava quando o valor era false; isTrue delegava à regra invertida
Teste criado: grupo "Contract isTrue/isFalse", incluindo encadeamento
Correção aplicada: isFalse passou a notificar somente quando value é true
Resultado após correção: 5/5 cenários aprovados
```

### 2. RG com separadores arbitrários

```text
Entrada: 29a385b462-2, 29@385#462-2, 29 385 462-2, 29/385/462-2
Resultado anterior: true em AllValidations e válido no BrZod
Resultado esperado: false/erro de validação
Causa raiz: `.?` usava ponto curinga em vez de `\.?`
Teste criado: válidos com/sem ponto e X; inválidos com cinco separadores e conteúdo externo
Correção aplicada: pontos literais opcionais nas duas implementações
Resultado após correção: AllValidations, validateRG e BrZod rejeitam os casos
```

### 3. CPF com caracteres extras

```text
Entrada: abc529.982.247-25xyz, 529a982b247c25 e 529-982-247.25
Resultado anterior: válido após remover todos os não dígitos
Resultado esperado: rejeição integral da entrada
Causa raiz: o algoritmo limpava antes de validar o formato original
Teste criado: vetor independente, lixo externo, letras internas, máscara inválida e BrZod
Correção aplicada: somente 11 dígitos ou máscara ddd.ddd.ddd-dd antes do cálculo dos DVs
Resultado após correção: todos os negativos são rejeitados nas APIs testadas
```

### 4. CNPJ numérico com caracteres extras

```text
Entrada: abc11.222.333/0001-81xyz, 11A222B333C0001D81 e máscara com hífens
Resultado anterior: válido após limpeza indiscriminada
Resultado esperado: rejeição integral da entrada
Causa raiz: ausência de validação do formato original
Teste criado: vetor independente, lixo externo, letras internas, máscara inválida e BrZod
Correção aplicada: somente 14 dígitos ou máscara dd.ddd.ddd/dddd-dd antes dos DVs
Resultado após correção: todos os negativos são rejeitados
```

### 5. CNH com caracteres extras

```text
Entrada: abc84718735264xyz e 8_4718735264
Resultado anterior: válido
Resultado esperado: inválido
Causa raiz: remoção de qualquer caractere não numérico
Teste criado: vetor válido conhecido e entradas contaminadas em AllValidations/BrZod
Correção aplicada: exigir exatamente 11 dígitos antes do algoritmo existente
Resultado após correção: entradas contaminadas rejeitadas
```

### 6. RENAVAM com caracteres extras

```text
Entrada: abc95606520941xyz e 9_5606520941
Resultado anterior: válido
Resultado esperado: inválido
Causa raiz: remoção de qualquer caractere não numérico
Teste criado: vetor válido conhecido e entradas contaminadas em AllValidations/BrZod
Correção aplicada: exigir de 9 a 11 dígitos antes do algoritmo existente
Resultado após correção: entradas contaminadas rejeitadas
```

### 7. PIS/PASEP com caracteres extras

```text
Entrada: abc12345678919xyz e 1_2345678919
Resultado anterior: válido
Resultado esperado: inválido; a máscara oficial deve permanecer válida
Causa raiz: remoção de qualquer caractere não numérico
Teste criado: número puro, máscara 123.45678.91-9 e entradas contaminadas
Correção aplicada: aceitar 11 dígitos ou máscara ddd.ddddd.dd-d antes dos DVs
Resultado após correção: formatos documentados passam e lixo é rejeitado
```

### 8. Título de Eleitor com caracteres extras

```text
Entrada: abc006000610949xyz e 0_06000610949
Resultado anterior: válido
Resultado esperado: inválido
Causa raiz: remoção de qualquer caractere não numérico
Teste criado: vetor válido conhecido e entradas contaminadas em AllValidations/BrZod
Correção aplicada: exigir exatamente 12 dígitos antes do algoritmo existente
Resultado após correção: entradas contaminadas rejeitadas
```

### 9. `AllValidations.isDateTime` superficial

```text
Entrada: 2026-02-30T12:00:00.000Z, hora 25, minuto/segundo 60 e X antes dos ms
Resultado anterior: true
Resultado esperado: false
Causa raiz: regex com `.` curinga e sem validação dos componentes do calendário
Teste criado: 2 positivos e 7 negativos de formato/calendário
Correção aplicada: formato integral, DateTime.tryParse e comparação dos sete componentes
Resultado após correção: somente datas e horários reais passam
```

### 10. Datas normalizadas pelo `BrZod`

```text
Entrada: 2020-01-42, 2026-02-29, 2026-13-01 e horário 25:00
Resultado anterior: DateTime.tryParse normalizava e a validação aceitava
Resultado esperado: rejeição
Causa raiz: isDate chamava tryParse diretamente e before/after tinham parsing separado
Teste criado: isDate, funções genéricas, isBefore e isAfter
Correção aplicada: uma única função interna valida formato, calendário, horário e timezone
Resultado após correção: isDate/isBefore/isAfter interpretam as entradas igualmente
```

### 11. Exemplos inválidos de CNPJ alfanumérico

```text
Entrada: K7B3X19QAC0234, AB1CD2EF3GHI45, AB123CDE000139 e AB1CD2EF000199
Resultado anterior: exemplos documentados, mas rejeitados pela biblioteca
Resultado esperado: todo literal apresentado como CNPJ válido deve ter DVs corretos
Causa raiz: DVs ilustrativos inventados manualmente
Teste criado: vetores oficiais fixos, geração round-trip e varredura dos literais do guia
Correção aplicada: vetor oficial 12ABC34501DE35 ou valores gerados e validados
Resultado após correção: todos os literais encontrados no guia são válidos
```

## Arquivos modificados

### Correções e evidências desta auditoria

- `.github/workflows/dart_flutter_ci.yml`: CI mínima com `pub get`, analyzer,
  testes e publish dry-run, sem `continue-on-error`.
- `doc/CnpjAlfanumerico.md`: remove DVs ilustrativos inventados e usa vetor
  oficial ou geração validada.
- `lib/src/validator/contract_validations.dart`: corrige a semântica de
  `isFalse`; `isTrue` volta a funcionar por delegação.
- `lib/src/validator/all_validations.dart`: formatos estritos de documentos,
  ponto literal do RG e validação real de data/hora.
- `lib/src/br_zod/validations/br.dart`: aplica os mesmos formatos estritos nas
  validações brasileiras do BrZod.
- `lib/src/br_zod/validations/generic.dart`: parser estrito compartilhado por
  `isDate`, `isBeforeDate` e `isAfterDate`.
- `test/regressions/validation_follow_up_regressions_test.dart`: 61 testes
  específicos, vetores independentes e contratos entre APIs.
- `AUDITORIA_validation_follow_up.md`: este relatório.

### Reversões de mudanças fora do escopo

Os nove arquivos abaixo eram byte a byte equivalentes à base após remover
whitespace. Portanto, eram somente formatação. Foram restaurados exatamente a
`e6eb4234` e não aparecem no diff acumulado contra essa base:

- `lib/src/crypt/algorithms/aes_core.dart`
- `lib/src/crypt/algorithms/aes_gcm.dart`
- `lib/src/crypt/algorithms/sha256.dart`
- `lib/src/crypt/crypt_util.dart`
- `lib/src/crypt/models/crypt_algorithm.dart`
- `test/aes_gcm_test.dart`
- `test/br_zod_generic_test.dart`
- `test/masks/card_mask_test.dart`
- `test/masks/cest_iof_nup_cert_mask_test.dart`

Esses arquivos aparecem como reversões no status relativo ao `HEAD` atual,
pois a formatação havia sido incluída no commit anterior. Isso é intencional e
remove as mudanças alheias do diff funcional acumulado contra `e6eb4234`.

## Compatibilidade

- Nenhum método público foi removido, renomeado ou teve assinatura alterada.
- CPF aceita somente 11 dígitos ou máscara oficial.
- CNPJ numérico aceita somente 14 dígitos ou máscara oficial.
- CNH e Título de Eleitor aceitam somente dígitos.
- RENAVAM preserva 9 a 11 dígitos, sem separadores arbitrários.
- PIS/PASEP preserva número puro e máscara oficial.
- RG preserva ausência de separadores ou pontos literais, com hífen opcional.
- Datas impossíveis deixam de ser normalizadas silenciosamente.
- `isTrue`/`isFalse` passam a cumprir a semântica indicada pelos nomes.

Consumidores que dependiam da aceitação permissiva de letras, espaços ou
separadores arbitrários precisarão normalizar explicitamente os dados antes de
validá-los. Consumidores que contornavam a semântica invertida dos contratos
também devem remover o contorno.

Uma versão `4.5.1` é recomendada: são correções compatíveis em nível de API,
adequadas a patch version, mas com endurecimento intencional de entradas. A
versão e o `CHANGELOG.md` não foram alterados porque isso foi proibido no
escopo.

## Execução final

```text
flutter analyze                                      OK — No issues found
flutter test validation_follow_up...                 OK — 61 testes
flutter test                                         OK — 1.258 testes
flutter test --coverage                              OK — 1.258 testes
coverage                                             84,32% (2.200/2.609 linhas)
flutter pub publish --dry-run (cópia limpa)          OK — 0 avisos
dart format <cinco arquivos Dart no escopo>          OK
git diff --check                                     OK
```

## Pendências

- Nenhuma pendência funcional confirmada desta auditoria permanece aberta.
- A versão `4.5.1`, o `CHANGELOG.md`, commit, push e publicação real dependem
  de autorização explícita e não foram executados.

