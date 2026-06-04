/// Parsed constant from an existing AppImages file.
class AppImagesConstant {
  const AppImagesConstant({
    required this.name,
    required this.assetPath,
    required this.line,
  });

  final String name;
  final String assetPath;

  /// Full source line including indentation.
  final String line;
}

/// Result of parsing an existing AppImages Dart file.
class AppImagesParseResult {
  const AppImagesParseResult({
    required this.knownPaths,
    required this.knownConstantNames,
    required this.constants,
  });

  final Set<String> knownPaths;
  final Set<String> knownConstantNames;
  final List<AppImagesConstant> constants;
}

/// Parses existing AppImages Dart source for merge logic.
class AppImagesParser {
  static final RegExp _literalLinePattern = RegExp(
    r"^[ \t]*static const String (\w+) = '([^']+)';[ \t]*$",
    multiLine: true,
  );

  static final RegExp _interpolatedLinePattern = RegExp(
    r"^[ \t]*static const String (\w+) = '\$\{(\w+)\}([^']+)';[ \t]*$",
    multiLine: true,
  );

  AppImagesParseResult parse(String content) {
    final Set<String> knownPaths = <String>{};
    final Set<String> knownConstantNames = <String>{};
    final List<AppImagesConstant> constants = <AppImagesConstant>[];
    final Map<String, String> basePathConstants = <String, String>{};

    for (final Match match in _literalLinePattern.allMatches(content)) {
      final String name = match.group(1)!;
      final String value = match.group(2)!;
      final String line = match.group(0)!;
      knownConstantNames.add(name);

      if (value.startsWith('assets/')) {
        if (value.endsWith('/')) {
          basePathConstants[name] = value;
        } else {
          final String normalized = _normalizeAssetPath(value);
          knownPaths.add(normalized);
          constants.add(
            AppImagesConstant(name: name, assetPath: normalized, line: line),
          );
        }
      } else if (value.endsWith('/')) {
        basePathConstants[name] = value;
      }
    }

    for (final Match match in _interpolatedLinePattern.allMatches(content)) {
      final String name = match.group(1)!;
      final String baseConst = match.group(2)!;
      final String suffix = match.group(3)!;
      final String line = match.group(0)!;
      knownConstantNames.add(name);

      final String? base = basePathConstants[baseConst];
      if (base != null) {
        final String normalized = _normalizeAssetPath('$base$suffix');
        knownPaths.add(normalized);
        constants.add(
          AppImagesConstant(name: name, assetPath: normalized, line: line),
        );
      }
    }

    return AppImagesParseResult(
      knownPaths: knownPaths,
      knownConstantNames: knownConstantNames,
      constants: constants,
    );
  }

  /// Constants whose paths are outside configured [directories].
  List<AppImagesConstant> unmanagedConstants(
    AppImagesParseResult result,
    List<String> directories,
  ) {
    return result.constants
        .where(
          (AppImagesConstant constant) =>
              !isManagedPath(constant.assetPath, directories),
        )
        .toList();
  }

  /// Removes [pathsToRemove] constant lines from [content].
  String removeConstants(String content, Set<String> pathsToRemove) {
    if (pathsToRemove.isEmpty) {
      return content;
    }

    final AppImagesParseResult parsed = parse(content);
    var updated = content;

    for (final AppImagesConstant constant in parsed.constants) {
      if (!pathsToRemove.contains(constant.assetPath)) {
        continue;
      }

      final String trimmedLine = constant.line.trim();
      final RegExp linePattern = RegExp(
        '^[ \\t]*${RegExp.escape(trimmedLine)}\\r?\\n?',
        multiLine: true,
      );
      updated = updated.replaceFirst(linePattern, '');
    }

    return updated.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  /// Whether [assetPath] is under one of the configured [directories].
  static bool isManagedPath(String assetPath, List<String> directories) {
    final String normalized = assetPath.replaceAll(r'\', '/');
    for (final String directory in directories) {
      final String prefix =
          directory.endsWith('/') ? directory : '$directory/';
      if (normalized.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }

  static String _normalizeAssetPath(String path) {
    return path.replaceAll(r'\', '/').replaceAll('//', '/');
  }
}
