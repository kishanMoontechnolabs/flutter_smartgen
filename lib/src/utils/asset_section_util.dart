/// Derives section doc-comment titles from asset directory paths.
class AssetSectionUtil {
  /// Returns a title for [directory] (e.g. `assets/images` → `Images`).
  static String titleForDirectory(String directory) {
    final String normalized = directory.replaceAll(r'\', '/');
    final List<String> segments = normalized
        .split('/')
        .where((String segment) => segment.isNotEmpty)
        .toList();

    if (segments.isEmpty) {
      return _titleCase(normalized);
    }

    return _titleCase(segments.last);
  }

  static String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}
