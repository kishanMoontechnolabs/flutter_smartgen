import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/generators/page_generator.dart';
import 'package:flutter_smartgen/src/utils/file_ops.dart';
import 'package:flutter_smartgen/src/utils/project_root.dart';

/// Scaffolds a feature-module page.
class PageCommand extends Command<int> {
  @override
  String get name => 'page';

  @override
  String get description => 'Generate a feature-module page (6 files).';

  @override
  String get invocation => 'smartgen page <page_name>';

  PageCommand() {
    argParser.addOption(
      'cwd',
      help: 'Flutter project root (default: search upward from current directory).',
    );
  }

  @override
  Future<int> run() async {
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

    late final SmartgenConfig config;
    try {
      config = SmartgenConfig.load(root.directory);
    } on StateError catch (e) {
      stderr.writeln(e.message);
      return 1;
    } on FormatException catch (e) {
      stderr.writeln(e.message);
      return 1;
    }

    final PageGenerationResult result = PageGenerator(
      projectRoot: root.directory,
      config: config,
      pageName: pageName,
    ).generate();

    stdout.writeln('Module: ${result.moduleDirectory}');
    for (final WriteResult write in result.results) {
      final String status = write.created ? 'created' : 'skipped (exists)';
      stdout.writeln('  $status: ${write.path}');
    }
    stdout.writeln(
      'Done: ${result.createdCount} created, ${result.skippedCount} skipped.',
    );
    stdout.writeln(
      'Reminder: register a route and GetPage binding for this screen in your router.',
    );

    return 0;
  }
}
