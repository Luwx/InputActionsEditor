// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TriggerAction {

 Action get action; bool? get enabled;/// Null means the `on:` key was absent in YAML (daemon defaults to
/// `end`).
 TriggerOnValue? get on; Condition? get conditions; String? get interval; String? get threshold; bool get conflicting; String? get id; int? get limit;/// In-memory identity, filled in by `assignEditIds`; never serialized.
 int? get editId;
/// Create a copy of TriggerAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriggerActionCopyWith<TriggerAction> get copyWith => _$TriggerActionCopyWithImpl<TriggerAction>(this as TriggerAction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TriggerAction&&(identical(other.action, action) || other.action == action)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.on, on) || other.on == on)&&(identical(other.conditions, conditions) || other.conditions == conditions)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.conflicting, conflicting) || other.conflicting == conflicting)&&(identical(other.id, id) || other.id == id)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,action,enabled,on,conditions,interval,threshold,conflicting,id,limit,editId);

@override
String toString() {
  return 'TriggerAction(action: $action, enabled: $enabled, on: $on, conditions: $conditions, interval: $interval, threshold: $threshold, conflicting: $conflicting, id: $id, limit: $limit, editId: $editId)';
}


}

/// @nodoc
abstract mixin class $TriggerActionCopyWith<$Res>  {
  factory $TriggerActionCopyWith(TriggerAction value, $Res Function(TriggerAction) _then) = _$TriggerActionCopyWithImpl;
@useResult
$Res call({
 Action action, bool? enabled, TriggerOnValue? on, Condition? conditions, String? interval, String? threshold, bool conflicting, String? id, int? limit, int? editId
});


$ActionCopyWith<$Res> get action;$ConditionCopyWith<$Res>? get conditions;

}
/// @nodoc
class _$TriggerActionCopyWithImpl<$Res>
    implements $TriggerActionCopyWith<$Res> {
  _$TriggerActionCopyWithImpl(this._self, this._then);

  final TriggerAction _self;
  final $Res Function(TriggerAction) _then;

/// Create a copy of TriggerAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? enabled = freezed,Object? on = freezed,Object? conditions = freezed,Object? interval = freezed,Object? threshold = freezed,Object? conflicting = null,Object? id = freezed,Object? limit = freezed,Object? editId = freezed,}) {
  return _then(_self.copyWith(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as Action,enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,on: freezed == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as TriggerOnValue?,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as Condition?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String?,threshold: freezed == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String?,conflicting: null == conflicting ? _self.conflicting : conflicting // ignore: cast_nullable_to_non_nullable
as bool,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TriggerAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActionCopyWith<$Res> get action {
  
  return $ActionCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}/// Create a copy of TriggerAction
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
}
}


/// Adds pattern-matching-related methods to [TriggerAction].
extension TriggerActionPatterns on TriggerAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TriggerAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TriggerAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TriggerAction value)  $default,){
final _that = this;
switch (_that) {
case _TriggerAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TriggerAction value)?  $default,){
final _that = this;
switch (_that) {
case _TriggerAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Action action,  bool? enabled,  TriggerOnValue? on,  Condition? conditions,  String? interval,  String? threshold,  bool conflicting,  String? id,  int? limit,  int? editId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TriggerAction() when $default != null:
return $default(_that.action,_that.enabled,_that.on,_that.conditions,_that.interval,_that.threshold,_that.conflicting,_that.id,_that.limit,_that.editId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Action action,  bool? enabled,  TriggerOnValue? on,  Condition? conditions,  String? interval,  String? threshold,  bool conflicting,  String? id,  int? limit,  int? editId)  $default,) {final _that = this;
switch (_that) {
case _TriggerAction():
return $default(_that.action,_that.enabled,_that.on,_that.conditions,_that.interval,_that.threshold,_that.conflicting,_that.id,_that.limit,_that.editId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Action action,  bool? enabled,  TriggerOnValue? on,  Condition? conditions,  String? interval,  String? threshold,  bool conflicting,  String? id,  int? limit,  int? editId)?  $default,) {final _that = this;
switch (_that) {
case _TriggerAction() when $default != null:
return $default(_that.action,_that.enabled,_that.on,_that.conditions,_that.interval,_that.threshold,_that.conflicting,_that.id,_that.limit,_that.editId);case _:
  return null;

}
}

}

/// @nodoc


class _TriggerAction implements TriggerAction {
  const _TriggerAction({required this.action, this.enabled, this.on, this.conditions, this.interval, this.threshold, this.conflicting = true, this.id, this.limit, this.editId});
  

@override final  Action action;
@override final  bool? enabled;
/// Null means the `on:` key was absent in YAML (daemon defaults to
/// `end`).
@override final  TriggerOnValue? on;
@override final  Condition? conditions;
@override final  String? interval;
@override final  String? threshold;
@override@JsonKey() final  bool conflicting;
@override final  String? id;
@override final  int? limit;
/// In-memory identity, filled in by `assignEditIds`; never serialized.
@override final  int? editId;

/// Create a copy of TriggerAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TriggerActionCopyWith<_TriggerAction> get copyWith => __$TriggerActionCopyWithImpl<_TriggerAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TriggerAction&&(identical(other.action, action) || other.action == action)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.on, on) || other.on == on)&&(identical(other.conditions, conditions) || other.conditions == conditions)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.conflicting, conflicting) || other.conflicting == conflicting)&&(identical(other.id, id) || other.id == id)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,action,enabled,on,conditions,interval,threshold,conflicting,id,limit,editId);

@override
String toString() {
  return 'TriggerAction(action: $action, enabled: $enabled, on: $on, conditions: $conditions, interval: $interval, threshold: $threshold, conflicting: $conflicting, id: $id, limit: $limit, editId: $editId)';
}


}

/// @nodoc
abstract mixin class _$TriggerActionCopyWith<$Res> implements $TriggerActionCopyWith<$Res> {
  factory _$TriggerActionCopyWith(_TriggerAction value, $Res Function(_TriggerAction) _then) = __$TriggerActionCopyWithImpl;
@override @useResult
$Res call({
 Action action, bool? enabled, TriggerOnValue? on, Condition? conditions, String? interval, String? threshold, bool conflicting, String? id, int? limit, int? editId
});


@override $ActionCopyWith<$Res> get action;@override $ConditionCopyWith<$Res>? get conditions;

}
/// @nodoc
class __$TriggerActionCopyWithImpl<$Res>
    implements _$TriggerActionCopyWith<$Res> {
  __$TriggerActionCopyWithImpl(this._self, this._then);

  final _TriggerAction _self;
  final $Res Function(_TriggerAction) _then;

/// Create a copy of TriggerAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? enabled = freezed,Object? on = freezed,Object? conditions = freezed,Object? interval = freezed,Object? threshold = freezed,Object? conflicting = null,Object? id = freezed,Object? limit = freezed,Object? editId = freezed,}) {
  return _then(_TriggerAction(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as Action,enabled: freezed == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool?,on: freezed == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as TriggerOnValue?,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as Condition?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String?,threshold: freezed == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String?,conflicting: null == conflicting ? _self.conflicting : conflicting // ignore: cast_nullable_to_non_nullable
as bool,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TriggerAction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ActionCopyWith<$Res> get action {
  
  return $ActionCopyWith<$Res>(_self.action, (value) {
    return _then(_self.copyWith(action: value));
  });
}/// Create a copy of TriggerAction
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
}
}

/// @nodoc
mixin _$Action {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Action);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Action()';
}


}

/// @nodoc
class $ActionCopyWith<$Res>  {
$ActionCopyWith(Action _, $Res Function(Action) __);
}


/// Adds pattern-matching-related methods to [Action].
extension ActionPatterns on Action {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CommandAction value)?  command,TResult Function( InputAction value)?  input,TResult Function( PlasmaShortcutAction value)?  plasmaShortcut,TResult Function( ActivateWindowAction value)?  activateWindow,TResult Function( ReplaceTextAction value)?  replaceText,TResult Function( SleepAction value)?  sleep,TResult Function( FunctionAction value)?  function,TResult Function( ActionGroup value)?  group,TResult Function( ContextMenuAction value)?  contextMenu,TResult Function( RawAction value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CommandAction() when command != null:
return command(_that);case InputAction() when input != null:
return input(_that);case PlasmaShortcutAction() when plasmaShortcut != null:
return plasmaShortcut(_that);case ActivateWindowAction() when activateWindow != null:
return activateWindow(_that);case ReplaceTextAction() when replaceText != null:
return replaceText(_that);case SleepAction() when sleep != null:
return sleep(_that);case FunctionAction() when function != null:
return function(_that);case ActionGroup() when group != null:
return group(_that);case ContextMenuAction() when contextMenu != null:
return contextMenu(_that);case RawAction() when raw != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CommandAction value)  command,required TResult Function( InputAction value)  input,required TResult Function( PlasmaShortcutAction value)  plasmaShortcut,required TResult Function( ActivateWindowAction value)  activateWindow,required TResult Function( ReplaceTextAction value)  replaceText,required TResult Function( SleepAction value)  sleep,required TResult Function( FunctionAction value)  function,required TResult Function( ActionGroup value)  group,required TResult Function( ContextMenuAction value)  contextMenu,required TResult Function( RawAction value)  raw,}){
final _that = this;
switch (_that) {
case CommandAction():
return command(_that);case InputAction():
return input(_that);case PlasmaShortcutAction():
return plasmaShortcut(_that);case ActivateWindowAction():
return activateWindow(_that);case ReplaceTextAction():
return replaceText(_that);case SleepAction():
return sleep(_that);case FunctionAction():
return function(_that);case ActionGroup():
return group(_that);case ContextMenuAction():
return contextMenu(_that);case RawAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CommandAction value)?  command,TResult? Function( InputAction value)?  input,TResult? Function( PlasmaShortcutAction value)?  plasmaShortcut,TResult? Function( ActivateWindowAction value)?  activateWindow,TResult? Function( ReplaceTextAction value)?  replaceText,TResult? Function( SleepAction value)?  sleep,TResult? Function( FunctionAction value)?  function,TResult? Function( ActionGroup value)?  group,TResult? Function( ContextMenuAction value)?  contextMenu,TResult? Function( RawAction value)?  raw,}){
final _that = this;
switch (_that) {
case CommandAction() when command != null:
return command(_that);case InputAction() when input != null:
return input(_that);case PlasmaShortcutAction() when plasmaShortcut != null:
return plasmaShortcut(_that);case ActivateWindowAction() when activateWindow != null:
return activateWindow(_that);case ReplaceTextAction() when replaceText != null:
return replaceText(_that);case SleepAction() when sleep != null:
return sleep(_that);case FunctionAction() when function != null:
return function(_that);case ActionGroup() when group != null:
return group(_that);case ContextMenuAction() when contextMenu != null:
return contextMenu(_that);case RawAction() when raw != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String command,  bool? wait)?  command,TResult Function( List<InputEntry> entries,  int? delay)?  input,TResult Function( String component,  String shortcut)?  plasmaShortcut,TResult Function( String windowId)?  activateWindow,TResult Function( List<TextSubstitutionRule> rules)?  replaceText,TResult Function( int milliseconds)?  sleep,TResult Function( String expression)?  function,TResult Function( List<TriggerAction> actions)?  group,TResult Function( List<MenuItem> items)?  contextMenu,TResult Function( String raw)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CommandAction() when command != null:
return command(_that.command,_that.wait);case InputAction() when input != null:
return input(_that.entries,_that.delay);case PlasmaShortcutAction() when plasmaShortcut != null:
return plasmaShortcut(_that.component,_that.shortcut);case ActivateWindowAction() when activateWindow != null:
return activateWindow(_that.windowId);case ReplaceTextAction() when replaceText != null:
return replaceText(_that.rules);case SleepAction() when sleep != null:
return sleep(_that.milliseconds);case FunctionAction() when function != null:
return function(_that.expression);case ActionGroup() when group != null:
return group(_that.actions);case ContextMenuAction() when contextMenu != null:
return contextMenu(_that.items);case RawAction() when raw != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String command,  bool? wait)  command,required TResult Function( List<InputEntry> entries,  int? delay)  input,required TResult Function( String component,  String shortcut)  plasmaShortcut,required TResult Function( String windowId)  activateWindow,required TResult Function( List<TextSubstitutionRule> rules)  replaceText,required TResult Function( int milliseconds)  sleep,required TResult Function( String expression)  function,required TResult Function( List<TriggerAction> actions)  group,required TResult Function( List<MenuItem> items)  contextMenu,required TResult Function( String raw)  raw,}) {final _that = this;
switch (_that) {
case CommandAction():
return command(_that.command,_that.wait);case InputAction():
return input(_that.entries,_that.delay);case PlasmaShortcutAction():
return plasmaShortcut(_that.component,_that.shortcut);case ActivateWindowAction():
return activateWindow(_that.windowId);case ReplaceTextAction():
return replaceText(_that.rules);case SleepAction():
return sleep(_that.milliseconds);case FunctionAction():
return function(_that.expression);case ActionGroup():
return group(_that.actions);case ContextMenuAction():
return contextMenu(_that.items);case RawAction():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String command,  bool? wait)?  command,TResult? Function( List<InputEntry> entries,  int? delay)?  input,TResult? Function( String component,  String shortcut)?  plasmaShortcut,TResult? Function( String windowId)?  activateWindow,TResult? Function( List<TextSubstitutionRule> rules)?  replaceText,TResult? Function( int milliseconds)?  sleep,TResult? Function( String expression)?  function,TResult? Function( List<TriggerAction> actions)?  group,TResult? Function( List<MenuItem> items)?  contextMenu,TResult? Function( String raw)?  raw,}) {final _that = this;
switch (_that) {
case CommandAction() when command != null:
return command(_that.command,_that.wait);case InputAction() when input != null:
return input(_that.entries,_that.delay);case PlasmaShortcutAction() when plasmaShortcut != null:
return plasmaShortcut(_that.component,_that.shortcut);case ActivateWindowAction() when activateWindow != null:
return activateWindow(_that.windowId);case ReplaceTextAction() when replaceText != null:
return replaceText(_that.rules);case SleepAction() when sleep != null:
return sleep(_that.milliseconds);case FunctionAction() when function != null:
return function(_that.expression);case ActionGroup() when group != null:
return group(_that.actions);case ContextMenuAction() when contextMenu != null:
return contextMenu(_that.items);case RawAction() when raw != null:
return raw(_that.raw);case _:
  return null;

}
}

}

/// @nodoc


class CommandAction implements Action {
  const CommandAction({required this.command, this.wait});
  

 final  String command;
 final  bool? wait;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandActionCopyWith<CommandAction> get copyWith => _$CommandActionCopyWithImpl<CommandAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandAction&&(identical(other.command, command) || other.command == command)&&(identical(other.wait, wait) || other.wait == wait));
}


@override
int get hashCode => Object.hash(runtimeType,command,wait);

@override
String toString() {
  return 'Action.command(command: $command, wait: $wait)';
}


}

/// @nodoc
abstract mixin class $CommandActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $CommandActionCopyWith(CommandAction value, $Res Function(CommandAction) _then) = _$CommandActionCopyWithImpl;
@useResult
$Res call({
 String command, bool? wait
});




}
/// @nodoc
class _$CommandActionCopyWithImpl<$Res>
    implements $CommandActionCopyWith<$Res> {
  _$CommandActionCopyWithImpl(this._self, this._then);

  final CommandAction _self;
  final $Res Function(CommandAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? command = null,Object? wait = freezed,}) {
  return _then(CommandAction(
command: null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,wait: freezed == wait ? _self.wait : wait // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc


class InputAction implements Action {
  const InputAction({final  List<InputEntry> entries = const [], this.delay}): _entries = entries;
  

 final  List<InputEntry> _entries;
@JsonKey() List<InputEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

 final  int? delay;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InputActionCopyWith<InputAction> get copyWith => _$InputActionCopyWithImpl<InputAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InputAction&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.delay, delay) || other.delay == delay));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),delay);

@override
String toString() {
  return 'Action.input(entries: $entries, delay: $delay)';
}


}

/// @nodoc
abstract mixin class $InputActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $InputActionCopyWith(InputAction value, $Res Function(InputAction) _then) = _$InputActionCopyWithImpl;
@useResult
$Res call({
 List<InputEntry> entries, int? delay
});




}
/// @nodoc
class _$InputActionCopyWithImpl<$Res>
    implements $InputActionCopyWith<$Res> {
  _$InputActionCopyWithImpl(this._self, this._then);

  final InputAction _self;
  final $Res Function(InputAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? delay = freezed,}) {
  return _then(InputAction(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<InputEntry>,delay: freezed == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class PlasmaShortcutAction implements Action {
  const PlasmaShortcutAction({required this.component, required this.shortcut});
  

 final  String component;
 final  String shortcut;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlasmaShortcutActionCopyWith<PlasmaShortcutAction> get copyWith => _$PlasmaShortcutActionCopyWithImpl<PlasmaShortcutAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlasmaShortcutAction&&(identical(other.component, component) || other.component == component)&&(identical(other.shortcut, shortcut) || other.shortcut == shortcut));
}


@override
int get hashCode => Object.hash(runtimeType,component,shortcut);

@override
String toString() {
  return 'Action.plasmaShortcut(component: $component, shortcut: $shortcut)';
}


}

/// @nodoc
abstract mixin class $PlasmaShortcutActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $PlasmaShortcutActionCopyWith(PlasmaShortcutAction value, $Res Function(PlasmaShortcutAction) _then) = _$PlasmaShortcutActionCopyWithImpl;
@useResult
$Res call({
 String component, String shortcut
});




}
/// @nodoc
class _$PlasmaShortcutActionCopyWithImpl<$Res>
    implements $PlasmaShortcutActionCopyWith<$Res> {
  _$PlasmaShortcutActionCopyWithImpl(this._self, this._then);

  final PlasmaShortcutAction _self;
  final $Res Function(PlasmaShortcutAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? component = null,Object? shortcut = null,}) {
  return _then(PlasmaShortcutAction(
component: null == component ? _self.component : component // ignore: cast_nullable_to_non_nullable
as String,shortcut: null == shortcut ? _self.shortcut : shortcut // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ActivateWindowAction implements Action {
  const ActivateWindowAction({required this.windowId});
  

 final  String windowId;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivateWindowActionCopyWith<ActivateWindowAction> get copyWith => _$ActivateWindowActionCopyWithImpl<ActivateWindowAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivateWindowAction&&(identical(other.windowId, windowId) || other.windowId == windowId));
}


@override
int get hashCode => Object.hash(runtimeType,windowId);

@override
String toString() {
  return 'Action.activateWindow(windowId: $windowId)';
}


}

/// @nodoc
abstract mixin class $ActivateWindowActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $ActivateWindowActionCopyWith(ActivateWindowAction value, $Res Function(ActivateWindowAction) _then) = _$ActivateWindowActionCopyWithImpl;
@useResult
$Res call({
 String windowId
});




}
/// @nodoc
class _$ActivateWindowActionCopyWithImpl<$Res>
    implements $ActivateWindowActionCopyWith<$Res> {
  _$ActivateWindowActionCopyWithImpl(this._self, this._then);

  final ActivateWindowAction _self;
  final $Res Function(ActivateWindowAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? windowId = null,}) {
  return _then(ActivateWindowAction(
windowId: null == windowId ? _self.windowId : windowId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ReplaceTextAction implements Action {
  const ReplaceTextAction({final  List<TextSubstitutionRule> rules = const []}): _rules = rules;
  

 final  List<TextSubstitutionRule> _rules;
@JsonKey() List<TextSubstitutionRule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}


/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplaceTextActionCopyWith<ReplaceTextAction> get copyWith => _$ReplaceTextActionCopyWithImpl<ReplaceTextAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReplaceTextAction&&const DeepCollectionEquality().equals(other._rules, _rules));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rules));

@override
String toString() {
  return 'Action.replaceText(rules: $rules)';
}


}

/// @nodoc
abstract mixin class $ReplaceTextActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $ReplaceTextActionCopyWith(ReplaceTextAction value, $Res Function(ReplaceTextAction) _then) = _$ReplaceTextActionCopyWithImpl;
@useResult
$Res call({
 List<TextSubstitutionRule> rules
});




}
/// @nodoc
class _$ReplaceTextActionCopyWithImpl<$Res>
    implements $ReplaceTextActionCopyWith<$Res> {
  _$ReplaceTextActionCopyWithImpl(this._self, this._then);

  final ReplaceTextAction _self;
  final $Res Function(ReplaceTextAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rules = null,}) {
  return _then(ReplaceTextAction(
rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<TextSubstitutionRule>,
  ));
}


}

/// @nodoc


class SleepAction implements Action {
  const SleepAction({required this.milliseconds});
  

 final  int milliseconds;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SleepActionCopyWith<SleepAction> get copyWith => _$SleepActionCopyWithImpl<SleepAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SleepAction&&(identical(other.milliseconds, milliseconds) || other.milliseconds == milliseconds));
}


@override
int get hashCode => Object.hash(runtimeType,milliseconds);

@override
String toString() {
  return 'Action.sleep(milliseconds: $milliseconds)';
}


}

/// @nodoc
abstract mixin class $SleepActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $SleepActionCopyWith(SleepAction value, $Res Function(SleepAction) _then) = _$SleepActionCopyWithImpl;
@useResult
$Res call({
 int milliseconds
});




}
/// @nodoc
class _$SleepActionCopyWithImpl<$Res>
    implements $SleepActionCopyWith<$Res> {
  _$SleepActionCopyWithImpl(this._self, this._then);

  final SleepAction _self;
  final $Res Function(SleepAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? milliseconds = null,}) {
  return _then(SleepAction(
milliseconds: null == milliseconds ? _self.milliseconds : milliseconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class FunctionAction implements Action {
  const FunctionAction({required this.expression});
  

 final  String expression;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FunctionActionCopyWith<FunctionAction> get copyWith => _$FunctionActionCopyWithImpl<FunctionAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FunctionAction&&(identical(other.expression, expression) || other.expression == expression));
}


@override
int get hashCode => Object.hash(runtimeType,expression);

@override
String toString() {
  return 'Action.function(expression: $expression)';
}


}

/// @nodoc
abstract mixin class $FunctionActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $FunctionActionCopyWith(FunctionAction value, $Res Function(FunctionAction) _then) = _$FunctionActionCopyWithImpl;
@useResult
$Res call({
 String expression
});




}
/// @nodoc
class _$FunctionActionCopyWithImpl<$Res>
    implements $FunctionActionCopyWith<$Res> {
  _$FunctionActionCopyWithImpl(this._self, this._then);

  final FunctionAction _self;
  final $Res Function(FunctionAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? expression = null,}) {
  return _then(FunctionAction(
expression: null == expression ? _self.expression : expression // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ActionGroup implements Action {
  const ActionGroup({final  List<TriggerAction> actions = const []}): _actions = actions;
  

 final  List<TriggerAction> _actions;
@JsonKey() List<TriggerAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}


/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionGroupCopyWith<ActionGroup> get copyWith => _$ActionGroupCopyWithImpl<ActionGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionGroup&&const DeepCollectionEquality().equals(other._actions, _actions));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_actions));

@override
String toString() {
  return 'Action.group(actions: $actions)';
}


}

/// @nodoc
abstract mixin class $ActionGroupCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $ActionGroupCopyWith(ActionGroup value, $Res Function(ActionGroup) _then) = _$ActionGroupCopyWithImpl;
@useResult
$Res call({
 List<TriggerAction> actions
});




}
/// @nodoc
class _$ActionGroupCopyWithImpl<$Res>
    implements $ActionGroupCopyWith<$Res> {
  _$ActionGroupCopyWithImpl(this._self, this._then);

  final ActionGroup _self;
  final $Res Function(ActionGroup) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? actions = null,}) {
  return _then(ActionGroup(
actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<TriggerAction>,
  ));
}


}

/// @nodoc


class ContextMenuAction implements Action {
  const ContextMenuAction({final  List<MenuItem> items = const []}): _items = items;
  

 final  List<MenuItem> _items;
@JsonKey() List<MenuItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContextMenuActionCopyWith<ContextMenuAction> get copyWith => _$ContextMenuActionCopyWithImpl<ContextMenuAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContextMenuAction&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Action.contextMenu(items: $items)';
}


}

/// @nodoc
abstract mixin class $ContextMenuActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $ContextMenuActionCopyWith(ContextMenuAction value, $Res Function(ContextMenuAction) _then) = _$ContextMenuActionCopyWithImpl;
@useResult
$Res call({
 List<MenuItem> items
});




}
/// @nodoc
class _$ContextMenuActionCopyWithImpl<$Res>
    implements $ContextMenuActionCopyWith<$Res> {
  _$ContextMenuActionCopyWithImpl(this._self, this._then);

  final ContextMenuAction _self;
  final $Res Function(ContextMenuAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(ContextMenuAction(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MenuItem>,
  ));
}


}

/// @nodoc


class RawAction implements Action {
  const RawAction({required this.raw});
  

 final  String raw;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawActionCopyWith<RawAction> get copyWith => _$RawActionCopyWithImpl<RawAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawAction&&(identical(other.raw, raw) || other.raw == raw));
}


@override
int get hashCode => Object.hash(runtimeType,raw);

@override
String toString() {
  return 'Action.raw(raw: $raw)';
}


}

/// @nodoc
abstract mixin class $RawActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $RawActionCopyWith(RawAction value, $Res Function(RawAction) _then) = _$RawActionCopyWithImpl;
@useResult
$Res call({
 String raw
});




}
/// @nodoc
class _$RawActionCopyWithImpl<$Res>
    implements $RawActionCopyWith<$Res> {
  _$RawActionCopyWithImpl(this._self, this._then);

  final RawAction _self;
  final $Res Function(RawAction) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? raw = null,}) {
  return _then(RawAction(
raw: null == raw ? _self.raw : raw // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MenuItem {

/// In-memory identity, filled in by `assignEditIds`; never serialized.
 int? get editId;
/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuItemCopyWith<MenuItem> get copyWith => _$MenuItemCopyWithImpl<MenuItem>(this as MenuItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuItem&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,editId);

@override
String toString() {
  return 'MenuItem(editId: $editId)';
}


}

/// @nodoc
abstract mixin class $MenuItemCopyWith<$Res>  {
  factory $MenuItemCopyWith(MenuItem value, $Res Function(MenuItem) _then) = _$MenuItemCopyWithImpl;
@useResult
$Res call({
 int? editId
});




}
/// @nodoc
class _$MenuItemCopyWithImpl<$Res>
    implements $MenuItemCopyWith<$Res> {
  _$MenuItemCopyWithImpl(this._self, this._then);

  final MenuItem _self;
  final $Res Function(MenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? editId = freezed,}) {
  return _then(_self.copyWith(
editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuItem].
extension MenuItemPatterns on MenuItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ActionMenuItem value)?  action,TResult Function( SubMenuItem value)?  subMenu,TResult Function( SectionMenuItem value)?  section,TResult Function( SeparatorMenuItem value)?  separator,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ActionMenuItem() when action != null:
return action(_that);case SubMenuItem() when subMenu != null:
return subMenu(_that);case SectionMenuItem() when section != null:
return section(_that);case SeparatorMenuItem() when separator != null:
return separator(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ActionMenuItem value)  action,required TResult Function( SubMenuItem value)  subMenu,required TResult Function( SectionMenuItem value)  section,required TResult Function( SeparatorMenuItem value)  separator,}){
final _that = this;
switch (_that) {
case ActionMenuItem():
return action(_that);case SubMenuItem():
return subMenu(_that);case SectionMenuItem():
return section(_that);case SeparatorMenuItem():
return separator(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ActionMenuItem value)?  action,TResult? Function( SubMenuItem value)?  subMenu,TResult? Function( SectionMenuItem value)?  section,TResult? Function( SeparatorMenuItem value)?  separator,}){
final _that = this;
switch (_that) {
case ActionMenuItem() when action != null:
return action(_that);case SubMenuItem() when subMenu != null:
return subMenu(_that);case SectionMenuItem() when section != null:
return section(_that);case SeparatorMenuItem() when separator != null:
return separator(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text,  String? icon,  List<TriggerAction> actions,  int? editId)?  action,TResult Function( String text,  String? icon,  List<MenuItem> items,  int? editId)?  subMenu,TResult Function( String text,  int? editId)?  section,TResult Function( int? editId)?  separator,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ActionMenuItem() when action != null:
return action(_that.text,_that.icon,_that.actions,_that.editId);case SubMenuItem() when subMenu != null:
return subMenu(_that.text,_that.icon,_that.items,_that.editId);case SectionMenuItem() when section != null:
return section(_that.text,_that.editId);case SeparatorMenuItem() when separator != null:
return separator(_that.editId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text,  String? icon,  List<TriggerAction> actions,  int? editId)  action,required TResult Function( String text,  String? icon,  List<MenuItem> items,  int? editId)  subMenu,required TResult Function( String text,  int? editId)  section,required TResult Function( int? editId)  separator,}) {final _that = this;
switch (_that) {
case ActionMenuItem():
return action(_that.text,_that.icon,_that.actions,_that.editId);case SubMenuItem():
return subMenu(_that.text,_that.icon,_that.items,_that.editId);case SectionMenuItem():
return section(_that.text,_that.editId);case SeparatorMenuItem():
return separator(_that.editId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text,  String? icon,  List<TriggerAction> actions,  int? editId)?  action,TResult? Function( String text,  String? icon,  List<MenuItem> items,  int? editId)?  subMenu,TResult? Function( String text,  int? editId)?  section,TResult? Function( int? editId)?  separator,}) {final _that = this;
switch (_that) {
case ActionMenuItem() when action != null:
return action(_that.text,_that.icon,_that.actions,_that.editId);case SubMenuItem() when subMenu != null:
return subMenu(_that.text,_that.icon,_that.items,_that.editId);case SectionMenuItem() when section != null:
return section(_that.text,_that.editId);case SeparatorMenuItem() when separator != null:
return separator(_that.editId);case _:
  return null;

}
}

}

/// @nodoc


class ActionMenuItem implements MenuItem {
  const ActionMenuItem({this.text = '', this.icon, final  List<TriggerAction> actions = const [], this.editId}): _actions = actions;
  

@JsonKey() final  String text;
 final  String? icon;
 final  List<TriggerAction> _actions;
@JsonKey() List<TriggerAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

/// In-memory identity, filled in by `assignEditIds`; never serialized.
@override final  int? editId;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionMenuItemCopyWith<ActionMenuItem> get copyWith => _$ActionMenuItemCopyWithImpl<ActionMenuItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionMenuItem&&(identical(other.text, text) || other.text == text)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,text,icon,const DeepCollectionEquality().hash(_actions),editId);

@override
String toString() {
  return 'MenuItem.action(text: $text, icon: $icon, actions: $actions, editId: $editId)';
}


}

/// @nodoc
abstract mixin class $ActionMenuItemCopyWith<$Res> implements $MenuItemCopyWith<$Res> {
  factory $ActionMenuItemCopyWith(ActionMenuItem value, $Res Function(ActionMenuItem) _then) = _$ActionMenuItemCopyWithImpl;
@override @useResult
$Res call({
 String text, String? icon, List<TriggerAction> actions, int? editId
});




}
/// @nodoc
class _$ActionMenuItemCopyWithImpl<$Res>
    implements $ActionMenuItemCopyWith<$Res> {
  _$ActionMenuItemCopyWithImpl(this._self, this._then);

  final ActionMenuItem _self;
  final $Res Function(ActionMenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? icon = freezed,Object? actions = null,Object? editId = freezed,}) {
  return _then(ActionMenuItem(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<TriggerAction>,editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class SubMenuItem implements MenuItem {
  const SubMenuItem({this.text = '', this.icon, final  List<MenuItem> items = const [], this.editId}): _items = items;
  

@JsonKey() final  String text;
 final  String? icon;
 final  List<MenuItem> _items;
@JsonKey() List<MenuItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int? editId;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubMenuItemCopyWith<SubMenuItem> get copyWith => _$SubMenuItemCopyWithImpl<SubMenuItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubMenuItem&&(identical(other.text, text) || other.text == text)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,text,icon,const DeepCollectionEquality().hash(_items),editId);

@override
String toString() {
  return 'MenuItem.subMenu(text: $text, icon: $icon, items: $items, editId: $editId)';
}


}

/// @nodoc
abstract mixin class $SubMenuItemCopyWith<$Res> implements $MenuItemCopyWith<$Res> {
  factory $SubMenuItemCopyWith(SubMenuItem value, $Res Function(SubMenuItem) _then) = _$SubMenuItemCopyWithImpl;
@override @useResult
$Res call({
 String text, String? icon, List<MenuItem> items, int? editId
});




}
/// @nodoc
class _$SubMenuItemCopyWithImpl<$Res>
    implements $SubMenuItemCopyWith<$Res> {
  _$SubMenuItemCopyWithImpl(this._self, this._then);

  final SubMenuItem _self;
  final $Res Function(SubMenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? icon = freezed,Object? items = null,Object? editId = freezed,}) {
  return _then(SubMenuItem(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MenuItem>,editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class SectionMenuItem implements MenuItem {
  const SectionMenuItem({this.text = '', this.editId});
  

@JsonKey() final  String text;
@override final  int? editId;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SectionMenuItemCopyWith<SectionMenuItem> get copyWith => _$SectionMenuItemCopyWithImpl<SectionMenuItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SectionMenuItem&&(identical(other.text, text) || other.text == text)&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,text,editId);

@override
String toString() {
  return 'MenuItem.section(text: $text, editId: $editId)';
}


}

/// @nodoc
abstract mixin class $SectionMenuItemCopyWith<$Res> implements $MenuItemCopyWith<$Res> {
  factory $SectionMenuItemCopyWith(SectionMenuItem value, $Res Function(SectionMenuItem) _then) = _$SectionMenuItemCopyWithImpl;
@override @useResult
$Res call({
 String text, int? editId
});




}
/// @nodoc
class _$SectionMenuItemCopyWithImpl<$Res>
    implements $SectionMenuItemCopyWith<$Res> {
  _$SectionMenuItemCopyWithImpl(this._self, this._then);

  final SectionMenuItem _self;
  final $Res Function(SectionMenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = null,Object? editId = freezed,}) {
  return _then(SectionMenuItem(
text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class SeparatorMenuItem implements MenuItem {
  const SeparatorMenuItem({this.editId});
  

@override final  int? editId;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeparatorMenuItemCopyWith<SeparatorMenuItem> get copyWith => _$SeparatorMenuItemCopyWithImpl<SeparatorMenuItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeparatorMenuItem&&(identical(other.editId, editId) || other.editId == editId));
}


@override
int get hashCode => Object.hash(runtimeType,editId);

@override
String toString() {
  return 'MenuItem.separator(editId: $editId)';
}


}

/// @nodoc
abstract mixin class $SeparatorMenuItemCopyWith<$Res> implements $MenuItemCopyWith<$Res> {
  factory $SeparatorMenuItemCopyWith(SeparatorMenuItem value, $Res Function(SeparatorMenuItem) _then) = _$SeparatorMenuItemCopyWithImpl;
@override @useResult
$Res call({
 int? editId
});




}
/// @nodoc
class _$SeparatorMenuItemCopyWithImpl<$Res>
    implements $SeparatorMenuItemCopyWith<$Res> {
  _$SeparatorMenuItemCopyWithImpl(this._self, this._then);

  final SeparatorMenuItem _self;
  final $Res Function(SeparatorMenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? editId = freezed,}) {
  return _then(SeparatorMenuItem(
editId: freezed == editId ? _self.editId : editId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$TextSubstitutionRule {

 String get regex; DynamicText get replace;
/// Create a copy of TextSubstitutionRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextSubstitutionRuleCopyWith<TextSubstitutionRule> get copyWith => _$TextSubstitutionRuleCopyWithImpl<TextSubstitutionRule>(this as TextSubstitutionRule, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextSubstitutionRule&&(identical(other.regex, regex) || other.regex == regex)&&(identical(other.replace, replace) || other.replace == replace));
}


@override
int get hashCode => Object.hash(runtimeType,regex,replace);

@override
String toString() {
  return 'TextSubstitutionRule(regex: $regex, replace: $replace)';
}


}

/// @nodoc
abstract mixin class $TextSubstitutionRuleCopyWith<$Res>  {
  factory $TextSubstitutionRuleCopyWith(TextSubstitutionRule value, $Res Function(TextSubstitutionRule) _then) = _$TextSubstitutionRuleCopyWithImpl;
@useResult
$Res call({
 String regex, DynamicText replace
});


$DynamicTextCopyWith<$Res> get replace;

}
/// @nodoc
class _$TextSubstitutionRuleCopyWithImpl<$Res>
    implements $TextSubstitutionRuleCopyWith<$Res> {
  _$TextSubstitutionRuleCopyWithImpl(this._self, this._then);

  final TextSubstitutionRule _self;
  final $Res Function(TextSubstitutionRule) _then;

/// Create a copy of TextSubstitutionRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? regex = null,Object? replace = null,}) {
  return _then(_self.copyWith(
regex: null == regex ? _self.regex : regex // ignore: cast_nullable_to_non_nullable
as String,replace: null == replace ? _self.replace : replace // ignore: cast_nullable_to_non_nullable
as DynamicText,
  ));
}
/// Create a copy of TextSubstitutionRule
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DynamicTextCopyWith<$Res> get replace {
  
  return $DynamicTextCopyWith<$Res>(_self.replace, (value) {
    return _then(_self.copyWith(replace: value));
  });
}
}


/// Adds pattern-matching-related methods to [TextSubstitutionRule].
extension TextSubstitutionRulePatterns on TextSubstitutionRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextSubstitutionRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextSubstitutionRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextSubstitutionRule value)  $default,){
final _that = this;
switch (_that) {
case _TextSubstitutionRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextSubstitutionRule value)?  $default,){
final _that = this;
switch (_that) {
case _TextSubstitutionRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String regex,  DynamicText replace)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextSubstitutionRule() when $default != null:
return $default(_that.regex,_that.replace);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String regex,  DynamicText replace)  $default,) {final _that = this;
switch (_that) {
case _TextSubstitutionRule():
return $default(_that.regex,_that.replace);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String regex,  DynamicText replace)?  $default,) {final _that = this;
switch (_that) {
case _TextSubstitutionRule() when $default != null:
return $default(_that.regex,_that.replace);case _:
  return null;

}
}

}

/// @nodoc


class _TextSubstitutionRule implements TextSubstitutionRule {
  const _TextSubstitutionRule({required this.regex, required this.replace});
  

@override final  String regex;
@override final  DynamicText replace;

/// Create a copy of TextSubstitutionRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextSubstitutionRuleCopyWith<_TextSubstitutionRule> get copyWith => __$TextSubstitutionRuleCopyWithImpl<_TextSubstitutionRule>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextSubstitutionRule&&(identical(other.regex, regex) || other.regex == regex)&&(identical(other.replace, replace) || other.replace == replace));
}


@override
int get hashCode => Object.hash(runtimeType,regex,replace);

@override
String toString() {
  return 'TextSubstitutionRule(regex: $regex, replace: $replace)';
}


}

/// @nodoc
abstract mixin class _$TextSubstitutionRuleCopyWith<$Res> implements $TextSubstitutionRuleCopyWith<$Res> {
  factory _$TextSubstitutionRuleCopyWith(_TextSubstitutionRule value, $Res Function(_TextSubstitutionRule) _then) = __$TextSubstitutionRuleCopyWithImpl;
@override @useResult
$Res call({
 String regex, DynamicText replace
});


@override $DynamicTextCopyWith<$Res> get replace;

}
/// @nodoc
class __$TextSubstitutionRuleCopyWithImpl<$Res>
    implements _$TextSubstitutionRuleCopyWith<$Res> {
  __$TextSubstitutionRuleCopyWithImpl(this._self, this._then);

  final _TextSubstitutionRule _self;
  final $Res Function(_TextSubstitutionRule) _then;

/// Create a copy of TextSubstitutionRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? regex = null,Object? replace = null,}) {
  return _then(_TextSubstitutionRule(
regex: null == regex ? _self.regex : regex // ignore: cast_nullable_to_non_nullable
as String,replace: null == replace ? _self.replace : replace // ignore: cast_nullable_to_non_nullable
as DynamicText,
  ));
}

/// Create a copy of TextSubstitutionRule
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DynamicTextCopyWith<$Res> get replace {
  
  return $DynamicTextCopyWith<$Res>(_self.replace, (value) {
    return _then(_self.copyWith(replace: value));
  });
}
}

/// @nodoc
mixin _$DynamicText {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicText);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DynamicText()';
}


}

/// @nodoc
class $DynamicTextCopyWith<$Res>  {
$DynamicTextCopyWith(DynamicText _, $Res Function(DynamicText) __);
}


/// Adds pattern-matching-related methods to [DynamicText].
extension DynamicTextPatterns on DynamicText {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LiteralText value)?  literal,TResult Function( CommandText value)?  command,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LiteralText() when literal != null:
return literal(_that);case CommandText() when command != null:
return command(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LiteralText value)  literal,required TResult Function( CommandText value)  command,}){
final _that = this;
switch (_that) {
case LiteralText():
return literal(_that);case CommandText():
return command(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LiteralText value)?  literal,TResult? Function( CommandText value)?  command,}){
final _that = this;
switch (_that) {
case LiteralText() when literal != null:
return literal(_that);case CommandText() when command != null:
return command(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  literal,TResult Function( String command)?  command,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LiteralText() when literal != null:
return literal(_that.text);case CommandText() when command != null:
return command(_that.command);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  literal,required TResult Function( String command)  command,}) {final _that = this;
switch (_that) {
case LiteralText():
return literal(_that.text);case CommandText():
return command(_that.command);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  literal,TResult? Function( String command)?  command,}) {final _that = this;
switch (_that) {
case LiteralText() when literal != null:
return literal(_that.text);case CommandText() when command != null:
return command(_that.command);case _:
  return null;

}
}

}

/// @nodoc


class LiteralText implements DynamicText {
  const LiteralText(this.text);
  

 final  String text;

/// Create a copy of DynamicText
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiteralTextCopyWith<LiteralText> get copyWith => _$LiteralTextCopyWithImpl<LiteralText>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiteralText&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode => Object.hash(runtimeType,text);

@override
String toString() {
  return 'DynamicText.literal(text: $text)';
}


}

/// @nodoc
abstract mixin class $LiteralTextCopyWith<$Res> implements $DynamicTextCopyWith<$Res> {
  factory $LiteralTextCopyWith(LiteralText value, $Res Function(LiteralText) _then) = _$LiteralTextCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$LiteralTextCopyWithImpl<$Res>
    implements $LiteralTextCopyWith<$Res> {
  _$LiteralTextCopyWithImpl(this._self, this._then);

  final LiteralText _self;
  final $Res Function(LiteralText) _then;

/// Create a copy of DynamicText
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(LiteralText(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CommandText implements DynamicText {
  const CommandText(this.command);
  

 final  String command;

/// Create a copy of DynamicText
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommandTextCopyWith<CommandText> get copyWith => _$CommandTextCopyWithImpl<CommandText>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommandText&&(identical(other.command, command) || other.command == command));
}


@override
int get hashCode => Object.hash(runtimeType,command);

@override
String toString() {
  return 'DynamicText.command(command: $command)';
}


}

/// @nodoc
abstract mixin class $CommandTextCopyWith<$Res> implements $DynamicTextCopyWith<$Res> {
  factory $CommandTextCopyWith(CommandText value, $Res Function(CommandText) _then) = _$CommandTextCopyWithImpl;
@useResult
$Res call({
 String command
});




}
/// @nodoc
class _$CommandTextCopyWithImpl<$Res>
    implements $CommandTextCopyWith<$Res> {
  _$CommandTextCopyWithImpl(this._self, this._then);

  final CommandText _self;
  final $Res Function(CommandText) _then;

/// Create a copy of DynamicText
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? command = null,}) {
  return _then(CommandText(
null == command ? _self.command : command // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$InputEntry {

 InputDevice get device; List<InputToken> get tokens;
/// Create a copy of InputEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InputEntryCopyWith<InputEntry> get copyWith => _$InputEntryCopyWithImpl<InputEntry>(this as InputEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InputEntry&&(identical(other.device, device) || other.device == device)&&const DeepCollectionEquality().equals(other.tokens, tokens));
}


@override
int get hashCode => Object.hash(runtimeType,device,const DeepCollectionEquality().hash(tokens));

@override
String toString() {
  return 'InputEntry(device: $device, tokens: $tokens)';
}


}

/// @nodoc
abstract mixin class $InputEntryCopyWith<$Res>  {
  factory $InputEntryCopyWith(InputEntry value, $Res Function(InputEntry) _then) = _$InputEntryCopyWithImpl;
@useResult
$Res call({
 InputDevice device, List<InputToken> tokens
});




}
/// @nodoc
class _$InputEntryCopyWithImpl<$Res>
    implements $InputEntryCopyWith<$Res> {
  _$InputEntryCopyWithImpl(this._self, this._then);

  final InputEntry _self;
  final $Res Function(InputEntry) _then;

/// Create a copy of InputEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? device = null,Object? tokens = null,}) {
  return _then(_self.copyWith(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as InputDevice,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<InputToken>,
  ));
}

}


/// Adds pattern-matching-related methods to [InputEntry].
extension InputEntryPatterns on InputEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InputEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InputEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InputEntry value)  $default,){
final _that = this;
switch (_that) {
case _InputEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InputEntry value)?  $default,){
final _that = this;
switch (_that) {
case _InputEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InputDevice device,  List<InputToken> tokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InputEntry() when $default != null:
return $default(_that.device,_that.tokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InputDevice device,  List<InputToken> tokens)  $default,) {final _that = this;
switch (_that) {
case _InputEntry():
return $default(_that.device,_that.tokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InputDevice device,  List<InputToken> tokens)?  $default,) {final _that = this;
switch (_that) {
case _InputEntry() when $default != null:
return $default(_that.device,_that.tokens);case _:
  return null;

}
}

}

/// @nodoc


class _InputEntry implements InputEntry {
  const _InputEntry({required this.device, final  List<InputToken> tokens = const []}): _tokens = tokens;
  

@override final  InputDevice device;
 final  List<InputToken> _tokens;
@override@JsonKey() List<InputToken> get tokens {
  if (_tokens is EqualUnmodifiableListView) return _tokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tokens);
}


/// Create a copy of InputEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InputEntryCopyWith<_InputEntry> get copyWith => __$InputEntryCopyWithImpl<_InputEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InputEntry&&(identical(other.device, device) || other.device == device)&&const DeepCollectionEquality().equals(other._tokens, _tokens));
}


@override
int get hashCode => Object.hash(runtimeType,device,const DeepCollectionEquality().hash(_tokens));

@override
String toString() {
  return 'InputEntry(device: $device, tokens: $tokens)';
}


}

/// @nodoc
abstract mixin class _$InputEntryCopyWith<$Res> implements $InputEntryCopyWith<$Res> {
  factory _$InputEntryCopyWith(_InputEntry value, $Res Function(_InputEntry) _then) = __$InputEntryCopyWithImpl;
@override @useResult
$Res call({
 InputDevice device, List<InputToken> tokens
});




}
/// @nodoc
class __$InputEntryCopyWithImpl<$Res>
    implements _$InputEntryCopyWith<$Res> {
  __$InputEntryCopyWithImpl(this._self, this._then);

  final _InputEntry _self;
  final $Res Function(_InputEntry) _then;

/// Create a copy of InputEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? device = null,Object? tokens = null,}) {
  return _then(_InputEntry(
device: null == device ? _self.device : device // ignore: cast_nullable_to_non_nullable
as InputDevice,tokens: null == tokens ? _self._tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<InputToken>,
  ));
}


}

/// @nodoc
mixin _$InputToken {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InputToken);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'InputToken()';
}


}

/// @nodoc
class $InputTokenCopyWith<$Res>  {
$InputTokenCopyWith(InputToken _, $Res Function(InputToken) __);
}


/// Adds pattern-matching-related methods to [InputToken].
extension InputTokenPatterns on InputToken {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PressInputToken value)?  press,TResult Function( ReleaseInputToken value)?  release,TResult Function( ComboInputToken value)?  combo,TResult Function( TextInputToken value)?  text,TResult Function( MoveByInputToken value)?  moveBy,TResult Function( MoveByDeltaInputToken value)?  moveByDelta,TResult Function( MoveToInputToken value)?  moveTo,TResult Function( WheelInputToken value)?  wheel,TResult Function( RawInputToken value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PressInputToken() when press != null:
return press(_that);case ReleaseInputToken() when release != null:
return release(_that);case ComboInputToken() when combo != null:
return combo(_that);case TextInputToken() when text != null:
return text(_that);case MoveByInputToken() when moveBy != null:
return moveBy(_that);case MoveByDeltaInputToken() when moveByDelta != null:
return moveByDelta(_that);case MoveToInputToken() when moveTo != null:
return moveTo(_that);case WheelInputToken() when wheel != null:
return wheel(_that);case RawInputToken() when raw != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PressInputToken value)  press,required TResult Function( ReleaseInputToken value)  release,required TResult Function( ComboInputToken value)  combo,required TResult Function( TextInputToken value)  text,required TResult Function( MoveByInputToken value)  moveBy,required TResult Function( MoveByDeltaInputToken value)  moveByDelta,required TResult Function( MoveToInputToken value)  moveTo,required TResult Function( WheelInputToken value)  wheel,required TResult Function( RawInputToken value)  raw,}){
final _that = this;
switch (_that) {
case PressInputToken():
return press(_that);case ReleaseInputToken():
return release(_that);case ComboInputToken():
return combo(_that);case TextInputToken():
return text(_that);case MoveByInputToken():
return moveBy(_that);case MoveByDeltaInputToken():
return moveByDelta(_that);case MoveToInputToken():
return moveTo(_that);case WheelInputToken():
return wheel(_that);case RawInputToken():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PressInputToken value)?  press,TResult? Function( ReleaseInputToken value)?  release,TResult? Function( ComboInputToken value)?  combo,TResult? Function( TextInputToken value)?  text,TResult? Function( MoveByInputToken value)?  moveBy,TResult? Function( MoveByDeltaInputToken value)?  moveByDelta,TResult? Function( MoveToInputToken value)?  moveTo,TResult? Function( WheelInputToken value)?  wheel,TResult? Function( RawInputToken value)?  raw,}){
final _that = this;
switch (_that) {
case PressInputToken() when press != null:
return press(_that);case ReleaseInputToken() when release != null:
return release(_that);case ComboInputToken() when combo != null:
return combo(_that);case TextInputToken() when text != null:
return text(_that);case MoveByInputToken() when moveBy != null:
return moveBy(_that);case MoveByDeltaInputToken() when moveByDelta != null:
return moveByDelta(_that);case MoveToInputToken() when moveTo != null:
return moveTo(_that);case WheelInputToken() when wheel != null:
return wheel(_that);case RawInputToken() when raw != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String key)?  press,TResult Function( String key)?  release,TResult Function( List<String> keys)?  combo,TResult Function( DynamicText value)?  text,TResult Function( double x,  double y)?  moveBy,TResult Function( double? multiplier)?  moveByDelta,TResult Function( double x,  double y)?  moveTo,TResult Function( double x,  double y)?  wheel,TResult Function( String token)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PressInputToken() when press != null:
return press(_that.key);case ReleaseInputToken() when release != null:
return release(_that.key);case ComboInputToken() when combo != null:
return combo(_that.keys);case TextInputToken() when text != null:
return text(_that.value);case MoveByInputToken() when moveBy != null:
return moveBy(_that.x,_that.y);case MoveByDeltaInputToken() when moveByDelta != null:
return moveByDelta(_that.multiplier);case MoveToInputToken() when moveTo != null:
return moveTo(_that.x,_that.y);case WheelInputToken() when wheel != null:
return wheel(_that.x,_that.y);case RawInputToken() when raw != null:
return raw(_that.token);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String key)  press,required TResult Function( String key)  release,required TResult Function( List<String> keys)  combo,required TResult Function( DynamicText value)  text,required TResult Function( double x,  double y)  moveBy,required TResult Function( double? multiplier)  moveByDelta,required TResult Function( double x,  double y)  moveTo,required TResult Function( double x,  double y)  wheel,required TResult Function( String token)  raw,}) {final _that = this;
switch (_that) {
case PressInputToken():
return press(_that.key);case ReleaseInputToken():
return release(_that.key);case ComboInputToken():
return combo(_that.keys);case TextInputToken():
return text(_that.value);case MoveByInputToken():
return moveBy(_that.x,_that.y);case MoveByDeltaInputToken():
return moveByDelta(_that.multiplier);case MoveToInputToken():
return moveTo(_that.x,_that.y);case WheelInputToken():
return wheel(_that.x,_that.y);case RawInputToken():
return raw(_that.token);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String key)?  press,TResult? Function( String key)?  release,TResult? Function( List<String> keys)?  combo,TResult? Function( DynamicText value)?  text,TResult? Function( double x,  double y)?  moveBy,TResult? Function( double? multiplier)?  moveByDelta,TResult? Function( double x,  double y)?  moveTo,TResult? Function( double x,  double y)?  wheel,TResult? Function( String token)?  raw,}) {final _that = this;
switch (_that) {
case PressInputToken() when press != null:
return press(_that.key);case ReleaseInputToken() when release != null:
return release(_that.key);case ComboInputToken() when combo != null:
return combo(_that.keys);case TextInputToken() when text != null:
return text(_that.value);case MoveByInputToken() when moveBy != null:
return moveBy(_that.x,_that.y);case MoveByDeltaInputToken() when moveByDelta != null:
return moveByDelta(_that.multiplier);case MoveToInputToken() when moveTo != null:
return moveTo(_that.x,_that.y);case WheelInputToken() when wheel != null:
return wheel(_that.x,_that.y);case RawInputToken() when raw != null:
return raw(_that.token);case _:
  return null;

}
}

}

/// @nodoc


class PressInputToken implements InputToken {
  const PressInputToken(this.key);
  

 final  String key;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PressInputTokenCopyWith<PressInputToken> get copyWith => _$PressInputTokenCopyWithImpl<PressInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PressInputToken&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,key);

@override
String toString() {
  return 'InputToken.press(key: $key)';
}


}

/// @nodoc
abstract mixin class $PressInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $PressInputTokenCopyWith(PressInputToken value, $Res Function(PressInputToken) _then) = _$PressInputTokenCopyWithImpl;
@useResult
$Res call({
 String key
});




}
/// @nodoc
class _$PressInputTokenCopyWithImpl<$Res>
    implements $PressInputTokenCopyWith<$Res> {
  _$PressInputTokenCopyWithImpl(this._self, this._then);

  final PressInputToken _self;
  final $Res Function(PressInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(PressInputToken(
null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ReleaseInputToken implements InputToken {
  const ReleaseInputToken(this.key);
  

 final  String key;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseInputTokenCopyWith<ReleaseInputToken> get copyWith => _$ReleaseInputTokenCopyWithImpl<ReleaseInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseInputToken&&(identical(other.key, key) || other.key == key));
}


@override
int get hashCode => Object.hash(runtimeType,key);

@override
String toString() {
  return 'InputToken.release(key: $key)';
}


}

/// @nodoc
abstract mixin class $ReleaseInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $ReleaseInputTokenCopyWith(ReleaseInputToken value, $Res Function(ReleaseInputToken) _then) = _$ReleaseInputTokenCopyWithImpl;
@useResult
$Res call({
 String key
});




}
/// @nodoc
class _$ReleaseInputTokenCopyWithImpl<$Res>
    implements $ReleaseInputTokenCopyWith<$Res> {
  _$ReleaseInputTokenCopyWithImpl(this._self, this._then);

  final ReleaseInputToken _self;
  final $Res Function(ReleaseInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,}) {
  return _then(ReleaseInputToken(
null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ComboInputToken implements InputToken {
  const ComboInputToken(final  List<String> keys): _keys = keys;
  

 final  List<String> _keys;
 List<String> get keys {
  if (_keys is EqualUnmodifiableListView) return _keys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keys);
}


/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComboInputTokenCopyWith<ComboInputToken> get copyWith => _$ComboInputTokenCopyWithImpl<ComboInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComboInputToken&&const DeepCollectionEquality().equals(other._keys, _keys));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_keys));

@override
String toString() {
  return 'InputToken.combo(keys: $keys)';
}


}

/// @nodoc
abstract mixin class $ComboInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $ComboInputTokenCopyWith(ComboInputToken value, $Res Function(ComboInputToken) _then) = _$ComboInputTokenCopyWithImpl;
@useResult
$Res call({
 List<String> keys
});




}
/// @nodoc
class _$ComboInputTokenCopyWithImpl<$Res>
    implements $ComboInputTokenCopyWith<$Res> {
  _$ComboInputTokenCopyWithImpl(this._self, this._then);

  final ComboInputToken _self;
  final $Res Function(ComboInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? keys = null,}) {
  return _then(ComboInputToken(
null == keys ? _self._keys : keys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class TextInputToken implements InputToken {
  const TextInputToken(this.value);
  

 final  DynamicText value;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextInputTokenCopyWith<TextInputToken> get copyWith => _$TextInputTokenCopyWithImpl<TextInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextInputToken&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'InputToken.text(value: $value)';
}


}

/// @nodoc
abstract mixin class $TextInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $TextInputTokenCopyWith(TextInputToken value, $Res Function(TextInputToken) _then) = _$TextInputTokenCopyWithImpl;
@useResult
$Res call({
 DynamicText value
});


$DynamicTextCopyWith<$Res> get value;

}
/// @nodoc
class _$TextInputTokenCopyWithImpl<$Res>
    implements $TextInputTokenCopyWith<$Res> {
  _$TextInputTokenCopyWithImpl(this._self, this._then);

  final TextInputToken _self;
  final $Res Function(TextInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(TextInputToken(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as DynamicText,
  ));
}

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DynamicTextCopyWith<$Res> get value {
  
  return $DynamicTextCopyWith<$Res>(_self.value, (value) {
    return _then(_self.copyWith(value: value));
  });
}
}

/// @nodoc


class MoveByInputToken implements InputToken {
  const MoveByInputToken(this.x, this.y);
  

 final  double x;
 final  double y;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveByInputTokenCopyWith<MoveByInputToken> get copyWith => _$MoveByInputTokenCopyWithImpl<MoveByInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveByInputToken&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}


@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'InputToken.moveBy(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $MoveByInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $MoveByInputTokenCopyWith(MoveByInputToken value, $Res Function(MoveByInputToken) _then) = _$MoveByInputTokenCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$MoveByInputTokenCopyWithImpl<$Res>
    implements $MoveByInputTokenCopyWith<$Res> {
  _$MoveByInputTokenCopyWithImpl(this._self, this._then);

  final MoveByInputToken _self;
  final $Res Function(MoveByInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(MoveByInputToken(
null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class MoveByDeltaInputToken implements InputToken {
  const MoveByDeltaInputToken(this.multiplier);
  

 final  double? multiplier;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveByDeltaInputTokenCopyWith<MoveByDeltaInputToken> get copyWith => _$MoveByDeltaInputTokenCopyWithImpl<MoveByDeltaInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveByDeltaInputToken&&(identical(other.multiplier, multiplier) || other.multiplier == multiplier));
}


@override
int get hashCode => Object.hash(runtimeType,multiplier);

@override
String toString() {
  return 'InputToken.moveByDelta(multiplier: $multiplier)';
}


}

/// @nodoc
abstract mixin class $MoveByDeltaInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $MoveByDeltaInputTokenCopyWith(MoveByDeltaInputToken value, $Res Function(MoveByDeltaInputToken) _then) = _$MoveByDeltaInputTokenCopyWithImpl;
@useResult
$Res call({
 double? multiplier
});




}
/// @nodoc
class _$MoveByDeltaInputTokenCopyWithImpl<$Res>
    implements $MoveByDeltaInputTokenCopyWith<$Res> {
  _$MoveByDeltaInputTokenCopyWithImpl(this._self, this._then);

  final MoveByDeltaInputToken _self;
  final $Res Function(MoveByDeltaInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? multiplier = freezed,}) {
  return _then(MoveByDeltaInputToken(
freezed == multiplier ? _self.multiplier : multiplier // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

/// @nodoc


class MoveToInputToken implements InputToken {
  const MoveToInputToken(this.x, this.y);
  

 final  double x;
 final  double y;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveToInputTokenCopyWith<MoveToInputToken> get copyWith => _$MoveToInputTokenCopyWithImpl<MoveToInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoveToInputToken&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}


@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'InputToken.moveTo(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $MoveToInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $MoveToInputTokenCopyWith(MoveToInputToken value, $Res Function(MoveToInputToken) _then) = _$MoveToInputTokenCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$MoveToInputTokenCopyWithImpl<$Res>
    implements $MoveToInputTokenCopyWith<$Res> {
  _$MoveToInputTokenCopyWithImpl(this._self, this._then);

  final MoveToInputToken _self;
  final $Res Function(MoveToInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(MoveToInputToken(
null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class WheelInputToken implements InputToken {
  const WheelInputToken(this.x, this.y);
  

 final  double x;
 final  double y;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WheelInputTokenCopyWith<WheelInputToken> get copyWith => _$WheelInputTokenCopyWithImpl<WheelInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WheelInputToken&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}


@override
int get hashCode => Object.hash(runtimeType,x,y);

@override
String toString() {
  return 'InputToken.wheel(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class $WheelInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $WheelInputTokenCopyWith(WheelInputToken value, $Res Function(WheelInputToken) _then) = _$WheelInputTokenCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$WheelInputTokenCopyWithImpl<$Res>
    implements $WheelInputTokenCopyWith<$Res> {
  _$WheelInputTokenCopyWithImpl(this._self, this._then);

  final WheelInputToken _self;
  final $Res Function(WheelInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(WheelInputToken(
null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class RawInputToken implements InputToken {
  const RawInputToken(this.token);
  

 final  String token;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RawInputTokenCopyWith<RawInputToken> get copyWith => _$RawInputTokenCopyWithImpl<RawInputToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RawInputToken&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'InputToken.raw(token: $token)';
}


}

/// @nodoc
abstract mixin class $RawInputTokenCopyWith<$Res> implements $InputTokenCopyWith<$Res> {
  factory $RawInputTokenCopyWith(RawInputToken value, $Res Function(RawInputToken) _then) = _$RawInputTokenCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$RawInputTokenCopyWithImpl<$Res>
    implements $RawInputTokenCopyWith<$Res> {
  _$RawInputTokenCopyWithImpl(this._self, this._then);

  final RawInputToken _self;
  final $Res Function(RawInputToken) _then;

/// Create a copy of InputToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(RawInputToken(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
