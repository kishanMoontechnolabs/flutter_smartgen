import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/generators/app_generator.dart';
import 'package:flutter_smartgen/src/utils/cli_errors.dart';
import 'package:flutter_smartgen/src/utils/file_ops.dart';
import 'package:flutter_smartgen/src/utils/project_root.dart';

/// Scaffolds lib/app files (all or one by name).
class AppCommand extends Command<int> {
  @override
  String get name => 'app';

  @override
  String get description =>
      'Create lib/app scaffold files (skipped if they exist).';

  @override
  String get invocation => 'smartgen app [name]';

  AppCommand() {
    argParser.addOption(
      'cwd',
      help: 'Flutter project root (default: search upward from current directory).',
    );
  }

  @override
  Future<int> run() async {
    return runCommand(_run);
  }

  Future<int> _run() async {
    if (argResults!.rest.length > 1) {
      throw UsageException(
        'Unexpected extra arguments: ${argResults!.rest.skip(1).join(', ')}',
        usage,
      );
    }

    final ProjectRoot root = ProjectRoot.find(
      startPath: argResults?.option('cwd'),
    );

    final String? fileName =
        argResults!.rest.isNotEmpty ? argResults!.rest.first : null;

    final AppGenerationResult result = AppGenerator(
      projectRoot: root.directory,
      packageName: root.readPackageName(),
      fileName: fileName,
    ).generate();

    for (final WriteResult write in result.results) {
      final String status = write.created ? 'created' : 'skipped (exists)';
      stdout.writeln('  $status: ${write.path}');
    }
    stdout.writeln(
      'Done: ${result.createdCount} created, ${result.skippedCount} skipped.',
    );

    return 0;
  }
}
