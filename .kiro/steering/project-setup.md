---
inclusion: auto
---

# Project Setup

## Godot Console Binary

The Godot 4.6.1 console binary is located at:
```
C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe
```

## Running Tests

Run all property-based tests headlessly:
```
& "C:\Users\User\bin\Godot_v4.6.1-stable_win64_console.exe" --headless --path . -s tests/run_tests.gd
```

Or use the convenience script:
```
.\run_tests.ps1
```

Tests use a lightweight GdUnit4 shim (`tests/helpers/gdunit_shim.gd`) and a custom console runner (`tests/run_tests.gd`). New test files should extend `GdUnitTestSuite` and have method names prefixed with `test_`. Register new test files in the `_test_files` array in `tests/run_tests.gd`.
