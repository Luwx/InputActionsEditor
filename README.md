<h1 align="center">Input Actions Editor</h1>

A GUI config editor for [Input Actions](https://github.com/taj-ny/InputActions).

![screenshot](screenshot.png)


## Features

- Schema-aware editing. Each trigger and action shows only the fields that apply to it.
- Stroke recording and path visualization, recorded from the daemon over D-Bus.
- Plasma shortcut picker.
- Action types: run a command, send input, trigger a Plasma shortcut, sleep, or a raw passthrough.
- Multiple actions per gesture, run in order.
- Grouping and reordering for long gesture lists.
- Nested conditions on both triggers and actions.
- Conflict detection while editing.

## Building

You'll need the Flutter SDK installed and set up for Linux desktop builds.

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d linux
```

Release build (output lands in `build/linux/x64/release/bundle/`):

```sh
flutter build linux --release
```

### KDE helpers

The `kde_icon_lookup` and `kde_key_lookup` helpers need Qt 6 and KDE Frameworks 6 to compile. They are optional: without these libraries the build skips them and the app still runs, just without native KDE icon and key resolution. On Fedora:

```sh
sudo dnf install qt6-qtbase-devel kf6-kiconthemes-devel kf6-kservice-devel
```