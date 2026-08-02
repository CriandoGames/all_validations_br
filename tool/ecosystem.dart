import 'dart:io';

final Directory aggregatorRoot = File.fromUri(Platform.script).parent.parent;
final Directory workspaceRoot = aggregatorRoot.parent;

const pureDartPackages = <String>[
  'all_crypto',
  'all_logger',
  'all_result',
  'all_br_validations',
];

const flutterPackages = <String>['all_br_forms', 'all_validations_br'];

const publishOrder = <String>[
  'all_result',
  'all_crypto',
  'all_logger',
  'all_br_validations',
  'all_br_forms',
  'all_validations_br',
];

Directory packageDirectory(String name) => name == 'all_validations_br'
    ? aggregatorRoot
    : Directory('${workspaceRoot.path}${Platform.pathSeparator}$name');

Directory exampleDirectory(String name) => Directory(
      '${packageDirectory(name).path}${Platform.pathSeparator}example',
    );

bool isFlutterPackage(String name) => flutterPackages.contains(name);

String get dartExecutable => Platform.resolvedExecutable;

String get flutterExecutable {
  final configured = Platform.environment['ALL_FLUTTER_EXECUTABLE'];
  if (configured != null && configured.isNotEmpty) return configured;

  final flutterBin =
      File(Platform.resolvedExecutable).parent.parent.parent.parent;
  final executable = Platform.isWindows ? 'flutter.bat' : 'flutter';
  final bundled =
      File('${flutterBin.path}${Platform.pathSeparator}$executable');
  return bundled.existsSync() ? bundled.path : executable;
}

Future<void> runChecked(
  String package,
  String executable,
  List<String> arguments, {
  Map<String, String>? environment,
}) async {
  await runCheckedIn(
    package,
    packageDirectory(package),
    executable,
    arguments,
    environment: environment,
  );
}

Future<void> runCheckedIn(
  String label,
  Directory directory,
  String executable,
  List<String> arguments, {
  Map<String, String>? environment,
}) async {
  if (!directory.existsSync()) {
    throw FileSystemException('Diretório ausente para $label', directory.path);
  }
  stdout.writeln('\n[$label] $executable ${arguments.join(' ')}');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: directory.path,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
    environment: environment,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ProcessException(executable, arguments, 'Falha em $label', exitCode);
  }
}
