# Input Actions Editor

**WIP** beta

![screenshot](https://github.com/Luwx/InputActionsEditor/blob/main/screenshot.png)

A GUI config editor app for [Input Actions](https://github.com/taj-ny/InputActions).

## What it can do (so far)

- Edit the trigger types
- Edit the action types
- Group gestures and reorder them so things are easier to find
- Multiple actions on a single gesture
- Nested conditions for triggers and actions
- Stroke path visualization
- Conflict detection

## Building

You'll need the Flutter SDK installed and set up for Linux desktop builds.

First grab the dependencies:

```sh
flutter pub get
```

To just run it during development:

```sh
flutter run -d linux
```

To build a release binary:

```sh
flutter build linux --release
```

The built app ends up in `build/linux/x64/release/bundle/`.
