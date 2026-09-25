import 'package:freezed_annotation/freezed_annotation.dart';

part 'stroke.freezed.dart';

enum StrokeNameIssue { invalid, taken }

@freezed
abstract class Stroke with _$Stroke {
  const factory Stroke(String data, {String? name}) = _Stroke;

  static final _name = RegExp(r'^[^\s,\[\]{}]+$');

  static bool isValidName(String name) => _name.hasMatch(name);

  static StrokeNameIssue? nameIssue(
    Iterable<Stroke> strokes,
    String data,
    String name,
  ) {
    if (!isValidName(name)) return StrokeNameIssue.invalid;
    final taken = strokes.any(
      (stroke) => stroke.name == name && stroke.data != data,
    );
    return taken ? StrokeNameIssue.taken : null;
  }
}
