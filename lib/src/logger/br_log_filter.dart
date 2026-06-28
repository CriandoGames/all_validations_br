import 'br_log_level.dart';
import 'br_log_record.dart';

/// Decide se um [BrLogRecord] deve ser processado.
///
/// Implemente esta classe para criar filtros customizados.
///
/// ```dart
/// class MyFilter extends BrLogFilter {
///   @override
///   bool shouldLog(BrLogRecord record) => record.level.index >= BrLogLevel.info.index;
/// }
/// ```
abstract class BrLogFilter {
  const BrLogFilter();

  /// Retorna `true` se o [record] deve ser encaminhado ao printer.
  bool shouldLog(BrLogRecord record);
}

// ── Implementações prontas ────────────────────────────────────────────────────

/// Registra todos os níveis em modo debug; em produção (`dart --define`)
/// só registra [BrLogLevel.warning] e acima.
///
/// Use `const bool.fromEnvironment('dart.vm.product')` para detectar o modo.
class BrDevelopmentFilter extends BrLogFilter {
  final BrLogLevel minLevelProduction;

  const BrDevelopmentFilter({
    this.minLevelProduction = BrLogLevel.warning,
  });

  @override
  bool shouldLog(BrLogRecord record) {
    // Em modo release/product, aplica nível mínimo de produção.
    if (const bool.fromEnvironment('dart.vm.product')) {
      return record.level.index >= minLevelProduction.index;
    }
    return true;
  }
}

/// Registra apenas eventos com nível maior ou igual a [minLevel].
///
/// Adequado para produção: padrão é [BrLogLevel.warning].
class BrProductionFilter extends BrLogFilter {
  final BrLogLevel minLevel;

  const BrProductionFilter({this.minLevel = BrLogLevel.warning});

  @override
  bool shouldLog(BrLogRecord record) => record.level.index >= minLevel.index;
}

/// Registra tudo, sempre. Útil para testes.
class BrAllFilter extends BrLogFilter {
  const BrAllFilter();

  @override
  bool shouldLog(BrLogRecord record) => true;
}

/// Bloqueia tudo. Útil para silenciar o logger em testes específicos.
class BrNullFilter extends BrLogFilter {
  const BrNullFilter();

  @override
  bool shouldLog(BrLogRecord record) => false;
}
