<h1 align="center">All Validations BR</h1>

<p align="center">💡 Uma solução leve e poderosa para Flutter, facilitando a validação e manipulação de dados no desenvolvimento de projetos.</p>

---

## 🚀 Descrição do Projeto

**AllValidations BR** é uma biblioteca leve e eficiente para Flutter, projetada para agilizar a validação de dados e facilitar manipulações. Combinando diversas funcionalidades, ela é ideal para melhorar a produtividade no desenvolvimento de aplicativos.

---

## ⚙️ Funcionalidades

- **Validações Gerais**
- Verificação de tipos e formatos:
  - `isNull`, `isNum`, `isNumericOnly`, `isNumericFloat`
  - `isAlphabetOnly`, `isLowercase`, `isUppercase`
  - `isUUID`, `isJSON`, `isHexadecimal`
  - `isEmail`, `isURL`
- Validações específicas:
  - `isCpf`, `isCnpj`, `isRG`, `isValidBRZip`
  - `isBrazilianCellPhone`, `isBrazilianLandline`
  - `isLeapYear`, `isValidBrazilianLicensePlate`
  - Validação de chaves PIX: CPF, e-mail, celular e chave aleatória

---
### **Manipulação de Texto**
- **Remoção de caracteres especiais:**
  - `removeCharacters`, `removeNonNumeric`, `removeAccents`
- **Formatação de dados:**
  - CPF: `123.456.789-09`
  - CNPJ: `12.345.678/0001-95`
  - Celular: `(11) 99999-9999`
  - Moeda: `R$ 1.234,56`
  - Data e hora: `01/01/2023`, `12:30:45`
- **Outras manipulações:**
  - Comparação de frases: `isPhraseEqual`
  - Capitalização de palavras: `capitalizeWords`
  
---
### **Utilidades para Datas**
- **Conversões de horário:**
  - UTC para local: `convertUtcToLocal`
  - Local para UTC: `convertLocalToUtc`
- **Cálculos com datas:**
  - Diferença entre duas datas: `daysBetween`
  - Dias úteis entre duas datas: `businessDaysBetween`
  - Cálculo de idade: `calculateAge`

---
### **Funções Avançadas**
- **Validações por Regex:**
  - E-mails, URLs, UUIDs, senhas fortes
- **Geração e manipulação:**
  - Strings aleatórias: `generateRandomString`
  - Números aleatórios: `generateRandomInt`
  - Formatação de moeda: `formatCurrency`
- **Informações do dispositivo:**
  - Sistema operacional e versão do Dart: `getDeviceInfo`
- **Criptografia**
  - Criptografa senhas e realiza validações com as funções `encryptPassword e validatePassword `   

## 🧪 Exemplos de Uso

### Validação de Parâmetros

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

void main() {
  final testParameters = TestParameters(email: "exemplo@teste.com", name: "c");

  if (testParameters.isValid) {
    print("Válido");
  } else {
    print("Inválido");
    testParameters.notifications.forEach((f) => print(f.message));
  }
}


## Validação de CPF

```dart
var isCpf = AllValidations.isCpf("000.000.000-00"); 
// Retorna false
``` 

## Remoção de Caracteres

```dart
var remover = AllValidations.removeCharacters("000.000.000-00"); 
// Retorna: 00000000000
``` 

## Comparação de Senhas ou Frases

```dart
var comparacao = AllValidations.isPhraseEqual("123456789", "123456789");
// Retorna: true
``` 

## Lista de Dias da Semana

```dart
var diasDaSemana = AllValidationsGetWeek.listDaysWeekAbvr;
// Retorna: ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo']
``` 

## Remoção de Acentos e Caracteres Especiais

```dart
var texto = AllValidations.removeAccents("áãé");
// Retorna: aae
``` 

## Função para Retornar o Estado pelo DDD

```dart
print(AllValidations.getStateByDDD("11")); 
// Saída: BrazilianState.SP
``` 

## Verificação de Chaves em Mapas JSON

```dart
Map<String, dynamic> map1 = {"status": "success", "message": "successfully logged out"};

bool existe = AllValidations.isMapExists(map: map1, key: ['status']);
// Retorna: true
``` 

## 📖 Documentação e Wiki

Para mais detalhes sobre o uso da biblioteca, acesse nossa [Wiki](https://github.com/CriandoGames/all_validations_br/wiki).

---


📦 Instalação
## Adicione a dependência ao seu arquivo pubspec.yaml:

dependencies:
  all_validations_br: 

📜 Licença
Este projeto está sob a licença MIT.

---

<p align="center">💻 Desenvolvido com ❤️ para facilitar o desenvolvimento no Flutter.</p> ```
Essa versão está devidamente formatada, com divisões claras e blocos de código para facilitar a leitura e o uso no formato Markdown.