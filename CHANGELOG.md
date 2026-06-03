# Changelog

## 3.3.0
### 🆕 Novas Funcionalidades
* **Validação de Chaves PIX** (`HelperUtil.validatePixKey`)
  - Identifica o tipo da chave PIX: CPF, Celular, E-mail ou Chave Aleatória.
  - Segue a ordem de validação definida pelo BACEN.
  - Otimização: descarta e-mail e chave aleatória imediatamente quando o input contém apenas dígitos.

### 🔧 Correções
* **`validatePixKey`** — CPF agora valida dígitos verificadores via `AllValidations.isCpf` (antes aceitava qualquer 11 dígitos).
* **`validatePixKey`** — Celular corrigido para exigir formato E.164 com `9` após o DDD (`+55XXXXXXXXXXX`).
* **`validatePixKey`** — Chave aleatória corrigida para UUID v4 com hífens (`xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`), conforme padrão BACEN.
* **`validatePixKey`** — Removido `;` solto após bloco de e-mail.
* **`isDigit`** — Corrigida referência a `cleanedText` (inexistente) para `text`.

---

## 3.2.3
### 🆕 Novas Funcionalidades
* **Validação de Código de Barras (EAN-13)**
  - `isValidEAN13`: Valida se um código de barras EAN-13 é válido, garantindo conformidade com o padrão oficial.

* **Validação de Cores Hexadecimais**
  - `isValidHexColor`: Verifica se uma string representa uma cor em formato hexadecimal válido.

* **Contagem de Palavras**
  - `countWords`: Conta o número de palavras em uma string, útil para análise de textos e validações de preenchimento.

* **Geração de UUIDs**
  - `generateUUIDv3`: Gera um UUID versão 3 baseado em namespace e nome usando MD5.
  - `generateUUIDv4`: Gera um UUID versão 4 aleatório.
  - `generateUUIDv5`: Gera um UUID versão 5 baseado em namespace e nome usando SHA-1.

---

## 3.2.2
###  Novas Funcionalidades
* **Remoção de Tags HTML**
  - `removeHtmlTags`: Remove todas as tags HTML de um texto, retornando apenas o conteúdo limpo. Método robusto e performático para sanitização de entradas.

---

## 3.2.0
###  Novas Funcionalidades
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
