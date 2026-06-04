import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/templates/page_templates.dart';
import 'package:flutter_smartgen/src/utils/file_ops.dart';
import 'package:flutter_smartgen/src/utils/naming_util.dart';
import 'package:path/path.dart' as p;

/// Result of generating a page module.
class PageGenerationResult {
  PageGenerationResult({
    required this.moduleDirectory,
    required this.results,
  });

  final String moduleDirectory;
  final List<WriteResult> results;

  int get createdCount => results.where((WriteResult r) => r.created).length;
  int get skippedCount => results.where((WriteResult r) => r.skipped).length;
}

/// Generates a feature-module page under the target Flutter project.
class PageGenerator {
  PageGenerator({
    required this.projectRoot,
    required this.config,
    required this.pageName,
  });

  final Directory projectRoot;
  final SmartgenConfig config;
  final String pageName;

  PageGenerationResult generate() {
    final PageNaming naming = PageNaming(
      inputName: pageName,
      screenSuffix: config.naming.screenSuffix,
      controllerSuffix: config.naming.controllerSuffix,
    );

    final String modulePath = p.join(
      config.screensBase,
      naming.moduleSnake,
    );
    final String moduleImportPath = packageImportPath(modulePath);

    final PageTemplates templates = PageTemplates(
      config: config,
      naming: naming,
      moduleImportPath: moduleImportPath,
    );

    final Directory moduleDir = Directory(
      p.join(projectRoot.path, modulePath),
    );

    final String modelFileName = '${naming.moduleSnake.replaceAll('_screen', '')}_model.dart';

    final List<({String relativePath, String content})> files =
        <({String relativePath, String content})>[
      (relativePath: naming.barrelFile, content: templates.barrelFile()),
      (
        relativePath: 'view/${naming.viewFile}',
        content: templates.viewFile(),
      ),
      (
        relativePath: 'controller/${naming.moduleSnake}_controller.dart',
        content: templates.controllerFile(),
      ),
      (
        relativePath: 'resource/repository/${naming.moduleSnake}_repository.dart',
        content: templates.repositoryFile(),
      ),
      (
        relativePath: 'resource/model/$modelFileName',
        content: templates.modelFile(),
      ),
      (
        relativePath: 'binding/${naming.moduleSnake}_binding.dart',
        content: templates.bindingFile(),
      ),
    ];

    final List<WriteResult> results = <WriteResult>[];
    for (final ({String relativePath, String content}) file in files) {
      final File outFile = File(p.join(moduleDir.path, file.relativePath));
      results.add(
        FileOps.writeFile(file: outFile, content: file.content),
      );
    }

    return PageGenerationResult(
      moduleDirectory: moduleDir.path,
      results: results,
    );
  }

  /// Dart package imports omit the leading `lib/` segment.
  static String packageImportPath(String modulePath) {
    final String normalized = modulePath.replaceAll(r'\', '/');
    if (normalized.startsWith('lib/')) {
      return normalized.substring(4);
    }
    return normalized;
  }
}
