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
mixin _$GestureLocation {

 DeviceType get device; int get index;
/// Create a copy of GestureLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<GestureLocation> get copyWith => _$GestureLocationCopyWithImpl<GestureLocation>(this as GestureLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureLocation&&(identical(other.device, device) || other.device == device)&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,device,index);

@override
String toString() {
  return 'GestureLocation(device: $device, index: $index)';
}


}

/// @nodoc
abstract mixin class $GestureLocationCopyWith<$Res>  {
  factory $GestureLocationCopyWith(GestureLocation value, $Res Function(GestureLocation) _then) = _$GestureLocationCopyWithImpl;
@useResult
$Res call({
 DeviceType device, int index
});




}
/// @nodoc
class _$GestureLocationCopyWithImpl<$Res>
    implements $GestureLocationCopyWith<$Res> {
  _$GestureLocationCopyWithImpl(this._self, this._then);

  final GestureLocation _self;
  final $Res Function(GestureLocation) _then;

/// Create a copy of GestureLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? device = null,Object? index = null,}) {
  return _then(_self.copyWith(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceType,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GestureLocation].
extension GestureLocationPatterns on GestureLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestureLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestureLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestureLocation value)  $default,){
final _that = this;
switch (_that) {
case _GestureLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestureLocation value)?  $default,){
final _that = this;
switch (_that) {
case _GestureLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeviceType device,  int index)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestureLocation() when $default != null:
return $default(_that.device,_that.index);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeviceType device,  int index)  $default,) {final _that = this;
switch (_that) {
case _GestureLocation():
return $default(_that.device,_that.index);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeviceType device,  int index)?  $default,) {final _that = this;
switch (_that) {
case _GestureLocation() when $default != null:
return $default(_that.device,_that.index);case _:
  return null;

}
}

}

/// @nodoc


class _GestureLocation implements GestureLocation {
  const _GestureLocation({required this.device, required this.index});
  

@override final  DeviceType device;
@override final  int index;

/// Create a copy of GestureLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestureLocationCopyWith<_GestureLocation> get copyWith => __$GestureLocationCopyWithImpl<_GestureLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureLocation&&(identical(other.device, device) || other.device == device)&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,device,index);

@override
String toString() {
  return 'GestureLocation(device: $device, index: $index)';
}


}

/// @nodoc
abstract mixin class _$GestureLocationCopyWith<$Res> implements $GestureLocationCopyWith<$Res> {
  factory _$GestureLocationCopyWith(_GestureLocation value, $Res Function(_GestureLocation) _then) = __$GestureLocationCopyWithImpl;
@override @useResult
$Res call({
 DeviceType device, int index
});




}
/// @nodoc
class __$GestureLocationCopyWithImpl<$Res>
    implements _$GestureLocationCopyWith<$Res> {
  __$GestureLocationCopyWithImpl(this._self, this._then);

  final _GestureLocation _self;
  final $Res Function(_GestureLocation) _then;

/// Create a copy of GestureLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? device = null,Object? index = null,}) {
  return _then(_GestureLocation(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceType,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureSectionLocation&&(identical(other.gesture, gesture) || other.gesture == gesture)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,gesture,field);

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


$GestureLocationCopyWith<$Res> get gesture;

}
/// @nodoc
class _$GestureSectionLocationCopyWithImpl<$Res>
    implements $GestureSectionLocationCopyWith<$Res> {
  _$GestureSectionLocationCopyWithImpl(this._self, this._then);

  final GestureSectionLocation _self;
  final $Res Function(GestureSectionLocation) _then;

/// Create a copy of GestureSectionLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gesture = null,Object? field = null,}) {
  return _then(_self.copyWith(
gesture: null == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as GestureLocation,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as GestureSectionDirtyField,
  ));
}
/// Create a copy of GestureSectionLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get gesture {
  
  return $GestureLocationCopyWith<$Res>(_self.gesture, (value) {
    return _then(_self.copyWith(gesture: value));
  });
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureSectionLocation&&(identical(other.gesture, gesture) || other.gesture == gesture)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,gesture,field);

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


@override $GestureLocationCopyWith<$Res> get gesture;

}
/// @nodoc
class __$GestureSectionLocationCopyWithImpl<$Res>
    implements _$GestureSectionLocationCopyWith<$Res> {
  __$GestureSectionLocationCopyWithImpl(this._self, this._then);

  final _GestureSectionLocation _self;
  final $Res Function(_GestureSectionLocation) _then;

/// Create a copy of GestureSectionLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gesture = null,Object? field = null,}) {
  return _then(_GestureSectionLocation(
gesture: null == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as GestureLocation,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as GestureSectionDirtyField,
  ));
}

/// Create a copy of GestureSectionLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get gesture {
  
  return $GestureLocationCopyWith<$Res>(_self.gesture, (value) {
    return _then(_self.copyWith(gesture: value));
  });
}
}

/// @nodoc
mixin _$ActionLocation {

 GestureLocation get gesture; int get actionIndex;
/// Create a copy of ActionLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionLocationCopyWith<ActionLocation> get copyWith => _$ActionLocationCopyWithImpl<ActionLocation>(this as ActionLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionLocation&&(identical(other.gesture, gesture) || other.gesture == gesture)&&(identical(other.actionIndex, actionIndex) || other.actionIndex == actionIndex));
}


@override
int get hashCode => Object.hash(runtimeType,gesture,actionIndex);

@override
String toString() {
  return 'ActionLocation(gesture: $gesture, actionIndex: $actionIndex)';
}


}

/// @nodoc
abstract mixin class $ActionLocationCopyWith<$Res>  {
  factory $ActionLocationCopyWith(ActionLocation value, $Res Function(ActionLocation) _then) = _$ActionLocationCopyWithImpl;
@useResult
$Res call({
 GestureLocation gesture, int actionIndex
});


$GestureLocationCopyWith<$Res> get gesture;

}
/// @nodoc
class _$ActionLocationCopyWithImpl<$Res>
    implements $ActionLocationCopyWith<$Res> {
  _$ActionLocationCopyWithImpl(this._self, this._then);

  final ActionLocation _self;
  final $Res Function(ActionLocation) _then;

/// Create a copy of ActionLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gesture = null,Object? actionIndex = null,}) {
  return _then(_self.copyWith(
gesture: null == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as GestureLocation,actionIndex: null == actionIndex ? _self.actionIndex : actionIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ActionLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get gesture {
  
  return $GestureLocationCopyWith<$Res>(_self.gesture, (value) {
    return _then(_self.copyWith(gesture: value));
  });
}
}


/// Adds pattern-matching-related methods to [ActionLocation].
extension ActionLocationPatterns on ActionLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActionLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActionLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActionLocation value)  $default,){
final _that = this;
switch (_that) {
case _ActionLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActionLocation value)?  $default,){
final _that = this;
switch (_that) {
case _ActionLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GestureLocation gesture,  int actionIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActionLocation() when $default != null:
return $default(_that.gesture,_that.actionIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GestureLocation gesture,  int actionIndex)  $default,) {final _that = this;
switch (_that) {
case _ActionLocation():
return $default(_that.gesture,_that.actionIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GestureLocation gesture,  int actionIndex)?  $default,) {final _that = this;
switch (_that) {
case _ActionLocation() when $default != null:
return $default(_that.gesture,_that.actionIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ActionLocation implements ActionLocation {
  const _ActionLocation({required this.gesture, required this.actionIndex});
  

@override final  GestureLocation gesture;
@override final  int actionIndex;

/// Create a copy of ActionLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionLocationCopyWith<_ActionLocation> get copyWith => __$ActionLocationCopyWithImpl<_ActionLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionLocation&&(identical(other.gesture, gesture) || other.gesture == gesture)&&(identical(other.actionIndex, actionIndex) || other.actionIndex == actionIndex));
}


@override
int get hashCode => Object.hash(runtimeType,gesture,actionIndex);

@override
String toString() {
  return 'ActionLocation(gesture: $gesture, actionIndex: $actionIndex)';
}


}

/// @nodoc
abstract mixin class _$ActionLocationCopyWith<$Res> implements $ActionLocationCopyWith<$Res> {
  factory _$ActionLocationCopyWith(_ActionLocation value, $Res Function(_ActionLocation) _then) = __$ActionLocationCopyWithImpl;
@override @useResult
$Res call({
 GestureLocation gesture, int actionIndex
});


@override $GestureLocationCopyWith<$Res> get gesture;

}
/// @nodoc
class __$ActionLocationCopyWithImpl<$Res>
    implements _$ActionLocationCopyWith<$Res> {
  __$ActionLocationCopyWithImpl(this._self, this._then);

  final _ActionLocation _self;
  final $Res Function(_ActionLocation) _then;

/// Create a copy of ActionLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gesture = null,Object? actionIndex = null,}) {
  return _then(_ActionLocation(
gesture: null == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as GestureLocation,actionIndex: null == actionIndex ? _self.actionIndex : actionIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ActionLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get gesture {
  
  return $GestureLocationCopyWith<$Res>(_self.gesture, (value) {
    return _then(_self.copyWith(gesture: value));
  });
}
}

/// @nodoc
mixin _$ActionDirtyLocation {

 ActionLocation get action; ActionDirtyField get field;
/// Create a copy of ActionDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionDirtyLocationCopyWith<ActionDirtyLocation> get copyWith => _$ActionDirtyLocationCopyWithImpl<ActionDirtyLocation>(this as ActionDirtyLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionDirtyLocation&&(identical(other.action, action) || other.action == action)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,action,field);

@override
String toString() {
  return 'ActionDirtyLocation(action: $action, field: $field)';
}


}

/// @nodoc
abstract mixin class $ActionDirtyLocationCopyWith<$Res>  {
  factory $ActionDirtyLocationCopyWith(ActionDirtyLocation value, $Res Function(ActionDirtyLocation) _then) = _$ActionDirtyLocationCopyWithImpl;
@useResult
$Res call({
 ActionLocation action, ActionDirtyField field
});


$ActionLocationCopyWith<$Res> get action;

}
/// @nodoc
class _$ActionDirtyLocationCopyWithImpl<$Res>
    implements $ActionDirtyLocationCopyWith<$Res> {
  _$ActionDirtyLocationCopyWithImpl(this._self, this._then);

  final ActionDirtyLocation _self;
  final $Res Function(ActionDirtyLocation) _then;

/// Create a copy of ActionDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? field = null,}) {
  return _then(_self.copyWith(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ActionLocation,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as ActionDirtyField,
  ));
}
/// Create a copy of ActionDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActionLocationCopyWith<$Res> get action {
  
  return $ActionLocationCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}


/// Adds pattern-matching-related methods to [ActionDirtyLocation].
extension ActionDirtyLocationPatterns on ActionDirtyLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActionDirtyLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActionDirtyLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActionDirtyLocation value)  $default,){
final _that = this;
switch (_that) {
case _ActionDirtyLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActionDirtyLocation value)?  $default,){
final _that = this;
switch (_that) {
case _ActionDirtyLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActionLocation action,  ActionDirtyField field)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActionDirtyLocation() when $default != null:
return $default(_that.action,_that.field);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActionLocation action,  ActionDirtyField field)  $default,) {final _that = this;
switch (_that) {
case _ActionDirtyLocation():
return $default(_that.action,_that.field);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActionLocation action,  ActionDirtyField field)?  $default,) {final _that = this;
switch (_that) {
case _ActionDirtyLocation() when $default != null:
return $default(_that.action,_that.field);case _:
  return null;

}
}

}

/// @nodoc


class _ActionDirtyLocation implements ActionDirtyLocation {
  const _ActionDirtyLocation({required this.action, required this.field});
  

@override final  ActionLocation action;
@override final  ActionDirtyField field;

/// Create a copy of ActionDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionDirtyLocationCopyWith<_ActionDirtyLocation> get copyWith => __$ActionDirtyLocationCopyWithImpl<_ActionDirtyLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionDirtyLocation&&(identical(other.action, action) || other.action == action)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,action,field);

@override
String toString() {
  return 'ActionDirtyLocation(action: $action, field: $field)';
}


}

/// @nodoc
abstract mixin class _$ActionDirtyLocationCopyWith<$Res> implements $ActionDirtyLocationCopyWith<$Res> {
  factory _$ActionDirtyLocationCopyWith(_ActionDirtyLocation value, $Res Function(_ActionDirtyLocation) _then) = __$ActionDirtyLocationCopyWithImpl;
@override @useResult
$Res call({
 ActionLocation action, ActionDirtyField field
});


@override $ActionLocationCopyWith<$Res> get action;

}
/// @nodoc
class __$ActionDirtyLocationCopyWithImpl<$Res>
    implements _$ActionDirtyLocationCopyWith<$Res> {
  __$ActionDirtyLocationCopyWithImpl(this._self, this._then);

  final _ActionDirtyLocation _self;
  final $Res Function(_ActionDirtyLocation) _then;

/// Create a copy of ActionDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? field = null,}) {
  return _then(_ActionDirtyLocation(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as ActionLocation,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as ActionDirtyField,
  ));
}

/// Create a copy of ActionDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActionLocationCopyWith<$Res> get action {
  
  return $ActionLocationCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}

/// @nodoc
mixin _$GestureCommonDirtyLocation {

 GestureLocation get gesture; GestureCommonDirtyField get field;
/// Create a copy of GestureCommonDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureCommonDirtyLocationCopyWith<GestureCommonDirtyLocation> get copyWith => _$GestureCommonDirtyLocationCopyWithImpl<GestureCommonDirtyLocation>(this as GestureCommonDirtyLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureCommonDirtyLocation&&(identical(other.gesture, gesture) || other.gesture == gesture)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,gesture,field);

@override
String toString() {
  return 'GestureCommonDirtyLocation(gesture: $gesture, field: $field)';
}


}

/// @nodoc
abstract mixin class $GestureCommonDirtyLocationCopyWith<$Res>  {
  factory $GestureCommonDirtyLocationCopyWith(GestureCommonDirtyLocation value, $Res Function(GestureCommonDirtyLocation) _then) = _$GestureCommonDirtyLocationCopyWithImpl;
@useResult
$Res call({
 GestureLocation gesture, GestureCommonDirtyField field
});


$GestureLocationCopyWith<$Res> get gesture;

}
/// @nodoc
class _$GestureCommonDirtyLocationCopyWithImpl<$Res>
    implements $GestureCommonDirtyLocationCopyWith<$Res> {
  _$GestureCommonDirtyLocationCopyWithImpl(this._self, this._then);

  final GestureCommonDirtyLocation _self;
  final $Res Function(GestureCommonDirtyLocation) _then;

/// Create a copy of GestureCommonDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gesture = null,Object? field = null,}) {
  return _then(_self.copyWith(
gesture: null == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as GestureLocation,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as GestureCommonDirtyField,
  ));
}
/// Create a copy of GestureCommonDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get gesture {
  
  return $GestureLocationCopyWith<$Res>(_self.gesture, (value) {
    return _then(_self.copyWith(gesture: value));
  });
}
}


/// Adds pattern-matching-related methods to [GestureCommonDirtyLocation].
extension GestureCommonDirtyLocationPatterns on GestureCommonDirtyLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestureCommonDirtyLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestureCommonDirtyLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestureCommonDirtyLocation value)  $default,){
final _that = this;
switch (_that) {
case _GestureCommonDirtyLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestureCommonDirtyLocation value)?  $default,){
final _that = this;
switch (_that) {
case _GestureCommonDirtyLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GestureLocation gesture,  GestureCommonDirtyField field)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestureCommonDirtyLocation() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GestureLocation gesture,  GestureCommonDirtyField field)  $default,) {final _that = this;
switch (_that) {
case _GestureCommonDirtyLocation():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GestureLocation gesture,  GestureCommonDirtyField field)?  $default,) {final _that = this;
switch (_that) {
case _GestureCommonDirtyLocation() when $default != null:
return $default(_that.gesture,_that.field);case _:
  return null;

}
}

}

/// @nodoc


class _GestureCommonDirtyLocation implements GestureCommonDirtyLocation {
  const _GestureCommonDirtyLocation({required this.gesture, required this.field});
  

@override final  GestureLocation gesture;
@override final  GestureCommonDirtyField field;

/// Create a copy of GestureCommonDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestureCommonDirtyLocationCopyWith<_GestureCommonDirtyLocation> get copyWith => __$GestureCommonDirtyLocationCopyWithImpl<_GestureCommonDirtyLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureCommonDirtyLocation&&(identical(other.gesture, gesture) || other.gesture == gesture)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,gesture,field);

@override
String toString() {
  return 'GestureCommonDirtyLocation(gesture: $gesture, field: $field)';
}


}

/// @nodoc
abstract mixin class _$GestureCommonDirtyLocationCopyWith<$Res> implements $GestureCommonDirtyLocationCopyWith<$Res> {
  factory _$GestureCommonDirtyLocationCopyWith(_GestureCommonDirtyLocation value, $Res Function(_GestureCommonDirtyLocation) _then) = __$GestureCommonDirtyLocationCopyWithImpl;
@override @useResult
$Res call({
 GestureLocation gesture, GestureCommonDirtyField field
});


@override $GestureLocationCopyWith<$Res> get gesture;

}
/// @nodoc
class __$GestureCommonDirtyLocationCopyWithImpl<$Res>
    implements _$GestureCommonDirtyLocationCopyWith<$Res> {
  __$GestureCommonDirtyLocationCopyWithImpl(this._self, this._then);

  final _GestureCommonDirtyLocation _self;
  final $Res Function(_GestureCommonDirtyLocation) _then;

/// Create a copy of GestureCommonDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gesture = null,Object? field = null,}) {
  return _then(_GestureCommonDirtyLocation(
gesture: null == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as GestureLocation,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as GestureCommonDirtyField,
  ));
}

/// Create a copy of GestureCommonDirtyLocation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get gesture {
  
  return $GestureLocationCopyWith<$Res>(_self.gesture, (value) {
    return _then(_self.copyWith(gesture: value));
  });
}
}

/// @nodoc
mixin _$DevicePropertyLocation {

 DeviceType get device; DevicePropertyDirtyField get field;
/// Create a copy of DevicePropertyLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DevicePropertyLocationCopyWith<DevicePropertyLocation> get copyWith => _$DevicePropertyLocationCopyWithImpl<DevicePropertyLocation>(this as DevicePropertyLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DevicePropertyLocation&&(identical(other.device, device) || other.device == device)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,device,field);

@override
String toString() {
  return 'DevicePropertyLocation(device: $device, field: $field)';
}


}

/// @nodoc
abstract mixin class $DevicePropertyLocationCopyWith<$Res>  {
  factory $DevicePropertyLocationCopyWith(DevicePropertyLocation value, $Res Function(DevicePropertyLocation) _then) = _$DevicePropertyLocationCopyWithImpl;
@useResult
$Res call({
 DeviceType device, DevicePropertyDirtyField field
});




}
/// @nodoc
class _$DevicePropertyLocationCopyWithImpl<$Res>
    implements $DevicePropertyLocationCopyWith<$Res> {
  _$DevicePropertyLocationCopyWithImpl(this._self, this._then);

  final DevicePropertyLocation _self;
  final $Res Function(DevicePropertyLocation) _then;

/// Create a copy of DevicePropertyLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? device = null,Object? field = null,}) {
  return _then(_self.copyWith(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceType,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as DevicePropertyDirtyField,
  ));
}

}


/// Adds pattern-matching-related methods to [DevicePropertyLocation].
extension DevicePropertyLocationPatterns on DevicePropertyLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DevicePropertyLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DevicePropertyLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DevicePropertyLocation value)  $default,){
final _that = this;
switch (_that) {
case _DevicePropertyLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DevicePropertyLocation value)?  $default,){
final _that = this;
switch (_that) {
case _DevicePropertyLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeviceType device,  DevicePropertyDirtyField field)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DevicePropertyLocation() when $default != null:
return $default(_that.device,_that.field);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeviceType device,  DevicePropertyDirtyField field)  $default,) {final _that = this;
switch (_that) {
case _DevicePropertyLocation():
return $default(_that.device,_that.field);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeviceType device,  DevicePropertyDirtyField field)?  $default,) {final _that = this;
switch (_that) {
case _DevicePropertyLocation() when $default != null:
return $default(_that.device,_that.field);case _:
  return null;

}
}

}

/// @nodoc


class _DevicePropertyLocation implements DevicePropertyLocation {
  const _DevicePropertyLocation({required this.device, required this.field});
  

@override final  DeviceType device;
@override final  DevicePropertyDirtyField field;

/// Create a copy of DevicePropertyLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DevicePropertyLocationCopyWith<_DevicePropertyLocation> get copyWith => __$DevicePropertyLocationCopyWithImpl<_DevicePropertyLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DevicePropertyLocation&&(identical(other.device, device) || other.device == device)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,device,field);

@override
String toString() {
  return 'DevicePropertyLocation(device: $device, field: $field)';
}


}

/// @nodoc
abstract mixin class _$DevicePropertyLocationCopyWith<$Res> implements $DevicePropertyLocationCopyWith<$Res> {
  factory _$DevicePropertyLocationCopyWith(_DevicePropertyLocation value, $Res Function(_DevicePropertyLocation) _then) = __$DevicePropertyLocationCopyWithImpl;
@override @useResult
$Res call({
 DeviceType device, DevicePropertyDirtyField field
});




}
/// @nodoc
class __$DevicePropertyLocationCopyWithImpl<$Res>
    implements _$DevicePropertyLocationCopyWith<$Res> {
  __$DevicePropertyLocationCopyWithImpl(this._self, this._then);

  final _DevicePropertyLocation _self;
  final $Res Function(_DevicePropertyLocation) _then;

/// Create a copy of DevicePropertyLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? device = null,Object? field = null,}) {
  return _then(_DevicePropertyLocation(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceType,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as DevicePropertyDirtyField,
  ));
}


}

/// @nodoc
mixin _$SpeedSettingLocation {

 DeviceType get device; SpeedSettingDirtyField get field;
/// Create a copy of SpeedSettingLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpeedSettingLocationCopyWith<SpeedSettingLocation> get copyWith => _$SpeedSettingLocationCopyWithImpl<SpeedSettingLocation>(this as SpeedSettingLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpeedSettingLocation&&(identical(other.device, device) || other.device == device)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,device,field);

@override
String toString() {
  return 'SpeedSettingLocation(device: $device, field: $field)';
}


}

/// @nodoc
abstract mixin class $SpeedSettingLocationCopyWith<$Res>  {
  factory $SpeedSettingLocationCopyWith(SpeedSettingLocation value, $Res Function(SpeedSettingLocation) _then) = _$SpeedSettingLocationCopyWithImpl;
@useResult
$Res call({
 DeviceType device, SpeedSettingDirtyField field
});




}
/// @nodoc
class _$SpeedSettingLocationCopyWithImpl<$Res>
    implements $SpeedSettingLocationCopyWith<$Res> {
  _$SpeedSettingLocationCopyWithImpl(this._self, this._then);

  final SpeedSettingLocation _self;
  final $Res Function(SpeedSettingLocation) _then;

/// Create a copy of SpeedSettingLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? device = null,Object? field = null,}) {
  return _then(_self.copyWith(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceType,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as SpeedSettingDirtyField,
  ));
}

}


/// Adds pattern-matching-related methods to [SpeedSettingLocation].
extension SpeedSettingLocationPatterns on SpeedSettingLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpeedSettingLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpeedSettingLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpeedSettingLocation value)  $default,){
final _that = this;
switch (_that) {
case _SpeedSettingLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpeedSettingLocation value)?  $default,){
final _that = this;
switch (_that) {
case _SpeedSettingLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DeviceType device,  SpeedSettingDirtyField field)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpeedSettingLocation() when $default != null:
return $default(_that.device,_that.field);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DeviceType device,  SpeedSettingDirtyField field)  $default,) {final _that = this;
switch (_that) {
case _SpeedSettingLocation():
return $default(_that.device,_that.field);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DeviceType device,  SpeedSettingDirtyField field)?  $default,) {final _that = this;
switch (_that) {
case _SpeedSettingLocation() when $default != null:
return $default(_that.device,_that.field);case _:
  return null;

}
}

}

/// @nodoc


class _SpeedSettingLocation implements SpeedSettingLocation {
  const _SpeedSettingLocation({required this.device, required this.field});
  

@override final  DeviceType device;
@override final  SpeedSettingDirtyField field;

/// Create a copy of SpeedSettingLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpeedSettingLocationCopyWith<_SpeedSettingLocation> get copyWith => __$SpeedSettingLocationCopyWithImpl<_SpeedSettingLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpeedSettingLocation&&(identical(other.device, device) || other.device == device)&&(identical(other.field, field) || other.field == field));
}


@override
int get hashCode => Object.hash(runtimeType,device,field);

@override
String toString() {
  return 'SpeedSettingLocation(device: $device, field: $field)';
}


}

/// @nodoc
abstract mixin class _$SpeedSettingLocationCopyWith<$Res> implements $SpeedSettingLocationCopyWith<$Res> {
  factory _$SpeedSettingLocationCopyWith(_SpeedSettingLocation value, $Res Function(_SpeedSettingLocation) _then) = __$SpeedSettingLocationCopyWithImpl;
@override @useResult
$Res call({
 DeviceType device, SpeedSettingDirtyField field
});




}
/// @nodoc
class __$SpeedSettingLocationCopyWithImpl<$Res>
    implements _$SpeedSettingLocationCopyWith<$Res> {
  __$SpeedSettingLocationCopyWithImpl(this._self, this._then);

  final _SpeedSettingLocation _self;
  final $Res Function(_SpeedSettingLocation) _then;

/// Create a copy of SpeedSettingLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? device = null,Object? field = null,}) {
  return _then(_SpeedSettingLocation(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as DeviceType,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as SpeedSettingDirtyField,
  ));
}


}

// dart format on
