import 'coverage_pipeline.dart';
import 'ecosystem.dart';

Future<void> main() async {
  for (final package in pureDartPackages) {
    final directory = packageDirectory(package);
    resetCoverage(directory);
    await runChecked(
      package,
      dartExecutable,
      const ['test', '--coverage=coverage', '--reporter=compact'],
    );
    await runChecked(
      package,
      dartExecutable,
      const [
        'pub',
        'global',
        'run',
        'coverage:format_coverage',
        '--lcov',
        '--in=coverage/test',
        '--out=coverage/lcov.info',
        '--packages=.dart_tool/package_config.json',
        '--report-on=lib',
      ],
    );
    readLcovTotals(package, directory);
  }

  for (final package in flutterPackages) {
    final directory = packageDirectory(package);
    resetCoverage(directory);
    await runChecked(
      package,
      flutterExecutable,
      const ['test', '--coverage', '--reporter=compact'],
    );
    readLcovTotals(package, directory);
  }
}
