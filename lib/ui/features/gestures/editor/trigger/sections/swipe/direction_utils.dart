import 'package:input_actions_editor/model/enums.dart';

const List<SwipeDirection> kSectorDirs = [
  SwipeDirection.right,
  SwipeDirection.rightDown,
  SwipeDirection.down,
  SwipeDirection.leftDown,
  SwipeDirection.left,
  SwipeDirection.leftUp,
  SwipeDirection.up,
  SwipeDirection.rightUp,
];

const kSectorArrows = ['→', '↘', '↓', '↙', '←', '↖', '↑', '↗'];

const List<SwipeDirection> kBiDirs = [
  SwipeDirection.leftRight,
  SwipeDirection.upDown,
  SwipeDirection.leftUpRightDown,
  SwipeDirection.leftDownRightUp,
];

Set<int> activeSectors(SwipeDirection direction) => switch (direction) {
  SwipeDirection.right => {0},
  SwipeDirection.rightDown => {1},
  SwipeDirection.down => {2},
  SwipeDirection.leftDown => {3},
  SwipeDirection.left => {4},
  SwipeDirection.leftUp => {5},
  SwipeDirection.up => {6},
  SwipeDirection.rightUp => {7},
  SwipeDirection.leftRight => {0, 4},
  SwipeDirection.upDown => {2, 6},
  SwipeDirection.leftUpRightDown => {5, 1},
  SwipeDirection.leftDownRightUp => {3, 7},
  SwipeDirection.any => {0, 1, 2, 3, 4, 5, 6, 7},
};

String directionLabel(SwipeDirection direction) => switch (direction) {
  SwipeDirection.left => 'Left',
  SwipeDirection.right => 'Right',
  SwipeDirection.up => 'Up',
  SwipeDirection.down => 'Down',
  SwipeDirection.leftUp => 'Left-Up',
  SwipeDirection.leftDown => 'Left-Down',
  SwipeDirection.rightUp => 'Right-Up',
  SwipeDirection.rightDown => 'Right-Down',
  SwipeDirection.leftRight => 'Left / Right',
  SwipeDirection.upDown => 'Up / Down',
  SwipeDirection.leftUpRightDown => 'Left-Up / Right-Down',
  SwipeDirection.leftDownRightUp => 'Left-Down / Right-Up',
  SwipeDirection.any => 'Any direction',
};

SwipeDirection toBidirectional(SwipeDirection dir) => switch (dir) {
  SwipeDirection.left || SwipeDirection.right => SwipeDirection.leftRight,
  SwipeDirection.up || SwipeDirection.down => SwipeDirection.upDown,
  SwipeDirection.leftUp ||
  SwipeDirection.rightDown => SwipeDirection.leftUpRightDown,
  SwipeDirection.leftDown ||
  SwipeDirection.rightUp => SwipeDirection.leftDownRightUp,
  _ => SwipeDirection.leftRight,
};

SwipeDirection toSingleDirection(SwipeDirection dir) => switch (dir) {
  SwipeDirection.leftRight => SwipeDirection.left,
  SwipeDirection.upDown => SwipeDirection.up,
  SwipeDirection.leftUpRightDown => SwipeDirection.leftUp,
  SwipeDirection.leftDownRightUp => SwipeDirection.leftDown,
  _ => dir,
};
