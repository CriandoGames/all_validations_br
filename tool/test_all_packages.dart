import 'ecosystem.dart';

Future<void> main() async {
  for (final package in pureDartPackages) {
    await runChecked(
      package,
      dartExecutable,
      const ['test', '--coverage=coverage', '--reporter=compact'],
    );
  }

  for (final package in flutterPackages) {
    await runChecked(
      package,
      flutterExecutable,
      const ['test', '--coverage', '--reporter=compact'],
    );
  }
}
