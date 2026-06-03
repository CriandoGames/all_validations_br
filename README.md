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
  - Validação de código de barras EAN-13: `isValidEAN13`
  - Validação de cores hexadecimais: `isValidHexColor`
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
  - Removedor Tags Html: `removeHtmlTags`

- **Geração de UUID:**  
  - `generateUUIDv3` - Baseado em namespace e nome com MD5  
  - `generateUUIDv4` - UUID gerado aleatoriamente  
  - `generateUUIDv5` - Baseado em namespace e nome com SHA-1

  - **Manipulação de JWT:**  
  - `decodeJWT` - Decodifica um JSON Web Token (JWT) e retorna o payload  
  - `isJwtExpired` - Verifica se o token JWT está expirado  
  - `hasJwtClaim` - Verifica se uma chave específica existe no JWT  
  - `getJwtClaim` - Obtém o valor de uma chave específica no JWT  

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

````

## Validação de CPF

```dart
var isCpf = AllValidations.isCpf("000.000.000-00"); 
// Retorna false
``` 

## Validação de Cores Hexadecimais
```dart
bool isValidColor = AllValidations.isValidHexColor('#FF5733');
// Retorna: true; 
``` 

## Contagem de Palavras em uma String
```dart
int totalWords = HelperUtil.countWords('Flutter é incrível');
// Retorna: 3
``` 

## Remoção de Tags HTML
```dart
String cleanText = HelperUtil.removeHtmlTags('<p>Hello <b>World</b></p>');
// Retorna: Hello World
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

## Geração de UUIDs
```dart
String uuid4 = HelperUtil.generateUUIDv4();
// Exemplo de saída: '550e8400-e29b-41d4-a716-446655440000'
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

## Validação de Chaves PIX

`HelperUtil.validatePixKey` identifica o tipo da chave PIX informada, seguindo a ordem de validação definida pelo BACEN:

1. **CPF** — 11 dígitos com dígitos verificadores válidos (aceita formato com ou sem máscara)
2. **Celular** — formato E.164: `+55` + DDD + número começando com `9` (ex: `+5511912345678`)
3. **E-mail** — endereço de e-mail válido
4. **Chave aleatória** — UUID v4 (ex: `123e4567-e89b-4d3a-a456-426614174000`)

> **Otimização:** se o valor contiver apenas dígitos, e-mail e chave aleatória são descartados imediatamente.

```dart
// CPF (com ou sem máscara)
HelperUtil.validatePixKey('992.864.791-74'); // 'CPF'
HelperUtil.validatePixKey('99286479174');    // 'CPF'

// Celular — obrigatório formato E.164
HelperUtil.validatePixKey('+5511912345678'); // 'Celular'

// E-mail
HelperUtil.validatePixKey('user@example.com'); // 'Email'

// Chave aleatória — UUID v4
HelperUtil.validatePixKey('123e4567-e89b-4d3a-a456-426614174000'); // 'Chave Aleatória'

// Inválido
HelperUtil.validatePixKey('12345678901'); // null
```

## Mascaramento de Chave PIX

```dart
HelperUtil.maskPixKey('99286479174');                        // '992.***.***-74'
HelperUtil.maskPixKey('+5511912345678');                     // '+5511*****678'
HelperUtil.maskPixKey('user@example.com');                   // 'us**@example.com'
HelperUtil.maskPixKey('123e4567-e89b-4d3a-a456-426614174000'); // '123e4567-****-****-****-426614174000'
```

## Validação de Documentos Brasileiros

```dart
// CNH
AllValidations.isCnh('84718735264'); // true

// RENAVAM (aceita 9 ou 11 dígitos)
AllValidations.isRenavam('95606520941'); // true

// PIS/PASEP
AllValidations.isPisPasep('12345678919'); // true

// Título de Eleitor
AllValidations.isTituloEleitor('006000610949'); // true
```

## Validação de Data e Maioridade

```dart
// Verifica se a data existe de verdade
HelperUtil.isValidDate('31/02/2023'); // false
HelperUtil.isValidDate('15/06/2023'); // true
HelperUtil.isValidDate('2023-06-15'); // true

// Verifica maioridade (padrão 18 anos, customizável)
HelperUtil.isAdult(DateTime(2000, 1, 1));           // true
HelperUtil.isAdult(DateTime(2010, 1, 1));           // false
HelperUtil.isAdult(DateTime(2002, 1, 1), minAge: 21); // false
```

---

## 📖 Documentação e Wiki

Para mais detalhes sobre o uso da biblioteca, acesse nossa [Wiki](https://github.com/CriandoGames/all_validations_br/wiki).

---

## 🆘 Classes para Uso

Aqui estão as principais classes disponíveis na biblioteca **AllValidations BR**, juntamente com suas funcionalidades para facilitar a validação e manipulação de dados em seus projetos Flutter.

### `HelperUtil`  
Utilitários diversos para manipulação e formatação de dados, incluindo:  
- Decodificação de JWT  
- Geração de strings e números aleatórios  
- Conversão de datas entre UTC e horário local  
- Formatação de valores para moeda brasileira  
- Remoção de tags HTML de strings  
- Geração de UUIDs (v3, v4 e v5)  
- Criptografia e validação de senhas  
- Validação de chaves PIX (CPF, Celular, E-mail, Chave Aleatória)  

---

### `AllValidations`  
Conjunto de funções para validar diferentes tipos de dados, como:  
- CPF e CNPJ  
- E-mail e URL  
- Telefone brasileiro (fixo e celular)  
- CEP, RG e outras identificações  
- Formatos de data, IP e JSON  

---

### `Contract`  
Classe para gerenciamento de contratos de validação, permitindo a criação de regras flexíveis e reutilizáveis para validar dados com notificações de erro detalhadas.  
- Definição de regras de validação personalizada  
- Verificação de requisitos obrigatórios e condições específicas  
- Emissão de notificações de erro em propriedades inválidas  

---

### `AllValidationsGetMonth`  
Fornece listas de nomes dos meses do ano para fácil acesso e manipulação.  
- Exemplo de uso: `AllValidationsGetMonth.list` → `[Janeiro, Fevereiro, ...]`  

---

### `AllValidationsGetRegions`  
Retorna as regiões do Brasil, útil para aplicações que necessitam de categorização geográfica.  
- Exemplo de uso: `AllValidationsGetRegions.list` → `[Norte, Nordeste, ...]`  

---

### `AllValidationsGetStates`  
Disponibiliza os estados brasileiros e suas siglas.  
- Exemplo de uso: `AllValidationsGetStates.list` → `[SP, RJ, MG, ...]`  

---

### `AllValidationsGetWeek`  
Fornece listas de dias da semana em formato abreviado e completo.  
- Exemplo de uso: `AllValidationsGetWeek.listDaysWeekAbvr` → `[Seg, Ter, Qua, ...]`  

---

### 🤝 Contribuições
  Encontrou algum problema ou tem sugestões para melhorar a biblioteca?
 Contribua abrindo uma issue no nosso repositório oficial do GitHub!
- 🔗 All Validations BR -  [GitHub](https://github.com/CriandoGames/all_validations_br/)

--- 

### 📦 Instalação
## Adicione a dependência ao seu arquivo pubspec.yaml:

dependencies:
  all_validations_br: 

### 📜 Licença
Este projeto está sob a licença MIT.

---

<p align="center">💻 Desenvolvido com ❤️ para facilitar o desenvolvimento no Flutter.</p> 

