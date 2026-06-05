import 'dart:io';

import 'package:flutter_smartgen/src/templates/app_templates.dart';
import 'package:flutter_smartgen/src/utils/app_file_registry.dart';
import 'package:flutter_smartgen/src/utils/file_ops.dart';
import 'package:path/path.dart' as p;

/// Result of scaffolding lib/app files.
class AppGenerationResult {
  AppGenerationResult({
    required this.results,
  });

  final List<WriteResult> results;

  int get createdCount => results.where((WriteResult r) => r.created).length;

  int get skippedCount => results.where((WriteResult r) => r.skipped).length;
}

/// Creates lib/app scaffold files (skip-if-exists).
class AppGenerator {
  AppGenerator({
    required this.projectRoot,
    required this.packageName,
    this.fileName,
  });

  final Directory projectRoot;
  final String packageName;
  final String? fileName;

  AppGenerationResult generate() {
    final List<AppFileEntry> targets = _resolveTargets();
    final AppTemplates templates = AppTemplates(packageName: packageName);
    final List<WriteResult> results = <WriteResult>[];

    Directory(p.join(projectRoot.path, AppFileRegistry.appBase)).createSync(
      recursive: true,
    );

    for (final AppFileEntry entry in targets) {
      results.add(
        FileOps.writeFile(
          file: File(p.join(projectRoot.path, entry.relativePath)),
          content: templates.contentFor(entry.templateKey),
        ),
      );
    }

    return AppGenerationResult(results: results);
  }

  List<AppFileEntry> _resolveTargets() {
    if (fileName == null || fileName!.isEmpty) {
      return AppFileRegistry.entries;
    }

    final AppFileEntry? entry = AppFileRegistry.find(fileName!);
    if (entry == null) {
      throw StateError(
        'Unknown app file "$fileName". Valid: ${AppFileRegistry.cliNames.join(', ')}.',
      );
    }

    return <AppFileEntry>[entry];
  }
}
