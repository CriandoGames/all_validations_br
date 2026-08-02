import 'dart:convert';
import 'dart:io';

import 'ecosystem.dart';

final archiveLine = RegExp(
  r'^((?:(?:│   |    ))*)(?:├──|└──) (.+)$',
);

final displayedSize = RegExp(r' \([^)]*\)$');

Iterable<String> archiveEntries(String output) sync* {
  final stack = <String>[];
  var inArchive = false;
  for (final line in output.split(RegExp(r'\r?\n'))) {
    if (line.startsWith('Publishing ') && line.endsWith(':')) {
      inArchive = true;
      continue;
    }
    if (!inArchive) continue;
    if (line.startsWith('Total compressed archive size:')) return;

    final match = archiveLine.firstMatch(line);
    if (match == null) continue;
    final depth = match.group(1)!.length ~/ 4;
    final displayed = match.group(2)!;
    final isFile = displayedSize.hasMatch(displayed);
    final name = displayed.replaceFirst(displayedSize, '');
    while (stack.length > depth) {
      stack.removeLast();
    }
    final path = [...stack, name].join('/');
    yield path;
    if (!isFile) {
      if (stack.length == depth) stack.add(name);
    }
  }
}

bool forbiddenArchivePath(String path) {
  final lower = path.toLowerCase();
  final segments = lower.split('/');
  if (segments.any({'.dart_tool', 'coverage', 'build'}.contains) ||
      lower.startsWith('doc/api/') ||
      lower == 'doc/api' ||
      lower.startsWith('documentation/images/') ||
      lower.endsWith('/pubspec_overrides.yaml') ||
      lower == 'pubspec_overrides.yaml' ||
      lower.endsWith('.log')) {
    return true;
  }
  final name = segments.last;
  return name.startsWith('migration_inventory') ||
      name.startsWith('migration_baseline') ||
      name.startsWith('public_api_baseline') ||
      name.startsWith('package_extraction_report') ||
      name.startsWith('publishing_plan') ||
      name.startsWith('legacy_api_decisions') ||
      name.startsWith('semver_decision') ||
      name.startsWith('auditoria_');
}

Future<String?> publishDryRun(String package) async {
  final executable =
      isFlutterPackage(package) ? flutterExecutable : dartExecutable;
  const arguments = ['pub', 'publish', '--dry-run'];
  stdout.writeln('\n[$package] $executable ${arguments.join(' ')}');
  final result = await Process.run(
    executable,
    arguments,
    workingDirectory: packageDirectory(package).path,
    runInShell: Platform.isWindows,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  final output = '${result.stdout}\n${result.stderr}';
  final entries = archiveEntries(output).toList();
  if (entries.isEmpty) {
    return 'Não foi possível interpretar o conteúdo do archive de $package.';
  }
  final forbidden = entries.where(forbiddenArchivePath).toList();
  if (forbidden.isNotEmpty) {
    return 'Archive de $package contém entradas proibidas: '
        '${forbidden.join(', ')}';
  }
  if (result.exitCode != 0) {
    return 'Dry-run de $package terminou com código ${result.exitCode}.';
  }
  return null;
}

Future<void> main(List<String> arguments) async {
  final packages = arguments.isEmpty ? publishOrder : arguments;
  final failures = <String>[];
  for (final package in packages) {
    if (!publishOrder.contains(package)) {
      throw ArgumentError.value(package, 'package', 'Pacote desconhecido.');
    }
    final failure = await publishDryRun(package);
    if (failure != null) failures.add(failure);
  }
  if (failures.isNotEmpty) {
    throw StateError(
      'Falhas no dry-run consolidado:\n- ${failures.join('\n- ')}',
    );
  }
}
