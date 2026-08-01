# Auditoria e correção test-first — `all_validations_br`

Data: 2026-08-01  
Escopo: `AllValidations`, `ContractValidations`, `BrZod` e `CnpjAlfanumerico`.

## Resumo

- **Bugs inequívocos confirmados:** 11.
- **Bugs corrigidos:** 11.
- **Hipóteses não confirmadas e não alteradas:** 11.
- **Testes no `HEAD` original:** 1.110, todos passando.
- **Testes após as correções:** 1.197, todos passando (**+87**).
- **Analyzer original:** sem issues.
- **Analyzer final:** sem issues.
- **Cobertura final:** 83,61% das linhas (2.148/2.569).
- **SDK usado:** Flutter 3.47.0-1.0.pre-68 (stable), Dart 3.12.2.
- **Versões mínimas do pacote:** Dart `>=3.0.0 <4.0.0`; Flutter `>=3.0.0`.
- **Dependências de produção:** somente Flutter SDK. Dependências de desenvolvimento: `flutter_test` e `flutter_lints`.

O `HEAD` original foi executado em uma cópia temporária isolada, sem tocar no
worktree: `flutter analyze` não encontrou problemas e `flutter test` encerrou
com 1.110 testes aprovados. A suíte de regressão foi então colocada sobre essa
implementação antiga: 29 testes falharam no arquivo principal de regressões,
6 falharam no teste de integração do `BrZod` e 3 vetores de CNPJ falharam. A
aceitação de caracteres proibidos no CNPJ foi reproduzida depois em um teste
isolado, antes da correção mínima.

`dart format --output=none --set-exit-if-changed .` já falhava no `HEAD` em 10
arquivos. Um deles (`lib/src/br_zod/br_zod.dart`) entrou no escopo da correção;
após autorização para finalizar a formatação, os 9 arquivos restantes também
foram formatados. O projeto inteiro passa na verificação global de formatação.

## Inventário e compatibilidade estrutural

As APIs principais continuam exportadas por `lib/all_validations_br.dart`.
`BrZod` permanece disponível pelo barrel separado `lib/br_zod.dart`; contratos,
por `lib/validation.dart`. Nenhum método público foi removido, renomeado ou teve
a assinatura alterada.

Foram confirmadas duplicações entre as três famílias de API para URL, CEP, CPF,
CNPJ e UUID; e entre `AllValidations`/`BrZod` para RG, placa, CNH, RENAVAM,
PIS/PASEP e Título de Eleitor. Os testes de contrato agora comparam essas APIs.
A URL passou a usar uma função pura interna compartilhada; CEP delega no
contrato para `AllValidations`; e CNPJ alfanumérico no `BrZod` delega para
`CnpjAlfanumerico`. As demais duplicações foram mantidas para evitar refatoração
ampla sem necessidade.

## Alterações por arquivo

### `lib/src/validator/all_validations.dart`

- Ancoragem integral das regexes de SHA-1 e SHA-256.
- URL delegada ao validador interno baseado em `Uri.tryParse`.
- Código do país `55` removido apenas com 13 dígitos no celular ou 12 no fixo.
- `isUUID(null)` retorna `false`, sem exceção.
- CEP limitado aos três formatos públicos completos.
- RG ancorado no início e no fim.

### `lib/src/validator/internal/url_validator.dart`

- Nova função pura interna para URL.
- Aceita apenas `http`, `https` e `ftp`, com host não vazio e sem whitespace.

### `lib/src/validator/contract_validations.dart`

- `isURL` e `isValidBRZip` passaram a delegar às regras de `AllValidations`.

### `lib/src/br_zod/validations/security.dart`

- URL passou a usar a mesma função pura das demais APIs.

### `lib/src/br_zod/validations/br.dart`

- CNPJ alfanumérico delega para `CnpjAlfanumerico.isValid`.
- CEP valida o formato original completo, sem remover caracteres arbitrários.
- RG recebeu ancoragem integral.

### `lib/src/cnpj/cnpj_alfanumerico.dart`

- Conversão oficial corrigida para `codeUnit - 48` em todos os caracteres.
- Validação agora aceita apenas 14 caracteres sem máscara ou a máscara oficial.
- Geração usa o mesmo algoritmo oficial corrigido e continua aceitando CNPJs
  numéricos legados.

### `lib/src/br_zod/br_zod.dart`

- `validate()` percorre a árvore uma única vez e produz `errors`/`errorList` do
  mesmo resultado.
- Valores aninhados incompatíveis são tratados como mapa vazio; `Map` dinâmico
  é normalizado com segurança.
- Documentação do CEP atualizada com os três formatos preservados.

### `test/regressions/validation_regressions_test.dart`

- Nova suíte dos lotes 1–3 e testes de contrato entre APIs.

### `test/cnpj_alfanumerico_test.dart`

- Vetor oficial, vetor independente, máscara, lowercase, DVs adulterados,
  caracteres proibidos, posições alfanuméricas e legado numérico.

### `test/br_zod_integration_test.dart`

- Tipos aninhados incompatíveis, mapas dinâmicos, execução única e preservação
  de `errors`/`errorList`.

### `doc/CnpjAlfanumerico.md`

- Exemplo inventado substituído pelo vetor oficial auditável.
- Formatos aceitos documentados explicitamente.

## Matriz de bugs

| Bug | Reproduzido | Teste criado | Corrigido | Risco |
| --- | ---: | ---: | ---: | --- |
| SHA-1 aceita prefixo/sufixo | Sim | Sim | Sim | Baixo |
| SHA-256 aceita prefixo/sufixo | Sim | Sim | Sim | Baixo |
| `isUUID(null)` lança exceção | Sim | Sim | Sim | Baixo |
| RG aceita conteúdo extra | Sim | Sim | Sim | Baixo |
| CEP aceita conteúdo extra | Sim | Sim | Sim | Baixo |
| URL usa regex de e-mail | Sim | Sim | Sim | Médio |
| APIs de URL divergem | Sim | Sim | Sim | Baixo |
| DDD 55 é removido como país | Sim | Sim | Sim | Médio |
| CNPJ alfanumérico usa A=10 | Sim | Sim | Sim | Alto |
| CNPJ remove caracteres proibidos | Sim | Sim | Sim | Médio |
| `BrZod.validate()` lança `TypeError` | Sim | Sim | Sim | Baixo |
| `BrZod.validate()` executa schema 2x | Sim | Sim | Sim | Baixo |

Os dois itens de URL têm a mesma causa funcional ampla e são contabilizados
como um único bug no resumo: implementação incorreta/inconsistente da URL.

## Testes adicionados

- `Bug: isSHA1 aceitava prefixo/sufixo`: puro, separado por `:`, prefixo,
  sufixo, espaços, caracteres inválidos e limites 39/41.
- `Bug: isSHA256 aceitava prefixo/sufixo`: puro, separado por `:`, prefixo,
  sufixo e limites 63/65.
- `Bug: isUUID(null) lançava exceção`: `null`, vazio, versões 3/4/5/all,
  versão desconhecida e caixa alta/baixa.
- `Bug: isRG aceitava conteúdo extra`: com/sem máscara, X, prefixo, sufixo,
  espaço final, limite e contrato com `BrZod`.
- `Bug: isValidBRZip aceitava lixo`: três formatos preservados, conteúdo extra,
  pontuação, limites e contrato entre as três APIs.
- `Bug: isURL usava regex de e-mail`: URLs HTTP/HTTPS/FTP, localhost, IPv4,
  porta, path, query com/sem `/`, esquemas proibidos e contrato entre APIs.
- `Bug: telefone com DDD 55`: celular/fixo nacional e internacional, DDD
  inválido, ausência de DDD e contrato.
- `CnpjAlfanumerico — vetores oficiais`: exemplo oficial, vetor independente,
  minúsculas, máscara, DV adulterado, caracteres proibidos e legado.
- `BrZod.validate() — mapa aninhado com tipo incompatível`: `null`, `String`,
  `int`, `List`, `Map<dynamic,dynamic>` e `Map<String,dynamic>`.
- `BrZod.validate() — execução única`: contador raiz/aninhado e estruturas de
  erro preservadas.
- Contratos adicionais: CPF, CNPJ, UUID, placa, CNH, RENAVAM, PIS/PASEP e
  Título de Eleitor.

## Compatibilidade

APIs e assinaturas públicas foram preservadas. Permaneceram intencionalmente:

- RG como validação apenas de formato, sem DV estadual;
- os três formatos de CEP já cobertos (`12345678`, `12345-678`, `12.345-678`);
- telefones sem DDD rejeitados por `AllValidations`/`ContractValidations`;
- o contrato diferente de `BrZod().phone()`, que documenta aceitar telefone
  com ou sem DDD e por isso não foi forçado a delegar à regra mais restrita;
- CNPJs numéricos legados;
- caixa alta/baixa em UUID e CNPJ alfanumérico.

Comportamentos alterados são apenas os bugs demonstrados: hashes/RG/CEP/CNPJ
com conteúdo extra passam a ser rejeitados; URLs reais passam a ser aceitas e
e-mails/esquemas não permitidos rejeitados; DDD 55 passa a funcionar; UUID nulo
não derruba a aplicação; CNPJ alfanumérico segue o cálculo oficial; e cada
schema do `BrZod.validate()` roda uma vez.

## Pendências

- CNH, RENAVAM de 9 dígitos, Título de Eleitor, CNS, cartões, IPv6, nomes,
  e-mails internacionalizados, datas ISO, senhas e telefones sem DDD:
  **não confirmado — nenhuma alteração aplicada**. Os testes de consistência
  não substituem vetores oficiais independentes para auditar os algoritmos.
- `CHANGELOG.md` e versão do pacote não foram alterados; nenhuma publicação,
  commit ou push foi realizado.

## Evidências

| Correção | Teste que falhava antes | Causa raiz | Correção aplicada | Evidência depois |
| --- | --- | --- | --- | --- |
| SHA-1 | prefixo/sufixo/espaços/41 chars | regex sem âncoras | `^(?:...|...)$` | grupo SHA-1 passa |
| SHA-256 | prefixo/sufixo/65 chars | alternância sem grupo ancorado | grupo e âncoras | grupo SHA-256 passa |
| UUID | `isUUID(null)` lançava | operador `!` em nullable | retorno antecipado `false` | grupo UUID passa |
| RG | sufixo e espaço final aceitos | fim não ancorado | regex integral | grupos direto/BrZod passam |
| CEP | prefixo/strip arbitrário | match parcial/remoção de não dígitos | três formatos completos | contrato das três APIs passa |
| URL | URLs rejeitadas, e-mail aceito | regex de e-mail e regras duplicadas | `Uri.tryParse` + checagens compartilhadas | 19 cenários + contrato passam |
| DDD 55 | `(55) 99123-4567` rejeitado | `startsWith('55')` sem comprimento | remove país só em 13/12 dígitos | celular/fixo passam |
| CNPJ DV | vetor `12ABC34501DE35` rejeitado | letra convertida com `-55` | ASCII `-48` | vetor oficial e independente passam |
| CNPJ formato | prefixo/sufixo eram removidos | `strip()` antes de validar formato | regex da entrada original | teste de proibidos passa |
| BrZod tipo | String/int/List lançavam | cast forçado para mapa | checagem de tipo e fallback vazio | 6 cenários passam |
| BrZod 2x | contador retornava 2 | duas travessias da árvore | coleta única | contador raiz/aninhado retorna 1 |

## Fontes oficiais do CNPJ alfanumérico

- [Receita Federal — documentação técnica do cálculo do DV](https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/publicacoes/documentos-tecnicos/cnpj)
- [SERPRO — manual de cálculo dos dígitos verificadores](https://www.serpro.gov.br/menu/noticias/videos/calculodvcnpjalfanaumerico.pdf)
- [Receita Federal — projeto CNPJ Alfanumérico](https://www.gov.br/receitafederal/pt-br/acesso-a-informacao/acoes-e-programas/programas-e-atividades/cnpj-alfanumerico)

O manual oficial define 12 caracteres alfanuméricos, 2 DVs numéricos, valor
ASCII menos 48, módulo 11 e pesos 2–9 da direita para a esquerda. O exemplo
oficial resulta em `12.ABC.345/01DE-35`.

## Comandos finais

```text
flutter pub get                         OK
flutter analyze                         OK — No issues found
flutter test                            OK — 1.197 testes
flutter test --coverage                 OK — 1.197 testes
coverage/lcov.info                      83,61% (2.148/2.569 linhas)
dart format .                           OK — 121 arquivos; 9 formatados nesta etapa
dart format --output=none ... .         OK — nenhuma alteração pendente
```
