import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/generators/page_generator.dart';
import 'package:flutter_smartgen/src/templates/route_templates.dart';
import 'package:flutter_smartgen/src/utils/cli_errors.dart';
import 'package:flutter_smartgen/src/utils/file_ops.dart';
import 'package:flutter_smartgen/src/utils/naming_util.dart';
import 'package:flutter_smartgen/src/utils/route_naming_util.dart';
import 'package:flutter_smartgen/src/utils/routes_parser.dart';
import 'package:path/path.dart' as p;

/// Action taken during route registration.
enum RouteWriteAction { added, skipped }

/// One route registration result entry.
class RouteWriteEntry {
  const RouteWriteEntry({
    required this.label,
    required this.action,
  });

  final String label;
  final RouteWriteAction action;
}

/// Result of route registration.
class RouteGenerationResult {
  RouteGenerationResult({
    required this.entries,
  });

  final List<RouteWriteEntry> entries;

  int get addedCount =>
      entries.where((RouteWriteEntry e) => e.action == RouteWriteAction.added).length;

  int get skippedCount =>
      entries.where((RouteWriteEntry e) => e.action == RouteWriteAction.skipped).length;
}

/// Registers GetX routes for a page module.
class RouteGenerator {
  RouteGenerator({
    required this.projectRoot,
    required this.config,
    required this.pageName,
  });

  final Directory projectRoot;
  final SmartgenConfig config;
  final String pageName;

  RouteGenerationResult register() {
    final RoutesConfig routes = config.routes!;
    final PageNaming pageNaming = PageNaming(
      inputName: pageName,
      screenSuffix: config.naming.screenSuffix,
      controllerSuffix: config.naming.controllerSuffix,
    );
    final RouteNaming routeNaming = RouteNaming(
      pageNaming: pageNaming,
      routeNameSuffix: routes.routeNameSuffix,
    );

    final String modulePath = p.join(config.screensBase, pageNaming.moduleSnake);
    final Directory moduleDir = Directory(p.join(projectRoot.path, modulePath));
    if (!moduleDir.existsSync()) {
      throw StateError(
        'Page module not found at ${moduleDir.path}. Run `smartgen page $pageName` first.',
      );
    }

    final String moduleImportPath = PageGenerator.packageImportPath(modulePath);
    final RouteTemplates templates = RouteTemplates(
      config: config,
      routes: routes,
      pageNaming: pageNaming,
      routeNaming: routeNaming,
      moduleImportPath: moduleImportPath,
    );

    final File routesFile = File(p.join(projectRoot.path, routes.routesFile));
    final File pagesFile = File(p.join(projectRoot.path, routes.pagesFile));

    _ensureRouterFiles(
      routesFile: routesFile,
      pagesFile: pagesFile,
      templates: templates,
    );

    final List<RouteWriteEntry> entries = <RouteWriteEntry>[];

    entries.add(_registerRouteConstant(routesFile, templates, routeNaming));
    entries.addAll(_registerGetPage(pagesFile, templates, routes));

    return RouteGenerationResult(entries: entries);
  }

  static RouteGenerationResult? tryRegister({
    required Directory projectRoot,
    required SmartgenConfig config,
    required String pageName,
  }) {
    if (config.routes == null) {
      writeCliError(
        StateError(
          'routes is not configured in smartgen.yaml. '
          'Run `smartgen init` or add a routes block.',
        ),
      );
      return null;
    }

    try {
      return RouteGenerator(
        projectRoot: projectRoot,
        config: config,
        pageName: pageName,
      ).register();
    } on Object catch (error) {
      if (isExpectedCliError(error)) {
        writeCliError(error);
        return null;
      }
      rethrow;
    }
  }

  void _ensureRouterFiles({
    required File routesFile,
    required File pagesFile,
    required RouteTemplates templates,
  }) {
    routesFile.parent.createSync(recursive: true);

    if (!routesFile.existsSync()) {
      FileOps.writeNewFile(
        file: routesFile,
        content: templates.routesFileScaffold(),
      );
    }

    if (!pagesFile.existsSync()) {
      FileOps.writeNewFile(
        file: pagesFile,
        content: templates.pagesFileScaffold(),
      );
    }
  }

  RouteWriteEntry _registerRouteConstant(
    File routesFile,
    RouteTemplates templates,
    RouteNaming routeNaming,
  ) {
    final RoutesParser parser = RoutesParser();
    final String content = routesFile.readAsStringSync();
    final RoutesParseResult parsed = parser.parseRoutesFile(content);

    final bool nameExists = parsed.routeConstants.any(
      (ParsedRouteConstant c) => c.name == routeNaming.routeConstantName,
    );
    final bool pathExists = parsed.routeConstants.any(
      (ParsedRouteConstant c) => c.path == routeNaming.routePath,
    );

    if (nameExists || pathExists) {
      return RouteWriteEntry(
        label: '${routeNaming.routeConstantName} (${routeNaming.routePath})',
        action: RouteWriteAction.skipped,
      );
    }

    FileOps.appendBeforeClosingBrace(
      file: routesFile,
      contentToAppend: templates.routeConstantLine(),
    );

    return RouteWriteEntry(
      label: '${routeNaming.routeConstantName} (${routeNaming.routePath})',
      action: RouteWriteAction.added,
    );
  }

  List<RouteWriteEntry> _registerGetPage(
    File pagesFile,
    RouteTemplates templates,
    RoutesConfig routes,
  ) {
    final RoutesParser parser = RoutesParser();
    final String content = pagesFile.readAsStringSync();
    final RoutesParseResult parsed = parser.parsePagesFile(content);

    final bool getPageExists = parsed.getPages.any(
      (ParsedGetPage page) =>
          page.routeConstantName == templates.routeNaming.routeConstantName,
    );

    if (getPageExists) {
      return <RouteWriteEntry>[
        RouteWriteEntry(
          label:
              'GetPage ${routes.routesClass}.${templates.routeNaming.routeConstantName}',
          action: RouteWriteAction.skipped,
        ),
      ];
    }

    FileOps.addImportIfMissing(
      file: pagesFile,
      importLine: templates.bindingImport(),
    );
    FileOps.addImportIfMissing(
      file: pagesFile,
      importLine: templates.viewImport(),
    );

    FileOps.appendBeforeListClosing(
      file: pagesFile,
      contentToAppend: templates.getPageBlock(),
    );

    return <RouteWriteEntry>[
      RouteWriteEntry(
        label:
            'GetPage ${routes.routesClass}.${templates.routeNaming.routeConstantName}',
        action: RouteWriteAction.added,
      ),
    ];
  }
}
