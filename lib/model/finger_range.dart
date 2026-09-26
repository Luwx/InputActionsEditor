import 'package:freezed_annotation/freezed_annotation.dart';

part 'finger_range.freezed.dart';

@freezed
abstract class FingerRange with _$FingerRange {
  const factory FingerRange({required int min, required int max}) =
      _FingerRange;

  const FingerRange._();

  factory FingerRange.exactly(int count) => FingerRange(min: count, max: count);

  bool get isExact => min == max;

  String get label => isExact ? '$min' : '$min-$max';

  bool overlaps(FingerRange other) => min <= other.max && other.min <= max;
}
