<h1 align="center">All Validations BR</h1>

## Descrição do Projeto

- AllValidations é uma solução extra leve e poderosa para Flutter. Combine validações para agilizar seu desenvolvimento. esperamos que ajude você com seus projetos.

## ⚙️ Funcionalidades

- [✅]  isNull           - [✅]  isNum
- [✅]  isNumericOnly    - [✅]  isNumericFloat
- [✅]  isAlphabetOnly   - [✅]  isVideo
- [✅]  isImage          - [✅]  isURL
- [✅]  isEmail          - [✅]  isPhoneNumber
- [✅]  isDateTime       - [✅]  isMD5
- [✅]  isSHA1           - [✅]  isSHA256
- [✅]  isSSN            - [✅]  isBinary
- [✅]  isIPv4           - [✅]  isIPv6
- [✅]  isHexadecimal    - [✅]  isLowerThan
- [✅]  isGreaterThan    - [✅]  isCnpj
- [✅]  isCpf            - [✅]  isRG
- [✅]  isUUID           - [✅]  isJSON
- [✅]  isCreditCard     - [✅]  isLowercase
- [✅]  isUppercase      - [✅]  isInt
- [✅]  isEqual          - [✅]  isValidBRZip
- [✅]  isPDF            - [✅]  isTxt
- [✅]  isChm            - [✅]  isVector
- [✅]  isHTML           - [✅]  removeCaracteres
- [✅]  isMediumPassword - [✅]  isStrongPassword
- [✅]  removeAccents    - [✅]  isPalindrome
- [✅]  isName           - [✅]  isMapExists


### 🧪 Contracts
```dart
class TestParameters extends ValidationNotifiable {
  final String name;
  final String email;

  TestParameters({
    required this.name,
    required this.email,
  }) {
    addNotifications(Contract()
        .hasMinLen(name, 2, 'TestParameters.Name',
            "Nome deve ter no mínimo 2 caracteres!")
        .isEmail(email, "TestParameters.Email", "Email deve ser preenchido!"));
  }
}

main() {
      final testParameters =
          TestParameters(email: "exemplo@teste.com", name: "c");
      // print(testParameters.notifications.length);
     // 1;
      if(testParameters.isValid){
        print("Valido");
      }else{
        print("Invalido");
      }
      //print all erros
      testParameters.notifications.forEach((f) => print(f.message));
}
//this return false
```

#### 🎲 exemplo de validação CPF

```dart
var isCpf = AllValidations.isCpf(000.000.000.00); 
//this return false

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
Você também pode retornar meses, regiões, estados tudo através do AllValidationsGet


#### 🎲 exemplos de remoção acentos e caracters de um texto
```dart
//(ex: `/`, `-`, `.`)
var remover = AllValidations.removeAccents( 'áãé');
//this return aae
```

#### 🎲 exemplos para check se um key existe e se seu valor e nullo ou vazio -  map(json)
```dart
//(ex: `/`, `-`, `.`)
 Map map1 = {"status": "success", "message": "successfully logged out"};

    final sut =
        AllValidations.isMapExists(map: map1, key: ['status']);

    expect(sut, true);
//this return is log in your console
```


  ## 📝 Licença

Este projeto esta sobe a licença [MIT](./LICENSE).
