import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/generators/app_images_generator.dart';
import 'package:flutter_smartgen/src/utils/cli_errors.dart';
import 'package:flutter_smartgen/src/utils/project_root.dart';

/// Generates or updates AppImages from configured asset directories.
class AssetsImagesCommand extends Command<int> {
  @override
  String get name => 'images';

  @override
  String get description =>
      'Generate or update AppImages from configured asset directories.';

  @override
  String get invocation => 'smartgen assets images';

  AssetsImagesCommand() {
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
    final ProjectRoot root = ProjectRoot.find(
      startPath: argResults!.option('cwd'),
    );
    final SmartgenConfig config = loadConfigFrom(root.directory);

    final AssetsImagesConfig? assetsImages = config.assetsImages;
    if (assetsImages == null || !assetsImages.isConfigured) {
      stderr.writeln(
        'assets.images is not configured in smartgen.yaml. '
        'Add the assets.images block, then retry.',
      );
      return cliErrorExitCode;
    }

    final AppImagesGenerationResult result = AppImagesGenerator(
      projectRoot: root.directory,
      assetsImages: assetsImages,
    ).generate();

    stdout.writeln('Output: ${result.outputPath}');
    if (result.createdFile) {
      stdout.writeln('Created ${assetsImages.className} with ${result.addedCount} assets.');
    }

    for (final AppImagesWriteEntry entry in result.entries) {
      switch (entry.action) {
        case AppImagesEntryAction.added:
          stdout.writeln(
            '  added: ${entry.constantName} -> ${entry.assetPath}',
          );
        case AppImagesEntryAction.skipped:
          stdout.writeln('  skipped (exists): ${entry.assetPath}');
        case AppImagesEntryAction.removed:
          stdout.writeln(
            '  removed: ${entry.constantName} -> ${entry.assetPath}',
          );
      }
    }

    stdout.writeln(
      'Done: ${result.addedCount} added, ${result.skippedCount} skipped, '
      '${result.removedCount} removed.',
    );

    return 0;
  }
}
