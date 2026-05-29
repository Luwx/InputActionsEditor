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

 Action get action;/// Null means the `on:` key was absent in YAML (daemon defaults to
/// `begin`).
 TriggerOn? get on; Condition? get conditions; String? get interval; String? get threshold; bool get conflicting; String? get id; int? get limit;
/// Create a copy of TriggerAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriggerActionCopyWith<TriggerAction> get copyWith => _$TriggerActionCopyWithImpl<TriggerAction>(this as TriggerAction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TriggerAction&&(identical(other.action, action) || other.action == action)&&(identical(other.on, on) || other.on == on)&&(identical(other.conditions, conditions) || other.conditions == conditions)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.conflicting, conflicting) || other.conflicting == conflicting)&&(identical(other.id, id) || other.id == id)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,action,on,conditions,interval,threshold,conflicting,id,limit);

@override
String toString() {
  return 'TriggerAction(action: $action, on: $on, conditions: $conditions, interval: $interval, threshold: $threshold, conflicting: $conflicting, id: $id, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $TriggerActionCopyWith<$Res>  {
  factory $TriggerActionCopyWith(TriggerAction value, $Res Function(TriggerAction) _then) = _$TriggerActionCopyWithImpl;
@useResult
$Res call({
 Action action, TriggerOn? on, Condition? conditions, String? interval, String? threshold, bool conflicting, String? id, int? limit
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
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? on = freezed,Object? conditions = freezed,Object? interval = freezed,Object? threshold = freezed,Object? conflicting = null,Object? id = freezed,Object? limit = freezed,}) {
  return _then(_self.copyWith(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as Action,on: freezed == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as TriggerOn?,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as Condition?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String?,threshold: freezed == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String?,conflicting: null == conflicting ? _self.conflicting : conflicting // ignore: cast_nullable_to_non_nullable
as bool,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Action action,  TriggerOn? on,  Condition? conditions,  String? interval,  String? threshold,  bool conflicting,  String? id,  int? limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TriggerAction() when $default != null:
return $default(_that.action,_that.on,_that.conditions,_that.interval,_that.threshold,_that.conflicting,_that.id,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Action action,  TriggerOn? on,  Condition? conditions,  String? interval,  String? threshold,  bool conflicting,  String? id,  int? limit)  $default,) {final _that = this;
switch (_that) {
case _TriggerAction():
return $default(_that.action,_that.on,_that.conditions,_that.interval,_that.threshold,_that.conflicting,_that.id,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Action action,  TriggerOn? on,  Condition? conditions,  String? interval,  String? threshold,  bool conflicting,  String? id,  int? limit)?  $default,) {final _that = this;
switch (_that) {
case _TriggerAction() when $default != null:
return $default(_that.action,_that.on,_that.conditions,_that.interval,_that.threshold,_that.conflicting,_that.id,_that.limit);case _:
  return null;

}
}

}

/// @nodoc


class _TriggerAction implements TriggerAction {
  const _TriggerAction({required this.action, this.on, this.conditions, this.interval, this.threshold, this.conflicting = true, this.id, this.limit});
  

@override final  Action action;
/// Null means the `on:` key was absent in YAML (daemon defaults to
/// `begin`).
@override final  TriggerOn? on;
@override final  Condition? conditions;
@override final  String? interval;
@override final  String? threshold;
@override@JsonKey() final  bool conflicting;
@override final  String? id;
@override final  int? limit;

/// Create a copy of TriggerAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TriggerActionCopyWith<_TriggerAction> get copyWith => __$TriggerActionCopyWithImpl<_TriggerAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TriggerAction&&(identical(other.action, action) || other.action == action)&&(identical(other.on, on) || other.on == on)&&(identical(other.conditions, conditions) || other.conditions == conditions)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.conflicting, conflicting) || other.conflicting == conflicting)&&(identical(other.id, id) || other.id == id)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,action,on,conditions,interval,threshold,conflicting,id,limit);

@override
String toString() {
  return 'TriggerAction(action: $action, on: $on, conditions: $conditions, interval: $interval, threshold: $threshold, conflicting: $conflicting, id: $id, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$TriggerActionCopyWith<$Res> implements $TriggerActionCopyWith<$Res> {
  factory _$TriggerActionCopyWith(_TriggerAction value, $Res Function(_TriggerAction) _then) = __$TriggerActionCopyWithImpl;
@override @useResult
$Res call({
 Action action, TriggerOn? on, Condition? conditions, String? interval, String? threshold, bool conflicting, String? id, int? limit
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
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? on = freezed,Object? conditions = freezed,Object? interval = freezed,Object? threshold = freezed,Object? conflicting = null,Object? id = freezed,Object? limit = freezed,}) {
  return _then(_TriggerAction(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as Action,on: freezed == on ? _self.on : on // ignore: cast_nullable_to_non_nullable
as TriggerOn?,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as Condition?,interval: freezed == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as String?,threshold: freezed == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as String?,conflicting: null == conflicting ? _self.conflicting : conflicting // ignore: cast_nullable_to_non_nullable
as bool,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CommandAction value)?  command,TResult Function( InputAction value)?  input,TResult Function( PlasmaShortcutAction value)?  plasmaShortcut,TResult Function( SleepAction value)?  sleep,TResult Function( RawAction value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CommandAction() when command != null:
return command(_that);case InputAction() when input != null:
return input(_that);case PlasmaShortcutAction() when plasmaShortcut != null:
return plasmaShortcut(_that);case SleepAction() when sleep != null:
return sleep(_that);case RawAction() when raw != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CommandAction value)  command,required TResult Function( InputAction value)  input,required TResult Function( PlasmaShortcutAction value)  plasmaShortcut,required TResult Function( SleepAction value)  sleep,required TResult Function( RawAction value)  raw,}){
final _that = this;
switch (_that) {
case CommandAction():
return command(_that);case InputAction():
return input(_that);case PlasmaShortcutAction():
return plasmaShortcut(_that);case SleepAction():
return sleep(_that);case RawAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CommandAction value)?  command,TResult? Function( InputAction value)?  input,TResult? Function( PlasmaShortcutAction value)?  plasmaShortcut,TResult? Function( SleepAction value)?  sleep,TResult? Function( RawAction value)?  raw,}){
final _that = this;
switch (_that) {
case CommandAction() when command != null:
return command(_that);case InputAction() when input != null:
return input(_that);case PlasmaShortcutAction() when plasmaShortcut != null:
return plasmaShortcut(_that);case SleepAction() when sleep != null:
return sleep(_that);case RawAction() when raw != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String command,  bool? wait)?  command,TResult Function( List<InputEntry> entries)?  input,TResult Function( String component,  String shortcut)?  plasmaShortcut,TResult Function( int milliseconds)?  sleep,TResult Function( String raw)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CommandAction() when command != null:
return command(_that.command,_that.wait);case InputAction() when input != null:
return input(_that.entries);case PlasmaShortcutAction() when plasmaShortcut != null:
return plasmaShortcut(_that.component,_that.shortcut);case SleepAction() when sleep != null:
return sleep(_that.milliseconds);case RawAction() when raw != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String command,  bool? wait)  command,required TResult Function( List<InputEntry> entries)  input,required TResult Function( String component,  String shortcut)  plasmaShortcut,required TResult Function( int milliseconds)  sleep,required TResult Function( String raw)  raw,}) {final _that = this;
switch (_that) {
case CommandAction():
return command(_that.command,_that.wait);case InputAction():
return input(_that.entries);case PlasmaShortcutAction():
return plasmaShortcut(_that.component,_that.shortcut);case SleepAction():
return sleep(_that.milliseconds);case RawAction():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String command,  bool? wait)?  command,TResult? Function( List<InputEntry> entries)?  input,TResult? Function( String component,  String shortcut)?  plasmaShortcut,TResult? Function( int milliseconds)?  sleep,TResult? Function( String raw)?  raw,}) {final _that = this;
switch (_that) {
case CommandAction() when command != null:
return command(_that.command,_that.wait);case InputAction() when input != null:
return input(_that.entries);case PlasmaShortcutAction() when plasmaShortcut != null:
return plasmaShortcut(_that.component,_that.shortcut);case SleepAction() when sleep != null:
return sleep(_that.milliseconds);case RawAction() when raw != null:
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
  const InputAction({final  List<InputEntry> entries = const []}): _entries = entries;
  

 final  List<InputEntry> _entries;
@JsonKey() List<InputEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InputActionCopyWith<InputAction> get copyWith => _$InputActionCopyWithImpl<InputAction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InputAction&&const DeepCollectionEquality().equals(other._entries, _entries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'Action.input(entries: $entries)';
}


}

/// @nodoc
abstract mixin class $InputActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory $InputActionCopyWith(InputAction value, $Res Function(InputAction) _then) = _$InputActionCopyWithImpl;
@useResult
$Res call({
 List<InputEntry> entries
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
@pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(InputAction(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<InputEntry>,
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
mixin _$InputEntry {

 InputDevice get device; List<String> get tokens;
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
 InputDevice device, List<String> tokens
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
as List<String>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InputDevice device,  List<String> tokens)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InputDevice device,  List<String> tokens)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InputDevice device,  List<String> tokens)?  $default,) {final _that = this;
switch (_that) {
case _InputEntry() when $default != null:
return $default(_that.device,_that.tokens);case _:
  return null;

}
}

}

/// @nodoc


class _InputEntry implements InputEntry {
  const _InputEntry({required this.device, final  List<String> tokens = const []}): _tokens = tokens;
  

@override final  InputDevice device;
 final  List<String> _tokens;
@override@JsonKey() List<String> get tokens {
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
 InputDevice device, List<String> tokens
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
as List<String>,
  ));
}


}

// dart format on
