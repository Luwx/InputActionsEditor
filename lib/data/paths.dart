import 'dart:io';

String configFilePath() {
  final xdgConfig = Platform.environment['XDG_CONFIG_HOME'];
  final base = (xdgConfig != null && xdgConfig.isNotEmpty)
      ? xdgConfig
      : '${Platform.environment['HOME']}/.config';
  final dir = '$base/inputactions';

  for (final name in ['config.yaml', 'config.yml']) {
    if (File('$dir/$name').existsSync()) return '$dir/$name';
  }
  return '$dir/config.yml';
}
