<h1 align="center">All Validations BR</h1>

<p align="center">
  💡 Validações brasileiras, utilitários e criptografia autenticada — tudo em uma única biblioteca Dart/Flutter, sem dependências externas.
</p>

<p align="center">
  <a href="https://pub.dev/packages/all_validations_br"><img src="https://img.shields.io/pub/v/all_validations_br.svg?label=pub.dev" alt="pub version"></a>
  <a href="https://pub.dev/packages/all_validations_br/score"><img src="https://img.shields.io/pub/likes/all_validations_br?label=likes" alt="pub likes"></a>
  <a href="https://pub.dev/packages/all_validations_br/score"><img src="https://img.shields.io/pub/points/all_validations_br?label=pub%20points" alt="pub points"></a>
  <a href="https://github.com/CriandoGames/all_validations_br/blob/main/LICENSE"><img src="https://img.shields.io/github/license/CriandoGames/all_validations_br" alt="license"></a>
</p>

---

## 🚀 Descrição do Projeto

**AllValidations BR** é uma biblioteca Dart/Flutter com três pilares:

- **Validações brasileiras** — CPF, CNPJ, CNH, RENAVAM, PIS/PASEP, Título de Eleitor, chaves PIX, telefones, CEP, placas, EAN-13 e muito mais.
- **Utilitários** — formatação de moeda, datas, texto, JWT, UUID v3/v4/v5, HTML, PIX e informações de dispositivo.
- **Criptografia autenticada** — implementação Dart pura de ChaCha20-Poly1305 (RFC 8439), com geração segura de chaves, serialização em base64 e detecção automática de adulteração.

---

## 📦 Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  all_validations_br: ^4.0.5
```

Em seguida:

```bash
flutter pub get
```

E importe no seu código:

```dart
import 'package:all_validations_br/all_validations_br.dart';
```

---

## 📱 App de Exemplo

O diretório `example/` contém um app Flutter interativo que demonstra as principais funcionalidades da biblioteca.

Para rodar:

```bash
cd example
flutter pub get
flutter run
```

O app está dividido em seções:

| Seção | O que demonstra |
|-------|-----------------|
| **AllValidations — CPF** | Validação de CPFs válidos, inválidos e formatados |
| **HelperUtil — utilitários gerais** | `countWords`, `removeHtmlTags`, `capitalizeWords`, `BrFormatter.formatCurrency`, `daysBetween`, `generateUUIDv4`, `validatePixKey`, `maskPixKey` |
| **Máscaras de Campo — BrInputMask** | 23 `TextField`s ao vivo: CPF, CNPJ, CNPJ Alfa, CPF/CNPJ, Telefone, CEP, Data, Hora, Moeda, Cartão, Validade, Placa, KM, Centavos, NCM, CNS, Altura, Peso, Temperatura, CEST, IOF, NUP, Certidão de Nascimento |
| **CryptUtil — interativo** | Botão "Encriptar / Decriptar" exibe ciphertext em base64 e o texto recuperado; botão "Simular adulteração" demonstra a detecção de `CryptException` |
| **CryptUtil — estáticos** | Round-trip `encryptText` → `decryptText` com exibição da tag Poly1305 em hex |

---

## ⚙️ Funcionalidades

### Validações — `AllValidations`

- Verificação de tipos e formatos:
  - `isNull`, `isNum`, `isNumericOnly`, `isNumericFloat`
  - `isAlphabetOnly`, `isLowercase`, `isUppercase`
  - `isUUID`, `isJSON`, `isHexadecimal`
  - `isEmail`, `isURL`
- Validações específicas:
  - `isCpf`, `isCnpj`, `isCnpjAlphanumeric` (novo formato 2026), `isRG`, `isValidBRZip`
  - `isBrazilianCellPhone`, `isBrazilianLandline`
  - `isLeapYear`, `isValidBrazilianLicensePlate`
  - Validação de código de barras EAN-13: `isValidEAN13`
  - Validação de cores hexadecimais: `isValidHexColor`
  - Validação de chaves PIX: CPF, e-mail, celular e chave aleatória

---
### **Manipulação de Texto — `AllValidations` · `HelperUtil`**
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
### **Utilidades para Datas — `HelperUtil`**
- **Conversões de horário:**
  - UTC para local: `convertUtcToLocal`
  - Local para UTC: `convertLocalToUtc`
- **Cálculos com datas:**
  - Diferença entre duas datas: `daysBetween`
  - Dias úteis entre duas datas: `businessDaysBetween`
  - Cálculo de idade: `calculateAge`

---
### **Funções Avançadas — `HelperUtil`**
- **Validações por Regex:**
  - E-mails, URLs, UUIDs, senhas fortes

- **Geração e manipulação:**
  - Strings aleatórias: `generateRandomString`
  - Números aleatórios: `generateRandomInt`
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

---
### Classes especializadas

Cada classe tem documentação detalhada com exemplos completos na pasta `doc/`:

| Classe | Principais capabilities | Documentação |
|--------|------------------------|--------------|
| `AllValidations` | CPF, CNPJ, CNH, RG, RENAVAM, PIS, Título Eleitor, CEP, Placa, EAN-13, Cor Hex, PIX, UUID, e-mail, URL + `validate*()` retornando `Result` | [📄 AllValidations.md](doc/AllValidations.md) |
| `HelperUtil` | UUID v3/v4/v5, JWT decode/claims/expiry, PIX validação + máscara, datas, maioridade, strings aleatórias, remoção de HTML | [📄 HelperUtil.md](doc/HelperUtil.md) |
| `BrFormatter` | `formatCpf`, `generateCpf`, `formatCnpj`, `generateCnpj`, `formatPhone`, `extractDdd`, `formatCep`, `formatCurrency`, `parseCurrency`, `formatKm` | [📄 BrFormatter.md](doc/BrFormatter.md) |
| `BrData` | `format`, `formatMonthYear`, `formatDayMonth`, `formatTime`, `parse`, `parseWithTime`, `validate` — tudo sem o pacote `intl` | [📄 BrData.md](doc/BrData.md) |
| `BrInputMask` | CPF, CNPJ, CNPJ Alfa, CPF/CNPJ, Telefone, CEP, Data, Hora, Moeda, Centavos, Cartão, Validade, Placa, KM, NCM, CNS, Altura, Peso, Temperatura | [📄 BrInputMask.md](doc/BrInputMask.md) |
| `CnpjAlfanumerico` | `isValid`, `format`, `strip`, `generate(forceAlphanumeric)` — retrocompatível com CNPJ numérico | [📄 CnpjAlfanumerico.md](doc/CnpjAlfanumerico.md) |
| `CryptUtil` | `encryptText`, `decryptText`, `encryptToBase64`, `decryptFromBase64`, `generateKey`, AAD, detecção de adulteração | [📄 CryptUtil.md](doc/CryptUtil.md) |
| `Result<F, S>` | `map`, `then`, `fold`, `guard`, `tryAsync`, `thenAsync`, `recover`, `swap` + extensões em `Future<Result>` | [📄 Result.md](doc/Result.md) |
| `Contract` | `isEmail`, `isValidCPF`, `hasMinLen`, `requires` → `.toResult()`, `.toResultFirst()`, `.toResultAsync()` | [📄 Result.md](doc/Result.md#integração-com-contract) |

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

### Validação de CPF

```dart
var isCpf = AllValidations.isCpf("000.000.000-00"); 
// Retorna false
``` 

### Validação de Cores Hexadecimais
```dart
bool isValidColor = AllValidations.isValidHexColor('#FF5733');
// Retorna: true; 
``` 

### Contagem de Palavras em uma String
```dart
int totalWords = HelperUtil.countWords('Flutter é incrível');
// Retorna: 3
``` 

### Remoção de Tags HTML
```dart
String cleanText = HelperUtil.removeHtmlTags('<p>Hello <b>World</b></p>');
// Retorna: Hello World
``` 

### Remoção de Caracteres

```dart
var remover = AllValidations.removeCharacters("000.000.000-00"); 
// Retorna: 00000000000
``` 

### Comparação de Senhas ou Frases

```dart
var comparacao = AllValidations.isPhraseEqual("123456789", "123456789");
// Retorna: true
``` 

### Geração de UUIDs
```dart
String uuid4 = HelperUtil.generateUUIDv4();
// Exemplo de saída: '550e8400-e29b-41d4-a716-446655440000'
``` 

### Lista de Dias da Semana

```dart
var diasDaSemana = AllValidationsGetWeek.listDaysWeekAbvr;
// Retorna: ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo']
``` 

### Remoção de Acentos e Caracteres Especiais

```dart
var texto = AllValidations.removeAccents("áãé");
// Retorna: aae
``` 

### Função para Retornar o Estado pelo DDD

```dart
print(AllValidations.getStateByDDD("11")); 
// Saída: BrazilianState.SP
```

---

## 📚 Documentação

A documentação completa de cada classe — com todos os métodos, parâmetros e exemplos — está nos arquivos abaixo:

| Arquivo | Conteúdo |
|---------|----------|
| [📄 AllValidations.md](doc/AllValidations.md) | Todos os métodos de validação BR, `validate*()` com `Result`, `Contract` |
| [📄 HelperUtil.md](doc/HelperUtil.md) | Utilitários de texto, datas, UUID, JWT, PIX (validação e mascaramento), maioridade |
| [📄 BrFormatter.md](doc/BrFormatter.md) | Formatação e geração de CPF, CNPJ, CEP, telefone, moeda e KM |
| [📄 BrData.md](doc/BrData.md) | Parse, formatação e validação de datas no padrão BR sem `intl` |
| [📄 BrInputMask.md](doc/BrInputMask.md) | Referência completa das 19 máscaras de campo com exemplos de `TextField` |
| [📄 CnpjAlfanumerico.md](doc/CnpjAlfanumerico.md) | CNPJ alfanumérico 2026 — validação, formatação e geração |
| [📄 CryptUtil.md](doc/CryptUtil.md) | ChaCha20-Poly1305: criptografia, AAD, serialização e boas práticas |
| [📄 Result.md](doc/Result.md) | `Result<F,S>`, `Contract`, `ValidationResult` e operações assíncronas |


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
Fornece listas de dias da semana em formato abreviado, completo, apenas dias úteis e com ordenação a partir do domingo.  
- `AllValidationsGetWeek.listDaysWeek` → `['Segunda-Feira', 'Terça-Feira', ..., 'Domingo']`  
- `AllValidationsGetWeek.listDaysWeekAbvr` → `['Segunda', 'Terça', ..., 'Domingo']`  
- `AllValidationsGetWeek.listWorkDays` → `['Segunda-Feira', ..., 'Sexta-Feira']`  
- `AllValidationsGetWeek.listDaysWeekOrdered` → `['Domingo', 'Segunda', ..., 'Sábado']`  

---

## 👥 Contribuidores

[![Contributors](https://contrib.rocks/image?repo=CriandoGames/all_validations_br)](https://github.com/CriandoGames/all_validations_br/graphs/contributors)

Made with [contrib.rocks](https://contrib.rocks).

Contribuições são bem-vindas! Leia o [CONTRIBUTING.md](CONTRIBUTING.md) para começar.

---

## 📄 Licença

Distribuído sob a licença MIT. Veja [LICENSE](LICENSE) para mais detalhes.

---

<p align="center">💻 Desenvolvido com ❤️ para facilitar o desenvolvimento no Flutter.</p>
