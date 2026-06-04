# flutter_smartgen

[![pub package](https://img.shields.io/pub/v/flutter_smartgen.svg)](https://pub.dev/packages/flutter_smartgen)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Dart CLI that scaffolds **Flutter feature-module pages** with a consistent **GetX** architecture and syncs **AppImages** from your asset folders. Run `smartgen init` once, then `smartgen page <name>` or `smartgen assets images` from any Flutter project root. Global activation is optional if you add the package as a dev dependency.

---

## Features

- **Project setup** — `smartgen init` creates `smartgen.yaml` from your `pubspec.yaml` package name
- **Page scaffolding** — `smartgen page <name>` generates six Dart files per screen module
- **AppImages** — `smartgen assets images` syncs `lib/app/app_images.dart` from asset folders (add, skip existing, remove deleted files)
- **GetX-ready** — `GetView`, `GetxController`, `Bindings`, and `Get.lazyPut` out of the box
- **Flexible scaffold** — use your shared `CommonScaffold` or default Flutter `Scaffold`
- **Safe re-runs** — existing page files are never overwritten
- **Clean views** — generated screens use `_mainBody()` with a `SizedBox()` placeholder

---

## Installation

Use **either** option below. You do not need both.

### Option 1 — Global activate (CLI everywhere)

```bash
dart pub global activate flutter_smartgen
```

If `smartgen` is not found, add the pub cache to your `PATH`:

**macOS / Linux**

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

**Windows (PowerShell)**

```powershell
$env:Path += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

Verify:

```bash
smartgen --help
```

Run from any Flutter project:

```bash
smartgen init
smartgen page profile
smartgen assets images
```

---

### Option 2 — Project dev dependency (no global activate)

Add to your Flutter app `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_smartgen: ^0.2.0
```

Install and run via `dart run`:

```bash
dart pub get
dart run flutter_smartgen:smartgen init
dart run flutter_smartgen:smartgen page profile
dart run flutter_smartgen:smartgen assets images
```

No PATH setup required. Recommended for teams so everyone uses the same version from `pubspec.lock`.

---

## Quick start

From your **Flutter app root** (where `pubspec.yaml` and `lib/` exist):

**Global CLI**

```bash
smartgen init
smartgen page profile
smartgen assets images
```

**Project dev dependency**

```bash
dart run flutter_smartgen:smartgen init
dart run flutter_smartgen:smartgen page profile
dart run flutter_smartgen:smartgen assets images
```

This creates:

```text
lib/screens/profile_screen/
├── profile.dart                         # barrel exports
├── binding/profile_screen_binding.dart
├── controller/profile_screen_controller.dart
├── resource/
│   ├── model/profile_model.dart
│   └── repository/profile_screen_repository.dart
└── view/profile_screen.dart             # GetView screen UI
```

Wire the new screen in your router (`GetPage` + binding), then build your UI inside `_mainBody()`.

---

## Configuration

`smartgen init` creates `smartgen.yaml` in your project root.

```yaml
package_name: my_app
screens_base: lib/screens

# Optional — use CommonScaffold instead of Scaffold in generated views
common_scaffold:
  import: package:my_app/widgets/common_scaffold.dart
  class_name: CommonScaffold

naming:
  screen_suffix: Screen
  controller_suffix: Controller

assets:
  images:
    output: lib/app/app_images.dart
    class_name: AppImages
    directories:
      - assets/images
      # - assets/icons
```

| Key | Required | Description |
|-----|:--------:|-------------|
| `package_name` | Yes | Dart package name used in generated imports |
| `screens_base` | Yes | Base path for screen modules (e.g. `lib/screens`) |
| `common_scaffold` | No | `import` and `class_name` for a shared scaffold widget |
| `naming` | No | Class name suffixes for screen and controller |
| `assets.images` | No | Asset folders for `smartgen assets images` (see below) |

Each page is generated at `lib/screens/{name}_screen/` under `screens_base`.

---

## Asset images

Generate `AppImages` with one command. Config is at the bottom of `smartgen.yaml` after `smartgen init`.

```bash
smartgen assets images
```

**Setup**

1. Add image files under `assets/images` (and uncomment more paths under `directories` if needed).
2. List those folders in `pubspec.yaml` under `flutter: assets:`.
3. Run the command above.

**Example output**

```dart
class AppImages {
  AppImages._();

  /// Images
  static const String icBack = 'assets/images/ic_back.svg';

  /// Icons
  static const String searchIcon = 'assets/icons/search_icon.svg';
}
```

**What it does**

| Run | Result |
|-----|--------|
| First time | Creates `AppImages` with every file in your folders |
| Again | Adds new files only; skips existing; removes entries when a file was deleted |
| Folders | Add as many paths as you need under `directories` |

Paths are full strings (e.g. `'assets/icons/search_icon.svg'`). Section titles come from the folder name (`assets/icons` → `/// Icons`).

---

## Generated code

**View** — scaffold + empty body:

```dart
class ProfileScreen extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold( // or Scaffold when common_scaffold is not set
      body: _mainBody(context),
    );
  }

  Widget _mainBody(BuildContext context) {
    return const SizedBox();
  }
}
```

**Controller** — repository injection + `onInit`:

```dart
class ProfileController extends GetxController {
  ProfileController(this.repository);

  late ProfileScreenRepository repository;

  @override
  void onInit() {
    super.onInit();
  }
}
```

**Binding** — lazy dependency registration:

```dart
Get
  ..lazyPut<ProfileScreenRepository>(ProfileScreenRepository.new)
  ..lazyPut<ProfileController>(
    () => ProfileController(Get.find<ProfileScreenRepository>()),
  );
```

---

## Commands

| Command (global) | Command (dev dependency) | Description |
|------------------|--------------------------|-------------|
| `smartgen init` | `dart run flutter_smartgen:smartgen init` | Create `smartgen.yaml` (skipped if file exists) |
| `smartgen page <name>` | `dart run flutter_smartgen:smartgen page <name>` | Generate a screen module |
| `smartgen assets images` | `dart run flutter_smartgen:smartgen assets images` | Sync `AppImages` from asset folders |

---

## Naming conventions

| Input | Folder | Barrel file | View file |
|-------|--------|-------------|-----------|
| `profile` | `profile_screen/` | `profile.dart` | `view/profile_screen.dart` |
| `demo` | `demo_screen/` | `demo.dart` | `view/demo_screen.dart` |

Class names follow your `naming` config (default: `ProfileScreen`, `ProfileController`, `ProfileScreenRepository`).

---

## Support

For bugs, feature requests, or questions, [open an issue](https://github.com/kishanMoontechnolabs/flutter_smartgen/issues) on GitHub.

---

## Author

<p align="center">
  <img src="https://github.com/kishanMoontechnolabs.png?size=48" width="48" height="48" alt="Kishan" />
</p>

<p align="center">
  <a href="https://github.com/kishanMoontechnolabs"><strong>Kishan</strong></a>
</p>

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
