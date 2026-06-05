import 'package:flutter_smartgen/src/utils/app_file_registry.dart';

/// String templates for lib/app scaffold files.
class AppTemplates {
  AppTemplates({required this.packageName});

  final String packageName;

  String contentFor(AppTemplateKey key) {
    return switch (key) {
      AppTemplateKey.barrel => barrelFile(),
      AppTemplateKey.colors => colorsFile(),
      AppTemplateKey.constants => constantsFile(),
      AppTemplateKey.strings => stringsFile(),
      AppTemplateKey.images => imagesFile(),
      AppTemplateKey.fonts => fontsFile(),
      AppTemplateKey.lists => listsFile(),
      AppTemplateKey.enumFile => enumFile(),
      AppTemplateKey.dialogue => dialogueFile(),
      AppTemplateKey.appClass => appClassFile(),
      AppTemplateKey.translation => translationFile(),
    };
  }

  String barrelFile() {
    return '''
export 'package:flutter/material.dart';
export 'package:get/get.dart';
''';
  }

  String enumFile() {
    return '''
// Add app-wide enums here.
''';
  }

  String translationFile() {
    return '''
import 'package:get/get.dart';

/// App translations (load keys via JSON / assets as needed).
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => <String, Map<String, String>>{};
}
''';
  }

  String appClassFile() {
    return '''
import 'package:$packageName/app/app.dart';

/// Global app state (loading, etc.).
class AppClass {
  factory AppClass() => _singleton;

  AppClass._internal();

  static final AppClass _singleton = AppClass._internal();

  RxBool isLoading = false.obs;
}
''';
  }

  String colorsFile() => _emptyAppClass(
        doc: 'App color constants.',
        className: 'AppColors',
        importBarrel: true,
      );

  String constantsFile() => _emptyAppClass(
        doc: 'App constants.',
        className: 'AppConstants',
        importBarrel: false,
      );

  String stringsFile() => _emptyAppClass(
        doc: 'App strings.',
        className: 'AppStrings',
        importBarrel: false,
      );

  String imagesFile() => _emptyAppClass(
        doc: 'App image asset paths.',
        className: 'AppImages',
        importBarrel: false,
      );

  String fontsFile() => _emptyAppClass(
        doc: 'App fonts and text styles.',
        className: 'AppFonts',
        importBarrel: false,
      );

  String listsFile() => _emptyAppClass(
        doc: 'App list constants.',
        className: 'AppLists',
        importBarrel: false,
      );

  String dialogueFile() => _emptyAppClass(
        doc: 'App dialog helpers.',
        className: 'AppDialogue',
        importBarrel: false,
      );

  String _emptyAppClass({
    required String doc,
    required String className,
    required bool importBarrel,
  }) {
    final String importLine = importBarrel
        ? "import 'package:$packageName/app/app.dart';\n\n"
        : '';
    return '''
$importLine/// $doc
class $className {
  $className._();
}
''';
  }
}
