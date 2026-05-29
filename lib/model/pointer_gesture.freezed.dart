// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pointer_gesture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PointerGesture {

 TriggerCommon get common;
/// Create a copy of PointerGesture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointerGestureCopyWith<PointerGesture> get copyWith => _$PointerGestureCopyWithImpl<PointerGesture>(this as PointerGesture, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointerGesture&&(identical(other.common, common) || other.common == common));
}


@override
int get hashCode => Object.hash(runtimeType,common);

@override
String toString() {
  return 'PointerGesture(common: $common)';
}


}

/// @nodoc
abstract mixin class $PointerGestureCopyWith<$Res>  {
  factory $PointerGestureCopyWith(PointerGesture value, $Res Function(PointerGesture) _then) = _$PointerGestureCopyWithImpl;
@useResult
$Res call({
 TriggerCommon common
});


$TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$PointerGestureCopyWithImpl<$Res>
    implements $PointerGestureCopyWith<$Res> {
  _$PointerGestureCopyWithImpl(this._self, this._then);

  final PointerGesture _self;
  final $Res Function(PointerGesture) _then;

/// Create a copy of PointerGesture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? common = null,}) {
  return _then(_self.copyWith(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,
  ));
}
/// Create a copy of PointerGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}


/// Adds pattern-matching-related methods to [PointerGesture].
extension PointerGesturePatterns on PointerGesture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HoverGesture value)?  hover,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HoverGesture() when hover != null:
return hover(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HoverGesture value)  hover,}){
final _that = this;
switch (_that) {
case HoverGesture():
return hover(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HoverGesture value)?  hover,}){
final _that = this;
switch (_that) {
case HoverGesture() when hover != null:
return hover(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TriggerCommon common)?  hover,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HoverGesture() when hover != null:
return hover(_that.common);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TriggerCommon common)  hover,}) {final _that = this;
switch (_that) {
case HoverGesture():
return hover(_that.common);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TriggerCommon common)?  hover,}) {final _that = this;
switch (_that) {
case HoverGesture() when hover != null:
return hover(_that.common);case _:
  return null;

}
}

}

/// @nodoc


class HoverGesture extends PointerGesture {
  const HoverGesture({required this.common}): super._();
  

@override final  TriggerCommon common;

/// Create a copy of PointerGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HoverGestureCopyWith<HoverGesture> get copyWith => _$HoverGestureCopyWithImpl<HoverGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HoverGesture&&(identical(other.common, common) || other.common == common));
}


@override
int get hashCode => Object.hash(runtimeType,common);

@override
String toString() {
  return 'PointerGesture.hover(common: $common)';
}


}

/// @nodoc
abstract mixin class $HoverGestureCopyWith<$Res> implements $PointerGestureCopyWith<$Res> {
  factory $HoverGestureCopyWith(HoverGesture value, $Res Function(HoverGesture) _then) = _$HoverGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common
});


@override $TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$HoverGestureCopyWithImpl<$Res>
    implements $HoverGestureCopyWith<$Res> {
  _$HoverGestureCopyWithImpl(this._self, this._then);

  final HoverGesture _self;
  final $Res Function(HoverGesture) _then;

/// Create a copy of PointerGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,}) {
  return _then(HoverGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,
  ));
}

/// Create a copy of PointerGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}

// dart format on
