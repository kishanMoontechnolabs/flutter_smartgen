# flutter_smartgen example

Minimal Flutter app for testing the CLI from scratch.

This example uses **[GetX](https://pub.dev/packages/get)** for state management and dependency injection. Generated screen modules follow GetX patterns:

- `GetMaterialApp` in `main.dart`
- `GetView<Controller>` for views
- `GetxController` for controllers
- `Bindings` + `Get.lazyPut` for DI

Add GetX to your app before using generated code:

```yaml
dependencies:
  get: ^4.6.6
```

## Included

| Path | Purpose |
|------|---------|
| [`lib/widgets/common_scaffold.dart`](lib/widgets/common_scaffold.dart) | Optional shared scaffold — reference in `smartgen.yaml` after `init` |
| [`lib/main.dart`](lib/main.dart) | Empty starter UI with CLI steps |

No `smartgen.yaml` or generated screens — you create them with the commands below.

## Test the CLI

The example depends on `flutter_smartgen` via `path: ..` in `pubspec.yaml`.

From this folder:

```bash
flutter pub get

# 1. Create smartgen.yaml (package_name from example/pubspec.yaml)
dart run flutter_smartgen:smartgen init

# 2. Enable CommonScaffold in smartgen.yaml (uncomment and set):
#    common_scaffold:
#      import: package:flutter_smartgen_example/widgets/common_scaffold.dart
#      class_name: CommonScaffold

# 3. Generate a page module
dart run flutter_smartgen:smartgen page demo
```

Alternative (repo root binary): `dart run ../bin/smartgen.dart init`

Output:

```text
lib/screens/demo_screen/
  demo.dart                         # barrel exports
  binding/demo_screen_binding.dart
  controller/demo_screen_controller.dart
  resource/repository/demo_screen_repository.dart
  resource/model/demo_model.dart
  view/demo_screen.dart             # screen UI
```

## Run the app

After generation, wire the new screen in `lib/main.dart` using GetX navigation and binding:

```dart
Get.to<void>(
  () => const DemoScreen(),
  binding: DemoScreenBinding(),
);
```

Then:

```bash
flutter run
```

## One-liner from repo root

```bash
./tool/try_example.sh
```

Runs `init` and `page demo` in this directory.
