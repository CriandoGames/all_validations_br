<h1 align="center">All Validations BR</h1>

## Descrição do Projeto

- AllValidations é uma solução extra leve e poderosa para Flutter. Combine validações para agilizar seu desenvolvimento. esperamos que ajude você com seus projetos.

## ⚙️ Funcionalidades

- [✅]  isNull
- [✅]  isNum
- [✅]  isNumericOnly
- [✅]  isNumericFloat
- [✅]  isAlphabetOnly
- [✅]  isVideo
- [✅]  isImage
- [✅]  isURL
- [✅]  isEmail
- [✅]  isPhoneNumber
- [✅]  isDateTime
- [✅]  isMD5
- [✅]  isSHA1
- [✅]  isSHA256
- [✅]  isSSN
- [✅]  isBinary
- [✅]  isIPv4
- [✅]  isIPv6
- [✅]  isHexadecimal
- [✅]  isLowerThan
- [✅]  isGreaterThan
- [✅]  isCnpj
- [✅]  isCpf
- [✅]  isRG
- [✅]  isUUID
- [✅]  isJSON
- [✅]  isCreditCard
- [✅]  isLowercase
- [✅]  isUppercase
- [✅]  isInt
- [✅]  isEqual
- [✅]  isPDF
- [✅]  isTxt
- [✅]  isChm
- [✅]  isVector
- [✅]  isHTML
- [✅]  removeCaracteres
- [✅]  isMediumPassword
- [✅]  isStrongPassword
- [✅]  removeAccents
- [✅]  isPalindrome
- [✅]  isName


### 🧪 testes
- [✅]  isNull
- [✅]  isNum
- [✅]  isNumericOnly
- [✅]  isNumericFloat
- [✅]  isAlphabetOnly
- [✅]  isVideo
- [✅]  isImage
- [✅]  isURL
- [✅]  isEmail
- [✅]  isPhoneNumber
- [✅]  isEqual
- [ ]  isDateTime
- [ ]  isMD5
- [ ]  isSHA1
- [ ]  isSHA256
- [ ]  isSSN
- [ ]  isBinary
- [ ]  isIPv4
- [ ]  isIPv6
- [ ]  isHexadecimal
- [✅]  isLowerThan
- [✅]  isGreaterThan
- [✅]  isCnpj
- [✅]  isCpf
- [✅]  isRG
- [✅]  removeCaracteres
- [✅]  isUUID
- [ ]  isJSON
- [ ]  isCreditCard
- [✅]  isLowercase
- [✅]  isUppercase
- [✅]  isInt
- [✅]  isValidBRZip
- [✅]  isMediumPassword
- [✅]  isStrongPassword
- [ ]  isPDF
- [ ]  isTxt
- [ ]  isChm
- [ ]  isVector
- [ ]  isHTML
- [✅]  removeAccents
- [✅]  isPalindrome
- [✅]  isName


### 🛠 Tecnologias
- [Flutter](https://flutter.dev/)


#### 🎲 exemplo de validação CPF

```dart
var isCpf = AllValidations.isCpf(000.000.000.00); 
//this return false
```

#### 🎲 exemplos de validação String é bool 

```dart
var isBool = AllValidations.isBool('true'); 
//this return true
```
#### 🎲 exemplos de Remoção caracteres  
```dart
//(ex: `/`, `-`, `.`)
var remover = AllValidations.removeCharacters('000.000.000-00'); 
//this return 00000000000
```

#### 🎲 exemplos de comparação de senha ou frases  
```dart
//(ex: `/`, `-`, `.`)
var remover = AllValidations.isPhraseEqual('123456789', '123456789');
//this return true
```

#### 🎲 exemplos de retorno de lista de dias da semana  
```dart
//(ex: `/`, `-`, `.`)
var remover = AllValidationsGetWeek.listDaysWeekAbvr;
//this return ['Segunda','Terça','Quarta','Quinta','Sexta','Sábado','Domingo']
```
Você também pode retorna meses, regiões , estados tudo atraveis do AllValidationsGet


#### 🎲 exemplos de comparação de senha ou frases  
```dart
//(ex: `/`, `-`, `.`)
var remover = AllValidations.isPhraseEqual('123456789', '123456789');
//this return true
```

#### 🎲 exemplos de remoção acentos e caracters de um texto
```dart
//(ex: `/`, `-`, `.`)
var remover = AllValidations.removeAccents( 'áãé');
//this return aae
```

### Autor
---
Feito com ❤️ por 

<a href="###">
 <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/14837643?s=96&v=4" width="100px;" alt=""/>
 <br />

  <sub><b>Carlos Castro</b></sub></a> <a href="###" title="">🚀</a>


  
  ## 📝 Licença

Este projeto esta sobe a licença [MIT](./LICENSE).
