import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FileIcon extends StatelessWidget {
  const FileIcon({
    required this.path,
    required this.size,
    this.fallback = const SizedBox.shrink(),
    super.key,
  });

  final String path;
  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    if (path.endsWith('.svg')) {
      return SvgPicture.file(File(path), width: size, height: size);
    }
    return Image.file(
      File(path),
      width: size,
      height: size,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
