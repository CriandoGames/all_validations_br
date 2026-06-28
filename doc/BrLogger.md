# BrLogger — Logging Puro para Dart/Flutter

`BrLogger` é um sistema de logging **zero dependências** — apenas `dart:core` e `dart:developer`. Funciona tanto em projetos Flutter quanto em Dart server-side.

```dart
import 'package:all_validations_br/br_logger.dart';
```
---

## Pipeline de funcionamento

```
BrLogger.info('msg')
    │
    ▼
BrLogFilter.shouldLog(record)  →  false → descarta
    │ true
    ▼
BrLogPrinter.format(record)    →  List<String> (linhas formatadas)
    │
    ▼
BrLogOutput.write(record, lines)  →  console / DevTools / memória / multi
```

Cada etapa é substituível — você cria o seu `BrLogFilter`, `BrLogPrinter` ou `BrLogOutput` e passa no construtor.

---

## Uso básico

```dart
final log = BrLogger(tag: 'Auth');

log.trace('iniciando handshake');
log.debug('userId: $id');
log.info('login bem-sucedido');
log.warning('token expira em 5 min');
log.error('falha na requisição', error: e, stackTrace: st);
log.fatal('banco de dados indisponível');
```

Sem configuração adicional o `BrLogger` usa:
- **Filter:** `BrDevelopmentFilter` — tudo em debug, `warning+` em produção
- **Printer:** `BrPrettyPrinter` — caixas coloridas com ANSI
- **Output:** `BrPrintOutput` — `print()` para o terminal

---

## Níveis de log

| Método | Nível | Cor | Quando usar |
|---|---|---|---|
| `trace()` | `BrLogLevel.trace` | cinza | Rastreamento muito detalhado, loops internos |
| `debug()` | `BrLogLevel.debug` | azul | Informações úteis no desenvolvimento |
| `info()` | `BrLogLevel.info` | verde | Eventos normais do fluxo |
| `warning()` | `BrLogLevel.warning` | laranja | Situação inesperada, mas não crítica |
| `error()` | `BrLogLevel.error` | vermelho | Operação falhou, app continua |
| `fatal()` | `BrLogLevel.fatal` | vermelho bold | App não pode continuar normalmente |

Os níveis têm `index` crescente — útil para comparações:

```dart
if (record.level.index >= BrLogLevel.warning.index) { ... }
```

---

## Filters

Controlam quais eventos chegam ao printer.

### BrDevelopmentFilter *(padrão)*

Tudo em modo debug. Em produção (`dart.vm.product`) aplica `minLevelProduction`.

```dart
BrLogger(
  filter: BrDevelopmentFilter(minLevelProduction: BrLogLevel.error),
)
```

### BrProductionFilter

Só registra eventos com nível ≥ `minLevel`.

```dart
BrLogger(
  filter: BrProductionFilter(minLevel: BrLogLevel.warning), // padrão
)
```

### BrAllFilter / BrNullFilter

```dart
BrAllFilter()   // deixa tudo passar — ideal para testes
BrNullFilter()  // bloqueia tudo — silencia o logger em testes específicos
```

### Filter customizado

```dart
class MeuFilter extends BrLogFilter {
  @override
  bool shouldLog(BrLogRecord record) {
    // ignora trace e debug em ambiente de homologação
    return record.level.index >= BrLogLevel.info.index;
  }
}
```

---

## Printers

Transformam o `BrLogRecord` em linhas de texto.

### BrPrettyPrinter *(padrão)*

Caixas delimitadoras com cores ANSI. Ideal para terminal e console do Flutter.

```dart
BrLogger(
  printer: BrPrettyPrinter(
    showTime: true,          // exibe horário no header
    showTag: true,           // exibe a tag do logger
    useColors: true,         // habilita ANSI (desative para CI/CD)
    stackTraceMaxLines: 8,   // 0 = todas as linhas
  ),
)
```

Output no terminal:
```
┌─ Auth ─────────────────────────────────
│ [INFO ] 10:30:00.123
│ login bem-sucedido
└────────────────────────────────────────
```

Para erros com stack trace:
```
┌─ Pagamento ────────────────────────────
│ [ERROR] 10:30:01.456
│ falha na requisição
│
│ ⚠ Exception: connection timeout
│
│ #0  PagamentoService.cobrar (pagamento_service.dart:42)
│ #1  CheckoutBloc._onConfirmar (checkout_bloc.dart:88)
│ … (6 linhas omitidas)
└────────────────────────────────────────
```

### BrSimplePrinter

Uma linha por evento, sem cores. Ideal para arquivos de log, CI/CD e DevTools.

```dart
BrLogger(
  printer: BrSimplePrinter(
    showTime: true,   // 2024-01-15 10:30:00.123 [INFO] Auth: login ok
    showTag: true,
  ),
)
```

### Printer customizado

```dart
class JsonPrinter extends BrLogPrinter {
  @override
  List<String> format(BrLogRecord record) {
    return [
      '{"level":"${record.level.name}","tag":"${record.tag}","msg":"${record.message}","ts":"${record.time.toIso8601String()}"}',
    ];
  }
}
```

---

## Outputs

Definem onde as linhas formatadas são escritas.

### BrPrintOutput *(padrão)*

Usa `print()`. Suporta ANSI quando o terminal tem suporte.

```dart
BrLogger(output: BrPrintOutput())
```

### BrDeveloperOutput

Usa `dart:developer log()`. Integra com o painel **Logs** do Flutter DevTools. Não suporta ANSI — combine com `BrSimplePrinter`.

```dart
BrLogger(
  printer: BrSimplePrinter(showTime: true),
  output: BrDeveloperOutput(),
)
```

### BrMemoryOutput

Mantém os eventos em memória. Essencial para testes.

```dart
final memory = BrMemoryOutput(maxRecords: 200); // padrão: 200
final log = BrLogger(
  filter: BrAllFilter(),
  output: memory,
);

log.warning('algo suspeito');

expect(memory.records.last.level, BrLogLevel.warning);
expect(memory.records.last.message, 'algo suspeito');

memory.clear(); // limpa o buffer
```

### BrMultiOutput

Encaminha o mesmo evento para múltiplos outputs simultaneamente.

```dart
BrLogger(
  output: BrMultiOutput([
    BrDeveloperOutput(),   // → DevTools
    BrMemoryOutput(),      // → buffer para testes/inspeção
  ]),
)
```

### Output customizado

```dart
class FileOutput extends BrLogOutput {
  final IOSink _sink;

  FileOutput(File file) : _sink = file.openWrite(mode: FileMode.append);

  @override
  void write(BrLogRecord record, List<String> lines) {
    for (final line in lines) {
      _sink.writeln(line);
    }
  }

  @override
  void dispose() => _sink.close();
}
```

---

## Configurações comuns

### Desenvolvimento (padrão implícito)

```dart
final log = BrLogger(tag: 'MinhaFeature');
// BrDevelopmentFilter + BrPrettyPrinter + BrPrintOutput
```

### Produção

```dart
final log = BrLogger(
  tag: 'App',
  filter: BrProductionFilter(minLevel: BrLogLevel.warning),
  printer: BrSimplePrinter(showTime: true, showTag: true),
  output: BrDeveloperOutput(),
);
```

### Testes

```dart
late BrMemoryOutput memory;
late BrLogger log;

setUp(() {
  memory = BrMemoryOutput();
  log = BrLogger(
    filter: BrAllFilter(),
    printer: BrSimplePrinter(),
    output: memory,
  );
});

test('deve logar warning ao token expirar', () {
  authService.onTokenExpiry();
  expect(memory.records.last.level, BrLogLevel.warning);
});
```

### CI/CD (sem ANSI)

```dart
final log = BrLogger(
  printer: BrPrettyPrinter(useColors: false),
  output: BrPrintOutput(),
);
```

---

## BrLogRecord

Data class imutável criada pelo `BrLogger` a cada evento. Disponível no filter, printer e output.

| Campo | Tipo | Descrição |
|---|---|---|
| `level` | `BrLogLevel` | Severidade do evento |
| `message` | `Object?` | Mensagem (toString chamado no printer) |
| `tag` | `String` | Nome do módulo/classe |
| `time` | `DateTime` | Instante de criação |
| `error` | `Object?` | Exceção/erro (opcional) |
| `stackTrace` | `StackTrace?` | Stack trace (opcional) |

---

## Descarte de recursos

Se o seu output mantém recursos abertos (arquivo, socket), chame `dispose()` ao encerrar:

```dart
log.dispose();
```

`BrMemoryOutput`, `BrPrintOutput` e `BrDeveloperOutput` não precisam de dispose.

---

## Comparação: módulos de logging na biblioteca

| | `BrLogger` | `dart:developer log()` direto | `printMessageErrors()` em `ValidationNotifiable` |
|---|---|---|---|
| Níveis de severidade | ✅ 6 níveis | ✅ numérico livre | ❌ só erro |
| Cores ANSI | ✅ | ❌ | ❌ |
| Filtragem por ambiente | ✅ | ❌ manual | ❌ |
| Integração DevTools | ✅ via `BrDeveloperOutput` | ✅ nativo | ✅ via `dev.log` |
| Buffer em memória para testes | ✅ `BrMemoryOutput` | ❌ | ❌ |
| Extensível (printer/output) | ✅ | ❌ | ❌ |
| Dependências externas | ❌ zero | ❌ zero | ❌ zero |
