import 'dart:io';

import 'coverage_pipeline.dart';
import 'ecosystem.dart';

void main() {
  stdout
      .writeln('Pacote | Linhas cobertas | Linhas instrumentadas | Cobertura');
  stdout.writeln('---|---:|---:|---:');

  for (final package in publishOrder) {
    final totals = readLcovTotals(package, packageDirectory(package));
    final percentage = (totals.hit * 100 / totals.found).toStringAsFixed(2);
    stdout.writeln(
      '$package | ${totals.hit} | ${totals.found} | $percentage%',
    );
  }
}
