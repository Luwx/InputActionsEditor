// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'touchpad_gesture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TouchpadGesture {

 TriggerCommon get common; int? get fingers;
/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadGestureCopyWith<TouchpadGesture> get copyWith => _$TouchpadGestureCopyWithImpl<TouchpadGesture>(this as TouchpadGesture, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers);

@override
String toString() {
  return 'TouchpadGesture(common: $common, fingers: $fingers)';
}


}

/// @nodoc
abstract mixin class $TouchpadGestureCopyWith<$Res>  {
  factory $TouchpadGestureCopyWith(TouchpadGesture value, $Res Function(TouchpadGesture) _then) = _$TouchpadGestureCopyWithImpl;
@useResult
$Res call({
 TriggerCommon common, int? fingers
});


$TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$TouchpadGestureCopyWithImpl<$Res>
    implements $TouchpadGestureCopyWith<$Res> {
  _$TouchpadGestureCopyWithImpl(this._self, this._then);

  final TouchpadGesture _self;
  final $Res Function(TouchpadGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? common = null,Object? fingers = freezed,}) {
  return _then(_self.copyWith(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}


/// Adds pattern-matching-related methods to [TouchpadGesture].
extension TouchpadGesturePatterns on TouchpadGesture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TouchpadSwipeGesture value)?  swipe,TResult Function( TouchpadPinchGesture value)?  pinch,TResult Function( TouchpadRotateGesture value)?  rotate,TResult Function( TouchpadCircleGesture value)?  circle,TResult Function( TouchpadTapGesture value)?  tap,TResult Function( TouchpadClickGesture value)?  click,TResult Function( TouchpadHoldGesture value)?  hold,TResult Function( TouchpadStrokeGesture value)?  stroke,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TouchpadSwipeGesture() when swipe != null:
return swipe(_that);case TouchpadPinchGesture() when pinch != null:
return pinch(_that);case TouchpadRotateGesture() when rotate != null:
return rotate(_that);case TouchpadCircleGesture() when circle != null:
return circle(_that);case TouchpadTapGesture() when tap != null:
return tap(_that);case TouchpadClickGesture() when click != null:
return click(_that);case TouchpadHoldGesture() when hold != null:
return hold(_that);case TouchpadStrokeGesture() when stroke != null:
return stroke(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TouchpadSwipeGesture value)  swipe,required TResult Function( TouchpadPinchGesture value)  pinch,required TResult Function( TouchpadRotateGesture value)  rotate,required TResult Function( TouchpadCircleGesture value)  circle,required TResult Function( TouchpadTapGesture value)  tap,required TResult Function( TouchpadClickGesture value)  click,required TResult Function( TouchpadHoldGesture value)  hold,required TResult Function( TouchpadStrokeGesture value)  stroke,}){
final _that = this;
switch (_that) {
case TouchpadSwipeGesture():
return swipe(_that);case TouchpadPinchGesture():
return pinch(_that);case TouchpadRotateGesture():
return rotate(_that);case TouchpadCircleGesture():
return circle(_that);case TouchpadTapGesture():
return tap(_that);case TouchpadClickGesture():
return click(_that);case TouchpadHoldGesture():
return hold(_that);case TouchpadStrokeGesture():
return stroke(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TouchpadSwipeGesture value)?  swipe,TResult? Function( TouchpadPinchGesture value)?  pinch,TResult? Function( TouchpadRotateGesture value)?  rotate,TResult? Function( TouchpadCircleGesture value)?  circle,TResult? Function( TouchpadTapGesture value)?  tap,TResult? Function( TouchpadClickGesture value)?  click,TResult? Function( TouchpadHoldGesture value)?  hold,TResult? Function( TouchpadStrokeGesture value)?  stroke,}){
final _that = this;
switch (_that) {
case TouchpadSwipeGesture() when swipe != null:
return swipe(_that);case TouchpadPinchGesture() when pinch != null:
return pinch(_that);case TouchpadRotateGesture() when rotate != null:
return rotate(_that);case TouchpadCircleGesture() when circle != null:
return circle(_that);case TouchpadTapGesture() when tap != null:
return tap(_that);case TouchpadClickGesture() when click != null:
return click(_that);case TouchpadHoldGesture() when hold != null:
return hold(_that);case TouchpadStrokeGesture() when stroke != null:
return stroke(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TriggerCommon common,  SwipeMode mode,  int? fingers,  MotionCommon motion)?  swipe,TResult Function( TriggerCommon common,  int? fingers,  PinchDirection direction,  MotionCommon motion)?  pinch,TResult Function( TriggerCommon common,  int? fingers,  RotateDirection direction,  MotionCommon motion)?  rotate,TResult Function( TriggerCommon common,  int? fingers,  CircleDirection direction,  MotionCommon motion)?  circle,TResult Function( TriggerCommon common,  int? fingers)?  tap,TResult Function( TriggerCommon common,  int? fingers)?  click,TResult Function( TriggerCommon common,  int? fingers)?  hold,TResult Function( TriggerCommon common,  int? fingers,  List<String> strokes,  MotionCommon motion)?  stroke,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TouchpadSwipeGesture() when swipe != null:
return swipe(_that.common,_that.mode,_that.fingers,_that.motion);case TouchpadPinchGesture() when pinch != null:
return pinch(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadRotateGesture() when rotate != null:
return rotate(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadCircleGesture() when circle != null:
return circle(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadTapGesture() when tap != null:
return tap(_that.common,_that.fingers);case TouchpadClickGesture() when click != null:
return click(_that.common,_that.fingers);case TouchpadHoldGesture() when hold != null:
return hold(_that.common,_that.fingers);case TouchpadStrokeGesture() when stroke != null:
return stroke(_that.common,_that.fingers,_that.strokes,_that.motion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TriggerCommon common,  SwipeMode mode,  int? fingers,  MotionCommon motion)  swipe,required TResult Function( TriggerCommon common,  int? fingers,  PinchDirection direction,  MotionCommon motion)  pinch,required TResult Function( TriggerCommon common,  int? fingers,  RotateDirection direction,  MotionCommon motion)  rotate,required TResult Function( TriggerCommon common,  int? fingers,  CircleDirection direction,  MotionCommon motion)  circle,required TResult Function( TriggerCommon common,  int? fingers)  tap,required TResult Function( TriggerCommon common,  int? fingers)  click,required TResult Function( TriggerCommon common,  int? fingers)  hold,required TResult Function( TriggerCommon common,  int? fingers,  List<String> strokes,  MotionCommon motion)  stroke,}) {final _that = this;
switch (_that) {
case TouchpadSwipeGesture():
return swipe(_that.common,_that.mode,_that.fingers,_that.motion);case TouchpadPinchGesture():
return pinch(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadRotateGesture():
return rotate(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadCircleGesture():
return circle(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadTapGesture():
return tap(_that.common,_that.fingers);case TouchpadClickGesture():
return click(_that.common,_that.fingers);case TouchpadHoldGesture():
return hold(_that.common,_that.fingers);case TouchpadStrokeGesture():
return stroke(_that.common,_that.fingers,_that.strokes,_that.motion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TriggerCommon common,  SwipeMode mode,  int? fingers,  MotionCommon motion)?  swipe,TResult? Function( TriggerCommon common,  int? fingers,  PinchDirection direction,  MotionCommon motion)?  pinch,TResult? Function( TriggerCommon common,  int? fingers,  RotateDirection direction,  MotionCommon motion)?  rotate,TResult? Function( TriggerCommon common,  int? fingers,  CircleDirection direction,  MotionCommon motion)?  circle,TResult? Function( TriggerCommon common,  int? fingers)?  tap,TResult? Function( TriggerCommon common,  int? fingers)?  click,TResult? Function( TriggerCommon common,  int? fingers)?  hold,TResult? Function( TriggerCommon common,  int? fingers,  List<String> strokes,  MotionCommon motion)?  stroke,}) {final _that = this;
switch (_that) {
case TouchpadSwipeGesture() when swipe != null:
return swipe(_that.common,_that.mode,_that.fingers,_that.motion);case TouchpadPinchGesture() when pinch != null:
return pinch(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadRotateGesture() when rotate != null:
return rotate(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadCircleGesture() when circle != null:
return circle(_that.common,_that.fingers,_that.direction,_that.motion);case TouchpadTapGesture() when tap != null:
return tap(_that.common,_that.fingers);case TouchpadClickGesture() when click != null:
return click(_that.common,_that.fingers);case TouchpadHoldGesture() when hold != null:
return hold(_that.common,_that.fingers);case TouchpadStrokeGesture() when stroke != null:
return stroke(_that.common,_that.fingers,_that.strokes,_that.motion);case _:
  return null;

}
}

}

/// @nodoc


class TouchpadSwipeGesture extends TouchpadGesture {
  const TouchpadSwipeGesture({required this.common, required this.mode, this.fingers, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
 final  SwipeMode mode;
@override final  int? fingers;
@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadSwipeGestureCopyWith<TouchpadSwipeGesture> get copyWith => _$TouchpadSwipeGestureCopyWithImpl<TouchpadSwipeGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadSwipeGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,mode,fingers,motion);

@override
String toString() {
  return 'TouchpadGesture.swipe(common: $common, mode: $mode, fingers: $fingers, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchpadSwipeGestureCopyWith<$Res> implements $TouchpadGestureCopyWith<$Res> {
  factory $TouchpadSwipeGestureCopyWith(TouchpadSwipeGesture value, $Res Function(TouchpadSwipeGesture) _then) = _$TouchpadSwipeGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, SwipeMode mode, int? fingers, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$SwipeModeCopyWith<$Res> get mode;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchpadSwipeGestureCopyWithImpl<$Res>
    implements $TouchpadSwipeGestureCopyWith<$Res> {
  _$TouchpadSwipeGestureCopyWithImpl(this._self, this._then);

  final TouchpadSwipeGesture _self;
  final $Res Function(TouchpadSwipeGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? mode = null,Object? fingers = freezed,Object? motion = null,}) {
  return _then(TouchpadSwipeGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SwipeMode,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwipeModeCopyWith<$Res> get mode {
  
  return $SwipeModeCopyWith<$Res>(_self.mode, (value) {
    return _then(_self.copyWith(mode: value));
  });
}/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotionCommonCopyWith<$Res> get motion {
  
  return $MotionCommonCopyWith<$Res>(_self.motion, (value) {
    return _then(_self.copyWith(motion: value));
  });
}
}

/// @nodoc


class TouchpadPinchGesture extends TouchpadGesture {
  const TouchpadPinchGesture({required this.common, this.fingers, this.direction = PinchDirection.any, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;
@JsonKey() final  PinchDirection direction;
@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadPinchGestureCopyWith<TouchpadPinchGesture> get copyWith => _$TouchpadPinchGestureCopyWithImpl<TouchpadPinchGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadPinchGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers,direction,motion);

@override
String toString() {
  return 'TouchpadGesture.pinch(common: $common, fingers: $fingers, direction: $direction, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchpadPinchGestureCopyWith<$Res> implements $TouchpadGestureCopyWith<$Res> {
  factory $TouchpadPinchGestureCopyWith(TouchpadPinchGesture value, $Res Function(TouchpadPinchGesture) _then) = _$TouchpadPinchGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers, PinchDirection direction, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchpadPinchGestureCopyWithImpl<$Res>
    implements $TouchpadPinchGestureCopyWith<$Res> {
  _$TouchpadPinchGestureCopyWithImpl(this._self, this._then);

  final TouchpadPinchGesture _self;
  final $Res Function(TouchpadPinchGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,Object? direction = null,Object? motion = null,}) {
  return _then(TouchpadPinchGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as PinchDirection,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotionCommonCopyWith<$Res> get motion {
  
  return $MotionCommonCopyWith<$Res>(_self.motion, (value) {
    return _then(_self.copyWith(motion: value));
  });
}
}

/// @nodoc


class TouchpadRotateGesture extends TouchpadGesture {
  const TouchpadRotateGesture({required this.common, this.fingers, this.direction = RotateDirection.any, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;
@JsonKey() final  RotateDirection direction;
@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadRotateGestureCopyWith<TouchpadRotateGesture> get copyWith => _$TouchpadRotateGestureCopyWithImpl<TouchpadRotateGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadRotateGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers,direction,motion);

@override
String toString() {
  return 'TouchpadGesture.rotate(common: $common, fingers: $fingers, direction: $direction, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchpadRotateGestureCopyWith<$Res> implements $TouchpadGestureCopyWith<$Res> {
  factory $TouchpadRotateGestureCopyWith(TouchpadRotateGesture value, $Res Function(TouchpadRotateGesture) _then) = _$TouchpadRotateGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers, RotateDirection direction, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchpadRotateGestureCopyWithImpl<$Res>
    implements $TouchpadRotateGestureCopyWith<$Res> {
  _$TouchpadRotateGestureCopyWithImpl(this._self, this._then);

  final TouchpadRotateGesture _self;
  final $Res Function(TouchpadRotateGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,Object? direction = null,Object? motion = null,}) {
  return _then(TouchpadRotateGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as RotateDirection,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotionCommonCopyWith<$Res> get motion {
  
  return $MotionCommonCopyWith<$Res>(_self.motion, (value) {
    return _then(_self.copyWith(motion: value));
  });
}
}

/// @nodoc


class TouchpadCircleGesture extends TouchpadGesture {
  const TouchpadCircleGesture({required this.common, this.fingers, this.direction = CircleDirection.any, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;
@JsonKey() final  CircleDirection direction;
@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadCircleGestureCopyWith<TouchpadCircleGesture> get copyWith => _$TouchpadCircleGestureCopyWithImpl<TouchpadCircleGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadCircleGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers,direction,motion);

@override
String toString() {
  return 'TouchpadGesture.circle(common: $common, fingers: $fingers, direction: $direction, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchpadCircleGestureCopyWith<$Res> implements $TouchpadGestureCopyWith<$Res> {
  factory $TouchpadCircleGestureCopyWith(TouchpadCircleGesture value, $Res Function(TouchpadCircleGesture) _then) = _$TouchpadCircleGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers, CircleDirection direction, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchpadCircleGestureCopyWithImpl<$Res>
    implements $TouchpadCircleGestureCopyWith<$Res> {
  _$TouchpadCircleGestureCopyWithImpl(this._self, this._then);

  final TouchpadCircleGesture _self;
  final $Res Function(TouchpadCircleGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,Object? direction = null,Object? motion = null,}) {
  return _then(TouchpadCircleGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as CircleDirection,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotionCommonCopyWith<$Res> get motion {
  
  return $MotionCommonCopyWith<$Res>(_self.motion, (value) {
    return _then(_self.copyWith(motion: value));
  });
}
}

/// @nodoc


class TouchpadTapGesture extends TouchpadGesture {
  const TouchpadTapGesture({required this.common, this.fingers}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadTapGestureCopyWith<TouchpadTapGesture> get copyWith => _$TouchpadTapGestureCopyWithImpl<TouchpadTapGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadTapGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers);

@override
String toString() {
  return 'TouchpadGesture.tap(common: $common, fingers: $fingers)';
}


}

/// @nodoc
abstract mixin class $TouchpadTapGestureCopyWith<$Res> implements $TouchpadGestureCopyWith<$Res> {
  factory $TouchpadTapGestureCopyWith(TouchpadTapGesture value, $Res Function(TouchpadTapGesture) _then) = _$TouchpadTapGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers
});


@override $TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$TouchpadTapGestureCopyWithImpl<$Res>
    implements $TouchpadTapGestureCopyWith<$Res> {
  _$TouchpadTapGestureCopyWithImpl(this._self, this._then);

  final TouchpadTapGesture _self;
  final $Res Function(TouchpadTapGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,}) {
  return _then(TouchpadTapGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}

/// @nodoc


class TouchpadClickGesture extends TouchpadGesture {
  const TouchpadClickGesture({required this.common, this.fingers}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadClickGestureCopyWith<TouchpadClickGesture> get copyWith => _$TouchpadClickGestureCopyWithImpl<TouchpadClickGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadClickGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers);

@override
String toString() {
  return 'TouchpadGesture.click(common: $common, fingers: $fingers)';
}


}

/// @nodoc
abstract mixin class $TouchpadClickGestureCopyWith<$Res> implements $TouchpadGestureCopyWith<$Res> {
  factory $TouchpadClickGestureCopyWith(TouchpadClickGesture value, $Res Function(TouchpadClickGesture) _then) = _$TouchpadClickGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers
});


@override $TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$TouchpadClickGestureCopyWithImpl<$Res>
    implements $TouchpadClickGestureCopyWith<$Res> {
  _$TouchpadClickGestureCopyWithImpl(this._self, this._then);

  final TouchpadClickGesture _self;
  final $Res Function(TouchpadClickGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,}) {
  return _then(TouchpadClickGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}

/// @nodoc


class TouchpadHoldGesture extends TouchpadGesture {
  const TouchpadHoldGesture({required this.common, this.fingers}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadHoldGestureCopyWith<TouchpadHoldGesture> get copyWith => _$TouchpadHoldGestureCopyWithImpl<TouchpadHoldGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadHoldGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers);

@override
String toString() {
  return 'TouchpadGesture.hold(common: $common, fingers: $fingers)';
}


}

/// @nodoc
abstract mixin class $TouchpadHoldGestureCopyWith<$Res> implements $TouchpadGestureCopyWith<$Res> {
  factory $TouchpadHoldGestureCopyWith(TouchpadHoldGesture value, $Res Function(TouchpadHoldGesture) _then) = _$TouchpadHoldGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers
});


@override $TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$TouchpadHoldGestureCopyWithImpl<$Res>
    implements $TouchpadHoldGestureCopyWith<$Res> {
  _$TouchpadHoldGestureCopyWithImpl(this._self, this._then);

  final TouchpadHoldGesture _self;
  final $Res Function(TouchpadHoldGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,}) {
  return _then(TouchpadHoldGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}

/// @nodoc


class TouchpadStrokeGesture extends TouchpadGesture {
  const TouchpadStrokeGesture({required this.common, this.fingers, final  List<String> strokes = const [], this.motion = const MotionCommon()}): _strokes = strokes,super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;
 final  List<String> _strokes;
@JsonKey() List<String> get strokes {
  if (_strokes is EqualUnmodifiableListView) return _strokes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strokes);
}

@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchpadStrokeGestureCopyWith<TouchpadStrokeGesture> get copyWith => _$TouchpadStrokeGestureCopyWithImpl<TouchpadStrokeGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchpadStrokeGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&const DeepCollectionEquality().equals(other._strokes, _strokes)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers,const DeepCollectionEquality().hash(_strokes),motion);

@override
String toString() {
  return 'TouchpadGesture.stroke(common: $common, fingers: $fingers, strokes: $strokes, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchpadStrokeGestureCopyWith<$Res> implements $TouchpadGestureCopyWith<$Res> {
  factory $TouchpadStrokeGestureCopyWith(TouchpadStrokeGesture value, $Res Function(TouchpadStrokeGesture) _then) = _$TouchpadStrokeGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers, List<String> strokes, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchpadStrokeGestureCopyWithImpl<$Res>
    implements $TouchpadStrokeGestureCopyWith<$Res> {
  _$TouchpadStrokeGestureCopyWithImpl(this._self, this._then);

  final TouchpadStrokeGesture _self;
  final $Res Function(TouchpadStrokeGesture) _then;

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,Object? strokes = null,Object? motion = null,}) {
  return _then(TouchpadStrokeGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,strokes: null == strokes ? _self._strokes : strokes // ignore: cast_nullable_to_non_nullable
as List<String>,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchpadGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotionCommonCopyWith<$Res> get motion {
  
  return $MotionCommonCopyWith<$Res>(_self.motion, (value) {
    return _then(_self.copyWith(motion: value));
  });
}
}

// dart format on
