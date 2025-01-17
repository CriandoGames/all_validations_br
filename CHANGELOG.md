# Changelog

## 3.2.1
### 🆕 Novas Funcionalidades
* **Remoção de Tags HTML**
  - `removeHtmlTags`: Remove todas as tags HTML de um texto, retornando apenas o conteúdo limpo. Método robusto e performático para sanitização de entradas.

---

## 3.2.0
### 🆕 Novas Funcionalidades
* **Criptografia e Validação de Senhas**
  - `encryptPassword`: Gera uma senha criptografada utilizando uma chave de segurança personalizada.
  - `validatePassword`: Valida se uma senha corresponde ao hash gerado.

* **Utilidades Adicionais**
  - `formatCurrency`: Formata números para o padrão de moeda brasileiro (`R$`).
  - `calculatePercentage`: Calcula a porcentagem de um valor em relação a um total.
  - `generateRandomString`: Gera strings aleatórias de tamanho personalizado.

* **Manipulações de Texto**
  - `capitalizeWords`: Converte a primeira letra de cada palavra para maiúscula.
  - `removeNonNumeric`: Remove todos os caracteres não numéricos de uma string.

* **Utilidades de Datas**
  - `businessDaysBetween`: Calcula o número de dias úteis entre duas datas.
  - `daysBetween`: Calcula a diferença em dias entre duas datas.

---

## 3.1.2
### 🔧 Melhorias e Novas Funcionalidades
* Atualização para Contratos:
  - `isStrongPassword`: Verifica a força de uma senha.
  - `isURL`: Valida URLs.
  - `isPhoneNumber`: Valida números de telefone brasileiro (celulares e fixos).
  - `isValidBRZip`: Verifica o formato de CEP brasileiro.
  - `isUUID`: Valida identificadores únicos (UUID).
  - `isPalindrome`: Verifica se uma string é um palíndromo.
  - `customValidation`: Permite validações customizadas.
  - `isEnum`: Verifica se um valor pertence a um enum.
  - `isBefore`: Valida se uma data é anterior a outra.
  - `isUnique`: Valida se um valor é único em uma lista.
  - Validações para CPF, CNPJ, tamanhos mínimos/máximos de strings, entre outros.

---

## 3.1.0
### 🛠 Alterações e Melhorias
* **Novo Método**
  - `getStateByDDD`: Retorna o estado brasileiro com base no DDD.
* Suporte para validação de telefones fixos brasileiros com DDD.
* **Breaking Change**: Método `isPhoneNumber` removido. Substitua por:
  - `isBrazilianCellPhone` ou `isBrazilianLandline` para validações específicas.
* Documentação aprimorada e novos testes unitários.

---

## 3.0.0
* Introdução de contratos para validação.
* Alteração em rotas de importação (**Breaking Change**).
* Documentação expandida.

---

## 2.2.1
* Correção de bugs e melhorias em validações como:
  - `isValidBRZip` (por **@lucascorrea30**).
* Novos testes unitários.

---

## 2.2.0
* **Novos Métodos**
  - `isName` por **@lucascorrea30**.

---

## 2.1.0
* Adicionados métodos:
  - `isMediumPassword`, `isStrongPassword`.
  - `isNickname` (por **@danieldcastro**).
  - `removeAccents`, `isPalindrome`.

---

## 2.0.0
* Atualização de SDK.

---

## 1.1.4
* Correções de bugs.

---

## 1.1.2
* Novas validações:
  - `isPDF`, `isTxt`, `isChm`, `isVector`, `isHTML`.

---

## 1.1.0
* Renomeação de métodos:
  - `removeCaracteres` para `removeCharacters` (**Breaking Change**).
* Adicionado método: `isRG`.

---

## 1.0.1
* Primeiras melhorias e novos métodos.

---

## 1.0.0
* Lançamento inicial.
