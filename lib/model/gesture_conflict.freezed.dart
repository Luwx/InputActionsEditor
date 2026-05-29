// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gesture_conflict.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GestureConflict {

 GestureRef get a; GestureRef get b; String get aLabel; String get bLabel; ConflictKind get kind; String get reason;
/// Create a copy of GestureConflict
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureConflictCopyWith<GestureConflict> get copyWith => _$GestureConflictCopyWithImpl<GestureConflict>(this as GestureConflict, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureConflict&&(identical(other.a, a) || other.a == a)&&(identical(other.b, b) || other.b == b)&&(identical(other.aLabel, aLabel) || other.aLabel == aLabel)&&(identical(other.bLabel, bLabel) || other.bLabel == bLabel)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,a,b,aLabel,bLabel,kind,reason);

@override
String toString() {
  return 'GestureConflict(a: $a, b: $b, aLabel: $aLabel, bLabel: $bLabel, kind: $kind, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $GestureConflictCopyWith<$Res>  {
  factory $GestureConflictCopyWith(GestureConflict value, $Res Function(GestureConflict) _then) = _$GestureConflictCopyWithImpl;
@useResult
$Res call({
 GestureRef a, GestureRef b, String aLabel, String bLabel, ConflictKind kind, String reason
});




}
/// @nodoc
class _$GestureConflictCopyWithImpl<$Res>
    implements $GestureConflictCopyWith<$Res> {
  _$GestureConflictCopyWithImpl(this._self, this._then);

  final GestureConflict _self;
  final $Res Function(GestureConflict) _then;

/// Create a copy of GestureConflict
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = null,Object? b = null,Object? aLabel = null,Object? bLabel = null,Object? kind = null,Object? reason = null,}) {
  return _then(_self.copyWith(
a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as GestureRef,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as GestureRef,aLabel: null == aLabel ? _self.aLabel : aLabel // ignore: cast_nullable_to_non_nullable
as String,bLabel: null == bLabel ? _self.bLabel : bLabel // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConflictKind,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GestureConflict].
extension GestureConflictPatterns on GestureConflict {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GestureConflict value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GestureConflict() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GestureConflict value)  $default,){
final _that = this;
switch (_that) {
case _GestureConflict():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GestureConflict value)?  $default,){
final _that = this;
switch (_that) {
case _GestureConflict() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GestureRef a,  GestureRef b,  String aLabel,  String bLabel,  ConflictKind kind,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GestureConflict() when $default != null:
return $default(_that.a,_that.b,_that.aLabel,_that.bLabel,_that.kind,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GestureRef a,  GestureRef b,  String aLabel,  String bLabel,  ConflictKind kind,  String reason)  $default,) {final _that = this;
switch (_that) {
case _GestureConflict():
return $default(_that.a,_that.b,_that.aLabel,_that.bLabel,_that.kind,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GestureRef a,  GestureRef b,  String aLabel,  String bLabel,  ConflictKind kind,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _GestureConflict() when $default != null:
return $default(_that.a,_that.b,_that.aLabel,_that.bLabel,_that.kind,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _GestureConflict extends GestureConflict {
  const _GestureConflict({required this.a, required this.b, required this.aLabel, required this.bLabel, required this.kind, required this.reason}): super._();
  

@override final  GestureRef a;
@override final  GestureRef b;
@override final  String aLabel;
@override final  String bLabel;
@override final  ConflictKind kind;
@override final  String reason;

/// Create a copy of GestureConflict
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GestureConflictCopyWith<_GestureConflict> get copyWith => __$GestureConflictCopyWithImpl<_GestureConflict>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GestureConflict&&(identical(other.a, a) || other.a == a)&&(identical(other.b, b) || other.b == b)&&(identical(other.aLabel, aLabel) || other.aLabel == aLabel)&&(identical(other.bLabel, bLabel) || other.bLabel == bLabel)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,a,b,aLabel,bLabel,kind,reason);

@override
String toString() {
  return 'GestureConflict(a: $a, b: $b, aLabel: $aLabel, bLabel: $bLabel, kind: $kind, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$GestureConflictCopyWith<$Res> implements $GestureConflictCopyWith<$Res> {
  factory _$GestureConflictCopyWith(_GestureConflict value, $Res Function(_GestureConflict) _then) = __$GestureConflictCopyWithImpl;
@override @useResult
$Res call({
 GestureRef a, GestureRef b, String aLabel, String bLabel, ConflictKind kind, String reason
});




}
/// @nodoc
class __$GestureConflictCopyWithImpl<$Res>
    implements _$GestureConflictCopyWith<$Res> {
  __$GestureConflictCopyWithImpl(this._self, this._then);

  final _GestureConflict _self;
  final $Res Function(_GestureConflict) _then;

/// Create a copy of GestureConflict
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = null,Object? b = null,Object? aLabel = null,Object? bLabel = null,Object? kind = null,Object? reason = null,}) {
  return _then(_GestureConflict(
a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as GestureRef,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as GestureRef,aLabel: null == aLabel ? _self.aLabel : aLabel // ignore: cast_nullable_to_non_nullable
as String,bLabel: null == bLabel ? _self.bLabel : bLabel // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ConflictKind,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
