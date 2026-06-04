/// Converts asset file names to Dart constant identifiers.
class AssetNamingUtil {
  /// Converts [fileName] (e.g. `search_icon.svg`) to camelCase (e.g. `searchIcon`).
  static String toConstantName(String fileName) {
    var name = fileName;
    final int dotIndex = name.lastIndexOf('.');
    if (dotIndex > 0) {
      name = name.substring(0, dotIndex);
    }

    final RegExp iconWithDigits = RegExp(r'^(.*)_icon_(\d+)$');
    final Match? digitsMatch = iconWithDigits.firstMatch(name);
    if (digitsMatch != null) {
      final String prefix = digitsMatch.group(1)!;
      final String digits = digitsMatch.group(2)!;
      return '${_snakeToCamelCase(prefix)}${digits}Icon';
    }

    if (name.endsWith('_icon')) {
      name = name.substring(0, name.length - 5);
      return '${_snakeToCamelCase(name)}Icon';
    }

    return _snakeToCamelCase(name);
  }

  /// Returns a unique constant name not present in [usedNames].
  static String uniqueConstantName({
    required String fileName,
    required Set<String> usedNames,
  }) {
    var candidate = toConstantName(fileName);
    if (!usedNames.contains(candidate)) {
      return candidate;
    }

    var suffix = 2;
    while (usedNames.contains('${candidate}_$suffix')) {
      suffix++;
    }
    return '${candidate}_$suffix';
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
