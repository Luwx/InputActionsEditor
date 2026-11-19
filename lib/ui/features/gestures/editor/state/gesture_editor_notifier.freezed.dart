// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gesture_editor_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GestureEditorState {

 GestureLocation get location; Gesture? get gesture; TriggerCommon? get common; DirtyMarkState get triggerDirtyState; Gesture? get savedGesture;
/// Create a copy of GestureEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureEditorStateCopyWith<GestureEditorState> get copyWith => _$GestureEditorStateCopyWithImpl<GestureEditorState>(this as GestureEditorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureEditorState&&const DeepCollectionEquality().equals(other.location, location)&&(identical(other.gesture, gesture) || other.gesture == gesture)&&(identical(other.common, common) || other.common == common)&&(identical(other.triggerDirtyState, triggerDirtyState) || other.triggerDirtyState == triggerDirtyState)&&(identical(other.savedGesture, savedGesture) || other.savedGesture == savedGesture));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(location),gesture,common,triggerDirtyState,savedGesture);

@override
String toString() {
  return 'GestureEditorState(location: $location, gesture: $gesture, common: $common, triggerDirtyState: $triggerDirtyState, savedGesture: $savedGesture)';
}


}

/// @nodoc
abstract mixin class $GestureEditorStateCopyWith<$Res>  {
  factory $GestureEditorStateCopyWith(GestureEditorState value, $Res Function(GestureEditorState) _then) = _$GestureEditorStateCopyWithImpl;
@useResult
$Res call({
 GestureLocation location, Gesture? gesture, TriggerCommon? common, DirtyMarkState triggerDirtyState, Gesture? savedGesture
});


$TriggerCommonCopyWith<$Res>? get common;

}
/// @nodoc
class _$GestureEditorStateCopyWithImpl<$Res>
    implements $GestureEditorStateCopyWith<$Res> {
  _$GestureEditorStateCopyWithImpl(this._self, this._then);

  final GestureEditorState _self;
  final $Res Function(GestureEditorState) _then;

/// Create a copy of GestureEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = freezed,Object? gesture = freezed,Object? common = freezed,Object? triggerDirtyState = null,Object? savedGesture = freezed,}) {
  return _then(_self.copyWith(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GestureLocation,gesture: freezed == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as Gesture?,common: freezed == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon?,triggerDirtyState: null == triggerDirtyState ? _self.triggerDirtyState : triggerDirtyState // ignore: cast_nullable_to_non_nullable
as DirtyMarkState,savedGesture: freezed == savedGesture ? _self.savedGesture : savedGesture // ignore: cast_nullable_to_non_nullable
as Gesture?,
  ));
}
/// Create a copy of GestureEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res>? get common {
    if (_self.common == null) {
    return null;
  }

  return $TriggerCommonCopyWith<$Res>(_self.common!, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}


/// Adds pattern-matching-related methods to [GestureEditorState].
extension GestureEditorStatePatterns on GestureEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestureEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestureEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestureEditorState value)  $default,){
final _that = this;
switch (_that) {
case _GestureEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestureEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _GestureEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GestureLocation location,  Gesture? gesture,  TriggerCommon? common,  DirtyMarkState triggerDirtyState,  Gesture? savedGesture)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestureEditorState() when $default != null:
return $default(_that.location,_that.gesture,_that.common,_that.triggerDirtyState,_that.savedGesture);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GestureLocation location,  Gesture? gesture,  TriggerCommon? common,  DirtyMarkState triggerDirtyState,  Gesture? savedGesture)  $default,) {final _that = this;
switch (_that) {
case _GestureEditorState():
return $default(_that.location,_that.gesture,_that.common,_that.triggerDirtyState,_that.savedGesture);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GestureLocation location,  Gesture? gesture,  TriggerCommon? common,  DirtyMarkState triggerDirtyState,  Gesture? savedGesture)?  $default,) {final _that = this;
switch (_that) {
case _GestureEditorState() when $default != null:
return $default(_that.location,_that.gesture,_that.common,_that.triggerDirtyState,_that.savedGesture);case _:
  return null;

}
}

}

/// @nodoc


class _GestureEditorState extends GestureEditorState {
  const _GestureEditorState({required this.location, required this.gesture, required this.common, required this.triggerDirtyState, required this.savedGesture}): super._();
  

@override final  GestureLocation location;
@override final  Gesture? gesture;
@override final  TriggerCommon? common;
@override final  DirtyMarkState triggerDirtyState;
@override final  Gesture? savedGesture;

/// Create a copy of GestureEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestureEditorStateCopyWith<_GestureEditorState> get copyWith => __$GestureEditorStateCopyWithImpl<_GestureEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureEditorState&&const DeepCollectionEquality().equals(other.location, location)&&(identical(other.gesture, gesture) || other.gesture == gesture)&&(identical(other.common, common) || other.common == common)&&(identical(other.triggerDirtyState, triggerDirtyState) || other.triggerDirtyState == triggerDirtyState)&&(identical(other.savedGesture, savedGesture) || other.savedGesture == savedGesture));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(location),gesture,common,triggerDirtyState,savedGesture);

@override
String toString() {
  return 'GestureEditorState(location: $location, gesture: $gesture, common: $common, triggerDirtyState: $triggerDirtyState, savedGesture: $savedGesture)';
}


}

/// @nodoc
abstract mixin class _$GestureEditorStateCopyWith<$Res> implements $GestureEditorStateCopyWith<$Res> {
  factory _$GestureEditorStateCopyWith(_GestureEditorState value, $Res Function(_GestureEditorState) _then) = __$GestureEditorStateCopyWithImpl;
@override @useResult
$Res call({
 GestureLocation location, Gesture? gesture, TriggerCommon? common, DirtyMarkState triggerDirtyState, Gesture? savedGesture
});


@override $TriggerCommonCopyWith<$Res>? get common;

}
/// @nodoc
class __$GestureEditorStateCopyWithImpl<$Res>
    implements _$GestureEditorStateCopyWith<$Res> {
  __$GestureEditorStateCopyWithImpl(this._self, this._then);

  final _GestureEditorState _self;
  final $Res Function(_GestureEditorState) _then;

/// Create a copy of GestureEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = freezed,Object? gesture = freezed,Object? common = freezed,Object? triggerDirtyState = null,Object? savedGesture = freezed,}) {
  return _then(_GestureEditorState(
location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GestureLocation,gesture: freezed == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as Gesture?,common: freezed == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon?,triggerDirtyState: null == triggerDirtyState ? _self.triggerDirtyState : triggerDirtyState // ignore: cast_nullable_to_non_nullable
as DirtyMarkState,savedGesture: freezed == savedGesture ? _self.savedGesture : savedGesture // ignore: cast_nullable_to_non_nullable
as Gesture?,
  ));
}

/// Create a copy of GestureEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res>? get common {
    if (_self.common == null) {
    return null;
  }

  return $TriggerCommonCopyWith<$Res>(_self.common!, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}

// dart format on
