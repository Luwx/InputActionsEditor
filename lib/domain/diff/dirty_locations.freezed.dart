// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dirty_locations.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GestureSectionLocation {

 GestureLocation get gesture; GestureSectionDirtyField get field;
/// Create a copy of GestureSectionLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureSectionLocationCopyWith<GestureSectionLocation> get copyWith => _$GestureSectionLocationCopyWithImpl<GestureSectionLocation>(this as GestureSectionLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureSectionLocation&&const DeepCollectionEquality().equals(other.gesture, gesture)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(gesture),field);

@override
String toString() {
  return 'GestureSectionLocation(gesture: $gesture, field: $field)';
}


}

/// @nodoc
abstract mixin class $GestureSectionLocationCopyWith<$Res>  {
  factory $GestureSectionLocationCopyWith(GestureSectionLocation value, $Res Function(GestureSectionLocation) _then) = _$GestureSectionLocationCopyWithImpl;
@useResult
$Res call({
 GestureLocation gesture, GestureSectionDirtyField field
});




}
/// @nodoc
class _$GestureSectionLocationCopyWithImpl<$Res>
    implements $GestureSectionLocationCopyWith<$Res> {
  _$GestureSectionLocationCopyWithImpl(this._self, this._then);

  final GestureSectionLocation _self;
  final $Res Function(GestureSectionLocation) _then;

/// Create a copy of GestureSectionLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gesture = freezed,Object? field = null,}) {
  return _then(_self.copyWith(
gesture: freezed == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as GestureLocation,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as GestureSectionDirtyField,
  ));
}

}


/// Adds pattern-matching-related methods to [GestureSectionLocation].
extension GestureSectionLocationPatterns on GestureSectionLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestureSectionLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestureSectionLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestureSectionLocation value)  $default,){
final _that = this;
switch (_that) {
case _GestureSectionLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestureSectionLocation value)?  $default,){
final _that = this;
switch (_that) {
case _GestureSectionLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GestureLocation gesture,  GestureSectionDirtyField field)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestureSectionLocation() when $default != null:
return $default(_that.gesture,_that.field);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GestureLocation gesture,  GestureSectionDirtyField field)  $default,) {final _that = this;
switch (_that) {
case _GestureSectionLocation():
return $default(_that.gesture,_that.field);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GestureLocation gesture,  GestureSectionDirtyField field)?  $default,) {final _that = this;
switch (_that) {
case _GestureSectionLocation() when $default != null:
return $default(_that.gesture,_that.field);case _:
  return null;

}
}

}

/// @nodoc


class _GestureSectionLocation implements GestureSectionLocation {
  const _GestureSectionLocation({required this.gesture, required this.field});
  

@override final  GestureLocation gesture;
@override final  GestureSectionDirtyField field;

/// Create a copy of GestureSectionLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestureSectionLocationCopyWith<_GestureSectionLocation> get copyWith => __$GestureSectionLocationCopyWithImpl<_GestureSectionLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureSectionLocation&&const DeepCollectionEquality().equals(other.gesture, gesture)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(gesture),field);

@override
String toString() {
  return 'GestureSectionLocation(gesture: $gesture, field: $field)';
}


}

/// @nodoc
abstract mixin class _$GestureSectionLocationCopyWith<$Res> implements $GestureSectionLocationCopyWith<$Res> {
  factory _$GestureSectionLocationCopyWith(_GestureSectionLocation value, $Res Function(_GestureSectionLocation) _then) = __$GestureSectionLocationCopyWithImpl;
@override @useResult
$Res call({
 GestureLocation gesture, GestureSectionDirtyField field
});




}
/// @nodoc
class __$GestureSectionLocationCopyWithImpl<$Res>
    implements _$GestureSectionLocationCopyWith<$Res> {
  __$GestureSectionLocationCopyWithImpl(this._self, this._then);

  final _GestureSectionLocation _self;
  final $Res Function(_GestureSectionLocation) _then;

/// Create a copy of GestureSectionLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gesture = freezed,Object? field = null,}) {
  return _then(_GestureSectionLocation(
gesture: freezed == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as GestureLocation,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as GestureSectionDirtyField,
  ));
}


}

// dart format on
