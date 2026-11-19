// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gesture_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GestureNode {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureNode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GestureNode()';
}


}

/// @nodoc
class $GestureNodeCopyWith<$Res>  {
$GestureNodeCopyWith(GestureNode _, $Res Function(GestureNode) __);
}


/// Adds pattern-matching-related methods to [GestureNode].
extension GestureNodePatterns on GestureNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GestureLeaf value)?  leaf,TResult Function( GestureGroupNode value)?  group,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GestureLeaf() when leaf != null:
return leaf(_that);case GestureGroupNode() when group != null:
return group(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GestureLeaf value)  leaf,required TResult Function( GestureGroupNode value)  group,}){
final _that = this;
switch (_that) {
case GestureLeaf():
return leaf(_that);case GestureGroupNode():
return group(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GestureLeaf value)?  leaf,TResult? Function( GestureGroupNode value)?  group,}){
final _that = this;
switch (_that) {
case GestureLeaf() when leaf != null:
return leaf(_that);case GestureGroupNode() when group != null:
return group(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Gesture gesture)?  leaf,TResult Function( String name,  bool enabled,  Condition? conditions,  String? id,  String? threshold,  int? resumeTimeout,  bool? accelerated,  bool? blockEvents,  bool? clearModifiers,  bool? setLastTrigger,  Condition? endConditions,  List<MouseButtonValue>? mouseButtons,  bool? mouseButtonsExactOrder,  FingerRange? fingers,  TriggerSpeed? speed,  bool? instant,  bool? lockPointer,  Map<String, dynamic> extra,  List<GestureNode> children,  int? editId)?  group,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GestureLeaf() when leaf != null:
return leaf(_that.gesture);case GestureGroupNode() when group != null:
return group(_that.name,_that.enabled,_that.conditions,_that.id,_that.threshold,_that.resumeTimeout,_that.accelerated,_that.blockEvents,_that.clearModifiers,_that.setLastTrigger,_that.endConditions,_that.mouseButtons,_that.mouseButtonsExactOrder,_that.fingers,_that.speed,_that.instant,_that.lockPointer,_that.extra,_that.children,_that.editId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Gesture gesture)  leaf,required TResult Function( String name,  bool enabled,  Condition? conditions,  String? id,  String? threshold,  int? resumeTimeout,  bool? accelerated,  bool? blockEvents,  bool? clearModifiers,  bool? setLastTrigger,  Condition? endConditions,  List<MouseButtonValue>? mouseButtons,  bool? mouseButtonsExactOrder,  FingerRange? fingers,  TriggerSpeed? speed,  bool? instant,  bool? lockPointer,  Map<String, dynamic> extra,  List<GestureNode> children,  int? editId)  group,}) {final _that = this;
switch (_that) {
case GestureLeaf():
return leaf(_that.gesture);case GestureGroupNode():
return group(_that.name,_that.enabled,_that.conditions,_that.id,_that.threshold,_that.resumeTimeout,_that.accelerated,_that.blockEvents,_that.clearModifiers,_that.setLastTrigger,_that.endConditions,_that.mouseButtons,_that.mouseButtonsExactOrder,_that.fingers,_that.speed,_that.instant,_that.lockPointer,_that.extra,_that.children,_that.editId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Gesture gesture)?  leaf,TResult? Function( String name,  bool enabled,  Condition? conditions,  String? id,  String? threshold,  int? resumeTimeout,  bool? accelerated,  bool? blockEvents,  bool? clearModifiers,  bool? setLastTrigger,  Condition? endConditions,  List<MouseButtonValue>? mouseButtons,  bool? mouseButtonsExactOrder,  FingerRange? fingers,  TriggerSpeed? speed,  bool? instant,  bool? lockPointer,  Map<String, dynamic> extra,  List<GestureNode> children,  int? editId)?  group,}) {final _that = this;
switch (_that) {
case GestureLeaf() when leaf != null:
return leaf(_that.gesture);case GestureGroupNode() when group != null:
return group(_that.name,_that.enabled,_that.conditions,_that.id,_that.threshold,_that.resumeTimeout,_that.accelerated,_that.blockEvents,_that.clearModifiers,_that.setLastTrigger,_that.endConditions,_that.mouseButtons,_that.mouseButtonsExactOrder,_that.fingers,_that.speed,_that.instant,_that.lockPointer,_that.extra,_that.children,_that.editId);case _:
  return null;

}
}

}

/// @nodoc


class GestureLeaf extends GestureNode {
  const GestureLeaf(this.gesture): super._();
  

 final  Gesture gesture;

/// Create a copy of GestureNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureLeafCopyWith<GestureLeaf> get copyWith => _$GestureLeafCopyWithImpl<GestureLeaf>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureLeaf&&(identical(other.gesture, gesture) || other.gesture == gesture));
}


@override
int get hashCode => Object.hash(runtimeType,gesture);

@override
String toString() {
  return 'GestureNode.leaf(gesture: $gesture)';
}


}

/// @nodoc
abstract mixin class $GestureLeafCopyWith<$Res> implements $GestureNodeCopyWith<$Res> {
  factory $GestureLeafCopyWith(GestureLeaf value, $Res Function(GestureLeaf) _then) = _$GestureLeafCopyWithImpl;
@useResult
$Res call({
 Gesture gesture
});




}
/// @nodoc
class _$GestureLeafCopyWithImpl<$Res>
    implements $GestureLeafCopyWith<$Res> {
  _$GestureLeafCopyWithImpl(this._self, this._then);

  final GestureLeaf _self;
  final $Res Function(GestureLeaf) _then;

/// Create a copy of GestureNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? gesture = null,}) {
  return _then(GestureLeaf(
null == gesture ? _self.gesture : gesture // ignore: cast_nullable_to_non_nullable
as Gesture,
  ));
}


}

/// @nodoc


class GestureGroupNode extends GestureNode {
  const GestureGroupNode({this.name = '', this.enabled = true, this.conditions, this.id, this.threshold, this.resumeTimeout, this.accelerated, this.blockEvents, this.clearModifiers, this.setLastTrigger, this.endConditions, final  List<MouseButtonValue>? mouseButtons, this.mouseButtonsExactOrder, this.fingers, this.speed, this.instant, this.lockPointer, final  Map<String, dynamic> extra = const <String, dynamic>{}, final  List<GestureNode> children = const <GestureNode>[], this.editId}): _mouseButtons = mouseButtons,_extra = extra,_children = children,super._();
  

@JsonKey() final  String name;
@JsonKey() final  bool enabled;
/// Conditions the daemon applies to every gesture in this group. Unlike
/// the shared properties below, conditions genuinely compose: the daemon
/// AND-merges a group's conditions into each descendant's own.
 final  Condition? conditions;
/// Shared trigger properties. The daemon copies each of these onto every
/// gesture in the subtree that does not set the key itself, see
/// [GestureGroupNode] docs on why a descendant setting the same key is an
/// unresolvable conflict rather than an override.
 final  String? id;
 final  String? threshold;
 final  int? resumeTimeout;
 final  bool? accelerated;
 final  bool? blockEvents;
 final  bool? clearModifiers;
 final  bool? setLastTrigger;
 final  Condition? endConditions;
 final  List<MouseButtonValue>? _mouseButtons;
 List<MouseButtonValue>? get mouseButtons {
  final value = _mouseButtons;
  if (value == null) return null;
  if (_mouseButtons is EqualUnmodifiableListView) return _mouseButtons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  bool? mouseButtonsExactOrder;
 final  FingerRange? fingers;
 final  TriggerSpeed? speed;
 final  bool? instant;
 final  bool? lockPointer;
/// Unmodelled properties of the group node, preserved for round-trip.
 final  Map<String, dynamic> _extra;
/// Unmodelled properties of the group node, preserved for round-trip.
@JsonKey() Map<String, dynamic> get extra {
  if (_extra is EqualUnmodifiableMapView) return _extra;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extra);
}

 final  List<GestureNode> _children;
@JsonKey() List<GestureNode> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}

/// In-memory identity for UI state and edit targeting, assigned by
/// `assignEditIds` like gesture editIds; never serialized.
 final  int? editId;

/// Create a copy of GestureNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GestureGroupNodeCopyWith<GestureGroupNode> get copyWith => _$GestureGroupNodeCopyWithImpl<GestureGroupNode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GestureGroupNode&&(identical(other.name, name) || other.name == name)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.conditions, conditions) || other.conditions == conditions)&&(identical(other.id, id) || other.id == id)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.resumeTimeout, resumeTimeout) || other.resumeTimeout == resumeTimeout)&&(identical(other.accelerated, accelerated) || other.accelerated == accelerated)&&(identical(other.blockEvents, blockEvents) || other.blockEvents == blockEvents)&&(identical(other.clearModifiers, clearModifiers) || other.clearModifiers == clearModifiers)&&(identical(other.setLastTrigger, setLastTrigger) || other.setLastTrigger == setLastTrigger)&&(identical(other.endConditions, endConditions) || other.endConditions == endConditions)&&const DeepCollectionEquality().equals(other._mouseButtons, _mouseButtons)&&(identical(other.mouseButtonsExactOrder, mouseButtonsExactOrder) || other.mouseButtonsExactOrder == mouseButtonsExactOrder)&&(identical(other.fingers, fingers) || other.fingers == fingers)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.instant, instant) || other.instant == instant)&&(identical(other.lockPointer, lockPointer) || other.lockPointer == lockPointer)&&const DeepCollectionEquality().equals(other._extra, _extra)&&const DeepCollectionEquality().equals(other._children, _children)&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hashAll([runtimeType,name,enabled,conditions,id,threshold,resumeTimeout,accelerated,blockEvents,clearModifiers,setLastTrigger,endConditions,const DeepCollectionEquality().hash(_mouseButtons),mouseButtonsExactOrder,fingers,speed,instant,lockPointer,const DeepCollectionEquality().hash(_extra),const DeepCollectionEquality().hash(_children),editId]);

@override
String toString() {
  return 'GestureNode.group(name: $name, enabled: $enabled, conditions: $conditions, id: $id, threshold: $threshold, resumeTimeout: $resumeTimeout, accelerated: $accelerated, blockEvents: $blockEvents, clearModifiers: $clearModifiers, setLastTrigger: $setLastTrigger, endConditions: $endConditions, mouseButtons: $mouseButtons, mouseButtonsExactOrder: $mouseButtonsExactOrder, fingers: $fingers, speed: $speed, instant: $instant, lockPointer: $lockPointer, extra: $extra, children: $children, editId: $editId)';
}


}

/// @nodoc
abstract mixin class $GestureGroupNodeCopyWith<$Res> implements $GestureNodeCopyWith<$Res> {
  factory $GestureGroupNodeCopyWith(GestureGroupNode value, $Res Function(GestureGroupNode) _then) = _$GestureGroupNodeCopyWithImpl;
@useResult
$Res call({
 String name, bool enabled, Condition? conditions, String? id, String? threshold, int? resumeTimeout, bool? accelerated, bool? blockEvents, bool? clearModifiers, bool? setLastTrigger, Condition? endConditions, List<MouseButtonValue>? mouseButtons, bool? mouseButtonsExactOrder, FingerRange? fingers, TriggerSpeed? speed, bool? instant, bool? lockPointer, Map<String, dynamic> extra, List<GestureNode> children, int? editId
});


$ConditionCopyWith<$Res>? get conditions;$ConditionCopyWith<$Res>? get endConditions;$FingerRangeCopyWith<$Res>? get fingers;

}
/// @nodoc
class _$GestureGroupNodeCopyWithImpl<$Res>
    implements $GestureGroupNodeCopyWith<$Res> {
  _$GestureGroupNodeCopyWithImpl(this._self, this._then);

  final GestureGroupNode _self;
  final $Res Function(GestureGroupNode) _then;

/// Create a copy of GestureNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,Object? enabled = null,Object? conditions = freezed,Object? id = freezed,Object? threshold = freezed,Object? resumeTimeout = freezed,Object? accelerated = freezed,Object? blockEvents = freezed,Object? clearModifiers = freezed,Object? setLastTrigger = freezed,Object? endConditions = freezed,Object? mouseButtons = freezed,Object? mouseButtonsExactOrder = freezed,Object? fingers = freezed,Object? speed = freezed,Object? instant = freezed,Object? lockPointer = freezed,Object? extra = null,Object? children = null,Object? editId = freezed,}) {
  return _then(GestureGroupNode(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as Condition?,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,threshold: freezed == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String?,resumeTimeout: freezed == resumeTimeout ? _self.resumeTimeout : resumeTimeout // ignore: cast_nullable_to_non_nullable
as int?,accelerated: freezed == accelerated ? _self.accelerated : accelerated // ignore: cast_nullable_to_non_nullable
as bool?,blockEvents: freezed == blockEvents ? _self.blockEvents : blockEvents // ignore: cast_nullable_to_non_nullable
as bool?,clearModifiers: freezed == clearModifiers ? _self.clearModifiers : clearModifiers // ignore: cast_nullable_to_non_nullable
as bool?,setLastTrigger: freezed == setLastTrigger ? _self.setLastTrigger : setLastTrigger // ignore: cast_nullable_to_non_nullable
as bool?,endConditions: freezed == endConditions ? _self.endConditions : endConditions // ignore: cast_nullable_to_non_nullable
as Condition?,mouseButtons: freezed == mouseButtons ? _self._mouseButtons : mouseButtons // ignore: cast_nullable_to_non_nullable
as List<MouseButtonValue>?,mouseButtonsExactOrder: freezed == mouseButtonsExactOrder ? _self.mouseButtonsExactOrder : mouseButtonsExactOrder // ignore: cast_nullable_to_non_nullable
as bool?,fingers: freezed == fingers ? _self.fingers : fingers // ignore: cast_nullable_to_non_nullable
as FingerRange?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as TriggerSpeed?,instant: freezed == instant ? _self.instant : instant // ignore: cast_nullable_to_non_nullable
as bool?,lockPointer: freezed == lockPointer ? _self.lockPointer : lockPointer // ignore: cast_nullable_to_non_nullable
as bool?,extra: null == extra ? _self._extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of GestureNode
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
}/// Create a copy of GestureNode
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
}/// Create a copy of GestureNode
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FingerRangeCopyWith<$Res>? get fingers {
    if (_self.fingers == null) {
    return null;
  }

  return $FingerRangeCopyWith<$Res>(_self.fingers!, (value) {
    return _then(_self.copyWith(fingers: value));
  });
}
}

// dart format on
