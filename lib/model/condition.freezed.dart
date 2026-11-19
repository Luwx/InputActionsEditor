// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'condition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConditionVariableRef {

 String get name;
/// Create a copy of ConditionVariableRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConditionVariableRefCopyWith<ConditionVariableRef> get copyWith => _$ConditionVariableRefCopyWithImpl<ConditionVariableRef>(this as ConditionVariableRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConditionVariableRef&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'ConditionVariableRef(name: $name)';
}


}

/// @nodoc
abstract mixin class $ConditionVariableRefCopyWith<$Res>  {
  factory $ConditionVariableRefCopyWith(ConditionVariableRef value, $Res Function(ConditionVariableRef) _then) = _$ConditionVariableRefCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$ConditionVariableRefCopyWithImpl<$Res>
    implements $ConditionVariableRefCopyWith<$Res> {
  _$ConditionVariableRefCopyWithImpl(this._self, this._then);

  final ConditionVariableRef _self;
  final $Res Function(ConditionVariableRef) _then;

/// Create a copy of ConditionVariableRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConditionVariableRef].
extension ConditionVariableRefPatterns on ConditionVariableRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( KnownConditionVariable value)?  known,TResult Function( CustomConditionVariable value)?  custom,required TResult orElse(),}){
final _that = this;
switch (_that) {
case KnownConditionVariable() when known != null:
return known(_that);case CustomConditionVariable() when custom != null:
return custom(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( KnownConditionVariable value)  known,required TResult Function( CustomConditionVariable value)  custom,}){
final _that = this;
switch (_that) {
case KnownConditionVariable():
return known(_that);case CustomConditionVariable():
return custom(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( KnownConditionVariable value)?  known,TResult? Function( CustomConditionVariable value)?  custom,}){
final _that = this;
switch (_that) {
case KnownConditionVariable() when known != null:
return known(_that);case CustomConditionVariable() when custom != null:
return custom(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String name)?  known,TResult Function( String name)?  custom,required TResult orElse(),}) {final _that = this;
switch (_that) {
case KnownConditionVariable() when known != null:
return known(_that.name);case CustomConditionVariable() when custom != null:
return custom(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String name)  known,required TResult Function( String name)  custom,}) {final _that = this;
switch (_that) {
case KnownConditionVariable():
return known(_that.name);case CustomConditionVariable():
return custom(_that.name);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String name)?  known,TResult? Function( String name)?  custom,}) {final _that = this;
switch (_that) {
case KnownConditionVariable() when known != null:
return known(_that.name);case CustomConditionVariable() when custom != null:
return custom(_that.name);case _:
  return null;

}
}

}

/// @nodoc


class KnownConditionVariable implements ConditionVariableRef {
  const KnownConditionVariable(this.name);
  

@override final  String name;

/// Create a copy of ConditionVariableRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KnownConditionVariableCopyWith<KnownConditionVariable> get copyWith => _$KnownConditionVariableCopyWithImpl<KnownConditionVariable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KnownConditionVariable&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'ConditionVariableRef.known(name: $name)';
}


}

/// @nodoc
abstract mixin class $KnownConditionVariableCopyWith<$Res> implements $ConditionVariableRefCopyWith<$Res> {
  factory $KnownConditionVariableCopyWith(KnownConditionVariable value, $Res Function(KnownConditionVariable) _then) = _$KnownConditionVariableCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class _$KnownConditionVariableCopyWithImpl<$Res>
    implements $KnownConditionVariableCopyWith<$Res> {
  _$KnownConditionVariableCopyWithImpl(this._self, this._then);

  final KnownConditionVariable _self;
  final $Res Function(KnownConditionVariable) _then;

/// Create a copy of ConditionVariableRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(KnownConditionVariable(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CustomConditionVariable implements ConditionVariableRef {
  const CustomConditionVariable(this.name);
  

@override final  String name;

/// Create a copy of ConditionVariableRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomConditionVariableCopyWith<CustomConditionVariable> get copyWith => _$CustomConditionVariableCopyWithImpl<CustomConditionVariable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomConditionVariable&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'ConditionVariableRef.custom(name: $name)';
}


}

/// @nodoc
abstract mixin class $CustomConditionVariableCopyWith<$Res> implements $ConditionVariableRefCopyWith<$Res> {
  factory $CustomConditionVariableCopyWith(CustomConditionVariable value, $Res Function(CustomConditionVariable) _then) = _$CustomConditionVariableCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class _$CustomConditionVariableCopyWithImpl<$Res>
    implements $CustomConditionVariableCopyWith<$Res> {
  _$CustomConditionVariableCopyWithImpl(this._self, this._then);

  final CustomConditionVariable _self;
  final $Res Function(CustomConditionVariable) _then;

/// Create a copy of ConditionVariableRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(CustomConditionVariable(
null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ConditionValue {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConditionValue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConditionValue()';
}


}

/// @nodoc
class $ConditionValueCopyWith<$Res>  {
$ConditionValueCopyWith(ConditionValue _, $Res Function(ConditionValue) __);
}


/// Adds pattern-matching-related methods to [ConditionValue].
extension ConditionValuePatterns on ConditionValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextConditionValue value)?  text,TResult Function( NumberConditionValue value)?  number,TResult Function( BoolConditionValue value)?  boolean,TResult Function( FlagsConditionValue value)?  flags,TResult Function( PointConditionValue value)?  point,TResult Function( ListConditionValue value)?  list,TResult Function( RangeConditionValue value)?  range,TResult Function( RawConditionValue value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextConditionValue() when text != null:
return text(_that);case NumberConditionValue() when number != null:
return number(_that);case BoolConditionValue() when boolean != null:
return boolean(_that);case FlagsConditionValue() when flags != null:
return flags(_that);case PointConditionValue() when point != null:
return point(_that);case ListConditionValue() when list != null:
return list(_that);case RangeConditionValue() when range != null:
return range(_that);case RawConditionValue() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextConditionValue value)  text,required TResult Function( NumberConditionValue value)  number,required TResult Function( BoolConditionValue value)  boolean,required TResult Function( FlagsConditionValue value)  flags,required TResult Function( PointConditionValue value)  point,required TResult Function( ListConditionValue value)  list,required TResult Function( RangeConditionValue value)  range,required TResult Function( RawConditionValue value)  raw,}){
final _that = this;
switch (_that) {
case TextConditionValue():
return text(_that);case NumberConditionValue():
return number(_that);case BoolConditionValue():
return boolean(_that);case FlagsConditionValue():
return flags(_that);case PointConditionValue():
return point(_that);case ListConditionValue():
return list(_that);case RangeConditionValue():
return range(_that);case RawConditionValue():
return raw(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextConditionValue value)?  text,TResult? Function( NumberConditionValue value)?  number,TResult? Function( BoolConditionValue value)?  boolean,TResult? Function( FlagsConditionValue value)?  flags,TResult? Function( PointConditionValue value)?  point,TResult? Function( ListConditionValue value)?  list,TResult? Function( RangeConditionValue value)?  range,TResult? Function( RawConditionValue value)?  raw,}){
final _that = this;
switch (_that) {
case TextConditionValue() when text != null:
return text(_that);case NumberConditionValue() when number != null:
return number(_that);case BoolConditionValue() when boolean != null:
return boolean(_that);case FlagsConditionValue() when flags != null:
return flags(_that);case PointConditionValue() when point != null:
return point(_that);case ListConditionValue() when list != null:
return list(_that);case RangeConditionValue() when range != null:
return range(_that);case RawConditionValue() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String value)?  text,TResult Function( double value)?  number,TResult Function( bool value)?  boolean,TResult Function( List<String> values)?  flags,TResult Function( double x,  double y)?  point,TResult Function( List<String> values)?  list,TResult Function( ConditionValue from,  ConditionValue to)?  range,TResult Function( String value)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TextConditionValue() when text != null:
return text(_that.value);case NumberConditionValue() when number != null:
return number(_that.value);case BoolConditionValue() when boolean != null:
return boolean(_that.value);case FlagsConditionValue() when flags != null:
return flags(_that.values);case PointConditionValue() when point != null:
return point(_that.x,_that.y);case ListConditionValue() when list != null:
return list(_that.values);case RangeConditionValue() when range != null:
return range(_that.from,_that.to);case RawConditionValue() when raw != null:
return raw(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String value)  text,required TResult Function( double value)  number,required TResult Function( bool value)  boolean,required TResult Function( List<String> values)  flags,required TResult Function( double x,  double y)  point,required TResult Function( List<String> values)  list,required TResult Function( ConditionValue from,  ConditionValue to)  range,required TResult Function( String value)  raw,}) {final _that = this;
switch (_that) {
case TextConditionValue():
return text(_that.value);case NumberConditionValue():
return number(_that.value);case BoolConditionValue():
return boolean(_that.value);case FlagsConditionValue():
return flags(_that.values);case PointConditionValue():
return point(_that.x,_that.y);case ListConditionValue():
return list(_that.values);case RangeConditionValue():
return range(_that.from,_that.to);case RawConditionValue():
return raw(_that.value);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String value)?  text,TResult? Function( double value)?  number,TResult? Function( bool value)?  boolean,TResult? Function( List<String> values)?  flags,TResult? Function( double x,  double y)?  point,TResult? Function( List<String> values)?  list,TResult? Function( ConditionValue from,  ConditionValue to)?  range,TResult? Function( String value)?  raw,}) {final _that = this;
switch (_that) {
case TextConditionValue() when text != null:
return text(_that.value);case NumberConditionValue() when number != null:
return number(_that.value);case BoolConditionValue() when boolean != null:
return boolean(_that.value);case FlagsConditionValue() when flags != null:
return flags(_that.values);case PointConditionValue() when point != null:
return point(_that.x,_that.y);case ListConditionValue() when list != null:
return list(_that.values);case RangeConditionValue() when range != null:
return range(_that.from,_that.to);case RawConditionValue() when raw != null:
return raw(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class TextConditionValue implements ConditionValue {
  const TextConditionValue(this.value);
  

 final  String value;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextConditionValueCopyWith<TextConditionValue> get copyWith => _$TextConditionValueCopyWithImpl<TextConditionValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextConditionValue&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ConditionValue.text(value: $value)';
}


}

/// @nodoc
abstract mixin class $TextConditionValueCopyWith<$Res> implements $ConditionValueCopyWith<$Res> {
  factory $TextConditionValueCopyWith(TextConditionValue value, $Res Function(TextConditionValue) _then) = _$TextConditionValueCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$TextConditionValueCopyWithImpl<$Res>
    implements $TextConditionValueCopyWith<$Res> {
  _$TextConditionValueCopyWithImpl(this._self, this._then);

  final TextConditionValue _self;
  final $Res Function(TextConditionValue) _then;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(TextConditionValue(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NumberConditionValue implements ConditionValue {
  const NumberConditionValue(this.value);
  

 final  double value;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NumberConditionValueCopyWith<NumberConditionValue> get copyWith => _$NumberConditionValueCopyWithImpl<NumberConditionValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NumberConditionValue&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ConditionValue.number(value: $value)';
}


}

/// @nodoc
abstract mixin class $NumberConditionValueCopyWith<$Res> implements $ConditionValueCopyWith<$Res> {
  factory $NumberConditionValueCopyWith(NumberConditionValue value, $Res Function(NumberConditionValue) _then) = _$NumberConditionValueCopyWithImpl;
@useResult
$Res call({
 double value
});




}
/// @nodoc
class _$NumberConditionValueCopyWithImpl<$Res>
    implements $NumberConditionValueCopyWith<$Res> {
  _$NumberConditionValueCopyWithImpl(this._self, this._then);

  final NumberConditionValue _self;
  final $Res Function(NumberConditionValue) _then;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(NumberConditionValue(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class BoolConditionValue implements ConditionValue {
  const BoolConditionValue(this.value);
  

 final  bool value;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoolConditionValueCopyWith<BoolConditionValue> get copyWith => _$BoolConditionValueCopyWithImpl<BoolConditionValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoolConditionValue&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ConditionValue.boolean(value: $value)';
}


}

/// @nodoc
abstract mixin class $BoolConditionValueCopyWith<$Res> implements $ConditionValueCopyWith<$Res> {
  factory $BoolConditionValueCopyWith(BoolConditionValue value, $Res Function(BoolConditionValue) _then) = _$BoolConditionValueCopyWithImpl;
@useResult
$Res call({
 bool value
});




}
/// @nodoc
class _$BoolConditionValueCopyWithImpl<$Res>
    implements $BoolConditionValueCopyWith<$Res> {
  _$BoolConditionValueCopyWithImpl(this._self, this._then);

  final BoolConditionValue _self;
  final $Res Function(BoolConditionValue) _then;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(BoolConditionValue(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class FlagsConditionValue implements ConditionValue {
  const FlagsConditionValue(final  List<String> values): _values = values;
  

 final  List<String> _values;
 List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FlagsConditionValueCopyWith<FlagsConditionValue> get copyWith => _$FlagsConditionValueCopyWithImpl<FlagsConditionValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FlagsConditionValue&&const DeepCollectionEquality().equals(other._values, _values));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'ConditionValue.flags(values: $values)';
}


}

/// @nodoc
abstract mixin class $FlagsConditionValueCopyWith<$Res> implements $ConditionValueCopyWith<$Res> {
  factory $FlagsConditionValueCopyWith(FlagsConditionValue value, $Res Function(FlagsConditionValue) _then) = _$FlagsConditionValueCopyWithImpl;
@useResult
$Res call({
 List<String> values
});




}
/// @nodoc
class _$FlagsConditionValueCopyWithImpl<$Res>
    implements $FlagsConditionValueCopyWith<$Res> {
  _$FlagsConditionValueCopyWithImpl(this._self, this._then);

  final FlagsConditionValue _self;
  final $Res Function(FlagsConditionValue) _then;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? values = null,}) {
  return _then(FlagsConditionValue(
null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class PointConditionValue implements ConditionValue {
  const PointConditionValue(this.x, this.y);
  

 final  double x;
 final  double y;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointConditionValueCopyWith<PointConditionValue> get copyWith => _$PointConditionValueCopyWithImpl<PointConditionValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointConditionValue&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}


@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'ConditionValue.point(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $PointConditionValueCopyWith<$Res> implements $ConditionValueCopyWith<$Res> {
  factory $PointConditionValueCopyWith(PointConditionValue value, $Res Function(PointConditionValue) _then) = _$PointConditionValueCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$PointConditionValueCopyWithImpl<$Res>
    implements $PointConditionValueCopyWith<$Res> {
  _$PointConditionValueCopyWithImpl(this._self, this._then);

  final PointConditionValue _self;
  final $Res Function(PointConditionValue) _then;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(PointConditionValue(
null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class ListConditionValue implements ConditionValue {
  const ListConditionValue(final  List<String> values): _values = values;
  

 final  List<String> _values;
 List<String> get values {
  if (_values is EqualUnmodifiableListView) return _values;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_values);
}


/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListConditionValueCopyWith<ListConditionValue> get copyWith => _$ListConditionValueCopyWithImpl<ListConditionValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListConditionValue&&const DeepCollectionEquality().equals(other._values, _values));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_values));

@override
String toString() {
  return 'ConditionValue.list(values: $values)';
}


}

/// @nodoc
abstract mixin class $ListConditionValueCopyWith<$Res> implements $ConditionValueCopyWith<$Res> {
  factory $ListConditionValueCopyWith(ListConditionValue value, $Res Function(ListConditionValue) _then) = _$ListConditionValueCopyWithImpl;
@useResult
$Res call({
 List<String> values
});




}
/// @nodoc
class _$ListConditionValueCopyWithImpl<$Res>
    implements $ListConditionValueCopyWith<$Res> {
  _$ListConditionValueCopyWithImpl(this._self, this._then);

  final ListConditionValue _self;
  final $Res Function(ListConditionValue) _then;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? values = null,}) {
  return _then(ListConditionValue(
null == values ? _self._values : values // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class RangeConditionValue implements ConditionValue {
  const RangeConditionValue({required this.from, required this.to});
  

 final  ConditionValue from;
 final  ConditionValue to;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RangeConditionValueCopyWith<RangeConditionValue> get copyWith => _$RangeConditionValueCopyWithImpl<RangeConditionValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RangeConditionValue&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to));
}


@override
int get hashCode => Object.hash(runtimeType,from,to);

@override
String toString() {
  return 'ConditionValue.range(from: $from, to: $to)';
}


}

/// @nodoc
abstract mixin class $RangeConditionValueCopyWith<$Res> implements $ConditionValueCopyWith<$Res> {
  factory $RangeConditionValueCopyWith(RangeConditionValue value, $Res Function(RangeConditionValue) _then) = _$RangeConditionValueCopyWithImpl;
@useResult
$Res call({
 ConditionValue from, ConditionValue to
});


$ConditionValueCopyWith<$Res> get from;$ConditionValueCopyWith<$Res> get to;

}
/// @nodoc
class _$RangeConditionValueCopyWithImpl<$Res>
    implements $RangeConditionValueCopyWith<$Res> {
  _$RangeConditionValueCopyWithImpl(this._self, this._then);

  final RangeConditionValue _self;
  final $Res Function(RangeConditionValue) _then;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,}) {
  return _then(RangeConditionValue(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as ConditionValue,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as ConditionValue,
  ));
}

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionValueCopyWith<$Res> get from {
  
  return $ConditionValueCopyWith<$Res>(_self.from, (value) {
    return _then(_self.copyWith(from: value));
  });
}/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionValueCopyWith<$Res> get to {
  
  return $ConditionValueCopyWith<$Res>(_self.to, (value) {
    return _then(_self.copyWith(to: value));
  });
}
}

/// @nodoc


class RawConditionValue implements ConditionValue {
  const RawConditionValue(this.value);
  

 final  String value;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawConditionValueCopyWith<RawConditionValue> get copyWith => _$RawConditionValueCopyWithImpl<RawConditionValue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawConditionValue&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ConditionValue.raw(value: $value)';
}


}

/// @nodoc
abstract mixin class $RawConditionValueCopyWith<$Res> implements $ConditionValueCopyWith<$Res> {
  factory $RawConditionValueCopyWith(RawConditionValue value, $Res Function(RawConditionValue) _then) = _$RawConditionValueCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$RawConditionValueCopyWithImpl<$Res>
    implements $RawConditionValueCopyWith<$Res> {
  _$RawConditionValueCopyWithImpl(this._self, this._then);

  final RawConditionValue _self;
  final $Res Function(RawConditionValue) _then;

/// Create a copy of ConditionValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(RawConditionValue(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Condition {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Condition);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Condition()';
}


}

/// @nodoc
class $ConditionCopyWith<$Res>  {
$ConditionCopyWith(Condition _, $Res Function(Condition) __);
}


/// Adds pattern-matching-related methods to [Condition].
extension ConditionPatterns on Condition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VariableCondition value)?  variable,TResult Function( ConditionGroup value)?  group,TResult Function( FunctionCondition value)?  function,TResult Function( RawCondition value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VariableCondition() when variable != null:
return variable(_that);case ConditionGroup() when group != null:
return group(_that);case FunctionCondition() when function != null:
return function(_that);case RawCondition() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VariableCondition value)  variable,required TResult Function( ConditionGroup value)  group,required TResult Function( FunctionCondition value)  function,required TResult Function( RawCondition value)  raw,}){
final _that = this;
switch (_that) {
case VariableCondition():
return variable(_that);case ConditionGroup():
return group(_that);case FunctionCondition():
return function(_that);case RawCondition():
return raw(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VariableCondition value)?  variable,TResult? Function( ConditionGroup value)?  group,TResult? Function( FunctionCondition value)?  function,TResult? Function( RawCondition value)?  raw,}){
final _that = this;
switch (_that) {
case VariableCondition() when variable != null:
return variable(_that);case ConditionGroup() when group != null:
return group(_that);case FunctionCondition() when function != null:
return function(_that);case RawCondition() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( ConditionVariableRef variable,  ConditionOperator operator,  ConditionValue value,  bool negate)?  variable,TResult Function( ConditionGroupMode mode,  List<Condition> children)?  group,TResult Function( String expression)?  function,TResult Function( String raw)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VariableCondition() when variable != null:
return variable(_that.variable,_that.operator,_that.value,_that.negate);case ConditionGroup() when group != null:
return group(_that.mode,_that.children);case FunctionCondition() when function != null:
return function(_that.expression);case RawCondition() when raw != null:
return raw(_that.raw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( ConditionVariableRef variable,  ConditionOperator operator,  ConditionValue value,  bool negate)  variable,required TResult Function( ConditionGroupMode mode,  List<Condition> children)  group,required TResult Function( String expression)  function,required TResult Function( String raw)  raw,}) {final _that = this;
switch (_that) {
case VariableCondition():
return variable(_that.variable,_that.operator,_that.value,_that.negate);case ConditionGroup():
return group(_that.mode,_that.children);case FunctionCondition():
return function(_that.expression);case RawCondition():
return raw(_that.raw);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( ConditionVariableRef variable,  ConditionOperator operator,  ConditionValue value,  bool negate)?  variable,TResult? Function( ConditionGroupMode mode,  List<Condition> children)?  group,TResult? Function( String expression)?  function,TResult? Function( String raw)?  raw,}) {final _that = this;
switch (_that) {
case VariableCondition() when variable != null:
return variable(_that.variable,_that.operator,_that.value,_that.negate);case ConditionGroup() when group != null:
return group(_that.mode,_that.children);case FunctionCondition() when function != null:
return function(_that.expression);case RawCondition() when raw != null:
return raw(_that.raw);case _:
  return null;

}
}

}

/// @nodoc


class VariableCondition implements Condition {
  const VariableCondition({required this.variable, required this.operator, required this.value, this.negate = false});
  

 final  ConditionVariableRef variable;
 final  ConditionOperator operator;
 final  ConditionValue value;
@JsonKey() final  bool negate;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariableConditionCopyWith<VariableCondition> get copyWith => _$VariableConditionCopyWithImpl<VariableCondition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariableCondition&&(identical(other.variable, variable) || other.variable == variable)&&(identical(other.operator, operator) || other.operator == operator)&&(identical(other.value, value) || other.value == value)&&(identical(other.negate, negate) || other.negate == negate));
}


@override
int get hashCode => Object.hash(runtimeType,variable,operator,value,negate);

@override
String toString() {
  return 'Condition.variable(variable: $variable, operator: $operator, value: $value, negate: $negate)';
}


}

/// @nodoc
abstract mixin class $VariableConditionCopyWith<$Res> implements $ConditionCopyWith<$Res> {
  factory $VariableConditionCopyWith(VariableCondition value, $Res Function(VariableCondition) _then) = _$VariableConditionCopyWithImpl;
@useResult
$Res call({
 ConditionVariableRef variable, ConditionOperator operator, ConditionValue value, bool negate
});


$ConditionVariableRefCopyWith<$Res> get variable;$ConditionValueCopyWith<$Res> get value;

}
/// @nodoc
class _$VariableConditionCopyWithImpl<$Res>
    implements $VariableConditionCopyWith<$Res> {
  _$VariableConditionCopyWithImpl(this._self, this._then);

  final VariableCondition _self;
  final $Res Function(VariableCondition) _then;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? variable = null,Object? operator = null,Object? value = null,Object? negate = null,}) {
  return _then(VariableCondition(
variable: null == variable ? _self.variable : variable // ignore: cast_nullable_to_non_nullable
as ConditionVariableRef,operator: null == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as ConditionOperator,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as ConditionValue,negate: null == negate ? _self.negate : negate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionVariableRefCopyWith<$Res> get variable {
  
  return $ConditionVariableRefCopyWith<$Res>(_self.variable, (value) {
    return _then(_self.copyWith(variable: value));
  });
}/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionValueCopyWith<$Res> get value {
  
  return $ConditionValueCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}

/// @nodoc


class ConditionGroup implements Condition {
  const ConditionGroup({this.mode = ConditionGroupMode.all, final  List<Condition> children = const []}): _children = children;
  

@JsonKey() final  ConditionGroupMode mode;
 final  List<Condition> _children;
@JsonKey() List<Condition> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConditionGroupCopyWith<ConditionGroup> get copyWith => _$ConditionGroupCopyWithImpl<ConditionGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConditionGroup&&(identical(other.mode, mode) || other.mode == mode)&&const DeepCollectionEquality().equals(other._children, _children));
}


@override
int get hashCode => Object.hash(runtimeType,mode,const DeepCollectionEquality().hash(_children));

@override
String toString() {
  return 'Condition.group(mode: $mode, children: $children)';
}


}

/// @nodoc
abstract mixin class $ConditionGroupCopyWith<$Res> implements $ConditionCopyWith<$Res> {
  factory $ConditionGroupCopyWith(ConditionGroup value, $Res Function(ConditionGroup) _then) = _$ConditionGroupCopyWithImpl;
@useResult
$Res call({
 ConditionGroupMode mode, List<Condition> children
});




}
/// @nodoc
class _$ConditionGroupCopyWithImpl<$Res>
    implements $ConditionGroupCopyWith<$Res> {
  _$ConditionGroupCopyWithImpl(this._self, this._then);

  final ConditionGroup _self;
  final $Res Function(ConditionGroup) _then;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? children = null,}) {
  return _then(ConditionGroup(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as ConditionGroupMode,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<Condition>,
  ));
}


}

/// @nodoc


class FunctionCondition implements Condition {
  const FunctionCondition({required this.expression});
  

 final  String expression;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FunctionConditionCopyWith<FunctionCondition> get copyWith => _$FunctionConditionCopyWithImpl<FunctionCondition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FunctionCondition&&(identical(other.expression, expression) || other.expression == expression));
}


@override
int get hashCode => Object.hash(runtimeType,expression);

@override
String toString() {
  return 'Condition.function(expression: $expression)';
}


}

/// @nodoc
abstract mixin class $FunctionConditionCopyWith<$Res> implements $ConditionCopyWith<$Res> {
  factory $FunctionConditionCopyWith(FunctionCondition value, $Res Function(FunctionCondition) _then) = _$FunctionConditionCopyWithImpl;
@useResult
$Res call({
 String expression
});




}
/// @nodoc
class _$FunctionConditionCopyWithImpl<$Res>
    implements $FunctionConditionCopyWith<$Res> {
  _$FunctionConditionCopyWithImpl(this._self, this._then);

  final FunctionCondition _self;
  final $Res Function(FunctionCondition) _then;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? expression = null,}) {
  return _then(FunctionCondition(
expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RawCondition implements Condition {
  const RawCondition({required this.raw});
  

 final  String raw;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawConditionCopyWith<RawCondition> get copyWith => _$RawConditionCopyWithImpl<RawCondition>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawCondition&&(identical(other.raw, raw) || other.raw == raw));
}


@override
int get hashCode => Object.hash(runtimeType,raw);

@override
String toString() {
  return 'Condition.raw(raw: $raw)';
}


}

/// @nodoc
abstract mixin class $RawConditionCopyWith<$Res> implements $ConditionCopyWith<$Res> {
  factory $RawConditionCopyWith(RawCondition value, $Res Function(RawCondition) _then) = _$RawConditionCopyWithImpl;
@useResult
$Res call({
 String raw
});




}
/// @nodoc
class _$RawConditionCopyWithImpl<$Res>
    implements $RawConditionCopyWith<$Res> {
  _$RawConditionCopyWithImpl(this._self, this._then);

  final RawCondition _self;
  final $Res Function(RawCondition) _then;

/// Create a copy of Condition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? raw = null,}) {
  return _then(RawCondition(
raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
