# Changelog

## 3.1.1

* Atualização para Contratos 
* isStrongPassword: Verifica a força de uma senha.
* isURL: Valida URLs.
* isPhoneNumber: Valida números de telefone brasileiro (celulares e fixos).
* isValidBRZip: Verifica o formato de CEP brasileiro.
* isUUID: Valida identificadores únicos (UUID).
* isPalindrome: Verifica se uma string é um palíndromo.
* customValidation: Permite validações customizadas.
* isEnum: Verifica se um valor pertence a um enum.
* isBefore: Valida se uma data é anterior a outra.
* isUnique: Valida se um valor é único em uma lista.
* Validações para CPF, CNPJ, tamanhos mínimos/máximos de strings, entre outros.
# Melhorias:

* Adição de mensagens mais detalhadas para cada validação.
* Melhor organização e reutilização de código.
* Implementação de testes unitários abrangentes.

## 3.1.0
* Novo método: **getStateByDDD** para retornar o estado brasileiro com base no DDD.
* Adicionado suporte para validação específica de **telefones fixos brasileiros com DDD**.
* **Breaking Change**: O método `isPhoneNumber` foi removido. Substitua por `isBrazilianCellPhone` ou `isBrazilianLandline` para validações específicas de números brasileiros.
* Adicionado novos testes unitários para validações de DDDs e números de telefone.
* Documentação aprimorada e mais detalhada.

## 3.0.0
* Novo método de validação por contratos.
* **Breaking Change**: Alteração em rotas de importação.
* Adicionado suporte para `Contract`.
* Atualizações na documentação.

## 2.2.1
* Validação: Verificação se o mapa existe.
* Correção de bug na validação de telefone por **@danieldcastro**.

## 2.2.1
* Correção na validação de `isValidBRZip` por **@lucascorrea30**.
* Novos testes em `isValidBRZip` por **@lucascorrea30**.

## 2.2.0
* Novo método: `isName` por **@lucascorrea30**.

## 2.1.0
* Adicionados métodos:
  * `isMediumPassword`
  * `isStrongPassword`
  * `isNickname` por **@danieldcastro**
  * `isPhraseEqual`
  * `removeAccents` por **@danieldcastro**
  * `isPalindrome` por **@danieldcastro**
* Nova funcionalidade: `AllValidationsGet` agora permite obter:
  * Meses do ano.
  * Semanas.
  * Regiões.
  * Estados do Brasil.

## 2.0.0
* Atualização de SDK.

## 1.1.4
* Correção de bugs.

## 1.1.2
* Novas validações adicionadas:
  * `isPDF`
  * `isTxt`
  * `isChm`
  * `isVector`
  * `isHTML`

## 1.1.0
* Renomeada a função `removeCaracteres` para `removeCharacters`.
  * **Breaking Change**: Pode impactar seu código, por favor, revise antes de atualizar.
* Melhorias em validações de fotos e vídeos.
* Adicionado método: `isRG`.

## 1.0.1
* Novas validações implementadas.

## 1.0.0
* Lançamento inicial.
