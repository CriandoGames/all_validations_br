import 'dart:io';

final class LcovTotals {
  const LcovTotals({required this.found, required this.hit});

  final int found;
  final int hit;
}

Directory coverageDirectory(Directory packageDirectory) => Directory(
      '${packageDirectory.path}${Platform.pathSeparator}coverage',
    );

File lcovReport(Directory packageDirectory) => File(
      '${coverageDirectory(packageDirectory).path}${Platform.pathSeparator}'
      'lcov.info',
    );

void resetCoverage(Directory packageDirectory) {
  final directory = coverageDirectory(packageDirectory);
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
}

LcovTotals readLcovTotals(String package, Directory packageDirectory) {
  final report = lcovReport(packageDirectory);
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

  return LcovTotals(found: found, hit: hit);
}
