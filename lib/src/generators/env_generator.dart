import 'dart:io';

import 'package:flutter_smartgen/src/templates/env_templates.dart';
import 'package:flutter_smartgen/src/utils/file_ops.dart';
import 'package:path/path.dart' as p;

/// Result of generating environment files.
class EnvGenerationResult {
  EnvGenerationResult({
    required this.results,
  });

  final List<WriteResult> results;

  int get createdCount => results.where((WriteResult r) => r.created).length;

  int get skippedCount => results.where((WriteResult r) => r.skipped).length;
}

/// Creates `.env.development` and `.env.production` at the project root.
class EnvGenerator {
  EnvGenerator({
    required this.projectRoot,
  });

  final Directory projectRoot;

  static const String developmentFile = '.env.development';
  static const String productionFile = '.env.production';

  EnvGenerationResult generate() {
    final String content = EnvTemplates.envFileContent();
    final List<WriteResult> results = <WriteResult>[
      FileOps.writeFile(
        file: File(p.join(projectRoot.path, developmentFile)),
        content: content,
      ),
      FileOps.writeFile(
        file: File(p.join(projectRoot.path, productionFile)),
        content: content,
      ),
    ];

    return EnvGenerationResult(results: results);
  }
}
