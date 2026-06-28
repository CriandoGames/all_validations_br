/// Níveis de severidade do [BrLogger].
///
/// Ordenados do menos ao mais severo. O valor [index] pode ser usado
/// para comparações: `level.index >= BrLogLevel.warning.index`.
enum BrLogLevel {
  /// Informações de rastreamento muito detalhadas, verbosas.
  /// Cor: cinza.
  trace,

  /// Informações úteis durante o desenvolvimento.
  /// Cor: azul.
  debug,

  /// Eventos normais do fluxo da aplicação.
  /// Cor: verde.
  info,

  /// Situações inesperadas que não interrompem o fluxo.
  /// Cor: laranja.
  warning,

  /// Erros recuperáveis — operação falhou, mas a app continua.
  /// Cor: vermelho.
  error,

  /// Erros críticos — a app não pode continuar normalmente.
  /// Cor: vermelho bold.
  fatal,
}

/// Extensão com metadados de apresentação para cada [BrLogLevel].
extension BrLogLevelExt on BrLogLevel {
  /// Rótulo exibido no log (5 chars fixos para alinhar colunas).
  String get label {
    switch (this) {
      case BrLogLevel.trace:
        return 'TRACE';
      case BrLogLevel.debug:
        return 'DEBUG';
      case BrLogLevel.info:
        return 'INFO ';
      case BrLogLevel.warning:
        return 'WARN ';
      case BrLogLevel.error:
        return 'ERROR';
      case BrLogLevel.fatal:
        return 'FATAL';
    }
  }

  /// Código ANSI de abertura para colorir o output no terminal.
  String get ansiOpen {
    switch (this) {
      case BrLogLevel.trace:
        return '\x1B[90m'; // cinza
      case BrLogLevel.debug:
        return '\x1B[34m'; // azul
      case BrLogLevel.info:
        return '\x1B[32m'; // verde
      case BrLogLevel.warning:
        return '\x1B[33m'; // laranja/amarelo
      case BrLogLevel.error:
        return '\x1B[31m'; // vermelho
      case BrLogLevel.fatal:
        return '\x1B[1;31m'; // vermelho bold
    }
  }

  /// Código ANSI de reset (sempre o mesmo).
  static const String ansiClose = '\x1B[0m';
}
