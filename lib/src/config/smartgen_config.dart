import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Optional CommonScaffold widget configuration from smartgen.yaml.
class CommonScaffoldConfig {
  const CommonScaffoldConfig({
    required this.import,
    required this.className,
  });

  final String import;
  final String className;

  bool get isConfigured => import.isNotEmpty && className.isNotEmpty;
}

/// Image asset generation settings from smartgen.yaml.
class AssetsImagesConfig {
  AssetsImagesConfig({
    this.output = 'lib/app/app_images.dart',
    this.className = 'AppImages',
    this.directories = const <String>[
      'assets/images',
      'assets/icons',
    ],
  });

  final String output;
  final String className;
  final List<String> directories;

  bool get isConfigured => directories.isNotEmpty;
}

/// Naming conventions from smartgen.yaml.
class NamingConfig {
  const NamingConfig({
    this.screenSuffix = 'Screen',
    this.controllerSuffix = 'Controller',
  });

  final String screenSuffix;
  final String controllerSuffix;
}

/// Parsed smartgen.yaml for the target Flutter project.
class SmartgenConfig {
  SmartgenConfig({
    required this.packageName,
    required this.screensBase,
    required this.naming,
    this.commonScaffold,
    this.assetsImages,
    required this.configDirectory,
  });

  final String packageName;
  final String screensBase;
  final NamingConfig naming;
  final CommonScaffoldConfig? commonScaffold;
  final AssetsImagesConfig? assetsImages;
  final String configDirectory;

  static const String fileName = 'smartgen.yaml';

  /// Loads [SmartgenConfig] from [directory]/smartgen.yaml.
  static SmartgenConfig load(Directory directory) {
    final File file = File(p.join(directory.path, fileName));
    if (!file.existsSync()) {
      throw StateError(
        'smartgen.yaml not found. Run `smartgen init` in your Flutter project root first.',
      );
    }

    final dynamic doc = loadYaml(file.readAsStringSync());
    if (doc is! YamlMap) {
      throw FormatException('Invalid $fileName: expected a YAML map at the root.');
    }

    final String? packageName = _string(doc, 'package_name');
    final String? screensBase = _string(doc, 'screens_base');

    if (packageName == null || packageName.isEmpty) {
      throw FormatException('smartgen.yaml: package_name is required.');
    }
    if (screensBase == null || screensBase.isEmpty) {
      throw FormatException('smartgen.yaml: screens_base is required.');
    }

    CommonScaffoldConfig? commonScaffold;
    final dynamic scaffoldNode = doc['common_scaffold'];
    if (scaffoldNode is YamlMap) {
      final String import = _string(scaffoldNode, 'import') ?? '';
      final String className = _string(scaffoldNode, 'class_name') ?? '';
      if (import.isNotEmpty && className.isNotEmpty) {
        commonScaffold = CommonScaffoldConfig(
          import: import,
          className: className,
        );
      }
    }

    NamingConfig naming = const NamingConfig();
    final dynamic namingNode = doc['naming'];
    if (namingNode is YamlMap) {
      naming = NamingConfig(
        screenSuffix: _string(namingNode, 'screen_suffix') ?? 'Screen',
        controllerSuffix:
            _string(namingNode, 'controller_suffix') ?? 'Controller',
      );
    }

    AssetsImagesConfig? assetsImages;
    final dynamic assetsNode = doc['assets'];
    if (assetsNode is YamlMap) {
      final dynamic imagesNode = assetsNode['images'];
      if (imagesNode is YamlMap) {
        assetsImages = _parseAssetsImages(imagesNode);
      }
    }

    if (doc.containsKey('exports')) {
      stderr.writeln(
        'Warning: smartgen.yaml contains deprecated "exports" key; it is ignored.',
      );
    }

    return SmartgenConfig(
      packageName: packageName,
      screensBase: screensBase,
      naming: naming,
      commonScaffold: commonScaffold,
      assetsImages: assetsImages,
      configDirectory: directory.path,
    );
  }

  static AssetsImagesConfig _parseAssetsImages(YamlMap imagesNode) {
    final List<String> directories = _stringList(imagesNode, 'directories');

    if (imagesNode.containsKey('extensions')) {
      stderr.writeln(
        'Warning: smartgen.yaml assets.images.extensions is deprecated and ignored; all files are included.',
      );
    }

    return AssetsImagesConfig(
      output: _string(imagesNode, 'output') ?? 'lib/app/app_images.dart',
      className: _string(imagesNode, 'class_name') ?? 'AppImages',
      directories: directories.isEmpty
          ? const <String>['assets/images', 'assets/icons']
          : directories,
    );
  }

  static List<String> _stringList(YamlMap map, String key) {
    final dynamic value = map[key];
    if (value is! YamlList) {
      return <String>[];
    }
    return value.map((dynamic item) => item.toString()).toList();
  }

  static String? _string(YamlMap map, String key) {
    final dynamic value = map[key];
    if (value == null) {
      return null;
    }
    return value.toString();
  }
}
