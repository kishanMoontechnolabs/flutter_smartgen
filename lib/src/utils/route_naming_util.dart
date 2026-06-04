import 'package:flutter_smartgen/src/utils/naming_util.dart';

/// Route constant and path names derived from page naming.
class RouteNaming {
  RouteNaming({
    required PageNaming pageNaming,
    required String routeNameSuffix,
  })  : routeConstantName = _routeConstantName(pageNaming, routeNameSuffix),
        routePath = _routePath(pageNaming);

  final String routeConstantName;
  final String routePath;

  static String _featureBase(PageNaming pageNaming) {
    return pageNaming.moduleSnake.replaceAll('_screen', '');
  }

  static String _routeConstantName(
    PageNaming pageNaming,
    String routeNameSuffix,
  ) {
    final String base = _featureBase(pageNaming);
    final String camel = _snakeToCamelCase(base);
    if (camel.isEmpty) {
      return routeNameSuffix.toLowerCase();
    }
    final String firstLower =
        camel[0].toLowerCase() + (camel.length > 1 ? camel.substring(1) : '');
    return '$firstLower$routeNameSuffix';
  }

  static String _routePath(PageNaming pageNaming) {
    final String base = _featureBase(pageNaming);
    return '/$base';
  }

  static String _snakeToCamelCase(String snake) {
    final List<String> parts =
        snake.split('_').where((String part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '';
    }

    final StringBuffer buffer = StringBuffer(parts.first);
    for (final String part in parts.skip(1)) {
      buffer
        ..write(part[0].toUpperCase())
        ..write(part.length > 1 ? part.substring(1) : '');
    }
    return buffer.toString();
  }
}
