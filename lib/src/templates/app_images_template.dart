import 'package:flutter_smartgen/src/utils/app_images_parser.dart';
import 'package:flutter_smartgen/src/utils/asset_section_util.dart';

/// String templates for generated AppImages files.
class AppImagesTemplate {
  String fullClass({
    required String className,
    required List<AppImagesEntry> entries,
    required List<String> directoryOrder,
    List<AppImagesConstant> unmanagedConstants = const <AppImagesConstant>[],
  }) {
    return _buildClass(
      className: className,
      unmanagedConstants: unmanagedConstants,
      managedEntries: entries,
      directoryOrder: directoryOrder,
    );
  }

  String _buildClass({
    required String className,
    required List<AppImagesConstant> unmanagedConstants,
    required List<AppImagesEntry> managedEntries,
    required List<String> directoryOrder,
  }) {
    final StringBuffer buffer = StringBuffer()
      ..writeln(
        '/// This $className class holds the paths of all image assets used',
      )
      ..writeln('/// in the application.')
      ..writeln('///')
      ..writeln('/// It ensures a centralized and consistent way to reference image')
      ..writeln('/// assets.')
      ..writeln('class $className {')
      ..writeln('  $className._();')
      ..writeln();

    for (final AppImagesConstant constant in unmanagedConstants) {
      buffer.writeln('  ${constant.line.trim()}');
    }

    if (unmanagedConstants.isNotEmpty && managedEntries.isNotEmpty) {
      buffer.writeln();
    }

    _writeGroupedEntries(
      buffer: buffer,
      entries: managedEntries,
      directoryOrder: directoryOrder,
    );

    buffer.writeln('}');
    return buffer.toString();
  }

  void _writeGroupedEntries({
    required StringBuffer buffer,
    required List<AppImagesEntry> entries,
    required List<String> directoryOrder,
  }) {
    if (entries.isEmpty) {
      return;
    }

    final List<AppImagesEntry> sorted = List<AppImagesEntry>.from(entries)
      ..sort((AppImagesEntry a, AppImagesEntry b) {
        final int directoryCompare = directoryOrder
            .indexOf(a.directory)
            .compareTo(directoryOrder.indexOf(b.directory));
        if (directoryCompare != 0) {
          return directoryCompare;
        }
        return a.assetPath.compareTo(b.assetPath);
      });

    String? currentDirectory;
    for (final AppImagesEntry entry in sorted) {
      if (entry.directory != currentDirectory) {
        if (currentDirectory != null) {
          buffer.writeln();
        }
        buffer.writeln(
          '  /// ${AssetSectionUtil.titleForDirectory(entry.directory)}',
        );
        currentDirectory = entry.directory;
      }
      buffer.writeln(
        "  static const String ${entry.constantName} = '${entry.assetPath}';",
      );
    }
  }
}

/// One generated AppImages constant entry.
class AppImagesEntry {
  const AppImagesEntry({
    required this.constantName,
    required this.assetPath,
    required this.directory,
  });

  final String constantName;
  final String assetPath;
  final String directory;
}
