import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/utils/naming_util.dart';
import 'package:flutter_smartgen/src/utils/route_naming_util.dart';

/// String templates for router files.
class RouteTemplates {
  RouteTemplates({
    required this.config,
    required this.routes,
    required this.pageNaming,
    required this.routeNaming,
    required this.moduleImportPath,
  });

  final SmartgenConfig config;
  final RoutesConfig routes;
  final PageNaming pageNaming;
  final RouteNaming routeNaming;
  final String moduleImportPath;

  String routesFileScaffold() {
    return '''
/// Route name constants for the application.
class ${routes.routesClass} {
  ${routes.routesClass}._();
}
''';
  }

  String pagesFileScaffold() {
    final String routesImport = _packageImport(routes.routesFile);
    return '''
import 'package:get/get.dart';
import 'package:${config.packageName}/$routesImport';

/// Application pages and GetX route bindings.
class ${routes.pagesClass} {
  ${routes.pagesClass}._();

  static final List<GetPage<dynamic>> getPages = <GetPage<dynamic>>[
  ];
}
''';
  }

  String routeConstantLine() {
    return "  static const String ${routeNaming.routeConstantName} = '${routeNaming.routePath}';";
  }

  String bindingImport() {
    return "import 'package:${config.packageName}/$moduleImportPath/binding/${pageNaming.moduleSnake}_binding.dart';";
  }

  String viewImport() {
    return "import 'package:${config.packageName}/$moduleImportPath/view/${pageNaming.viewFile}';";
  }

  String getPageBlock() {
    return '''
    GetPage<dynamic>(
      name: ${routes.routesClass}.${routeNaming.routeConstantName},
      binding: ${pageNaming.bindingClass}(),
      page: () => const ${pageNaming.screenClass}(),
    ),
''';
  }

  String _packageImport(String filePath) {
    final String normalized = filePath.replaceAll(r'\', '/');
    if (normalized.startsWith('lib/')) {
      return normalized.substring(4);
    }
    return normalized;
  }
}
