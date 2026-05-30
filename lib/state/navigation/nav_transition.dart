import 'package:equatable/equatable.dart';

enum NavAxis { vertical, horizontal }

class TransitionConfig extends Equatable {
  const TransitionConfig(this.axis, this.sign, {this.amount = 0.25});

  final NavAxis axis;

  /// `+1` = toward trailing edge (down / right), `-1` = toward leading edge.
  final double sign;

  /// Slide distance as a fraction of the surface size.
  final double amount;

  @override
  List<Object?> get props => [axis, sign, amount];
}
