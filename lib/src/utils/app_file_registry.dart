/// Template key for a generated lib/app file.
enum AppTemplateKey {
  barrel,
  colors,
  constants,
  strings,
  images,
  fonts,
  lists,
  enumFile,
  dialogue,
  appClass,
  translation,
}

/// One scaffolds file under lib/app/.
class AppFileEntry {
  const AppFileEntry({
    required this.cliName,
    required this.relativePath,
    required this.templateKey,
  });

  final String cliName;
  final String relativePath;
  final AppTemplateKey templateKey;
}

/// Registry of smartgen app scaffold files.
class AppFileRegistry {
  AppFileRegistry._();

  static const String appBase = 'lib/app';

  static const List<AppFileEntry> entries = <AppFileEntry>[
    AppFileEntry(
      cliName: 'barrel',
      relativePath: '$appBase/app.dart',
      templateKey: AppTemplateKey.barrel,
    ),
    AppFileEntry(
      cliName: 'colors',
      relativePath: '$appBase/app_colors.dart',
      templateKey: AppTemplateKey.colors,
    ),
    AppFileEntry(
      cliName: 'constants',
      relativePath: '$appBase/app_constants.dart',
      templateKey: AppTemplateKey.constants,
    ),
    AppFileEntry(
      cliName: 'strings',
      relativePath: '$appBase/app_strings.dart',
      templateKey: AppTemplateKey.strings,
    ),
    AppFileEntry(
      cliName: 'images',
      relativePath: '$appBase/app_images.dart',
      templateKey: AppTemplateKey.images,
    ),
    AppFileEntry(
      cliName: 'fonts',
      relativePath: '$appBase/app_fonts.dart',
      templateKey: AppTemplateKey.fonts,
    ),
    AppFileEntry(
      cliName: 'lists',
      relativePath: '$appBase/app_lists.dart',
      templateKey: AppTemplateKey.lists,
    ),
    AppFileEntry(
      cliName: 'enum',
      relativePath: '$appBase/app_enum.dart',
      templateKey: AppTemplateKey.enumFile,
    ),
    AppFileEntry(
      cliName: 'dialogue',
      relativePath: '$appBase/app_dialogue.dart',
      templateKey: AppTemplateKey.dialogue,
    ),
    AppFileEntry(
      cliName: 'class',
      relativePath: '$appBase/app_class.dart',
      templateKey: AppTemplateKey.appClass,
    ),
    AppFileEntry(
      cliName: 'translation',
      relativePath: '$appBase/app_translation.dart',
      templateKey: AppTemplateKey.translation,
    ),
  ];

  static List<String> get cliNames =>
      entries.map((AppFileEntry e) => e.cliName).toList();

  static AppFileEntry? find(String cliName) {
    for (final AppFileEntry entry in entries) {
      if (entry.cliName == cliName) {
        return entry;
      }
    }
    return null;
  }
}
