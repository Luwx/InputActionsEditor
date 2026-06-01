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
mixin _$GestureEditorVm {

 GestureLocation get location; Object? get gesture; TriggerCommon? get common; DirtyMarkState get triggerDirtyState; TriggerCommon? get savedCommon;
/// Create a copy of GestureEditorVm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureEditorVmCopyWith<GestureEditorVm> get copyWith => _$GestureEditorVmCopyWithImpl<GestureEditorVm>(this as GestureEditorVm, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureEditorVm&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.gesture, gesture)&&(identical(other.common, common) || other.common == common)&&(identical(other.triggerDirtyState, triggerDirtyState) || other.triggerDirtyState == triggerDirtyState)&&(identical(other.savedCommon, savedCommon) || other.savedCommon == savedCommon));
}


@override
int get hashCode => Object.hash(runtimeType,location,const DeepCollectionEquality().hash(gesture),common,triggerDirtyState,savedCommon);

@override
String toString() {
  return 'GestureEditorVm(location: $location, gesture: $gesture, common: $common, triggerDirtyState: $triggerDirtyState, savedCommon: $savedCommon)';
}


}

/// @nodoc
abstract mixin class $GestureEditorVmCopyWith<$Res>  {
  factory $GestureEditorVmCopyWith(GestureEditorVm value, $Res Function(GestureEditorVm) _then) = _$GestureEditorVmCopyWithImpl;
@useResult
$Res call({
 GestureLocation location, Object? gesture, TriggerCommon? common, DirtyMarkState triggerDirtyState, TriggerCommon? savedCommon
});


$GestureLocationCopyWith<$Res> get location;$TriggerCommonCopyWith<$Res>? get common;$TriggerCommonCopyWith<$Res>? get savedCommon;

}
/// @nodoc
class _$GestureEditorVmCopyWithImpl<$Res>
    implements $GestureEditorVmCopyWith<$Res> {
  _$GestureEditorVmCopyWithImpl(this._self, this._then);

  final GestureEditorVm _self;
  final $Res Function(GestureEditorVm) _then;

/// Create a copy of GestureEditorVm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = null,Object? gesture = freezed,Object? common = freezed,Object? triggerDirtyState = null,Object? savedCommon = freezed,}) {
  return _then(_self.copyWith(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GestureLocation,gesture: freezed == gesture ? _self.gesture : gesture ,common: freezed == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon?,triggerDirtyState: null == triggerDirtyState ? _self.triggerDirtyState : triggerDirtyState // ignore: cast_nullable_to_non_nullable
as DirtyMarkState,savedCommon: freezed == savedCommon ? _self.savedCommon : savedCommon // ignore: cast_nullable_to_non_nullable
as TriggerCommon?,
  ));
}
/// Create a copy of GestureEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get location {
  
  return $GestureLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of GestureEditorVm
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
}/// Create a copy of GestureEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res>? get savedCommon {
    if (_self.savedCommon == null) {
    return null;
  }

  return $TriggerCommonCopyWith<$Res>(_self.savedCommon!, (value) {
    return _then(_self.copyWith(savedCommon: value));
  });
}
}


/// Adds pattern-matching-related methods to [GestureEditorVm].
extension GestureEditorVmPatterns on GestureEditorVm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestureEditorVm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestureEditorVm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestureEditorVm value)  $default,){
final _that = this;
switch (_that) {
case _GestureEditorVm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestureEditorVm value)?  $default,){
final _that = this;
switch (_that) {
case _GestureEditorVm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GestureLocation location,  Object? gesture,  TriggerCommon? common,  DirtyMarkState triggerDirtyState,  TriggerCommon? savedCommon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestureEditorVm() when $default != null:
return $default(_that.location,_that.gesture,_that.common,_that.triggerDirtyState,_that.savedCommon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GestureLocation location,  Object? gesture,  TriggerCommon? common,  DirtyMarkState triggerDirtyState,  TriggerCommon? savedCommon)  $default,) {final _that = this;
switch (_that) {
case _GestureEditorVm():
return $default(_that.location,_that.gesture,_that.common,_that.triggerDirtyState,_that.savedCommon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GestureLocation location,  Object? gesture,  TriggerCommon? common,  DirtyMarkState triggerDirtyState,  TriggerCommon? savedCommon)?  $default,) {final _that = this;
switch (_that) {
case _GestureEditorVm() when $default != null:
return $default(_that.location,_that.gesture,_that.common,_that.triggerDirtyState,_that.savedCommon);case _:
  return null;

}
}

}

/// @nodoc


class _GestureEditorVm extends GestureEditorVm {
  const _GestureEditorVm({required this.location, required this.gesture, required this.common, required this.triggerDirtyState, required this.savedCommon}): super._();
  

@override final  GestureLocation location;
@override final  Object? gesture;
@override final  TriggerCommon? common;
@override final  DirtyMarkState triggerDirtyState;
@override final  TriggerCommon? savedCommon;

/// Create a copy of GestureEditorVm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestureEditorVmCopyWith<_GestureEditorVm> get copyWith => __$GestureEditorVmCopyWithImpl<_GestureEditorVm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureEditorVm&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.gesture, gesture)&&(identical(other.common, common) || other.common == common)&&(identical(other.triggerDirtyState, triggerDirtyState) || other.triggerDirtyState == triggerDirtyState)&&(identical(other.savedCommon, savedCommon) || other.savedCommon == savedCommon));
}


@override
int get hashCode => Object.hash(runtimeType,location,const DeepCollectionEquality().hash(gesture),common,triggerDirtyState,savedCommon);

@override
String toString() {
  return 'GestureEditorVm(location: $location, gesture: $gesture, common: $common, triggerDirtyState: $triggerDirtyState, savedCommon: $savedCommon)';
}


}

/// @nodoc
abstract mixin class _$GestureEditorVmCopyWith<$Res> implements $GestureEditorVmCopyWith<$Res> {
  factory _$GestureEditorVmCopyWith(_GestureEditorVm value, $Res Function(_GestureEditorVm) _then) = __$GestureEditorVmCopyWithImpl;
@override @useResult
$Res call({
 GestureLocation location, Object? gesture, TriggerCommon? common, DirtyMarkState triggerDirtyState, TriggerCommon? savedCommon
});


@override $GestureLocationCopyWith<$Res> get location;@override $TriggerCommonCopyWith<$Res>? get common;@override $TriggerCommonCopyWith<$Res>? get savedCommon;

}
/// @nodoc
class __$GestureEditorVmCopyWithImpl<$Res>
    implements _$GestureEditorVmCopyWith<$Res> {
  __$GestureEditorVmCopyWithImpl(this._self, this._then);

  final _GestureEditorVm _self;
  final $Res Function(_GestureEditorVm) _then;

/// Create a copy of GestureEditorVm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = null,Object? gesture = freezed,Object? common = freezed,Object? triggerDirtyState = null,Object? savedCommon = freezed,}) {
  return _then(_GestureEditorVm(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GestureLocation,gesture: freezed == gesture ? _self.gesture : gesture ,common: freezed == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon?,triggerDirtyState: null == triggerDirtyState ? _self.triggerDirtyState : triggerDirtyState // ignore: cast_nullable_to_non_nullable
as DirtyMarkState,savedCommon: freezed == savedCommon ? _self.savedCommon : savedCommon // ignore: cast_nullable_to_non_nullable
as TriggerCommon?,
  ));
}

/// Create a copy of GestureEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get location {
  
  return $GestureLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of GestureEditorVm
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
}/// Create a copy of GestureEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res>? get savedCommon {
    if (_self.savedCommon == null) {
    return null;
  }

  return $TriggerCommonCopyWith<$Res>(_self.savedCommon!, (value) {
    return _then(_self.copyWith(savedCommon: value));
  });
}
}

// dart format on
