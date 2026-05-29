// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'touchscreen_gesture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TouchscreenGesture {

 TriggerCommon get common; int? get fingers;
/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchscreenGestureCopyWith<TouchscreenGesture> get copyWith => _$TouchscreenGestureCopyWithImpl<TouchscreenGesture>(this as TouchscreenGesture, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchscreenGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers);

@override
String toString() {
  return 'TouchscreenGesture(common: $common, fingers: $fingers)';
}


}

/// @nodoc
abstract mixin class $TouchscreenGestureCopyWith<$Res>  {
  factory $TouchscreenGestureCopyWith(TouchscreenGesture value, $Res Function(TouchscreenGesture) _then) = _$TouchscreenGestureCopyWithImpl;
@useResult
$Res call({
 TriggerCommon common, int? fingers
});


$TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$TouchscreenGestureCopyWithImpl<$Res>
    implements $TouchscreenGestureCopyWith<$Res> {
  _$TouchscreenGestureCopyWithImpl(this._self, this._then);

  final TouchscreenGesture _self;
  final $Res Function(TouchscreenGesture) _then;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? common = null,Object? fingers = freezed,}) {
  return _then(_self.copyWith(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}


/// Adds pattern-matching-related methods to [TouchscreenGesture].
extension TouchscreenGesturePatterns on TouchscreenGesture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TouchscreenSwipeGesture value)?  swipe,TResult Function( TouchscreenPinchGesture value)?  pinch,TResult Function( TouchscreenRotateGesture value)?  rotate,TResult Function( TouchscreenCircleGesture value)?  circle,TResult Function( TouchscreenTapGesture value)?  tap,TResult Function( TouchscreenHoldGesture value)?  hold,TResult Function( TouchscreenStrokeGesture value)?  stroke,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TouchscreenSwipeGesture() when swipe != null:
return swipe(_that);case TouchscreenPinchGesture() when pinch != null:
return pinch(_that);case TouchscreenRotateGesture() when rotate != null:
return rotate(_that);case TouchscreenCircleGesture() when circle != null:
return circle(_that);case TouchscreenTapGesture() when tap != null:
return tap(_that);case TouchscreenHoldGesture() when hold != null:
return hold(_that);case TouchscreenStrokeGesture() when stroke != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TouchscreenSwipeGesture value)  swipe,required TResult Function( TouchscreenPinchGesture value)  pinch,required TResult Function( TouchscreenRotateGesture value)  rotate,required TResult Function( TouchscreenCircleGesture value)  circle,required TResult Function( TouchscreenTapGesture value)  tap,required TResult Function( TouchscreenHoldGesture value)  hold,required TResult Function( TouchscreenStrokeGesture value)  stroke,}){
final _that = this;
switch (_that) {
case TouchscreenSwipeGesture():
return swipe(_that);case TouchscreenPinchGesture():
return pinch(_that);case TouchscreenRotateGesture():
return rotate(_that);case TouchscreenCircleGesture():
return circle(_that);case TouchscreenTapGesture():
return tap(_that);case TouchscreenHoldGesture():
return hold(_that);case TouchscreenStrokeGesture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TouchscreenSwipeGesture value)?  swipe,TResult? Function( TouchscreenPinchGesture value)?  pinch,TResult? Function( TouchscreenRotateGesture value)?  rotate,TResult? Function( TouchscreenCircleGesture value)?  circle,TResult? Function( TouchscreenTapGesture value)?  tap,TResult? Function( TouchscreenHoldGesture value)?  hold,TResult? Function( TouchscreenStrokeGesture value)?  stroke,}){
final _that = this;
switch (_that) {
case TouchscreenSwipeGesture() when swipe != null:
return swipe(_that);case TouchscreenPinchGesture() when pinch != null:
return pinch(_that);case TouchscreenRotateGesture() when rotate != null:
return rotate(_that);case TouchscreenCircleGesture() when circle != null:
return circle(_that);case TouchscreenTapGesture() when tap != null:
return tap(_that);case TouchscreenHoldGesture() when hold != null:
return hold(_that);case TouchscreenStrokeGesture() when stroke != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TriggerCommon common,  SwipeMode mode,  int? fingers,  MotionCommon motion)?  swipe,TResult Function( TriggerCommon common,  int? fingers,  PinchDirection direction,  MotionCommon motion)?  pinch,TResult Function( TriggerCommon common,  int? fingers,  RotateDirection direction,  MotionCommon motion)?  rotate,TResult Function( TriggerCommon common,  int? fingers,  CircleDirection direction,  MotionCommon motion)?  circle,TResult Function( TriggerCommon common,  int? fingers)?  tap,TResult Function( TriggerCommon common,  int? fingers)?  hold,TResult Function( TriggerCommon common,  int? fingers,  List<String> strokes,  MotionCommon motion)?  stroke,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TouchscreenSwipeGesture() when swipe != null:
return swipe(_that.common,_that.mode,_that.fingers,_that.motion);case TouchscreenPinchGesture() when pinch != null:
return pinch(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenRotateGesture() when rotate != null:
return rotate(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenCircleGesture() when circle != null:
return circle(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenTapGesture() when tap != null:
return tap(_that.common,_that.fingers);case TouchscreenHoldGesture() when hold != null:
return hold(_that.common,_that.fingers);case TouchscreenStrokeGesture() when stroke != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TriggerCommon common,  SwipeMode mode,  int? fingers,  MotionCommon motion)  swipe,required TResult Function( TriggerCommon common,  int? fingers,  PinchDirection direction,  MotionCommon motion)  pinch,required TResult Function( TriggerCommon common,  int? fingers,  RotateDirection direction,  MotionCommon motion)  rotate,required TResult Function( TriggerCommon common,  int? fingers,  CircleDirection direction,  MotionCommon motion)  circle,required TResult Function( TriggerCommon common,  int? fingers)  tap,required TResult Function( TriggerCommon common,  int? fingers)  hold,required TResult Function( TriggerCommon common,  int? fingers,  List<String> strokes,  MotionCommon motion)  stroke,}) {final _that = this;
switch (_that) {
case TouchscreenSwipeGesture():
return swipe(_that.common,_that.mode,_that.fingers,_that.motion);case TouchscreenPinchGesture():
return pinch(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenRotateGesture():
return rotate(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenCircleGesture():
return circle(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenTapGesture():
return tap(_that.common,_that.fingers);case TouchscreenHoldGesture():
return hold(_that.common,_that.fingers);case TouchscreenStrokeGesture():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TriggerCommon common,  SwipeMode mode,  int? fingers,  MotionCommon motion)?  swipe,TResult? Function( TriggerCommon common,  int? fingers,  PinchDirection direction,  MotionCommon motion)?  pinch,TResult? Function( TriggerCommon common,  int? fingers,  RotateDirection direction,  MotionCommon motion)?  rotate,TResult? Function( TriggerCommon common,  int? fingers,  CircleDirection direction,  MotionCommon motion)?  circle,TResult? Function( TriggerCommon common,  int? fingers)?  tap,TResult? Function( TriggerCommon common,  int? fingers)?  hold,TResult? Function( TriggerCommon common,  int? fingers,  List<String> strokes,  MotionCommon motion)?  stroke,}) {final _that = this;
switch (_that) {
case TouchscreenSwipeGesture() when swipe != null:
return swipe(_that.common,_that.mode,_that.fingers,_that.motion);case TouchscreenPinchGesture() when pinch != null:
return pinch(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenRotateGesture() when rotate != null:
return rotate(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenCircleGesture() when circle != null:
return circle(_that.common,_that.fingers,_that.direction,_that.motion);case TouchscreenTapGesture() when tap != null:
return tap(_that.common,_that.fingers);case TouchscreenHoldGesture() when hold != null:
return hold(_that.common,_that.fingers);case TouchscreenStrokeGesture() when stroke != null:
return stroke(_that.common,_that.fingers,_that.strokes,_that.motion);case _:
  return null;

}
}

}

/// @nodoc


class TouchscreenSwipeGesture extends TouchscreenGesture {
  const TouchscreenSwipeGesture({required this.common, required this.mode, this.fingers, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
 final  SwipeMode mode;
@override final  int? fingers;
@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchscreenSwipeGestureCopyWith<TouchscreenSwipeGesture> get copyWith => _$TouchscreenSwipeGestureCopyWithImpl<TouchscreenSwipeGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchscreenSwipeGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,mode,fingers,motion);

@override
String toString() {
  return 'TouchscreenGesture.swipe(common: $common, mode: $mode, fingers: $fingers, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchscreenSwipeGestureCopyWith<$Res> implements $TouchscreenGestureCopyWith<$Res> {
  factory $TouchscreenSwipeGestureCopyWith(TouchscreenSwipeGesture value, $Res Function(TouchscreenSwipeGesture) _then) = _$TouchscreenSwipeGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, SwipeMode mode, int? fingers, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$SwipeModeCopyWith<$Res> get mode;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchscreenSwipeGestureCopyWithImpl<$Res>
    implements $TouchscreenSwipeGestureCopyWith<$Res> {
  _$TouchscreenSwipeGestureCopyWithImpl(this._self, this._then);

  final TouchscreenSwipeGesture _self;
  final $Res Function(TouchscreenSwipeGesture) _then;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? mode = null,Object? fingers = freezed,Object? motion = null,}) {
  return _then(TouchscreenSwipeGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SwipeMode,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwipeModeCopyWith<$Res> get mode {
  
  return $SwipeModeCopyWith<$Res>(_self.mode, (value) {
    return _then(_self.copyWith(mode: value));
  });
}/// Create a copy of TouchscreenGesture
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


class TouchscreenPinchGesture extends TouchscreenGesture {
  const TouchscreenPinchGesture({required this.common, this.fingers, this.direction = PinchDirection.any, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;
@JsonKey() final  PinchDirection direction;
@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchscreenPinchGestureCopyWith<TouchscreenPinchGesture> get copyWith => _$TouchscreenPinchGestureCopyWithImpl<TouchscreenPinchGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchscreenPinchGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers,direction,motion);

@override
String toString() {
  return 'TouchscreenGesture.pinch(common: $common, fingers: $fingers, direction: $direction, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchscreenPinchGestureCopyWith<$Res> implements $TouchscreenGestureCopyWith<$Res> {
  factory $TouchscreenPinchGestureCopyWith(TouchscreenPinchGesture value, $Res Function(TouchscreenPinchGesture) _then) = _$TouchscreenPinchGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers, PinchDirection direction, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchscreenPinchGestureCopyWithImpl<$Res>
    implements $TouchscreenPinchGestureCopyWith<$Res> {
  _$TouchscreenPinchGestureCopyWithImpl(this._self, this._then);

  final TouchscreenPinchGesture _self;
  final $Res Function(TouchscreenPinchGesture) _then;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,Object? direction = null,Object? motion = null,}) {
  return _then(TouchscreenPinchGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as PinchDirection,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchscreenGesture
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


class TouchscreenRotateGesture extends TouchscreenGesture {
  const TouchscreenRotateGesture({required this.common, this.fingers, this.direction = RotateDirection.any, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;
@JsonKey() final  RotateDirection direction;
@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchscreenRotateGestureCopyWith<TouchscreenRotateGesture> get copyWith => _$TouchscreenRotateGestureCopyWithImpl<TouchscreenRotateGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchscreenRotateGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers,direction,motion);

@override
String toString() {
  return 'TouchscreenGesture.rotate(common: $common, fingers: $fingers, direction: $direction, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchscreenRotateGestureCopyWith<$Res> implements $TouchscreenGestureCopyWith<$Res> {
  factory $TouchscreenRotateGestureCopyWith(TouchscreenRotateGesture value, $Res Function(TouchscreenRotateGesture) _then) = _$TouchscreenRotateGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers, RotateDirection direction, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchscreenRotateGestureCopyWithImpl<$Res>
    implements $TouchscreenRotateGestureCopyWith<$Res> {
  _$TouchscreenRotateGestureCopyWithImpl(this._self, this._then);

  final TouchscreenRotateGesture _self;
  final $Res Function(TouchscreenRotateGesture) _then;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,Object? direction = null,Object? motion = null,}) {
  return _then(TouchscreenRotateGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as RotateDirection,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchscreenGesture
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


class TouchscreenCircleGesture extends TouchscreenGesture {
  const TouchscreenCircleGesture({required this.common, this.fingers, this.direction = CircleDirection.any, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;
@JsonKey() final  CircleDirection direction;
@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchscreenCircleGestureCopyWith<TouchscreenCircleGesture> get copyWith => _$TouchscreenCircleGestureCopyWithImpl<TouchscreenCircleGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchscreenCircleGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers,direction,motion);

@override
String toString() {
  return 'TouchscreenGesture.circle(common: $common, fingers: $fingers, direction: $direction, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchscreenCircleGestureCopyWith<$Res> implements $TouchscreenGestureCopyWith<$Res> {
  factory $TouchscreenCircleGestureCopyWith(TouchscreenCircleGesture value, $Res Function(TouchscreenCircleGesture) _then) = _$TouchscreenCircleGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers, CircleDirection direction, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchscreenCircleGestureCopyWithImpl<$Res>
    implements $TouchscreenCircleGestureCopyWith<$Res> {
  _$TouchscreenCircleGestureCopyWithImpl(this._self, this._then);

  final TouchscreenCircleGesture _self;
  final $Res Function(TouchscreenCircleGesture) _then;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,Object? direction = null,Object? motion = null,}) {
  return _then(TouchscreenCircleGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as CircleDirection,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchscreenGesture
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


class TouchscreenTapGesture extends TouchscreenGesture {
  const TouchscreenTapGesture({required this.common, this.fingers}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchscreenTapGestureCopyWith<TouchscreenTapGesture> get copyWith => _$TouchscreenTapGestureCopyWithImpl<TouchscreenTapGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchscreenTapGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers);

@override
String toString() {
  return 'TouchscreenGesture.tap(common: $common, fingers: $fingers)';
}


}

/// @nodoc
abstract mixin class $TouchscreenTapGestureCopyWith<$Res> implements $TouchscreenGestureCopyWith<$Res> {
  factory $TouchscreenTapGestureCopyWith(TouchscreenTapGesture value, $Res Function(TouchscreenTapGesture) _then) = _$TouchscreenTapGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers
});


@override $TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$TouchscreenTapGestureCopyWithImpl<$Res>
    implements $TouchscreenTapGestureCopyWith<$Res> {
  _$TouchscreenTapGestureCopyWithImpl(this._self, this._then);

  final TouchscreenTapGesture _self;
  final $Res Function(TouchscreenTapGesture) _then;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,}) {
  return _then(TouchscreenTapGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TouchscreenGesture
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


class TouchscreenHoldGesture extends TouchscreenGesture {
  const TouchscreenHoldGesture({required this.common, this.fingers}): super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchscreenHoldGestureCopyWith<TouchscreenHoldGesture> get copyWith => _$TouchscreenHoldGestureCopyWithImpl<TouchscreenHoldGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchscreenHoldGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers);

@override
String toString() {
  return 'TouchscreenGesture.hold(common: $common, fingers: $fingers)';
}


}

/// @nodoc
abstract mixin class $TouchscreenHoldGestureCopyWith<$Res> implements $TouchscreenGestureCopyWith<$Res> {
  factory $TouchscreenHoldGestureCopyWith(TouchscreenHoldGesture value, $Res Function(TouchscreenHoldGesture) _then) = _$TouchscreenHoldGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers
});


@override $TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$TouchscreenHoldGestureCopyWithImpl<$Res>
    implements $TouchscreenHoldGestureCopyWith<$Res> {
  _$TouchscreenHoldGestureCopyWithImpl(this._self, this._then);

  final TouchscreenHoldGesture _self;
  final $Res Function(TouchscreenHoldGesture) _then;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,}) {
  return _then(TouchscreenHoldGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TouchscreenGesture
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


class TouchscreenStrokeGesture extends TouchscreenGesture {
  const TouchscreenStrokeGesture({required this.common, this.fingers, final  List<String> strokes = const [], this.motion = const MotionCommon()}): _strokes = strokes,super._();
  

@override final  TriggerCommon common;
@override final  int? fingers;
 final  List<String> _strokes;
@JsonKey() List<String> get strokes {
  if (_strokes is EqualUnmodifiableListView) return _strokes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strokes);
}

@JsonKey() final  MotionCommon motion;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TouchscreenStrokeGestureCopyWith<TouchscreenStrokeGesture> get copyWith => _$TouchscreenStrokeGestureCopyWithImpl<TouchscreenStrokeGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TouchscreenStrokeGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&const DeepCollectionEquality().equals(other._strokes, _strokes)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,fingers,const DeepCollectionEquality().hash(_strokes),motion);

@override
String toString() {
  return 'TouchscreenGesture.stroke(common: $common, fingers: $fingers, strokes: $strokes, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $TouchscreenStrokeGestureCopyWith<$Res> implements $TouchscreenGestureCopyWith<$Res> {
  factory $TouchscreenStrokeGestureCopyWith(TouchscreenStrokeGesture value, $Res Function(TouchscreenStrokeGesture) _then) = _$TouchscreenStrokeGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, int? fingers, List<String> strokes, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$TouchscreenStrokeGestureCopyWithImpl<$Res>
    implements $TouchscreenStrokeGestureCopyWith<$Res> {
  _$TouchscreenStrokeGestureCopyWithImpl(this._self, this._then);

  final TouchscreenStrokeGesture _self;
  final $Res Function(TouchscreenStrokeGesture) _then;

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? fingers = freezed,Object? strokes = null,Object? motion = null,}) {
  return _then(TouchscreenStrokeGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as int?,strokes: null == strokes ? _self._strokes : strokes // ignore: cast_nullable_to_non_nullable
as List<String>,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of TouchscreenGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of TouchscreenGesture
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
