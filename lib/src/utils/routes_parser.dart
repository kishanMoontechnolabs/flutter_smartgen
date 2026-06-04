/// Parsed route constant from app_routes.dart.
class ParsedRouteConstant {
  const ParsedRouteConstant({
    required this.name,
    required this.path,
  });

  final String name;
  final String path;
}

/// Parsed GetPage registration from app_pages.dart.
class ParsedGetPage {
  const ParsedGetPage({
    required this.routeConstantName,
  });

  final String routeConstantName;
}

/// Result of parsing router files.
class RoutesParseResult {
  const RoutesParseResult({
    required this.routeConstants,
    required this.getPages,
    required this.existingImports,
  });

  final List<ParsedRouteConstant> routeConstants;
  final List<ParsedGetPage> getPages;
  final Set<String> existingImports;
}

/// Parses app_routes.dart and app_pages.dart for merge logic.
class RoutesParser {
  static final RegExp _routeConstantPattern = RegExp(
    r"static const String (\w+) = '([^']+)';",
  );

  static final RegExp _getPageRoutePattern = RegExp(
    r'name:\s*(\w+)\.(\w+)',
  );

  static final RegExp _importPattern = RegExp(
    r"^import\s+'([^']+)';",
    multiLine: true,
  );

  RoutesParseResult parseRoutesFile(String content) {
    final List<ParsedRouteConstant> constants = <ParsedRouteConstant>[];

    for (final Match match in _routeConstantPattern.allMatches(content)) {
      constants.add(
        ParsedRouteConstant(
          name: match.group(1)!,
          path: match.group(2)!,
        ),
      );
    }

    return RoutesParseResult(
      routeConstants: constants,
      getPages: <ParsedGetPage>[],
      existingImports: <String>{},
    );
  }

  RoutesParseResult parsePagesFile(String content) {
    final Set<String> imports = <String>{};
    for (final Match match in _importPattern.allMatches(content)) {
      imports.add(match.group(1)!);
    }

    final List<ParsedGetPage> getPages = <ParsedGetPage>[];
    for (final Match match in _getPageRoutePattern.allMatches(content)) {
      getPages.add(
        ParsedGetPage(routeConstantName: match.group(2)!),
      );
    }

    return RoutesParseResult(
      routeConstants: <ParsedRouteConstant>[],
      getPages: getPages,
      existingImports: imports,
    );
  }
}
