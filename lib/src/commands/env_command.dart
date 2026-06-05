import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/generators/env_generator.dart';
import 'package:flutter_smartgen/src/utils/cli_errors.dart';
import 'package:flutter_smartgen/src/utils/file_ops.dart';
import 'package:flutter_smartgen/src/utils/project_root.dart';

/// Creates `.env.development` and `.env.production` at the project root.
class EnvCommand extends Command<int> {
  @override
  String get name => 'env';

  @override
  String get description =>
      'Create .env.development and .env.production (skipped if they exist).';

  @override
  String get invocation => 'smartgen env';

  EnvCommand() {
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
    if (argResults!.rest.isNotEmpty) {
      throw UsageException(
        'Unexpected extra arguments: ${argResults!.rest.join(', ')}',
        usage,
      );
    }

    final ProjectRoot root = ProjectRoot.find(
      startPath: argResults?.option('cwd'),
    );

    final EnvGenerationResult result = EnvGenerator(
      projectRoot: root.directory,
    ).generate();

    for (final WriteResult write in result.results) {
      final String status = write.created ? 'created' : 'skipped (exists)';
      stdout.writeln('  $status: ${write.path}');
    }
    stdout.writeln(
      'Done: ${result.createdCount} created, ${result.skippedCount} skipped.',
    );
    stdout.writeln(
      'Reminder: add ${EnvGenerator.developmentFile} and '
      '${EnvGenerator.productionFile} to .gitignore.',
    );

    return 0;
  }
}
