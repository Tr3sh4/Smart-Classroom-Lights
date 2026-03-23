# iot_light_control

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Windows quick build fix

If you hit Windows linker/CMake stale-file/permission issues, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows_build_fix.ps1 -ForceClean
```

This removes stale `iot_light_control.exe` and `iot_light_control.ilk`, runs
`flutter clean`, `flutter pub get`, then `flutter run --debug -d windows`.

- An automatic CMake patch is also added in `windows/CMakeLists.txt` to update
  frozen `firebase_cpp_sdk_windows/CMakeLists.txt` from 3.1 to 3.5 so builds
  do not fail due to CMake policy version regression.
- If needed, set the policy override in Windows shell before running:
  `setx CMAKE_POLICY_VERSION_MINIMUM 3.5`.

