import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/generators/route_generator.dart';
import 'package:flutter_smartgen/src/utils/cli_errors.dart';
import 'package:flutter_smartgen/src/utils/project_root.dart';

/// Registers GetX routes for an existing page module.
class RouteCommand extends Command<int> {
  @override
  String get name => 'route';

  @override
  String get description =>
      'Register AppRoutes constant and GetPage for a page module.';

  @override
  String get invocation => 'smartgen route <page_name>';

  RouteCommand() {
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
    final String? pageName = argResults?.rest.isNotEmpty == true
        ? argResults!.rest.first
        : null;

    if (pageName == null || pageName.isEmpty) {
      throw UsageException('Missing page name.', usage);
    }

    if (argResults!.rest.length > 1) {
      throw UsageException(
        'Unexpected extra arguments: ${argResults!.rest.skip(1).join(', ')}',
        usage,
      );
    }

    final ProjectRoot root = ProjectRoot.find(
      startPath: argResults!.option('cwd'),
    );
    final config = loadConfigFrom(root.directory);

    final RouteGenerationResult? result = RouteGenerator.tryRegister(
      projectRoot: root.directory,
      config: config,
      pageName: pageName,
    );

    if (result == null) {
      return cliErrorExitCode;
    }

    printResult(result);
    return 0;
  }

  static void printResult(RouteGenerationResult result) {
    for (final RouteWriteEntry entry in result.entries) {
      final String status =
          entry.action == RouteWriteAction.added ? 'added' : 'skipped (exists)';
      stdout.writeln('  $status: ${entry.label}');
    }
    stdout.writeln(
      'Done: ${result.addedCount} added, ${result.skippedCount} skipped.',
    );
  }
}
