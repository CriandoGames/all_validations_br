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
- [✅]  isUUID
- [✅]  isJSON
- [✅]  isCreditCard
- [✅]  isLowercase
- [✅]  isUppercase
- [✅]  isInt
- [✅]  removeCaracteres

### 🧪 testes

- [✅]  isNull
- [✅]  isNum
- [✅]  isNumericOnly
- [✅]  isNumericFloat
- [✅]  isAlphabetOnly
- [ ]  isVideo
- [ ]  isImage
- [✅]  isURL
- [✅]  isEmail
- [ ]  isPhoneNumber
- [ ]  isDateTime
- [ ]  isMD5
- [ ]  isSHA1
- [ ]  isSHA256
- [ ]  isSSN
- [ ]  isBinary
- [ ]  isIPv4
- [ ]  isIPv6
- [ ]  isHexadecimal
- [ ]  isLowerThan
- [ ]  isGreaterThan
- [ ]  isCnpj
- [ ]  isCpf
- [ ]  removeCaracteres
- [ ]  isUUID
- [ ]  isJSON
- [ ]  isCreditCard
- [ ]  isLowercase
- [ ]  isUppercase
- [ ]  isInt

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

```dart
//(ex: `/`, `-`, `.`)
var remover = AllValidations.isBool('000.000.000-00'); 
//this return 00000000000
```

### Autores
---
Feito com ❤️ por 

<a href="###">
 <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/14837643?s=96&v=4" width="100px;" alt=""/>

 <a href="###">
 <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/60795279?v=4" width="100px;" alt=""/>

 
  <a href="###">
 <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/30814200?v=4" width="100px;" alt=""/>
 <br />

  <sub><b>Carlos Castro</b></sub></a> <a href="###" title="">🚀</a>
  <sub><b>Benjamim Soprani</b></sub></a> <a href="###" title="">🚀</a>
  <sub><b>Shedy Husein</b></sub></a> <a href="###" title="">🚀</a>

  
  ## 📝 Licença

Este projeto esta sobe a licença [MIT](./LICENSE).
