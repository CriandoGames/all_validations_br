import 'dart:io';

import 'ecosystem.dart';

Iterable<File> dartExamples(Directory directory) sync* {
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}

String relativeToPackage(String package, File file) => file.path
    .substring(packageDirectory(package).path.length + 1)
    .replaceAll('\\', '/');

bool hasWidgetTests(Directory example) {
  final tests = Directory('${example.path}${Platform.pathSeparator}test');
  if (!tests.existsSync()) return false;
  return tests
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .any((file) => file.path.endsWith('_test.dart'));
}

Future<void> main(List<String> arguments) async {
  final selected = arguments.isEmpty ? publishOrder : arguments;
  for (final package in selected) {
    if (!publishOrder.contains(package)) {
      throw ArgumentError.value(package, 'package', 'Pacote desconhecido.');
    }
  }

  for (final package in pureDartPackages.where(selected.contains)) {
    final example = exampleDirectory(package);
    final files = dartExamples(example).toList();
    if (files.isEmpty) {
      throw StateError('$package não contém exemplo Dart executável.');
    }
    await runChecked(package, dartExecutable, const ['pub', 'get']);
    await runChecked(package, dartExecutable, const ['analyze', 'example']);
    for (final file in files) {
      await runChecked(
        package,
        dartExecutable,
        ['run', relativeToPackage(package, file)],
      );
    }
  }

  for (final package in flutterPackages.where(selected.contains)) {
    final example = exampleDirectory(package);
    if (!File('${example.path}${Platform.pathSeparator}pubspec.yaml')
        .existsSync()) {
      throw StateError('$package/example não contém pubspec.yaml.');
    }
    final label = '$package/example';
    await runCheckedIn(label, example, flutterExecutable, const ['pub', 'get']);
    await runCheckedIn(
      label,
      example,
      dartExecutable,
      const ['format', '--output=none', '--set-exit-if-changed', '.'],
    );
    await runCheckedIn(label, example, flutterExecutable, const ['analyze']);
    if (hasWidgetTests(example)) {
      await runCheckedIn(label, example, flutterExecutable, const ['test']);
    }
    if (package == 'all_validations_br') {
      await runCheckedIn(
        label,
        example,
        dartExecutable,
        const ['run', 'custom_lint'],
      );
    }
  }
}
