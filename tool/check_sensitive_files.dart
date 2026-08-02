import 'dart:convert';
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

const ignoredSegments = <String>[
  '/.git/',
  '/.dart_tool/',
  '/coverage/',
  '/build/',
  '/doc/api/',
];

final forbiddenNames = RegExp(
  r'^(?:\.env(?:\..+)?|google-services\.json|GoogleService-Info\.plist|'
  r'key\.properties)$|'
  r'\.(?:pem|p12|pfx|jks|keystore|key)$',
  caseSensitive: false,
);

final secretPatterns = <String, RegExp>{
  'private key': RegExp(r'-----BEGIN [A-Z ]*PRIVATE KEY-----'),
  'AWS access key': RegExp(r'\bAKIA[0-9A-Z]{16}\b'),
  'GitHub token': RegExp(r'\bgh[pousr]_[A-Za-z0-9]{36,}\b'),
  'Google API key': RegExp(r'\bAIza[0-9A-Za-z_-]{35}\b'),
  'Slack token': RegExp(r'\bxox[baprs]-[0-9A-Za-z-]{20,}\b'),
  'Stripe secret': RegExp(r'\bsk_(?:live|test)_[0-9A-Za-z]{20,}\b'),
  'database URL with credentials': RegExp(
    r'\b(?:postgres(?:ql)?|mysql|mongodb(?:\+srv)?)://'
    r'[^\s:/]+:[^\s@/]+@',
    caseSensitive: false,
  ),
};

String normalized(FileSystemEntity entity) =>
    entity.absolute.path.replaceAll('\\', '/');

bool ignored(FileSystemEntity entity) {
  final path = '/${normalized(entity).toLowerCase()}/';
  return ignoredSegments.any(path.contains);
}

bool likelyText(List<int> bytes) {
  final sample = bytes.take(4096);
  return !sample.contains(0);
}

void main() {
  final findings = <String>[];
  final excludedLocalConfigs = <String>[];
  for (final package in packageNames) {
    final directory = packageDirectory(package);
    final pubignore = File(
      '${directory.path}${Platform.pathSeparator}.pubignore',
    );
    final pubignoreSource =
        pubignore.existsSync() ? pubignore.readAsStringSync() : '';
    for (final entity
        in directory.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || ignored(entity)) continue;
      final name = entity.uri.pathSegments.last;
      if (name.toLowerCase() == 'local.properties') {
        if (pubignoreSource.contains('local.properties')) {
          excludedLocalConfigs.add(entity.path);
        } else {
          findings.add(
            '$package: local.properties não excluído pelo .pubignore: '
            '${entity.path}',
          );
        }
        continue;
      }
      if (forbiddenNames.hasMatch(name) &&
          name != '.env.example' &&
          name != '.env.template') {
        findings.add('$package: arquivo sensível por nome: ${entity.path}');
        continue;
      }

      final bytes = entity.readAsBytesSync();
      if (!likelyText(bytes)) continue;
      final source = utf8.decode(bytes, allowMalformed: true);
      for (final entry in secretPatterns.entries) {
        if (entry.value.hasMatch(source)) {
          findings.add('$package: ${entry.key} em ${entity.path}');
        }
      }
    }
  }

  if (findings.isNotEmpty) {
    stderr
        .writeln('Possíveis segredos/arquivos sensíveis (${findings.length}):');
    for (final finding in findings) {
      stderr.writeln('- $finding');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Varredura de segredos e arquivos sensíveis: OK.');
  if (excludedLocalConfigs.isNotEmpty) {
    stdout.writeln(
      'Configurações locais geradas e explicitamente excluídas do archive: '
      '${excludedLocalConfigs.length}.',
    );
  }
}
