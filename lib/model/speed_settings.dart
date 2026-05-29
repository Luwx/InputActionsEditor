import 'package:freezed_annotation/freezed_annotation.dart';

part 'speed_settings.freezed.dart';

@freezed
abstract class SpeedSettings with _$SpeedSettings {
  const factory SpeedSettings({
    int? events,
    double? swipeThreshold,
    double? pinchInThreshold,
    double? pinchOutThreshold,
    double? rotateThreshold,
  }) = _SpeedSettings;

  const SpeedSettings._();

  bool get isEmpty =>
      events == null &&
      swipeThreshold == null &&
      pinchInThreshold == null &&
      pinchOutThreshold == null &&
      rotateThreshold == null;
}
