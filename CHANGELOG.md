## 0.2.0

### New: `smartgen assets images`

- Generate or update `lib/app/app_images.dart` from folders listed in `smartgen.yaml` → `assets.images.directories`.
- Includes every file in each folder (not only images).
- Constants use full paths, grouped with doc comments per folder (`/// Images`, `/// Icons`, …).
- Re-run safely: adds new files, keeps existing names, removes constants when the file was deleted.
- `smartgen init` writes the `assets.images` block at the bottom of `smartgen.yaml` (`# - assets/icons` is a commented example for extra folders).

### Page scaffolding (unchanged)

- `smartgen init` and `smartgen page <name>` work as in 0.1.x.

## 0.1.1

- Lower Dart SDK constraint to `>=3.2.0 <4.0.0` for broader Flutter compatibility.

## 0.1.0

- Initial release: `smartgen init` and `smartgen page` commands.
- Scaffolds six files per feature module (barrel, binding, controller, repository, model, view).
- Optional `common_scaffold` in `smartgen.yaml` (otherwise uses `Scaffold`).
- Generated views include `_mainBody()` with `SizedBox()` placeholder.
