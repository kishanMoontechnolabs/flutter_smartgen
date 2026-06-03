/// Naming helpers for page generation.
class PageNaming {
  PageNaming({
    required this.inputName,
    required this.screenSuffix,
    required this.controllerSuffix,
  }) : featureSnake = _normalizeFeatureSnake(inputName) {
    featurePascal = _toPascalCase(featureSnake.replaceAll('_screen', ''));
    if (featurePascal.isEmpty) {
      featurePascal = _toPascalCase(featureSnake);
    }

    moduleSnake = featureSnake.endsWith('_screen')
        ? featureSnake
        : '${featureSnake}_screen';

    final String featureBase = moduleSnake.replaceAll('_screen', '');

    screenClass = '$featurePascal$screenSuffix';
    controllerClass = '$featurePascal$controllerSuffix';
    repositoryClass = '${featurePascal}ScreenRepository';
    modelClass = '${featurePascal}Model';
    dataClass = '${featurePascal}Data';
    bindingClass = '${featurePascal}ScreenBinding';
    barrelFile = '$featureBase.dart';
    viewFile = '$moduleSnake.dart';
  }

  final String inputName;
  final String screenSuffix;
  final String controllerSuffix;

  final String featureSnake;
  late final String featurePascal;
  late final String moduleSnake;
  late final String screenClass;
  late final String controllerClass;
  late final String repositoryClass;
  late final String modelClass;
  late final String dataClass;
  late final String bindingClass;
  late final String barrelFile;
  late final String viewFile;

  static String _normalizeFeatureSnake(String name) {
    var normalized = name.trim().toLowerCase().replaceAll('-', '_');
    if (normalized.endsWith('_page')) {
      normalized = normalized.substring(0, normalized.length - 5);
    }
    return normalized;
  }

  static String _toPascalCase(String snake) {
    if (snake.isEmpty) {
      return '';
    }
    return snake
        .split('_')
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              part[0].toUpperCase() + (part.length > 1 ? part.substring(1) : ''),
        )
        .join();
  }
}
