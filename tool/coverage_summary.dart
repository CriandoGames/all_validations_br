import 'dart:io';

import 'ecosystem.dart';

void main() {
  stdout
      .writeln('Pacote | Linhas cobertas | Linhas instrumentadas | Cobertura');
  stdout.writeln('---|---:|---:|---:');

  for (final package in publishOrder) {
    final report = File(
      '${packageDirectory(package).path}${Platform.pathSeparator}'
      'coverage${Platform.pathSeparator}lcov.info',
    );
    if (!report.existsSync()) {
      throw StateError('Cobertura ausente para $package: ${report.path}');
    }

    var found = 0;
    var hit = 0;
    for (final line in report.readAsLinesSync()) {
      if (line.startsWith('LF:')) {
        found += int.parse(line.substring(3));
      } else if (line.startsWith('LH:')) {
        hit += int.parse(line.substring(3));
      }
    }
    if (found == 0 || hit > found) {
      throw StateError('LCOV inválido para $package: LF=$found, LH=$hit.');
    }
    final percentage = (hit * 100 / found).toStringAsFixed(2);
    stdout.writeln('$package | $hit | $found | $percentage%');
  }
}
