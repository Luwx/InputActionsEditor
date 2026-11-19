/// Editor keys on the item itself, from before `_extra`. Delete to drop them.
library;

import 'package:yaml/yaml.dart';

const legacyEditorKeys = {'name', 'enabled'};

dynamic legacyEditorValue(YamlMap item, String key) => item[key];

List<Object?> legacyEditorPath(List<Object?> item, String key) => [
  ...item,
  key,
];
