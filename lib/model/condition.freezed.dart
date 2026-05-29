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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( VariableCondition value)?  variable,TResult Function( ConditionGroup value)?  group,TResult Function( RawCondition value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case VariableCondition() when variable != null:
return variable(_that);case ConditionGroup() when group != null:
return group(_that);case RawCondition() when raw != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( VariableCondition value)  variable,required TResult Function( ConditionGroup value)  group,required TResult Function( RawCondition value)  raw,}){
final _that = this;
switch (_that) {
case VariableCondition():
return variable(_that);case ConditionGroup():
return group(_that);case RawCondition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( VariableCondition value)?  variable,TResult? Function( ConditionGroup value)?  group,TResult? Function( RawCondition value)?  raw,}){
final _that = this;
switch (_that) {
case VariableCondition() when variable != null:
return variable(_that);case ConditionGroup() when group != null:
return group(_that);case RawCondition() when raw != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String variable,  String operator,  String value,  bool negate)?  variable,TResult Function( ConditionGroupMode mode,  List<Condition> children)?  group,TResult Function( String raw)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case VariableCondition() when variable != null:
return variable(_that.variable,_that.operator,_that.value,_that.negate);case ConditionGroup() when group != null:
return group(_that.mode,_that.children);case RawCondition() when raw != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String variable,  String operator,  String value,  bool negate)  variable,required TResult Function( ConditionGroupMode mode,  List<Condition> children)  group,required TResult Function( String raw)  raw,}) {final _that = this;
switch (_that) {
case VariableCondition():
return variable(_that.variable,_that.operator,_that.value,_that.negate);case ConditionGroup():
return group(_that.mode,_that.children);case RawCondition():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String variable,  String operator,  String value,  bool negate)?  variable,TResult? Function( ConditionGroupMode mode,  List<Condition> children)?  group,TResult? Function( String raw)?  raw,}) {final _that = this;
switch (_that) {
case VariableCondition() when variable != null:
return variable(_that.variable,_that.operator,_that.value,_that.negate);case ConditionGroup() when group != null:
return group(_that.mode,_that.children);case RawCondition() when raw != null:
return raw(_that.raw);case _:
  return null;

}
}

}

/// @nodoc


class VariableCondition implements Condition {
  const VariableCondition({required this.variable, required this.operator, required this.value, this.negate = false});
  

 final  String variable;
 final  String operator;
 final  String value;
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
 String variable, String operator, String value, bool negate
});




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
as String,operator: null == operator ? _self.operator : operator // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,negate: null == negate ? _self.negate : negate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
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
