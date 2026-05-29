// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mouse_gesture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SwipeMode {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwipeMode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SwipeMode()';
}


}

/// @nodoc
class $SwipeModeCopyWith<$Res>  {
$SwipeModeCopyWith(SwipeMode _, $Res Function(SwipeMode) __);
}


/// Adds pattern-matching-related methods to [SwipeMode].
extension SwipeModePatterns on SwipeMode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SwipeDirectionMode value)?  direction,TResult Function( SwipeAngleMode value)?  angle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SwipeDirectionMode() when direction != null:
return direction(_that);case SwipeAngleMode() when angle != null:
return angle(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SwipeDirectionMode value)  direction,required TResult Function( SwipeAngleMode value)  angle,}){
final _that = this;
switch (_that) {
case SwipeDirectionMode():
return direction(_that);case SwipeAngleMode():
return angle(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SwipeDirectionMode value)?  direction,TResult? Function( SwipeAngleMode value)?  angle,}){
final _that = this;
switch (_that) {
case SwipeDirectionMode() when direction != null:
return direction(_that);case SwipeAngleMode() when angle != null:
return angle(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SwipeDirection direction)?  direction,TResult Function( double minAngle,  double maxAngle,  bool bidirectional)?  angle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SwipeDirectionMode() when direction != null:
return direction(_that.direction);case SwipeAngleMode() when angle != null:
return angle(_that.minAngle,_that.maxAngle,_that.bidirectional);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SwipeDirection direction)  direction,required TResult Function( double minAngle,  double maxAngle,  bool bidirectional)  angle,}) {final _that = this;
switch (_that) {
case SwipeDirectionMode():
return direction(_that.direction);case SwipeAngleMode():
return angle(_that.minAngle,_that.maxAngle,_that.bidirectional);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SwipeDirection direction)?  direction,TResult? Function( double minAngle,  double maxAngle,  bool bidirectional)?  angle,}) {final _that = this;
switch (_that) {
case SwipeDirectionMode() when direction != null:
return direction(_that.direction);case SwipeAngleMode() when angle != null:
return angle(_that.minAngle,_that.maxAngle,_that.bidirectional);case _:
  return null;

}
}

}

/// @nodoc


class SwipeDirectionMode implements SwipeMode {
  const SwipeDirectionMode({required this.direction});
  

 final  SwipeDirection direction;

/// Create a copy of SwipeMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwipeDirectionModeCopyWith<SwipeDirectionMode> get copyWith => _$SwipeDirectionModeCopyWithImpl<SwipeDirectionMode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwipeDirectionMode&&(identical(other.direction, direction) || other.direction == direction));
}


@override
int get hashCode => Object.hash(runtimeType,direction);

@override
String toString() {
  return 'SwipeMode.direction(direction: $direction)';
}


}

/// @nodoc
abstract mixin class $SwipeDirectionModeCopyWith<$Res> implements $SwipeModeCopyWith<$Res> {
  factory $SwipeDirectionModeCopyWith(SwipeDirectionMode value, $Res Function(SwipeDirectionMode) _then) = _$SwipeDirectionModeCopyWithImpl;
@useResult
$Res call({
 SwipeDirection direction
});




}
/// @nodoc
class _$SwipeDirectionModeCopyWithImpl<$Res>
    implements $SwipeDirectionModeCopyWith<$Res> {
  _$SwipeDirectionModeCopyWithImpl(this._self, this._then);

  final SwipeDirectionMode _self;
  final $Res Function(SwipeDirectionMode) _then;

/// Create a copy of SwipeMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? direction = null,}) {
  return _then(SwipeDirectionMode(
direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as SwipeDirection,
  ));
}


}

/// @nodoc


class SwipeAngleMode implements SwipeMode {
  const SwipeAngleMode({required this.minAngle, required this.maxAngle, this.bidirectional = false});
  

 final  double minAngle;
 final  double maxAngle;
@JsonKey() final  bool bidirectional;

/// Create a copy of SwipeMode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwipeAngleModeCopyWith<SwipeAngleMode> get copyWith => _$SwipeAngleModeCopyWithImpl<SwipeAngleMode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwipeAngleMode&&(identical(other.minAngle, minAngle) || other.minAngle == minAngle)&&(identical(other.maxAngle, maxAngle) || other.maxAngle == maxAngle)&&(identical(other.bidirectional, bidirectional) || other.bidirectional == bidirectional));
}


@override
int get hashCode => Object.hash(runtimeType,minAngle,maxAngle,bidirectional);

@override
String toString() {
  return 'SwipeMode.angle(minAngle: $minAngle, maxAngle: $maxAngle, bidirectional: $bidirectional)';
}


}

/// @nodoc
abstract mixin class $SwipeAngleModeCopyWith<$Res> implements $SwipeModeCopyWith<$Res> {
  factory $SwipeAngleModeCopyWith(SwipeAngleMode value, $Res Function(SwipeAngleMode) _then) = _$SwipeAngleModeCopyWithImpl;
@useResult
$Res call({
 double minAngle, double maxAngle, bool bidirectional
});




}
/// @nodoc
class _$SwipeAngleModeCopyWithImpl<$Res>
    implements $SwipeAngleModeCopyWith<$Res> {
  _$SwipeAngleModeCopyWithImpl(this._self, this._then);

  final SwipeAngleMode _self;
  final $Res Function(SwipeAngleMode) _then;

/// Create a copy of SwipeMode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minAngle = null,Object? maxAngle = null,Object? bidirectional = null,}) {
  return _then(SwipeAngleMode(
minAngle: null == minAngle ? _self.minAngle : minAngle // ignore: cast_nullable_to_non_nullable
as double,maxAngle: null == maxAngle ? _self.maxAngle : maxAngle // ignore: cast_nullable_to_non_nullable
as double,bidirectional: null == bidirectional ? _self.bidirectional : bidirectional // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$MouseGesture {

 TriggerCommon get common; MotionCommon get motion;
/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MouseGestureCopyWith<MouseGesture> get copyWith => _$MouseGestureCopyWithImpl<MouseGesture>(this as MouseGesture, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MouseGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,motion);

@override
String toString() {
  return 'MouseGesture(common: $common, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $MouseGestureCopyWith<$Res>  {
  factory $MouseGestureCopyWith(MouseGesture value, $Res Function(MouseGesture) _then) = _$MouseGestureCopyWithImpl;
@useResult
$Res call({
 TriggerCommon common, MotionCommon motion
});


$TriggerCommonCopyWith<$Res> get common;$MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$MouseGestureCopyWithImpl<$Res>
    implements $MouseGestureCopyWith<$Res> {
  _$MouseGestureCopyWithImpl(this._self, this._then);

  final MouseGesture _self;
  final $Res Function(MouseGesture) _then;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? common = null,Object? motion = null,}) {
  return _then(_self.copyWith(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}
/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MotionCommonCopyWith<$Res> get motion {
  
  return $MotionCommonCopyWith<$Res>(_self.motion, (value) {
    return _then(_self.copyWith(motion: value));
  });
}
}


/// Adds pattern-matching-related methods to [MouseGesture].
extension MouseGesturePatterns on MouseGesture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( StrokeGesture value)?  stroke,TResult Function( SwipeGesture value)?  swipe,TResult Function( CircleGesture value)?  circle,TResult Function( PressGesture value)?  press,TResult Function( WheelGesture value)?  wheel,required TResult orElse(),}){
final _that = this;
switch (_that) {
case StrokeGesture() when stroke != null:
return stroke(_that);case SwipeGesture() when swipe != null:
return swipe(_that);case CircleGesture() when circle != null:
return circle(_that);case PressGesture() when press != null:
return press(_that);case WheelGesture() when wheel != null:
return wheel(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( StrokeGesture value)  stroke,required TResult Function( SwipeGesture value)  swipe,required TResult Function( CircleGesture value)  circle,required TResult Function( PressGesture value)  press,required TResult Function( WheelGesture value)  wheel,}){
final _that = this;
switch (_that) {
case StrokeGesture():
return stroke(_that);case SwipeGesture():
return swipe(_that);case CircleGesture():
return circle(_that);case PressGesture():
return press(_that);case WheelGesture():
return wheel(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( StrokeGesture value)?  stroke,TResult? Function( SwipeGesture value)?  swipe,TResult? Function( CircleGesture value)?  circle,TResult? Function( PressGesture value)?  press,TResult? Function( WheelGesture value)?  wheel,}){
final _that = this;
switch (_that) {
case StrokeGesture() when stroke != null:
return stroke(_that);case SwipeGesture() when swipe != null:
return swipe(_that);case CircleGesture() when circle != null:
return circle(_that);case PressGesture() when press != null:
return press(_that);case WheelGesture() when wheel != null:
return wheel(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TriggerCommon common,  MotionCommon motion,  List<String> strokes)?  stroke,TResult Function( TriggerCommon common,  SwipeMode mode,  MotionCommon motion)?  swipe,TResult Function( TriggerCommon common,  CircleDirection direction,  MotionCommon motion)?  circle,TResult Function( TriggerCommon common,  MotionCommon motion,  bool? instant)?  press,TResult Function( TriggerCommon common,  WheelDirection direction,  MotionCommon motion)?  wheel,required TResult orElse(),}) {final _that = this;
switch (_that) {
case StrokeGesture() when stroke != null:
return stroke(_that.common,_that.motion,_that.strokes);case SwipeGesture() when swipe != null:
return swipe(_that.common,_that.mode,_that.motion);case CircleGesture() when circle != null:
return circle(_that.common,_that.direction,_that.motion);case PressGesture() when press != null:
return press(_that.common,_that.motion,_that.instant);case WheelGesture() when wheel != null:
return wheel(_that.common,_that.direction,_that.motion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TriggerCommon common,  MotionCommon motion,  List<String> strokes)  stroke,required TResult Function( TriggerCommon common,  SwipeMode mode,  MotionCommon motion)  swipe,required TResult Function( TriggerCommon common,  CircleDirection direction,  MotionCommon motion)  circle,required TResult Function( TriggerCommon common,  MotionCommon motion,  bool? instant)  press,required TResult Function( TriggerCommon common,  WheelDirection direction,  MotionCommon motion)  wheel,}) {final _that = this;
switch (_that) {
case StrokeGesture():
return stroke(_that.common,_that.motion,_that.strokes);case SwipeGesture():
return swipe(_that.common,_that.mode,_that.motion);case CircleGesture():
return circle(_that.common,_that.direction,_that.motion);case PressGesture():
return press(_that.common,_that.motion,_that.instant);case WheelGesture():
return wheel(_that.common,_that.direction,_that.motion);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TriggerCommon common,  MotionCommon motion,  List<String> strokes)?  stroke,TResult? Function( TriggerCommon common,  SwipeMode mode,  MotionCommon motion)?  swipe,TResult? Function( TriggerCommon common,  CircleDirection direction,  MotionCommon motion)?  circle,TResult? Function( TriggerCommon common,  MotionCommon motion,  bool? instant)?  press,TResult? Function( TriggerCommon common,  WheelDirection direction,  MotionCommon motion)?  wheel,}) {final _that = this;
switch (_that) {
case StrokeGesture() when stroke != null:
return stroke(_that.common,_that.motion,_that.strokes);case SwipeGesture() when swipe != null:
return swipe(_that.common,_that.mode,_that.motion);case CircleGesture() when circle != null:
return circle(_that.common,_that.direction,_that.motion);case PressGesture() when press != null:
return press(_that.common,_that.motion,_that.instant);case WheelGesture() when wheel != null:
return wheel(_that.common,_that.direction,_that.motion);case _:
  return null;

}
}

}

/// @nodoc


class StrokeGesture extends MouseGesture {
  const StrokeGesture({required this.common, this.motion = const MotionCommon(), final  List<String> strokes = const []}): _strokes = strokes,super._();
  

@override final  TriggerCommon common;
@override@JsonKey() final  MotionCommon motion;
 final  List<String> _strokes;
@JsonKey() List<String> get strokes {
  if (_strokes is EqualUnmodifiableListView) return _strokes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strokes);
}


/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrokeGestureCopyWith<StrokeGesture> get copyWith => _$StrokeGestureCopyWithImpl<StrokeGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StrokeGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.motion, motion) || other.motion == motion)&&const DeepCollectionEquality().equals(other._strokes, _strokes));
}


@override
int get hashCode => Object.hash(runtimeType,common,motion,const DeepCollectionEquality().hash(_strokes));

@override
String toString() {
  return 'MouseGesture.stroke(common: $common, motion: $motion, strokes: $strokes)';
}


}

/// @nodoc
abstract mixin class $StrokeGestureCopyWith<$Res> implements $MouseGestureCopyWith<$Res> {
  factory $StrokeGestureCopyWith(StrokeGesture value, $Res Function(StrokeGesture) _then) = _$StrokeGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, MotionCommon motion, List<String> strokes
});


@override $TriggerCommonCopyWith<$Res> get common;@override $MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$StrokeGestureCopyWithImpl<$Res>
    implements $StrokeGestureCopyWith<$Res> {
  _$StrokeGestureCopyWithImpl(this._self, this._then);

  final StrokeGesture _self;
  final $Res Function(StrokeGesture) _then;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? motion = null,Object? strokes = null,}) {
  return _then(StrokeGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,strokes: null == strokes ? _self._strokes : strokes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of MouseGesture
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


class SwipeGesture extends MouseGesture {
  const SwipeGesture({required this.common, required this.mode, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
 final  SwipeMode mode;
@override@JsonKey() final  MotionCommon motion;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwipeGestureCopyWith<SwipeGesture> get copyWith => _$SwipeGestureCopyWithImpl<SwipeGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SwipeGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,mode,motion);

@override
String toString() {
  return 'MouseGesture.swipe(common: $common, mode: $mode, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $SwipeGestureCopyWith<$Res> implements $MouseGestureCopyWith<$Res> {
  factory $SwipeGestureCopyWith(SwipeGesture value, $Res Function(SwipeGesture) _then) = _$SwipeGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, SwipeMode mode, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;$SwipeModeCopyWith<$Res> get mode;@override $MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$SwipeGestureCopyWithImpl<$Res>
    implements $SwipeGestureCopyWith<$Res> {
  _$SwipeGestureCopyWithImpl(this._self, this._then);

  final SwipeGesture _self;
  final $Res Function(SwipeGesture) _then;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? mode = null,Object? motion = null,}) {
  return _then(SwipeGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as SwipeMode,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SwipeModeCopyWith<$Res> get mode {
  
  return $SwipeModeCopyWith<$Res>(_self.mode, (value) {
    return _then(_self.copyWith(mode: value));
  });
}/// Create a copy of MouseGesture
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


class CircleGesture extends MouseGesture {
  const CircleGesture({required this.common, required this.direction, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
 final  CircleDirection direction;
@override@JsonKey() final  MotionCommon motion;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CircleGestureCopyWith<CircleGesture> get copyWith => _$CircleGestureCopyWithImpl<CircleGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CircleGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,direction,motion);

@override
String toString() {
  return 'MouseGesture.circle(common: $common, direction: $direction, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $CircleGestureCopyWith<$Res> implements $MouseGestureCopyWith<$Res> {
  factory $CircleGestureCopyWith(CircleGesture value, $Res Function(CircleGesture) _then) = _$CircleGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, CircleDirection direction, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;@override $MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$CircleGestureCopyWithImpl<$Res>
    implements $CircleGestureCopyWith<$Res> {
  _$CircleGestureCopyWithImpl(this._self, this._then);

  final CircleGesture _self;
  final $Res Function(CircleGesture) _then;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? direction = null,Object? motion = null,}) {
  return _then(CircleGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as CircleDirection,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of MouseGesture
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


class PressGesture extends MouseGesture {
  const PressGesture({required this.common, this.motion = const MotionCommon(), this.instant}): super._();
  

@override final  TriggerCommon common;
@override@JsonKey() final  MotionCommon motion;
 final  bool? instant;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PressGestureCopyWith<PressGesture> get copyWith => _$PressGestureCopyWithImpl<PressGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PressGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.motion, motion) || other.motion == motion)&&(identical(other.instant, instant) || other.instant == instant));
}


@override
int get hashCode => Object.hash(runtimeType,common,motion,instant);

@override
String toString() {
  return 'MouseGesture.press(common: $common, motion: $motion, instant: $instant)';
}


}

/// @nodoc
abstract mixin class $PressGestureCopyWith<$Res> implements $MouseGestureCopyWith<$Res> {
  factory $PressGestureCopyWith(PressGesture value, $Res Function(PressGesture) _then) = _$PressGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, MotionCommon motion, bool? instant
});


@override $TriggerCommonCopyWith<$Res> get common;@override $MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$PressGestureCopyWithImpl<$Res>
    implements $PressGestureCopyWith<$Res> {
  _$PressGestureCopyWithImpl(this._self, this._then);

  final PressGesture _self;
  final $Res Function(PressGesture) _then;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? motion = null,Object? instant = freezed,}) {
  return _then(PressGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,instant: freezed == instant ? _self.instant : instant // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of MouseGesture
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


class WheelGesture extends MouseGesture {
  const WheelGesture({required this.common, required this.direction, this.motion = const MotionCommon()}): super._();
  

@override final  TriggerCommon common;
 final  WheelDirection direction;
@override@JsonKey() final  MotionCommon motion;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WheelGestureCopyWith<WheelGesture> get copyWith => _$WheelGestureCopyWithImpl<WheelGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WheelGesture&&(identical(other.common, common) || other.common == common)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.motion, motion) || other.motion == motion));
}


@override
int get hashCode => Object.hash(runtimeType,common,direction,motion);

@override
String toString() {
  return 'MouseGesture.wheel(common: $common, direction: $direction, motion: $motion)';
}


}

/// @nodoc
abstract mixin class $WheelGestureCopyWith<$Res> implements $MouseGestureCopyWith<$Res> {
  factory $WheelGestureCopyWith(WheelGesture value, $Res Function(WheelGesture) _then) = _$WheelGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, WheelDirection direction, MotionCommon motion
});


@override $TriggerCommonCopyWith<$Res> get common;@override $MotionCommonCopyWith<$Res> get motion;

}
/// @nodoc
class _$WheelGestureCopyWithImpl<$Res>
    implements $WheelGestureCopyWith<$Res> {
  _$WheelGestureCopyWithImpl(this._self, this._then);

  final WheelGesture _self;
  final $Res Function(WheelGesture) _then;

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? direction = null,Object? motion = null,}) {
  return _then(WheelGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as WheelDirection,motion: null == motion ? _self.motion : motion // ignore: cast_nullable_to_non_nullable
as MotionCommon,
  ));
}

/// Create a copy of MouseGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}/// Create a copy of MouseGesture
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
