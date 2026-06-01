// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action_editor_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActionListEditorVm {

 GestureLocation get location; List<TriggerAction> get actions; DirtyMarkState get dirtyState; List<TriggerAction>? get savedActions;
/// Create a copy of ActionListEditorVm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionListEditorVmCopyWith<ActionListEditorVm> get copyWith => _$ActionListEditorVmCopyWithImpl<ActionListEditorVm>(this as ActionListEditorVm, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionListEditorVm&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.dirtyState, dirtyState) || other.dirtyState == dirtyState)&&const DeepCollectionEquality().equals(other.savedActions, savedActions));
}


@override
int get hashCode => Object.hash(runtimeType,location,const DeepCollectionEquality().hash(actions),dirtyState,const DeepCollectionEquality().hash(savedActions));

@override
String toString() {
  return 'ActionListEditorVm(location: $location, actions: $actions, dirtyState: $dirtyState, savedActions: $savedActions)';
}


}

/// @nodoc
abstract mixin class $ActionListEditorVmCopyWith<$Res>  {
  factory $ActionListEditorVmCopyWith(ActionListEditorVm value, $Res Function(ActionListEditorVm) _then) = _$ActionListEditorVmCopyWithImpl;
@useResult
$Res call({
 GestureLocation location, List<TriggerAction> actions, DirtyMarkState dirtyState, List<TriggerAction>? savedActions
});


$GestureLocationCopyWith<$Res> get location;

}
/// @nodoc
class _$ActionListEditorVmCopyWithImpl<$Res>
    implements $ActionListEditorVmCopyWith<$Res> {
  _$ActionListEditorVmCopyWithImpl(this._self, this._then);

  final ActionListEditorVm _self;
  final $Res Function(ActionListEditorVm) _then;

/// Create a copy of ActionListEditorVm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = null,Object? actions = null,Object? dirtyState = null,Object? savedActions = freezed,}) {
  return _then(_self.copyWith(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GestureLocation,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<TriggerAction>,dirtyState: null == dirtyState ? _self.dirtyState : dirtyState // ignore: cast_nullable_to_non_nullable
as DirtyMarkState,savedActions: freezed == savedActions ? _self.savedActions : savedActions // ignore: cast_nullable_to_non_nullable
as List<TriggerAction>?,
  ));
}
/// Create a copy of ActionListEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get location {
  
  return $GestureLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [ActionListEditorVm].
extension ActionListEditorVmPatterns on ActionListEditorVm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActionListEditorVm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActionListEditorVm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActionListEditorVm value)  $default,){
final _that = this;
switch (_that) {
case _ActionListEditorVm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActionListEditorVm value)?  $default,){
final _that = this;
switch (_that) {
case _ActionListEditorVm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GestureLocation location,  List<TriggerAction> actions,  DirtyMarkState dirtyState,  List<TriggerAction>? savedActions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActionListEditorVm() when $default != null:
return $default(_that.location,_that.actions,_that.dirtyState,_that.savedActions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GestureLocation location,  List<TriggerAction> actions,  DirtyMarkState dirtyState,  List<TriggerAction>? savedActions)  $default,) {final _that = this;
switch (_that) {
case _ActionListEditorVm():
return $default(_that.location,_that.actions,_that.dirtyState,_that.savedActions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GestureLocation location,  List<TriggerAction> actions,  DirtyMarkState dirtyState,  List<TriggerAction>? savedActions)?  $default,) {final _that = this;
switch (_that) {
case _ActionListEditorVm() when $default != null:
return $default(_that.location,_that.actions,_that.dirtyState,_that.savedActions);case _:
  return null;

}
}

}

/// @nodoc


class _ActionListEditorVm implements ActionListEditorVm {
  const _ActionListEditorVm({required this.location, required final  List<TriggerAction> actions, required this.dirtyState, required final  List<TriggerAction>? savedActions}): _actions = actions,_savedActions = savedActions;
  

@override final  GestureLocation location;
 final  List<TriggerAction> _actions;
@override List<TriggerAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

@override final  DirtyMarkState dirtyState;
 final  List<TriggerAction>? _savedActions;
@override List<TriggerAction>? get savedActions {
  final value = _savedActions;
  if (value == null) return null;
  if (_savedActions is EqualUnmodifiableListView) return _savedActions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ActionListEditorVm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionListEditorVmCopyWith<_ActionListEditorVm> get copyWith => __$ActionListEditorVmCopyWithImpl<_ActionListEditorVm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionListEditorVm&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.dirtyState, dirtyState) || other.dirtyState == dirtyState)&&const DeepCollectionEquality().equals(other._savedActions, _savedActions));
}


@override
int get hashCode => Object.hash(runtimeType,location,const DeepCollectionEquality().hash(_actions),dirtyState,const DeepCollectionEquality().hash(_savedActions));

@override
String toString() {
  return 'ActionListEditorVm(location: $location, actions: $actions, dirtyState: $dirtyState, savedActions: $savedActions)';
}


}

/// @nodoc
abstract mixin class _$ActionListEditorVmCopyWith<$Res> implements $ActionListEditorVmCopyWith<$Res> {
  factory _$ActionListEditorVmCopyWith(_ActionListEditorVm value, $Res Function(_ActionListEditorVm) _then) = __$ActionListEditorVmCopyWithImpl;
@override @useResult
$Res call({
 GestureLocation location, List<TriggerAction> actions, DirtyMarkState dirtyState, List<TriggerAction>? savedActions
});


@override $GestureLocationCopyWith<$Res> get location;

}
/// @nodoc
class __$ActionListEditorVmCopyWithImpl<$Res>
    implements _$ActionListEditorVmCopyWith<$Res> {
  __$ActionListEditorVmCopyWithImpl(this._self, this._then);

  final _ActionListEditorVm _self;
  final $Res Function(_ActionListEditorVm) _then;

/// Create a copy of ActionListEditorVm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = null,Object? actions = null,Object? dirtyState = null,Object? savedActions = freezed,}) {
  return _then(_ActionListEditorVm(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GestureLocation,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<TriggerAction>,dirtyState: null == dirtyState ? _self.dirtyState : dirtyState // ignore: cast_nullable_to_non_nullable
as DirtyMarkState,savedActions: freezed == savedActions ? _self._savedActions : savedActions // ignore: cast_nullable_to_non_nullable
as List<TriggerAction>?,
  ));
}

/// Create a copy of ActionListEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GestureLocationCopyWith<$Res> get location {
  
  return $GestureLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}

/// @nodoc
mixin _$ActionEditorVm {

 ActionLocation get location; TriggerAction? get action; ActionKind get kind; bool get showInterval; bool get showThreshold; bool get hasNonDefaultTriggerOptions;
/// Create a copy of ActionEditorVm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionEditorVmCopyWith<ActionEditorVm> get copyWith => _$ActionEditorVmCopyWithImpl<ActionEditorVm>(this as ActionEditorVm, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionEditorVm&&(identical(other.location, location) || other.location == location)&&(identical(other.action, action) || other.action == action)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.showInterval, showInterval) || other.showInterval == showInterval)&&(identical(other.showThreshold, showThreshold) || other.showThreshold == showThreshold)&&(identical(other.hasNonDefaultTriggerOptions, hasNonDefaultTriggerOptions) || other.hasNonDefaultTriggerOptions == hasNonDefaultTriggerOptions));
}


@override
int get hashCode => Object.hash(runtimeType,location,action,kind,showInterval,showThreshold,hasNonDefaultTriggerOptions);

@override
String toString() {
  return 'ActionEditorVm(location: $location, action: $action, kind: $kind, showInterval: $showInterval, showThreshold: $showThreshold, hasNonDefaultTriggerOptions: $hasNonDefaultTriggerOptions)';
}


}

/// @nodoc
abstract mixin class $ActionEditorVmCopyWith<$Res>  {
  factory $ActionEditorVmCopyWith(ActionEditorVm value, $Res Function(ActionEditorVm) _then) = _$ActionEditorVmCopyWithImpl;
@useResult
$Res call({
 ActionLocation location, TriggerAction? action, ActionKind kind, bool showInterval, bool showThreshold, bool hasNonDefaultTriggerOptions
});


$ActionLocationCopyWith<$Res> get location;$TriggerActionCopyWith<$Res>? get action;

}
/// @nodoc
class _$ActionEditorVmCopyWithImpl<$Res>
    implements $ActionEditorVmCopyWith<$Res> {
  _$ActionEditorVmCopyWithImpl(this._self, this._then);

  final ActionEditorVm _self;
  final $Res Function(ActionEditorVm) _then;

/// Create a copy of ActionEditorVm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? location = null,Object? action = freezed,Object? kind = null,Object? showInterval = null,Object? showThreshold = null,Object? hasNonDefaultTriggerOptions = null,}) {
  return _then(_self.copyWith(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as ActionLocation,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as TriggerAction?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ActionKind,showInterval: null == showInterval ? _self.showInterval : showInterval // ignore: cast_nullable_to_non_nullable
as bool,showThreshold: null == showThreshold ? _self.showThreshold : showThreshold // ignore: cast_nullable_to_non_nullable
as bool,hasNonDefaultTriggerOptions: null == hasNonDefaultTriggerOptions ? _self.hasNonDefaultTriggerOptions : hasNonDefaultTriggerOptions // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ActionEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActionLocationCopyWith<$Res> get location {
  
  return $ActionLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of ActionEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerActionCopyWith<$Res>? get action {
    if (_self.action == null) {
    return null;
  }

  return $TriggerActionCopyWith<$Res>(_self.action!, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}


/// Adds pattern-matching-related methods to [ActionEditorVm].
extension ActionEditorVmPatterns on ActionEditorVm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActionEditorVm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActionEditorVm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActionEditorVm value)  $default,){
final _that = this;
switch (_that) {
case _ActionEditorVm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActionEditorVm value)?  $default,){
final _that = this;
switch (_that) {
case _ActionEditorVm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActionLocation location,  TriggerAction? action,  ActionKind kind,  bool showInterval,  bool showThreshold,  bool hasNonDefaultTriggerOptions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActionEditorVm() when $default != null:
return $default(_that.location,_that.action,_that.kind,_that.showInterval,_that.showThreshold,_that.hasNonDefaultTriggerOptions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActionLocation location,  TriggerAction? action,  ActionKind kind,  bool showInterval,  bool showThreshold,  bool hasNonDefaultTriggerOptions)  $default,) {final _that = this;
switch (_that) {
case _ActionEditorVm():
return $default(_that.location,_that.action,_that.kind,_that.showInterval,_that.showThreshold,_that.hasNonDefaultTriggerOptions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActionLocation location,  TriggerAction? action,  ActionKind kind,  bool showInterval,  bool showThreshold,  bool hasNonDefaultTriggerOptions)?  $default,) {final _that = this;
switch (_that) {
case _ActionEditorVm() when $default != null:
return $default(_that.location,_that.action,_that.kind,_that.showInterval,_that.showThreshold,_that.hasNonDefaultTriggerOptions);case _:
  return null;

}
}

}

/// @nodoc


class _ActionEditorVm extends ActionEditorVm {
  const _ActionEditorVm({required this.location, required this.action, required this.kind, required this.showInterval, required this.showThreshold, required this.hasNonDefaultTriggerOptions}): super._();
  

@override final  ActionLocation location;
@override final  TriggerAction? action;
@override final  ActionKind kind;
@override final  bool showInterval;
@override final  bool showThreshold;
@override final  bool hasNonDefaultTriggerOptions;

/// Create a copy of ActionEditorVm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionEditorVmCopyWith<_ActionEditorVm> get copyWith => __$ActionEditorVmCopyWithImpl<_ActionEditorVm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionEditorVm&&(identical(other.location, location) || other.location == location)&&(identical(other.action, action) || other.action == action)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.showInterval, showInterval) || other.showInterval == showInterval)&&(identical(other.showThreshold, showThreshold) || other.showThreshold == showThreshold)&&(identical(other.hasNonDefaultTriggerOptions, hasNonDefaultTriggerOptions) || other.hasNonDefaultTriggerOptions == hasNonDefaultTriggerOptions));
}


@override
int get hashCode => Object.hash(runtimeType,location,action,kind,showInterval,showThreshold,hasNonDefaultTriggerOptions);

@override
String toString() {
  return 'ActionEditorVm(location: $location, action: $action, kind: $kind, showInterval: $showInterval, showThreshold: $showThreshold, hasNonDefaultTriggerOptions: $hasNonDefaultTriggerOptions)';
}


}

/// @nodoc
abstract mixin class _$ActionEditorVmCopyWith<$Res> implements $ActionEditorVmCopyWith<$Res> {
  factory _$ActionEditorVmCopyWith(_ActionEditorVm value, $Res Function(_ActionEditorVm) _then) = __$ActionEditorVmCopyWithImpl;
@override @useResult
$Res call({
 ActionLocation location, TriggerAction? action, ActionKind kind, bool showInterval, bool showThreshold, bool hasNonDefaultTriggerOptions
});


@override $ActionLocationCopyWith<$Res> get location;@override $TriggerActionCopyWith<$Res>? get action;

}
/// @nodoc
class __$ActionEditorVmCopyWithImpl<$Res>
    implements _$ActionEditorVmCopyWith<$Res> {
  __$ActionEditorVmCopyWithImpl(this._self, this._then);

  final _ActionEditorVm _self;
  final $Res Function(_ActionEditorVm) _then;

/// Create a copy of ActionEditorVm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? location = null,Object? action = freezed,Object? kind = null,Object? showInterval = null,Object? showThreshold = null,Object? hasNonDefaultTriggerOptions = null,}) {
  return _then(_ActionEditorVm(
location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as ActionLocation,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as TriggerAction?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ActionKind,showInterval: null == showInterval ? _self.showInterval : showInterval // ignore: cast_nullable_to_non_nullable
as bool,showThreshold: null == showThreshold ? _self.showThreshold : showThreshold // ignore: cast_nullable_to_non_nullable
as bool,hasNonDefaultTriggerOptions: null == hasNonDefaultTriggerOptions ? _self.hasNonDefaultTriggerOptions : hasNonDefaultTriggerOptions // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ActionEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActionLocationCopyWith<$Res> get location {
  
  return $ActionLocationCopyWith<$Res>(_self.location, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of ActionEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerActionCopyWith<$Res>? get action {
    if (_self.action == null) {
    return null;
  }

  return $TriggerActionCopyWith<$Res>(_self.action!, (value) {
    return _then(_self.copyWith(action: value));
  });
}
}

// dart format on
