import 'ecosystem.dart';

Future<void> main() async {
  for (final package in pureDartPackages) {
    await runChecked(package, dartExecutable, const ['pub', 'get']);
    await runChecked(package, dartExecutable, const [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      '.',
    ]);
    await runChecked(package, dartExecutable, const ['analyze']);
  }

  for (final package in flutterPackages) {
    await runChecked(package, flutterExecutable, const ['pub', 'get']);
    await runChecked(package, dartExecutable, const [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      '.',
    ]);
    await runChecked(package, flutterExecutable, const ['analyze']);
  }
}
