import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/common/path_preview.dart';

void main() {
  test('densifyPathPoints pads sparse paths to minimum sample count', () {
    final realPoints = [
      Offset.zero,
      const Offset(20, 10),
      const Offset(40, 0),
    ];
    final densePoints = densifyPathPoints(realPoints, 12);

    expect(densePoints.length, 12);
    expect(densePoints.first, realPoints.first);
    expect(densePoints.last, realPoints.last);
  });

  test('densifyPathPoints keeps every corner of the original path', () {
    final realPoints = [
      Offset.zero,
      const Offset(20, 10),
      const Offset(40, 0),
    ];

    final densePoints = densifyPathPoints(realPoints, 12);

    for (final point in realPoints) {
      expect(
        densePoints,
        contains(point),
        reason: 'the densified path cuts the corner at $point',
      );
    }
  });

  test('a morph samples both paths on every corner of either', () {
    final short = [Offset.zero, const Offset(20, 10), const Offset(40, 0)];
    final long = [
      Offset.zero,
      const Offset(4, 8),
      const Offset(12, 2),
      const Offset(28, 9),
      const Offset(36, 4),
      const Offset(40, 0),
    ];
    final parameters = morphParameters(long.length, short.length);

    expect(parameters.first, 0);
    expect(parameters.last, 1);
    for (final path in [short, long]) {
      for (final point in path) {
        expect(
          parameters.map((t) => samplePathAt(path, t)),
          contains(point),
          reason: 'the tween drops a corner of the path it ends on',
        );
      }
    }
  });
}
