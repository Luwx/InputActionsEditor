import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_scope.freezed.dart';

/// A null scope means the step belongs to no screen in particular.
@freezed
sealed class EditScope with _$EditScope {
  const factory EditScope.gestures() = GesturesScope;

  const factory EditScope.settings() = SettingsScope;
}
