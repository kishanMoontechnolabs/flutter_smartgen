import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/utils/naming_util.dart';

/// String templates for generated page files.
class PageTemplates {
  PageTemplates({
    required this.config,
    required this.naming,
    required this.moduleImportPath,
  });

  final SmartgenConfig config;
  final PageNaming naming;
  final String moduleImportPath;

  String get _package => config.packageName;

  String barrelFile() {
    final StringBuffer exports = StringBuffer()
      ..writeln("export 'package:flutter/material.dart';")
      ..writeln("export 'package:get/get.dart';")
      ..writeln(
        "export 'package:$_package/$moduleImportPath/controller/${naming.moduleSnake}_controller.dart';",
      )
      ..writeln(
        "export 'package:$_package/$moduleImportPath/resource/model/${_modelFileName()}';",
      )
      ..writeln(
        "export 'package:$_package/$moduleImportPath/resource/repository/${naming.moduleSnake}_repository.dart';",
      );

    final CommonScaffoldConfig? scaffold = config.commonScaffold;
    if (scaffold != null && scaffold.isConfigured) {
      exports.writeln("export '${scaffold.import}';");
    }

    return '''
$exports''';
  }

  String viewFile() {
    final bool useCommonScaffold =
        config.commonScaffold?.isConfigured ?? false;
    final String scaffoldWidget =
        useCommonScaffold ? config.commonScaffold!.className : 'Scaffold';

    return '''
import 'package:$_package/$moduleImportPath/${naming.barrelFile}';

/// Screen for the ${naming.featureSnake.replaceAll('_', ' ')} feature.
class ${naming.screenClass} extends GetView<${naming.controllerClass}> {
  const ${naming.screenClass}({super.key});

  @override
  Widget build(BuildContext context) {
    return $scaffoldWidget(
      body: _mainBody(context),
    );
  }

  /// Builds the primary body of the ${naming.featureSnake.replaceAll('_', ' ')} screen.
  Widget _mainBody(BuildContext context) {
    return const SizedBox();
  }
}
''';
  }

  String controllerFile() {
    return '''
import 'package:$_package/$moduleImportPath/${naming.barrelFile}';

/// Controller for the ${naming.featureSnake.replaceAll('_', ' ')} screen.
class ${naming.controllerClass} extends GetxController {
  ${naming.controllerClass}(this.repository);

  late ${naming.repositoryClass} repository;

  @override
  void onInit() {
    super.onInit();
  }
}
''';
  }

  String repositoryFile() {
    return '''
/// Repository for ${naming.featureSnake.replaceAll('_', ' ')} data operations.
class ${naming.repositoryClass} {
  ${naming.repositoryClass}();
}
''';
  }

  String modelFile() {
    return '''
class ${naming.modelClass} {
  ${naming.modelClass}({num? code, String? message, ${naming.dataClass}? response}) {
    _code = code;
    _message = message;
    _response = response;
  }

  ${naming.modelClass}.fromJson(dynamic json) {
    _code = json['code'];
    _message = json['message'];
    _response = json['response'] != null
        ? ${naming.dataClass}.fromJson(json['response'])
        : null;
  }

  num? _code;
  String? _message;
  ${naming.dataClass}? _response;

  ${naming.modelClass} copyWith({
    num? code,
    String? message,
    ${naming.dataClass}? response,
  }) =>
      ${naming.modelClass}(
        code: code ?? _code,
        message: message ?? _message,
        response: response ?? _response,
      );

  num? get code => _code;

  String? get message => _message;

  ${naming.dataClass}? get response => _response;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['code'] = _code;
    map['message'] = _message;
    if (_response != null) {
      map['response'] = _response?.toJson();
    }
    return map;
  }
}

class ${naming.dataClass} {
  ${naming.dataClass}();

  ${naming.dataClass}.fromJson(dynamic json);

  Map<String, dynamic> toJson() => <String, dynamic>{};
}
''';
  }

  String bindingFile() {
    return '''
import 'package:$_package/$moduleImportPath/${naming.barrelFile}';

/// GetX binding for the ${naming.screenClass} module.
class ${naming.bindingClass} extends Bindings {
  ${naming.bindingClass}();

  @override
  void dependencies() {
    Get
      ..lazyPut<${naming.repositoryClass}>(${naming.repositoryClass}.new)
      ..lazyPut<${naming.controllerClass}>(
        () => ${naming.controllerClass}(Get.find<${naming.repositoryClass}>()),
      );
  }
}
''';
  }

  String _modelFileName() {
    final String base = naming.moduleSnake.replaceAll('_screen', '');
    return '${base}_model.dart';
  }
}
