import 'dart:io';

import 'package:flutter_smartgen/src/config/smartgen_config.dart';
import 'package:flutter_smartgen/src/templates/app_images_template.dart';
import 'package:flutter_smartgen/src/utils/app_images_parser.dart';
import 'package:flutter_smartgen/src/utils/asset_naming_util.dart';
import 'package:flutter_smartgen/src/utils/asset_scanner.dart';
import 'package:flutter_smartgen/src/utils/file_ops.dart';
import 'package:path/path.dart' as p;

/// Action taken for one asset during generation.
enum AppImagesEntryAction { added, skipped, removed }

/// One asset constant added, skipped, or removed during generation.
class AppImagesWriteEntry {
  const AppImagesWriteEntry({
    required this.constantName,
    required this.assetPath,
    required this.action,
  });

  final String constantName;
  final String assetPath;
  final AppImagesEntryAction action;
}

/// Result of generating or merging AppImages.
class AppImagesGenerationResult {
  AppImagesGenerationResult({
    required this.outputPath,
    required this.createdFile,
    required this.entries,
  });

  final String outputPath;
  final bool createdFile;
  final List<AppImagesWriteEntry> entries;

  int get addedCount => entries
      .where((AppImagesWriteEntry e) => e.action == AppImagesEntryAction.added)
      .length;

  int get skippedCount => entries
      .where((AppImagesWriteEntry e) => e.action == AppImagesEntryAction.skipped)
      .length;

  int get removedCount => entries
      .where((AppImagesWriteEntry e) => e.action == AppImagesEntryAction.removed)
      .length;
}

/// Generates or incrementally updates AppImages from scanned asset folders.
class AppImagesGenerator {
  AppImagesGenerator({
    required this.projectRoot,
    required this.assetsImages,
  });

  final Directory projectRoot;
  final AssetsImagesConfig assetsImages;

  AppImagesGenerationResult generate() {
    final File outputFile = File(
      p.join(projectRoot.path, assetsImages.output),
    );
    final AssetScanner scanner = AssetScanner(
      projectRoot: projectRoot,
      directories: assetsImages.directories,
    );
    final List<ScannedAsset> scanned = scanner.scan();
    final Set<String> scannedPaths = scanned
        .map((ScannedAsset asset) => asset.assetPath.replaceAll(r'\', '/'))
        .toSet();

    final AppImagesTemplate template = AppImagesTemplate();
    final AppImagesParser parser = AppImagesParser();

    if (!outputFile.existsSync()) {
      final List<AppImagesEntry> entries = _buildManagedEntries(
        scanned: scanned,
        existing: null,
      );

      final String content = template.fullClass(
        className: assetsImages.className,
        entries: entries,
        directoryOrder: assetsImages.directories,
      );

      FileOps.writeNewFile(file: outputFile, content: content);

      return AppImagesGenerationResult(
        outputPath: outputFile.path,
        createdFile: true,
        entries: entries
            .map(
              (AppImagesEntry entry) => AppImagesWriteEntry(
                constantName: entry.constantName,
                assetPath: entry.assetPath,
                action: AppImagesEntryAction.added,
              ),
            )
            .toList(),
      );
    }

    final AppImagesParseResult existing = parser.parse(
      outputFile.readAsStringSync(),
    );

    final Set<String> pathsToRemove = existing.constants
        .where(
          (AppImagesConstant constant) =>
              AppImagesParser.isManagedPath(
                constant.assetPath,
                assetsImages.directories,
              ) &&
              !scannedPaths.contains(constant.assetPath),
        )
        .map((AppImagesConstant constant) => constant.assetPath)
        .toSet();

    final Set<String> pathsToAdd = scannedPaths.difference(existing.knownPaths);

    final List<AppImagesWriteEntry> results = <AppImagesWriteEntry>[
      for (final AppImagesConstant constant in existing.constants)
        if (pathsToRemove.contains(constant.assetPath))
          AppImagesWriteEntry(
            constantName: constant.name,
            assetPath: constant.assetPath,
            action: AppImagesEntryAction.removed,
          ),
      for (final ScannedAsset asset in scanned)
        AppImagesWriteEntry(
          constantName: _findConstantName(asset.assetPath, existing),
          assetPath: asset.assetPath,
          action: pathsToAdd.contains(asset.assetPath.replaceAll(r'\', '/'))
              ? AppImagesEntryAction.added
              : AppImagesEntryAction.skipped,
        ),
    ];

    if (pathsToRemove.isNotEmpty || pathsToAdd.isNotEmpty) {
      final List<AppImagesConstant> unmanagedConstants =
          parser.unmanagedConstants(
        existing,
        assetsImages.directories,
      );
      final List<AppImagesEntry> managedEntries = _buildManagedEntries(
        scanned: scanned,
        existing: existing,
      );

      final String content = template.fullClass(
        className: assetsImages.className,
        entries: managedEntries,
        directoryOrder: assetsImages.directories,
        unmanagedConstants: unmanagedConstants,
      );

      outputFile.parent.createSync(recursive: true);
      outputFile.writeAsStringSync(content);
    }

    return AppImagesGenerationResult(
      outputPath: outputFile.path,
      createdFile: false,
      entries: results,
    );
  }

  List<AppImagesEntry> _buildManagedEntries({
    required List<ScannedAsset> scanned,
    required AppImagesParseResult? existing,
  }) {
    final Set<String> reservedNames = <String>{
      if (existing != null) ...existing.knownConstantNames,
    };
    final List<AppImagesEntry> entries = <AppImagesEntry>[];

    for (final ScannedAsset asset in scanned) {
      final String normalizedPath = asset.assetPath.replaceAll(r'\', '/');
      final String? existingName = existing == null
          ? null
          : _findConstantName(normalizedPath, existing);

      final String constantName = existingName ??
          AssetNamingUtil.uniqueConstantName(
            fileName: asset.fileName,
            usedNames: reservedNames,
          );
      reservedNames.add(constantName);

      entries.add(
        AppImagesEntry(
          constantName: constantName,
          assetPath: normalizedPath,
          directory: asset.directory,
        ),
      );
    }

    return entries;
  }

  String _findConstantName(
    String assetPath,
    AppImagesParseResult existing,
  ) {
    final String normalizedPath = assetPath.replaceAll(r'\', '/');
    for (final AppImagesConstant constant in existing.constants) {
      if (constant.assetPath == normalizedPath) {
        return constant.name;
      }
    }

    return AssetNamingUtil.toConstantName(p.basename(assetPath));
  }
}
