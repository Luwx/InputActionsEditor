// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trigger_common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TriggerCommon {

 String? get name;/// KWin does not yet read this field; setting it to false is UI-only until
/// native support is added to the effect.
 bool? get enabled; String? get id;/// UI-only: references a [GestureGroup] by id for organizational grouping.
 String? get groupId; List<MouseButtonValue> get mouseButtons; bool get mouseButtonsExactOrder; Condition? get conditions; Condition? get endConditions; bool? get blockEvents; bool? get clearModifiers; int? get resumeTimeout; bool? get setLastTrigger;/// Either a single number or "min-max" string.
 String? get threshold; bool? get accelerated; List<TriggerAction> get actions;/// In-memory only, never serialized. A stable identity assigned by
/// [ConfigController] so per-gesture undo history survives reorders/index
/// shifts. Excluded from dirty-diff comparisons via
/// [comparableTriggerCommon].
 int? get editId;
/// Create a copy of TriggerCommon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<TriggerCommon> get copyWith => _$TriggerCommonCopyWithImpl<TriggerCommon>(this as TriggerCommon, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TriggerCommon&&(identical(other.name, name) || other.name == name)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&const DeepCollectionEquality().equals(other.mouseButtons, mouseButtons)&&(identical(other.mouseButtonsExactOrder, mouseButtonsExactOrder) || other.mouseButtonsExactOrder == mouseButtonsExactOrder)&&(identical(other.conditions, conditions) || other.conditions == conditions)&&(identical(other.endConditions, endConditions) || other.endConditions == endConditions)&&(identical(other.blockEvents, blockEvents) || other.blockEvents == blockEvents)&&(identical(other.clearModifiers, clearModifiers) || other.clearModifiers == clearModifiers)&&(identical(other.resumeTimeout, resumeTimeout) || other.resumeTimeout == resumeTimeout)&&(identical(other.setLastTrigger, setLastTrigger) || other.setLastTrigger == setLastTrigger)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.accelerated, accelerated) || other.accelerated == accelerated)&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,name,enabled,id,groupId,const DeepCollectionEquality().hash(mouseButtons),mouseButtonsExactOrder,conditions,endConditions,blockEvents,clearModifiers,resumeTimeout,setLastTrigger,threshold,accelerated,const DeepCollectionEquality().hash(actions),editId);

@override
String toString() {
  return 'TriggerCommon(name: $name, enabled: $enabled, id: $id, groupId: $groupId, mouseButtons: $mouseButtons, mouseButtonsExactOrder: $mouseButtonsExactOrder, conditions: $conditions, endConditions: $endConditions, blockEvents: $blockEvents, clearModifiers: $clearModifiers, resumeTimeout: $resumeTimeout, setLastTrigger: $setLastTrigger, threshold: $threshold, accelerated: $accelerated, actions: $actions, editId: $editId)';
}


}

/// @nodoc
abstract mixin class $TriggerCommonCopyWith<$Res>  {
  factory $TriggerCommonCopyWith(TriggerCommon value, $Res Function(TriggerCommon) _then) = _$TriggerCommonCopyWithImpl;
@useResult
$Res call({
 String? name, bool? enabled, String? id, String? groupId, List<MouseButtonValue> mouseButtons, bool mouseButtonsExactOrder, Condition? conditions, Condition? endConditions, bool? blockEvents, bool? clearModifiers, int? resumeTimeout, bool? setLastTrigger, String? threshold, bool? accelerated, List<TriggerAction> actions, int? editId
});


$ConditionCopyWith<$Res>? get conditions;$ConditionCopyWith<$Res>? get endConditions;

}
/// @nodoc
class _$TriggerCommonCopyWithImpl<$Res>
    implements $TriggerCommonCopyWith<$Res> {
  _$TriggerCommonCopyWithImpl(this._self, this._then);

  final TriggerCommon _self;
  final $Res Function(TriggerCommon) _then;

/// Create a copy of TriggerCommon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? enabled = freezed,Object? id = freezed,Object? groupId = freezed,Object? mouseButtons = null,Object? mouseButtonsExactOrder = null,Object? conditions = freezed,Object? endConditions = freezed,Object? blockEvents = freezed,Object? clearModifiers = freezed,Object? resumeTimeout = freezed,Object? setLastTrigger = freezed,Object? threshold = freezed,Object? accelerated = freezed,Object? actions = null,Object? editId = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,mouseButtons: null == mouseButtons ? _self.mouseButtons : mouseButtons // ignore: cast_nullable_to_non_nullable
as List<MouseButtonValue>,mouseButtonsExactOrder: null == mouseButtonsExactOrder ? _self.mouseButtonsExactOrder : mouseButtonsExactOrder // ignore: cast_nullable_to_non_nullable
as bool,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as Condition?,endConditions: freezed == endConditions ? _self.endConditions : endConditions // ignore: cast_nullable_to_non_nullable
as Condition?,blockEvents: freezed == blockEvents ? _self.blockEvents : blockEvents // ignore: cast_nullable_to_non_nullable
as bool?,clearModifiers: freezed == clearModifiers ? _self.clearModifiers : clearModifiers // ignore: cast_nullable_to_non_nullable
as bool?,resumeTimeout: freezed == resumeTimeout ? _self.resumeTimeout : resumeTimeout // ignore: cast_nullable_to_non_nullable
as int?,setLastTrigger: freezed == setLastTrigger ? _self.setLastTrigger : setLastTrigger // ignore: cast_nullable_to_non_nullable
as bool?,threshold: freezed == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String?,accelerated: freezed == accelerated ? _self.accelerated : accelerated // ignore: cast_nullable_to_non_nullable
as bool?,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<TriggerAction>,editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TriggerCommon
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionCopyWith<$Res>? get conditions {
    if (_self.conditions == null) {
    return null;
  }

  return $ConditionCopyWith<$Res>(_self.conditions!, (value) {
    return _then(_self.copyWith(conditions: value));
  });
}/// Create a copy of TriggerCommon
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionCopyWith<$Res>? get endConditions {
    if (_self.endConditions == null) {
    return null;
  }

  return $ConditionCopyWith<$Res>(_self.endConditions!, (value) {
    return _then(_self.copyWith(endConditions: value));
  });
}
}


/// Adds pattern-matching-related methods to [TriggerCommon].
extension TriggerCommonPatterns on TriggerCommon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TriggerCommon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TriggerCommon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TriggerCommon value)  $default,){
final _that = this;
switch (_that) {
case _TriggerCommon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TriggerCommon value)?  $default,){
final _that = this;
switch (_that) {
case _TriggerCommon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  bool? enabled,  String? id,  String? groupId,  List<MouseButtonValue> mouseButtons,  bool mouseButtonsExactOrder,  Condition? conditions,  Condition? endConditions,  bool? blockEvents,  bool? clearModifiers,  int? resumeTimeout,  bool? setLastTrigger,  String? threshold,  bool? accelerated,  List<TriggerAction> actions,  int? editId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TriggerCommon() when $default != null:
return $default(_that.name,_that.enabled,_that.id,_that.groupId,_that.mouseButtons,_that.mouseButtonsExactOrder,_that.conditions,_that.endConditions,_that.blockEvents,_that.clearModifiers,_that.resumeTimeout,_that.setLastTrigger,_that.threshold,_that.accelerated,_that.actions,_that.editId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  bool? enabled,  String? id,  String? groupId,  List<MouseButtonValue> mouseButtons,  bool mouseButtonsExactOrder,  Condition? conditions,  Condition? endConditions,  bool? blockEvents,  bool? clearModifiers,  int? resumeTimeout,  bool? setLastTrigger,  String? threshold,  bool? accelerated,  List<TriggerAction> actions,  int? editId)  $default,) {final _that = this;
switch (_that) {
case _TriggerCommon():
return $default(_that.name,_that.enabled,_that.id,_that.groupId,_that.mouseButtons,_that.mouseButtonsExactOrder,_that.conditions,_that.endConditions,_that.blockEvents,_that.clearModifiers,_that.resumeTimeout,_that.setLastTrigger,_that.threshold,_that.accelerated,_that.actions,_that.editId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  bool? enabled,  String? id,  String? groupId,  List<MouseButtonValue> mouseButtons,  bool mouseButtonsExactOrder,  Condition? conditions,  Condition? endConditions,  bool? blockEvents,  bool? clearModifiers,  int? resumeTimeout,  bool? setLastTrigger,  String? threshold,  bool? accelerated,  List<TriggerAction> actions,  int? editId)?  $default,) {final _that = this;
switch (_that) {
case _TriggerCommon() when $default != null:
return $default(_that.name,_that.enabled,_that.id,_that.groupId,_that.mouseButtons,_that.mouseButtonsExactOrder,_that.conditions,_that.endConditions,_that.blockEvents,_that.clearModifiers,_that.resumeTimeout,_that.setLastTrigger,_that.threshold,_that.accelerated,_that.actions,_that.editId);case _:
  return null;

}
}

}

/// @nodoc


class _TriggerCommon implements TriggerCommon {
  const _TriggerCommon({this.name, this.enabled, this.id, this.groupId, final  List<MouseButtonValue> mouseButtons = const [], this.mouseButtonsExactOrder = false, this.conditions, this.endConditions, this.blockEvents, this.clearModifiers, this.resumeTimeout, this.setLastTrigger, this.threshold, this.accelerated, final  List<TriggerAction> actions = const [], this.editId}): _mouseButtons = mouseButtons,_actions = actions;
  

@override final  String? name;
/// KWin does not yet read this field; setting it to false is UI-only until
/// native support is added to the effect.
@override final  bool? enabled;
@override final  String? id;
/// UI-only: references a [GestureGroup] by id for organizational grouping.
@override final  String? groupId;
 final  List<MouseButtonValue> _mouseButtons;
@override@JsonKey() List<MouseButtonValue> get mouseButtons {
  if (_mouseButtons is EqualUnmodifiableListView) return _mouseButtons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mouseButtons);
}

@override@JsonKey() final  bool mouseButtonsExactOrder;
@override final  Condition? conditions;
@override final  Condition? endConditions;
@override final  bool? blockEvents;
@override final  bool? clearModifiers;
@override final  int? resumeTimeout;
@override final  bool? setLastTrigger;
/// Either a single number or "min-max" string.
@override final  String? threshold;
@override final  bool? accelerated;
 final  List<TriggerAction> _actions;
@override@JsonKey() List<TriggerAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

/// In-memory only, never serialized. A stable identity assigned by
/// [ConfigController] so per-gesture undo history survives reorders/index
/// shifts. Excluded from dirty-diff comparisons via
/// [comparableTriggerCommon].
@override final  int? editId;

/// Create a copy of TriggerCommon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TriggerCommonCopyWith<_TriggerCommon> get copyWith => __$TriggerCommonCopyWithImpl<_TriggerCommon>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TriggerCommon&&(identical(other.name, name) || other.name == name)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&const DeepCollectionEquality().equals(other._mouseButtons, _mouseButtons)&&(identical(other.mouseButtonsExactOrder, mouseButtonsExactOrder) || other.mouseButtonsExactOrder == mouseButtonsExactOrder)&&(identical(other.conditions, conditions) || other.conditions == conditions)&&(identical(other.endConditions, endConditions) || other.endConditions == endConditions)&&(identical(other.blockEvents, blockEvents) || other.blockEvents == blockEvents)&&(identical(other.clearModifiers, clearModifiers) || other.clearModifiers == clearModifiers)&&(identical(other.resumeTimeout, resumeTimeout) || other.resumeTimeout == resumeTimeout)&&(identical(other.setLastTrigger, setLastTrigger) || other.setLastTrigger == setLastTrigger)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.accelerated, accelerated) || other.accelerated == accelerated)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,name,enabled,id,groupId,const DeepCollectionEquality().hash(_mouseButtons),mouseButtonsExactOrder,conditions,endConditions,blockEvents,clearModifiers,resumeTimeout,setLastTrigger,threshold,accelerated,const DeepCollectionEquality().hash(_actions),editId);

@override
String toString() {
  return 'TriggerCommon(name: $name, enabled: $enabled, id: $id, groupId: $groupId, mouseButtons: $mouseButtons, mouseButtonsExactOrder: $mouseButtonsExactOrder, conditions: $conditions, endConditions: $endConditions, blockEvents: $blockEvents, clearModifiers: $clearModifiers, resumeTimeout: $resumeTimeout, setLastTrigger: $setLastTrigger, threshold: $threshold, accelerated: $accelerated, actions: $actions, editId: $editId)';
}


}

/// @nodoc
abstract mixin class _$TriggerCommonCopyWith<$Res> implements $TriggerCommonCopyWith<$Res> {
  factory _$TriggerCommonCopyWith(_TriggerCommon value, $Res Function(_TriggerCommon) _then) = __$TriggerCommonCopyWithImpl;
@override @useResult
$Res call({
 String? name, bool? enabled, String? id, String? groupId, List<MouseButtonValue> mouseButtons, bool mouseButtonsExactOrder, Condition? conditions, Condition? endConditions, bool? blockEvents, bool? clearModifiers, int? resumeTimeout, bool? setLastTrigger, String? threshold, bool? accelerated, List<TriggerAction> actions, int? editId
});


@override $ConditionCopyWith<$Res>? get conditions;@override $ConditionCopyWith<$Res>? get endConditions;

}
/// @nodoc
class __$TriggerCommonCopyWithImpl<$Res>
    implements _$TriggerCommonCopyWith<$Res> {
  __$TriggerCommonCopyWithImpl(this._self, this._then);

  final _TriggerCommon _self;
  final $Res Function(_TriggerCommon) _then;

/// Create a copy of TriggerCommon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? enabled = freezed,Object? id = freezed,Object? groupId = freezed,Object? mouseButtons = null,Object? mouseButtonsExactOrder = null,Object? conditions = freezed,Object? endConditions = freezed,Object? blockEvents = freezed,Object? clearModifiers = freezed,Object? resumeTimeout = freezed,Object? setLastTrigger = freezed,Object? threshold = freezed,Object? accelerated = freezed,Object? actions = null,Object? editId = freezed,}) {
  return _then(_TriggerCommon(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String?,mouseButtons: null == mouseButtons ? _self._mouseButtons : mouseButtons // ignore: cast_nullable_to_non_nullable
as List<MouseButtonValue>,mouseButtonsExactOrder: null == mouseButtonsExactOrder ? _self.mouseButtonsExactOrder : mouseButtonsExactOrder // ignore: cast_nullable_to_non_nullable
as bool,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as Condition?,endConditions: freezed == endConditions ? _self.endConditions : endConditions // ignore: cast_nullable_to_non_nullable
as Condition?,blockEvents: freezed == blockEvents ? _self.blockEvents : blockEvents // ignore: cast_nullable_to_non_nullable
as bool?,clearModifiers: freezed == clearModifiers ? _self.clearModifiers : clearModifiers // ignore: cast_nullable_to_non_nullable
as bool?,resumeTimeout: freezed == resumeTimeout ? _self.resumeTimeout : resumeTimeout // ignore: cast_nullable_to_non_nullable
as int?,setLastTrigger: freezed == setLastTrigger ? _self.setLastTrigger : setLastTrigger // ignore: cast_nullable_to_non_nullable
as bool?,threshold: freezed == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String?,accelerated: freezed == accelerated ? _self.accelerated : accelerated // ignore: cast_nullable_to_non_nullable
as bool?,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<TriggerAction>,editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TriggerCommon
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionCopyWith<$Res>? get conditions {
    if (_self.conditions == null) {
    return null;
  }

  return $ConditionCopyWith<$Res>(_self.conditions!, (value) {
    return _then(_self.copyWith(conditions: value));
  });
}/// Create a copy of TriggerCommon
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConditionCopyWith<$Res>? get endConditions {
    if (_self.endConditions == null) {
    return null;
  }

  return $ConditionCopyWith<$Res>(_self.endConditions!, (value) {
    return _then(_self.copyWith(endConditions: value));
  });
}
}

/// @nodoc
mixin _$MotionCommon {

 TriggerSpeed? get speed; bool? get lockPointer;
/// Create a copy of MotionCommon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MotionCommonCopyWith<MotionCommon> get copyWith => _$MotionCommonCopyWithImpl<MotionCommon>(this as MotionCommon, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MotionCommon&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.lockPointer, lockPointer) || other.lockPointer == lockPointer));
}


@override
int get hashCode => Object.hash(runtimeType,speed,lockPointer);

@override
String toString() {
  return 'MotionCommon(speed: $speed, lockPointer: $lockPointer)';
}


}

/// @nodoc
abstract mixin class $MotionCommonCopyWith<$Res>  {
  factory $MotionCommonCopyWith(MotionCommon value, $Res Function(MotionCommon) _then) = _$MotionCommonCopyWithImpl;
@useResult
$Res call({
 TriggerSpeed? speed, bool? lockPointer
});




}
/// @nodoc
class _$MotionCommonCopyWithImpl<$Res>
    implements $MotionCommonCopyWith<$Res> {
  _$MotionCommonCopyWithImpl(this._self, this._then);

  final MotionCommon _self;
  final $Res Function(MotionCommon) _then;

/// Create a copy of MotionCommon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? speed = freezed,Object? lockPointer = freezed,}) {
  return _then(_self.copyWith(
speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as TriggerSpeed?,lockPointer: freezed == lockPointer ? _self.lockPointer : lockPointer // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [MotionCommon].
extension MotionCommonPatterns on MotionCommon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MotionCommon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MotionCommon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MotionCommon value)  $default,){
final _that = this;
switch (_that) {
case _MotionCommon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MotionCommon value)?  $default,){
final _that = this;
switch (_that) {
case _MotionCommon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TriggerSpeed? speed,  bool? lockPointer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MotionCommon() when $default != null:
return $default(_that.speed,_that.lockPointer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TriggerSpeed? speed,  bool? lockPointer)  $default,) {final _that = this;
switch (_that) {
case _MotionCommon():
return $default(_that.speed,_that.lockPointer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TriggerSpeed? speed,  bool? lockPointer)?  $default,) {final _that = this;
switch (_that) {
case _MotionCommon() when $default != null:
return $default(_that.speed,_that.lockPointer);case _:
  return null;

}
}

}

/// @nodoc


class _MotionCommon implements MotionCommon {
  const _MotionCommon({this.speed, this.lockPointer});
  

@override final  TriggerSpeed? speed;
@override final  bool? lockPointer;

/// Create a copy of MotionCommon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MotionCommonCopyWith<_MotionCommon> get copyWith => __$MotionCommonCopyWithImpl<_MotionCommon>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MotionCommon&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.lockPointer, lockPointer) || other.lockPointer == lockPointer));
}


@override
int get hashCode => Object.hash(runtimeType,speed,lockPointer);

@override
String toString() {
  return 'MotionCommon(speed: $speed, lockPointer: $lockPointer)';
}


}

/// @nodoc
abstract mixin class _$MotionCommonCopyWith<$Res> implements $MotionCommonCopyWith<$Res> {
  factory _$MotionCommonCopyWith(_MotionCommon value, $Res Function(_MotionCommon) _then) = __$MotionCommonCopyWithImpl;
@override @useResult
$Res call({
 TriggerSpeed? speed, bool? lockPointer
});




}
/// @nodoc
class __$MotionCommonCopyWithImpl<$Res>
    implements _$MotionCommonCopyWith<$Res> {
  __$MotionCommonCopyWithImpl(this._self, this._then);

  final _MotionCommon _self;
  final $Res Function(_MotionCommon) _then;

/// Create a copy of MotionCommon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? speed = freezed,Object? lockPointer = freezed,}) {
  return _then(_MotionCommon(
speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as TriggerSpeed?,lockPointer: freezed == lockPointer ? _self.lockPointer : lockPointer // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
