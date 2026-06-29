/// Módulo de listas e modelos geográficos brasileiros.
///
/// Exporta classes estáticas para meses, dias da semana, regiões,
/// estados e o enum `BrazilianState` — sem dependências externas.
///
/// ## Importação
///
/// ```dart
/// import 'package:all_validations_br/regions_validations.dart';
/// ```
///
/// ## Classes disponíveis
///
/// | Classe | Exemplo de uso |
/// |--------|----------------|
/// | `AllValidationsGetMonth` | `AllValidationsGetMonth.listMonths` → `['Janeiro', 'Fevereiro', ...]` |
/// | `AllValidationsGetWeek` | `AllValidationsGetWeek.listDaysWeek` → `['Segunda-Feira', ...]` |
/// | `AllValidationsGetRegions` | `AllValidationsGetRegions.listRegions` → `['Centro-Oeste', ...]` |
/// | `AllValidationsGetStates` | `AllValidationsGetStates.listStates` → `['Acre', 'Alagoas', ...]` |
/// | `BrazilianState` | enum com todos os estados — `BrazilianState.SP` |
/// | `ValidationError` | modelo de erro de validação com `field` e `message` |
library regions_validations;

export 'src/models/models.dart';
