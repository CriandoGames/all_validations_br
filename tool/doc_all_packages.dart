import 'dart:io';

import 'ecosystem.dart';

Future<void> main(List<String> arguments) async {
  final knownPackages = [...pureDartPackages, ...flutterPackages];
  final packages = arguments.isEmpty ? knownPackages : arguments;
  for (final package in packages) {
    if (!knownPackages.contains(package)) {
      throw ArgumentError.value(package, 'package', 'Pacote desconhecido.');
    }
  }

  final outputRoot = Directory.systemTemp.createTempSync(
    'all_validations_br_dartdoc_',
  );

  try {
    final flutterRoot = File(flutterExecutable).parent.parent.path;
    for (final package in packages) {
      final output = Directory(
        '${outputRoot.path}${Platform.pathSeparator}$package',
      );
      await runChecked(
        package,
        dartExecutable,
        ['pub', 'global', 'run', 'dartdoc', '--output', output.path],
        environment:
            isFlutterPackage(package) ? {'FLUTTER_ROOT': flutterRoot} : null,
      );
    }
  } finally {
    if (outputRoot.existsSync()) {
      outputRoot.deleteSync(recursive: true);
    }
  }
}
