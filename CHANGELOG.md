## 0.5.0

### New: `smartgen app`

- Scaffold `lib/app/` files aligned with common GetX app structure (11 files).
- `smartgen app` — create all missing files; `smartgen app <name>` — one file (e.g. `fonts`, `class`).
- Skip-if-exists: never overwrites existing files.
- `AppClass` includes singleton + `RxBool isLoading = false.obs`; other classes are empty shells.

## 0.4.0

### New: `smartgen env`

- Create `.env.development` and `.env.production` at the Flutter project root.
- Each file includes `BASE_URL` and `API_KEY` placeholders (empty values).
- Skip-if-exists: never overwrites an existing env file.

## 0.3.0

### New: route registration

- `smartgen route <page>` — merge-only registration of `AppRoutes` constant and `GetPage` for an existing page module.
- `smartgen page <name> --route` — generate the page module, then register the route in one step.

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
