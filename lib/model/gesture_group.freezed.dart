// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gesture_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GestureGroup {

 String get id; String get name; DeviceType get device; bool get enabled;
/// Create a copy of GestureGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureGroupCopyWith<GestureGroup> get copyWith => _$GestureGroupCopyWithImpl<GestureGroup>(this as GestureGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.device, device) || other.device == device)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,device,enabled);

@override
String toString() {
  return 'GestureGroup(id: $id, name: $name, device: $device, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class $GestureGroupCopyWith<$Res>  {
  factory $GestureGroupCopyWith(GestureGroup value, $Res Function(GestureGroup) _then) = _$GestureGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, DeviceType device, bool enabled
});




}
/// @nodoc
class _$GestureGroupCopyWithImpl<$Res>
    implements $GestureGroupCopyWith<$Res> {
  _$GestureGroupCopyWithImpl(this._self, this._then);

  final GestureGroup _self;
  final $Res Function(GestureGroup) _then;

/// Create a copy of GestureGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? device = null,Object? enabled = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceType,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GestureGroup].
extension GestureGroupPatterns on GestureGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestureGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestureGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestureGroup value)  $default,){
final _that = this;
switch (_that) {
case _GestureGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestureGroup value)?  $default,){
final _that = this;
switch (_that) {
case _GestureGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  DeviceType device,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestureGroup() when $default != null:
return $default(_that.id,_that.name,_that.device,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  DeviceType device,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _GestureGroup():
return $default(_that.id,_that.name,_that.device,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  DeviceType device,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _GestureGroup() when $default != null:
return $default(_that.id,_that.name,_that.device,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc


class _GestureGroup implements GestureGroup {
  const _GestureGroup({required this.id, required this.name, required this.device, this.enabled = true});
  

@override final  String id;
@override final  String name;
@override final  DeviceType device;
@override@JsonKey() final  bool enabled;

/// Create a copy of GestureGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestureGroupCopyWith<_GestureGroup> get copyWith => __$GestureGroupCopyWithImpl<_GestureGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.device, device) || other.device == device)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,device,enabled);

@override
String toString() {
  return 'GestureGroup(id: $id, name: $name, device: $device, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$GestureGroupCopyWith<$Res> implements $GestureGroupCopyWith<$Res> {
  factory _$GestureGroupCopyWith(_GestureGroup value, $Res Function(_GestureGroup) _then) = __$GestureGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, DeviceType device, bool enabled
});




}
/// @nodoc
class __$GestureGroupCopyWithImpl<$Res>
    implements _$GestureGroupCopyWith<$Res> {
  __$GestureGroupCopyWithImpl(this._self, this._then);

  final _GestureGroup _self;
  final $Res Function(_GestureGroup) _then;

/// Create a copy of GestureGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? device = null,Object? enabled = null,}) {
  return _then(_GestureGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceType,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
