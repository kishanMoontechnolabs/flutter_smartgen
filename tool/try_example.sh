#!/usr/bin/env bash
# Initialize smartgen and generate a demo page in the example app.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/example"
echo "==> flutter pub get (example)"
flutter pub get
echo "==> smartgen init"
dart run flutter_smartgen:smartgen init
echo "==> smartgen page demo"
dart run flutter_smartgen:smartgen page demo
echo "==> Done. Uncomment common_scaffold in smartgen.yaml, then: cd example && flutter analyze"
