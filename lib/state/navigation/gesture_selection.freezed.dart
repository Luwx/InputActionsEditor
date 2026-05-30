// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gesture_selection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GestureSelection {

/// Device-type sidebar filter (null = All).
 DeviceType? get filter;/// Currently open gesture (null = nothing selected).
 OpenGesture? get open;
/// Create a copy of GestureSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureSelectionCopyWith<GestureSelection> get copyWith => _$GestureSelectionCopyWithImpl<GestureSelection>(this as GestureSelection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureSelection&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.open, open) || other.open == open));
}


@override
int get hashCode => Object.hash(runtimeType,filter,open);

@override
String toString() {
  return 'GestureSelection(filter: $filter, open: $open)';
}


}

/// @nodoc
abstract mixin class $GestureSelectionCopyWith<$Res>  {
  factory $GestureSelectionCopyWith(GestureSelection value, $Res Function(GestureSelection) _then) = _$GestureSelectionCopyWithImpl;
@useResult
$Res call({
 DeviceType? filter, OpenGesture? open
});




}
/// @nodoc
class _$GestureSelectionCopyWithImpl<$Res>
    implements $GestureSelectionCopyWith<$Res> {
  _$GestureSelectionCopyWithImpl(this._self, this._then);

  final GestureSelection _self;
  final $Res Function(GestureSelection) _then;

/// Create a copy of GestureSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filter = freezed,Object? open = freezed,}) {
  return _then(_self.copyWith(
filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as DeviceType?,open: freezed == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as OpenGesture?,
  ));
}

}


/// Adds pattern-matching-related methods to [GestureSelection].
extension GestureSelectionPatterns on GestureSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestureSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestureSelection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestureSelection value)  $default,){
final _that = this;
switch (_that) {
case _GestureSelection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestureSelection value)?  $default,){
final _that = this;
switch (_that) {
case _GestureSelection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeviceType? filter,  OpenGesture? open)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestureSelection() when $default != null:
return $default(_that.filter,_that.open);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeviceType? filter,  OpenGesture? open)  $default,) {final _that = this;
switch (_that) {
case _GestureSelection():
return $default(_that.filter,_that.open);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeviceType? filter,  OpenGesture? open)?  $default,) {final _that = this;
switch (_that) {
case _GestureSelection() when $default != null:
return $default(_that.filter,_that.open);case _:
  return null;

}
}

}

/// @nodoc


class _GestureSelection implements GestureSelection {
  const _GestureSelection({this.filter, this.open});
  

/// Device-type sidebar filter (null = All).
@override final  DeviceType? filter;
/// Currently open gesture (null = nothing selected).
@override final  OpenGesture? open;

/// Create a copy of GestureSelection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestureSelectionCopyWith<_GestureSelection> get copyWith => __$GestureSelectionCopyWithImpl<_GestureSelection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureSelection&&(identical(other.filter, filter) || other.filter == filter)&&(identical(other.open, open) || other.open == open));
}


@override
int get hashCode => Object.hash(runtimeType,filter,open);

@override
String toString() {
  return 'GestureSelection(filter: $filter, open: $open)';
}


}

/// @nodoc
abstract mixin class _$GestureSelectionCopyWith<$Res> implements $GestureSelectionCopyWith<$Res> {
  factory _$GestureSelectionCopyWith(_GestureSelection value, $Res Function(_GestureSelection) _then) = __$GestureSelectionCopyWithImpl;
@override @useResult
$Res call({
 DeviceType? filter, OpenGesture? open
});




}
/// @nodoc
class __$GestureSelectionCopyWithImpl<$Res>
    implements _$GestureSelectionCopyWith<$Res> {
  __$GestureSelectionCopyWithImpl(this._self, this._then);

  final _GestureSelection _self;
  final $Res Function(_GestureSelection) _then;

/// Create a copy of GestureSelection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filter = freezed,Object? open = freezed,}) {
  return _then(_GestureSelection(
filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as DeviceType?,open: freezed == open ? _self.open : open // ignore: cast_nullable_to_non_nullable
as OpenGesture?,
  ));
}


}

// dart format on
