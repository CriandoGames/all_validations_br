import 'dart:io';

import 'ecosystem.dart';

const packageNames = <String>[
  'all_crypto',
  'all_logger',
  'all_result',
  'all_br_validations',
  'all_br_forms',
  'all_validations_br',
];

const purePackages = <String>{
  'all_crypto',
  'all_logger',
  'all_result',
  'all_br_validations',
};

final errors = <String>[];

void fail(String message) => errors.add(message);

Iterable<File> filesUnder(Directory directory, String suffix) sync* {
  if (!directory.existsSync()) return;
  for (final entity
      in directory.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith(suffix)) {
      yield entity;
    }
  }
}

String relative(File file, Directory package) =>
    file.path.substring(package.path.length + 1).replaceAll('\\', '/');

File packageFile(String package, String path) => File(
      '${packageDirectory(package).path}${Platform.pathSeparator}'
      '${path.replaceAll('/', Platform.pathSeparator)}',
    );

Set<String> dependenciesOf(String package) {
  final pubspec = packageFile(package, 'pubspec.yaml');
  if (!pubspec.existsSync()) return const {};
  final lines = pubspec.readAsLinesSync();
  final dependencies = <String>{};
  var inDependencies = false;
  for (final line in lines) {
    if (line == 'dependencies:') {
      inDependencies = true;
      continue;
    }
    if (inDependencies && line.isNotEmpty && !line.startsWith(' ')) break;
    final match = RegExp(r'^  ([a-zA-Z0-9_]+):').firstMatch(line);
    if (inDependencies && match != null) {
      dependencies.add(match.group(1)!);
    }
  }
  return dependencies.intersection(packageNames.toSet());
}

void checkCycles() {
  final graph = <String, Set<String>>{
    for (final package in packageNames) package: dependenciesOf(package),
  };
  final active = <String>{};
  final complete = <String>{};

  void visit(String package, List<String> path) {
    if (active.contains(package)) {
      fail('Ciclo de dependências: ${[...path, package].join(' -> ')}');
      return;
    }
    if (complete.contains(package)) return;
    active.add(package);
    for (final dependency in graph[package] ?? const <String>{}) {
      visit(dependency, [...path, package]);
    }
    active.remove(package);
    complete.add(package);
  }

  for (final package in packageNames) {
    visit(package, const []);
  }
}

void checkImports(String package, Directory directory) {
  final lib = Directory('${directory.path}${Platform.pathSeparator}lib');
  final uriPattern = RegExp(r'''(?:import|export|part)\s+['"]([^'"]+)['"]''');

  for (final file in filesUnder(lib, '.dart')) {
    final source = file.readAsStringSync();
    final name = relative(file, directory);

    if (package != 'all_validations_br' &&
        source.contains('package:all_validations_br/')) {
      fail('$package/$name importa o agregador.');
    }

    if (purePackages.contains(package)) {
      for (final token in [
        'package:flutter/',
        'TextInputFormatter',
        'TextEditingValue',
        'BuildContext',
        'Widget',
      ]) {
        if (source.contains(token)) {
          fail('$package/$name contém referência Flutter: $token.');
        }
      }
    }

    for (final match in uriPattern.allMatches(source)) {
      final uri = match.group(1)!;
      File? target;
      if (!uri.contains(':')) {
        target = File(
          '${file.parent.path}${Platform.pathSeparator}'
          '${uri.replaceAll('/', Platform.pathSeparator)}',
        );
      } else if (uri.startsWith('package:')) {
        final packageMatch = RegExp(r'^package:([^/]+)/(.+)$').firstMatch(uri);
        if (packageMatch != null &&
            packageNames.contains(packageMatch.group(1))) {
          target = packageFile(
            packageMatch.group(1)!,
            'lib/${packageMatch.group(2)!}',
          );
        }
      }
      if (target != null && !target.existsSync()) {
        fail('$package/$name referencia import/export/part inexistente: $uri.');
      }
    }
  }
}

void checkDocumentation(String package, Directory directory) {
  const required = <String>[
    'README.md',
    'README.en.md',
    'CHANGELOG.md',
    'LICENSE',
    'CONTRIBUTING.md',
    'CONTRIBUTING.en.md',
    'SECURITY.md',
    'SECURITY.en.md',
    'analysis_options.yaml',
    'pubspec.yaml',
    '.pubignore',
  ];
  for (final path in required) {
    if (!File('${directory.path}${Platform.pathSeparator}$path').existsSync()) {
      fail('$package não contém $path.');
    }
  }

  const heroPath = 'documentation/images/hero.png';
  if (!File('${directory.path}${Platform.pathSeparator}$heroPath')
      .existsSync()) {
    fail('$package não contém $heroPath.');
  }

  for (final readme in ['README.md', 'README.en.md']) {
    final file = File(
      '${directory.path}${Platform.pathSeparator}$readme',
    );
    if (file.existsSync() && !file.readAsStringSync().contains(heroPath)) {
      fail('$package/$readme não referencia o hero padronizado.');
    }
  }

  for (final locale in ['pt-BR', 'en']) {
    final docs = Directory(
      '${directory.path}${Platform.pathSeparator}doc'
      '${Platform.pathSeparator}$locale',
    );
    if (!docs.existsSync() || filesUnder(docs, '.md').isEmpty) {
      fail('$package não contém documentação $locale.');
    }
  }

  final example = Directory(
    '${directory.path}${Platform.pathSeparator}example',
  );
  if (!example.existsSync() || filesUnder(example, '.dart').isEmpty) {
    fail('$package não contém exemplo Dart.');
  }

  final tests = Directory('${directory.path}${Platform.pathSeparator}test');
  if (!tests.existsSync() || filesUnder(tests, '_test.dart').isEmpty) {
    fail('$package não contém testes.');
  }

  final pubignore =
      File('${directory.path}${Platform.pathSeparator}.pubignore');
  if (pubignore.existsSync()) {
    final source = pubignore.readAsStringSync();
    for (final entry in [
      '.github/',
      '.dart_tool/',
      'coverage/',
      'build/',
      'doc/api/',
      'documentation/images/',
      'pubspec_overrides.yaml',
      '*.log',
    ]) {
      if (!source.contains(entry)) {
        fail('$package/.pubignore não exclui $entry.');
      }
    }
  }
}

void checkMarkdownLinks(String package, Directory directory) {
  final linkPattern = RegExp(r'\[[^\]]+\]\(([^)]+)\)');
  for (final file in filesUnder(directory, '.md')) {
    final source = file.readAsStringSync();
    for (final match in linkPattern.allMatches(source)) {
      var target = match.group(1)!.trim();
      if (target.startsWith('<') && target.endsWith('>')) {
        target = target.substring(1, target.length - 1);
      }
      if (target.isEmpty ||
          target.startsWith('#') ||
          target.startsWith('/') ||
          RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(target)) {
        continue;
      }
      target = target.split('#').first.split('?').first;
      try {
        target = Uri.decodeComponent(target);
      } on FormatException {
        fail(
          '$package/${relative(file, directory)} contém link malformado: '
          '${match.group(1)}.',
        );
        continue;
      }
      final resolved = File(
        '${file.parent.path}${Platform.pathSeparator}'
        '${target.replaceAll('/', Platform.pathSeparator)}',
      );
      if (!resolved.existsSync() && !Directory(resolved.path).existsSync()) {
        fail(
          '$package/${relative(file, directory)} contém link local '
          'inexistente: ${match.group(1)}.',
        );
      }
    }
  }
}

Set<String> publicDeclarations(Directory lib) {
  final declarations = <String>{};
  final pattern = RegExp(
    r'^(?:(?:abstract|base|final|sealed)\s+)?'
    r'(?:class|enum|extension|mixin|typedef)\s+([A-Za-z_]\w*)'
    r'|^[A-Za-z_][\w<>?, ]*\s+([a-zA-Z]\w*)\s*\(',
    multiLine: true,
  );
  for (final file in filesUnder(lib, '.dart')) {
    for (final match in pattern.allMatches(file.readAsStringSync())) {
      final name = match.group(1) ?? match.group(2);
      if (name != null && !name.startsWith('_')) declarations.add(name);
    }
  }
  return declarations;
}

void checkRootDuplicates() {
  final rootLib =
      Directory('${aggregatorRoot.path}${Platform.pathSeparator}lib');
  final rootSrc = Directory(
    '${rootLib.path}${Platform.pathSeparator}src',
  );

  for (final file in filesUnder(rootSrc, '.dart')) {
    final path = relative(file, aggregatorRoot);
    if (!path.startsWith('lib/src/helper_utils/')) {
      fail('Implementação extraída ainda existe no agregador: $path.');
    }
  }

  final specialized = <String>{};
  for (final package
      in packageNames.where((name) => name != 'all_validations_br')) {
    specialized.addAll(
      publicDeclarations(
        Directory(
          '${packageDirectory(package).path}${Platform.pathSeparator}lib',
        ),
      ),
    );
  }
  final duplicated = publicDeclarations(rootSrc).intersection(specialized);
  for (final declaration in duplicated) {
    fail('Declaração pública duplicada no agregador: $declaration.');
  }
}

void checkHistoricalBarrels() {
  const expectedExports = <String, String>{
    'lib/br_zod.dart': 'package:all_br_validations/br_zod.dart',
    'lib/br_logger.dart': 'package:all_logger/all_logger.dart',
    'lib/crypt.dart': 'package:all_crypto/all_crypto.dart',
    'lib/validation.dart': 'package:all_br_validations/validation.dart',
    'lib/regions_validations.dart':
        'package:all_br_validations/regions_validations.dart',
  };
  for (final entry in expectedExports.entries) {
    final file = packageFile('all_validations_br', entry.key);
    if (!file.existsSync()) {
      fail('Barrel histórico ausente: ${entry.key}.');
      continue;
    }
    if (!file.readAsStringSync().contains("export '${entry.value}';")) {
      fail('${entry.key} não aponta exclusivamente para ${entry.value}.');
    }
  }

  for (final test in [
    'all_validations_br_import_test.dart',
    'br_zod_import_test.dart',
    'br_logger_import_test.dart',
    'crypt_import_test.dart',
    'validation_import_test.dart',
    'regions_validations_import_test.dart',
  ]) {
    if (!packageFile(
      'all_validations_br',
      'test/legacy_compatibility/$test',
    ).existsSync()) {
      fail('Teste isolado de barrel ausente: $test.');
    }
  }
}

void main() {
  for (final package in packageNames) {
    final directory = packageDirectory(package);
    if (!directory.existsSync()) {
      fail('Pacote ausente: ${directory.path}.');
      continue;
    }
    final pubspec = packageFile(package, 'pubspec.yaml');
    if (!pubspec.existsSync()) {
      fail('$package não contém pubspec.yaml.');
      continue;
    }
    final source = pubspec.readAsStringSync();
    if (RegExp(r'^\s+path:\s+', multiLine: true).hasMatch(source)) {
      fail('$package possui dependência path no pubspec.yaml publicável.');
    }
    if (purePackages.contains(package) &&
        RegExp(r'^\s+flutter:\s*$', multiLine: true).hasMatch(source)) {
      fail('$package Dart puro declara dependência Flutter.');
    }
    checkImports(package, directory);
    checkDocumentation(package, directory);
    checkMarkdownLinks(package, directory);
  }

  checkCycles();
  checkRootDuplicates();
  checkHistoricalBarrels();

  if (errors.isNotEmpty) {
    stderr.writeln('Falhas de fronteira (${errors.length}):');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Fronteiras, imports, ciclos, manifests, barrels e documentos: OK.',
  );
}
