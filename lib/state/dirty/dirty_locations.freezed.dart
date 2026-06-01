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

// dart format on
