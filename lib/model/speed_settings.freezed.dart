// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'speed_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpeedSettings {

 int? get events; double? get swipeThreshold; double? get pinchInThreshold; double? get pinchOutThreshold; double? get rotateThreshold;
/// Create a copy of SpeedSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeedSettingsCopyWith<SpeedSettings> get copyWith => _$SpeedSettingsCopyWithImpl<SpeedSettings>(this as SpeedSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeedSettings&&(identical(other.events, events) || other.events == events)&&(identical(other.swipeThreshold, swipeThreshold) || other.swipeThreshold == swipeThreshold)&&(identical(other.pinchInThreshold, pinchInThreshold) || other.pinchInThreshold == pinchInThreshold)&&(identical(other.pinchOutThreshold, pinchOutThreshold) || other.pinchOutThreshold == pinchOutThreshold)&&(identical(other.rotateThreshold, rotateThreshold) || other.rotateThreshold == rotateThreshold));
}


@override
int get hashCode => Object.hash(runtimeType,events,swipeThreshold,pinchInThreshold,pinchOutThreshold,rotateThreshold);

@override
String toString() {
  return 'SpeedSettings(events: $events, swipeThreshold: $swipeThreshold, pinchInThreshold: $pinchInThreshold, pinchOutThreshold: $pinchOutThreshold, rotateThreshold: $rotateThreshold)';
}


}

/// @nodoc
abstract mixin class $SpeedSettingsCopyWith<$Res>  {
  factory $SpeedSettingsCopyWith(SpeedSettings value, $Res Function(SpeedSettings) _then) = _$SpeedSettingsCopyWithImpl;
@useResult
$Res call({
 int? events, double? swipeThreshold, double? pinchInThreshold, double? pinchOutThreshold, double? rotateThreshold
});




}
/// @nodoc
class _$SpeedSettingsCopyWithImpl<$Res>
    implements $SpeedSettingsCopyWith<$Res> {
  _$SpeedSettingsCopyWithImpl(this._self, this._then);

  final SpeedSettings _self;
  final $Res Function(SpeedSettings) _then;

/// Create a copy of SpeedSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? events = freezed,Object? swipeThreshold = freezed,Object? pinchInThreshold = freezed,Object? pinchOutThreshold = freezed,Object? rotateThreshold = freezed,}) {
  return _then(_self.copyWith(
events: freezed == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int?,swipeThreshold: freezed == swipeThreshold ? _self.swipeThreshold : swipeThreshold // ignore: cast_nullable_to_non_nullable
as double?,pinchInThreshold: freezed == pinchInThreshold ? _self.pinchInThreshold : pinchInThreshold // ignore: cast_nullable_to_non_nullable
as double?,pinchOutThreshold: freezed == pinchOutThreshold ? _self.pinchOutThreshold : pinchOutThreshold // ignore: cast_nullable_to_non_nullable
as double?,rotateThreshold: freezed == rotateThreshold ? _self.rotateThreshold : rotateThreshold // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpeedSettings].
extension SpeedSettingsPatterns on SpeedSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpeedSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpeedSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpeedSettings value)  $default,){
final _that = this;
switch (_that) {
case _SpeedSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpeedSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SpeedSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? events,  double? swipeThreshold,  double? pinchInThreshold,  double? pinchOutThreshold,  double? rotateThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpeedSettings() when $default != null:
return $default(_that.events,_that.swipeThreshold,_that.pinchInThreshold,_that.pinchOutThreshold,_that.rotateThreshold);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? events,  double? swipeThreshold,  double? pinchInThreshold,  double? pinchOutThreshold,  double? rotateThreshold)  $default,) {final _that = this;
switch (_that) {
case _SpeedSettings():
return $default(_that.events,_that.swipeThreshold,_that.pinchInThreshold,_that.pinchOutThreshold,_that.rotateThreshold);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? events,  double? swipeThreshold,  double? pinchInThreshold,  double? pinchOutThreshold,  double? rotateThreshold)?  $default,) {final _that = this;
switch (_that) {
case _SpeedSettings() when $default != null:
return $default(_that.events,_that.swipeThreshold,_that.pinchInThreshold,_that.pinchOutThreshold,_that.rotateThreshold);case _:
  return null;

}
}

}

/// @nodoc


class _SpeedSettings extends SpeedSettings {
  const _SpeedSettings({this.events, this.swipeThreshold, this.pinchInThreshold, this.pinchOutThreshold, this.rotateThreshold}): super._();
  

@override final  int? events;
@override final  double? swipeThreshold;
@override final  double? pinchInThreshold;
@override final  double? pinchOutThreshold;
@override final  double? rotateThreshold;

/// Create a copy of SpeedSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpeedSettingsCopyWith<_SpeedSettings> get copyWith => __$SpeedSettingsCopyWithImpl<_SpeedSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpeedSettings&&(identical(other.events, events) || other.events == events)&&(identical(other.swipeThreshold, swipeThreshold) || other.swipeThreshold == swipeThreshold)&&(identical(other.pinchInThreshold, pinchInThreshold) || other.pinchInThreshold == pinchInThreshold)&&(identical(other.pinchOutThreshold, pinchOutThreshold) || other.pinchOutThreshold == pinchOutThreshold)&&(identical(other.rotateThreshold, rotateThreshold) || other.rotateThreshold == rotateThreshold));
}


@override
int get hashCode => Object.hash(runtimeType,events,swipeThreshold,pinchInThreshold,pinchOutThreshold,rotateThreshold);

@override
String toString() {
  return 'SpeedSettings(events: $events, swipeThreshold: $swipeThreshold, pinchInThreshold: $pinchInThreshold, pinchOutThreshold: $pinchOutThreshold, rotateThreshold: $rotateThreshold)';
}


}

/// @nodoc
abstract mixin class _$SpeedSettingsCopyWith<$Res> implements $SpeedSettingsCopyWith<$Res> {
  factory _$SpeedSettingsCopyWith(_SpeedSettings value, $Res Function(_SpeedSettings) _then) = __$SpeedSettingsCopyWithImpl;
@override @useResult
$Res call({
 int? events, double? swipeThreshold, double? pinchInThreshold, double? pinchOutThreshold, double? rotateThreshold
});




}
/// @nodoc
class __$SpeedSettingsCopyWithImpl<$Res>
    implements _$SpeedSettingsCopyWith<$Res> {
  __$SpeedSettingsCopyWithImpl(this._self, this._then);

  final _SpeedSettings _self;
  final $Res Function(_SpeedSettings) _then;

/// Create a copy of SpeedSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? events = freezed,Object? swipeThreshold = freezed,Object? pinchInThreshold = freezed,Object? pinchOutThreshold = freezed,Object? rotateThreshold = freezed,}) {
  return _then(_SpeedSettings(
events: freezed == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as int?,swipeThreshold: freezed == swipeThreshold ? _self.swipeThreshold : swipeThreshold // ignore: cast_nullable_to_non_nullable
as double?,pinchInThreshold: freezed == pinchInThreshold ? _self.pinchInThreshold : pinchInThreshold // ignore: cast_nullable_to_non_nullable
as double?,pinchOutThreshold: freezed == pinchOutThreshold ? _self.pinchOutThreshold : pinchOutThreshold // ignore: cast_nullable_to_non_nullable
as double?,rotateThreshold: freezed == rotateThreshold ? _self.rotateThreshold : rotateThreshold // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
