#!/usr/bin/env bash
# Sourced by the other scripts — do not run directly.

APP_ID=dev.luwx.input_actions_editor
APP_NAME=input-actions-editor
BINARY_NAME=input_actions_editor

# Allow callers (e.g. the release workflow) to pin VERSION from the git tag;
# otherwise derive it from pubspec.yaml.
VERSION="${VERSION:-$(grep '^version:' pubspec.yaml | sed 's/version: //;s/+.*//' | tr -d '[:space:]')}"

BUNDLE=build/linux/x64/release/bundle
STAGE=packaging/stage
APPDIR=packaging/AppDir
