# Auditoria final de validações

## Resumo

```text
Commit inicial: c8b22db608e726abba057fd7195dd4692c7dda2e
Versão inicial: 4.5.1
Problemas analisados: 9
Bugs confirmados: 9
Bugs corrigidos: 9
Testes antes: 1.258
Testes depois: 1.319
Analyzer: aprovado, sem issues
Coverage: 85,49% de linhas (2.269/2.654)
Publish dry-run: aprovado, sem warnings
Versão preparada: 4.5.2
```

A linha de base estava limpa, com 1.258 testes, analyzer sem issues e
`flutter pub publish --dry-run` sem warnings. A versão 4.5.2 foi escolhida após
confirmação do mantenedor de que a 4.5.1 já havia sido publicada.

## Matriz

| Problema | Teste falhou antes | Corrigido | Risco |
|---|---:|---:|---|
| `getStateByDDD` inacessível | Sim — erro de compilação | Sim | Baixo |
| Cartão sem Luhn | Sim — 6 casos | Sim | Médio |
| `DateTime` por `inDays` | Sim — 2 casos | Sim | Médio |
| Tipos misturados no `Contract` | Sim — 7 casos | Sim | Baixo |
| CNS permissivo | Sim — 3 casos | Sim | Médio |
| Telefone permissivo | Sim — 6 casos | Sim | Médio |
| E-mail divergente | Sim — 7 casos | Sim | Médio |
| `null` convertido em `''` | Sim — 2 casos | Sim | Médio |
| Documentação incorreta | Sim — 1 varredura | Sim | Baixo |

## Evidências

### `AllValidations.getStateByDDD`

```text
Entrada: AllValidations.getStateByDDD('11')
Resultado anterior: erro de compilação "Member not found"
Resultado esperado: BrazilianState.SP
Causa raiz: método de instância em classe com construtor privado
Teste: grupo AllValidations.getStateByDDD
Correção: método convertido para static, sem alteração do mapa ou enum
Resultado depois: SP, RJ, DF e Unknown aprovados
```

### Cartão de crédito

```text
Entrada: 4111111111111112 e abc4111111111111111xyz
Resultado anterior: ambos aceitos
Resultado esperado: ambos rejeitados
Causa raiz: somente bandeira/comprimento eram verificados e qualquer
  caractere não numérico era removido
Teste: grupo AllValidations.isCreditCard
Correção: formato original estrito, bandeira/comprimento e Luhn
Resultado depois: 11 casos aprovados
```

### Comparações de `DateTime`

```text
Entrada: 2026-08-01 10:00 versus 2026-08-01 20:00
Resultado anterior: areEquals considerava os valores iguais
Resultado esperado: instantes diferentes
Causa raiz: uso de difference(...).inDays
Teste: subgrupo equality de Contract DateTime comparisons
Correção: uso de isAtSameMomentAs
Resultado depois: 4 casos de igualdade aprovados
```

```text
Entrada: DateTime(2026) versus '2026-01-01'
Resultado anterior: TypeError por cast forçado
Resultado esperado: notificação sem exceção
Causa raiz: bastava um operando ser DateTime para todos serem convertidos
Teste: subgrupo mixed types, cobrindo os 7 comparadores
Correção: detecção centralizada de tipos DateTime incompatíveis
Resultado depois: 7 comparadores notificam e retornam normalmente
```

### CNS

```text
Entrada: abc700616457492001xyz
Resultado anterior: aceito após remoção de caracteres
Resultado esperado: rejeitado
Causa raiz: normalização de qualquer caractere não numérico
Teste: grupo BrZod CNS
Correção: exigência de exatamente 15 dígitos antes do algoritmo
Resultado depois: vetor válido preservado e 3 contaminações rejeitadas
```

### Telefone

```text
Entrada: (00) 98765-4321 e (11) 18765-4321
Resultado anterior: aceitos pela quantidade de dígitos
Resultado esperado: rejeitados por DDD e prefixo
Causa raiz: remoção irrestrita de caracteres e ausência de regras básicas
Teste: grupo BrZod phone
Correção: formatos conhecidos, lista oficial de DDDs e prefixos por tamanho
Resultado depois: 6 formatos válidos aceitos e 7 inválidos rejeitados
```

### E-mail

```text
Entrada: a..b@example.com, a@-example.com e user%tag@example.com
Resultado anterior: aceitação divergente entre as APIs
Resultado esperado: rejeição consistente
Causa raiz: regexes independentes e permissivas
Teste: grupo Email consistency
Correção: função interna isAllowedEmail compartilhada pelas três APIs
Resultado depois: 3 válidos aceitos e 10 inválidos rejeitados em todas as APIs
```

### Preservação de `null`

```text
Entrada: {'field': null} com BrZod().custom(...)
Resultado anterior: callback recebia ''
Resultado esperado: callback recebe null
Causa raiz: schema.build(data[key] ?? '')
Teste: grupo BrZod.validate null preservation
Correção: schema.build(data[key])
Resultado depois: null preservado; required e optional sem regressão
```

### Documentação

```text
Entrada: AB.1CD.2EF/3GHI-45 documentado como válido
Resultado anterior: CnpjAlfanumerico.isValid retornava false
Resultado esperado: exemplo com DVs válidos
Causa raiz: dígitos verificadores incorretos no guia
Teste: varredura de README.md, doc/AllValidations.md e
  doc/CnpjAlfanumerico.md
Correção: vetor alterado para AB.1CD.2EF/3GHI-09 e referência inexistente
  a cnpjOuAlfa removida
Resultado depois: todos os exemplos marcados como válidos são aceitos
```

## Compatibilidade

- Nenhuma API pública foi removida ou renomeada.
- `getStateByDDD` passou a ser acessível estaticamente; o construtor privado já
  impedia o uso externo como método de instância.
- Há possível **breaking change comportamental**: cartão, CNS, telefone e
  e-mail agora rejeitam entradas contaminadas ou estruturalmente inválidas que
  antes eram aceitas por normalização permissiva.
- Comparações de `DateTime` agora consideram o instante completo. Tipos
  incompatíveis geram notificação, em vez de lançar `TypeError`.
- Callbacks de `BrZod.validate()` recebem o `null` original, não uma string
  vazia. Callbacks que presumiam `String` devem tratar `null` explicitamente.
- Consumidores que desejem tolerar pontuação ou espaços não documentados devem
  normalizar a entrada explicitamente antes de chamar os validadores.
- Como a 4.5.1 já foi publicada, a versão preparada é 4.5.2.

## Arquivos modificados

| Arquivo | Justificativa |
|---|---|
| `.github/workflows/dart_flutter_ci.yml` | Adiciona `git diff --check` sem ocultar falhas. |
| `pubspec.yaml` | Prepara a versão 4.5.2. |
| `README.md` | Atualiza instalação e badge para 1.319 testes. |
| `CHANGELOG.md` | Documenta correções e possível quebra comportamental. |
| `doc/AllValidations.md` | Corrige uso estático, cartão estrito e exemplo de CNPJ. |
| `doc/BrZod.md` | Documenta telefone/CNS estritos, e-mail comum e `null`. |
| `doc/Result.md` | Registra a regra compartilhada de e-mail. |
| `lib/src/validator/all_validations.dart` | Torna DDD estático e adiciona Luhn/e-mail comum. |
| `lib/src/validator/contract_validations.dart` | Corrige comparações e delega e-mail. |
| `lib/src/validator/internal/email_validator.dart` | Centraliza a regra interna de e-mail. |
| `lib/src/br_zod/br_zod.dart` | Preserva `null` e corrige o dartdoc de CNPJ. |
| `lib/src/br_zod/validations/br.dart` | Torna CNS estrito. |
| `lib/src/br_zod/validations/generic.dart` | Torna telefone estrito e unifica e-mail. |
| `test/regressions/validation_final_regressions_test.dart` | Reproduz e protege todas as correções. |
| `test/public_api_smoke_test.dart` | Protege as principais exportações públicas. |
| `AUDITORIA_validation_final.md` | Consolida evidências e impacto da auditoria. |
