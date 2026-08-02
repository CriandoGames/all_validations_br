import 'dart:io';

import 'ecosystem.dart';

String overrideEntry(String dependency) => '  $dependency:\n'
    '    path: ${packageDirectory(dependency).absolute.path.replaceAll('\\', '/')}';

void writeOverrides(Directory directory, Iterable<String> dependencies) {
  if (dependencies.isEmpty) return;
  final file = File(
    '${directory.path}${Platform.pathSeparator}pubspec_overrides.yaml',
  );
  final entries = dependencies.map(overrideEntry);
  file.writeAsStringSync('dependency_overrides:\n${entries.join('\n')}\n');
}

void main() {
  if (Platform.environment['GITHUB_ACTIONS'] != 'true') {
    throw StateError(
      'Este utilitário só pode criar overrides efêmeros no GitHub Actions.',
    );
  }

  writeOverrides(packageDirectory('all_br_validations'), ['all_result']);
  writeOverrides(packageDirectory('all_br_forms'), ['all_br_validations']);
  writeOverrides(packageDirectory('all_validations_br'), [
    'all_result',
    'all_crypto',
    'all_logger',
    'all_br_validations',
    'all_br_forms',
  ]);
  writeOverrides(exampleDirectory('all_br_forms'), ['all_br_validations']);
  writeOverrides(exampleDirectory('all_validations_br'), publishOrder);
  stdout.writeln('Overrides locais efêmeros criados para o CI.');
}
