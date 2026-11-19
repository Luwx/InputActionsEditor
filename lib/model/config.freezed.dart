// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Config {

 List<GestureNode> get mouseNodes; List<GestureNode> get keyboardNodes; List<GestureNode> get pointerNodes; List<GestureNode> get touchpadNodes; List<GestureNode> get touchscreenNodes; List<DeviceRule> get deviceRules; SpeedSettings? get mouseSpeed; SpeedSettings? get touchpadSpeed; SpeedSettings? get touchscreenSpeed; GlobalSettings get globalSettings;/// Preserves any top-level YAML keys we don't model for round-trip
/// fidelity.
 Map<String, dynamic> get extra;
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigCopyWith<Config> get copyWith => _$ConfigCopyWithImpl<Config>(this as Config, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Config&&const DeepCollectionEquality().equals(other.mouseNodes, mouseNodes)&&const DeepCollectionEquality().equals(other.keyboardNodes, keyboardNodes)&&const DeepCollectionEquality().equals(other.pointerNodes, pointerNodes)&&const DeepCollectionEquality().equals(other.touchpadNodes, touchpadNodes)&&const DeepCollectionEquality().equals(other.touchscreenNodes, touchscreenNodes)&&const DeepCollectionEquality().equals(other.deviceRules, deviceRules)&&(identical(other.mouseSpeed, mouseSpeed) || other.mouseSpeed == mouseSpeed)&&(identical(other.touchpadSpeed, touchpadSpeed) || other.touchpadSpeed == touchpadSpeed)&&(identical(other.touchscreenSpeed, touchscreenSpeed) || other.touchscreenSpeed == touchscreenSpeed)&&(identical(other.globalSettings, globalSettings) || other.globalSettings == globalSettings)&&const DeepCollectionEquality().equals(other.extra, extra));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mouseNodes),const DeepCollectionEquality().hash(keyboardNodes),const DeepCollectionEquality().hash(pointerNodes),const DeepCollectionEquality().hash(touchpadNodes),const DeepCollectionEquality().hash(touchscreenNodes),const DeepCollectionEquality().hash(deviceRules),mouseSpeed,touchpadSpeed,touchscreenSpeed,globalSettings,const DeepCollectionEquality().hash(extra));

@override
String toString() {
  return 'Config(mouseNodes: $mouseNodes, keyboardNodes: $keyboardNodes, pointerNodes: $pointerNodes, touchpadNodes: $touchpadNodes, touchscreenNodes: $touchscreenNodes, deviceRules: $deviceRules, mouseSpeed: $mouseSpeed, touchpadSpeed: $touchpadSpeed, touchscreenSpeed: $touchscreenSpeed, globalSettings: $globalSettings, extra: $extra)';
}


}

/// @nodoc
abstract mixin class $ConfigCopyWith<$Res>  {
  factory $ConfigCopyWith(Config value, $Res Function(Config) _then) = _$ConfigCopyWithImpl;
@useResult
$Res call({
 List<GestureNode> mouseNodes, List<GestureNode> keyboardNodes, List<GestureNode> pointerNodes, List<GestureNode> touchpadNodes, List<GestureNode> touchscreenNodes, List<DeviceRule> deviceRules, SpeedSettings? mouseSpeed, SpeedSettings? touchpadSpeed, SpeedSettings? touchscreenSpeed, GlobalSettings globalSettings, Map<String, dynamic> extra
});


$SpeedSettingsCopyWith<$Res>? get mouseSpeed;$SpeedSettingsCopyWith<$Res>? get touchpadSpeed;$SpeedSettingsCopyWith<$Res>? get touchscreenSpeed;$GlobalSettingsCopyWith<$Res> get globalSettings;

}
/// @nodoc
class _$ConfigCopyWithImpl<$Res>
    implements $ConfigCopyWith<$Res> {
  _$ConfigCopyWithImpl(this._self, this._then);

  final Config _self;
  final $Res Function(Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mouseNodes = null,Object? keyboardNodes = null,Object? pointerNodes = null,Object? touchpadNodes = null,Object? touchscreenNodes = null,Object? deviceRules = null,Object? mouseSpeed = freezed,Object? touchpadSpeed = freezed,Object? touchscreenSpeed = freezed,Object? globalSettings = null,Object? extra = null,}) {
  return _then(_self.copyWith(
mouseNodes: null == mouseNodes ? _self.mouseNodes : mouseNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,keyboardNodes: null == keyboardNodes ? _self.keyboardNodes : keyboardNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,pointerNodes: null == pointerNodes ? _self.pointerNodes : pointerNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,touchpadNodes: null == touchpadNodes ? _self.touchpadNodes : touchpadNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,touchscreenNodes: null == touchscreenNodes ? _self.touchscreenNodes : touchscreenNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,deviceRules: null == deviceRules ? _self.deviceRules : deviceRules // ignore: cast_nullable_to_non_nullable
as List<DeviceRule>,mouseSpeed: freezed == mouseSpeed ? _self.mouseSpeed : mouseSpeed // ignore: cast_nullable_to_non_nullable
as SpeedSettings?,touchpadSpeed: freezed == touchpadSpeed ? _self.touchpadSpeed : touchpadSpeed // ignore: cast_nullable_to_non_nullable
as SpeedSettings?,touchscreenSpeed: freezed == touchscreenSpeed ? _self.touchscreenSpeed : touchscreenSpeed // ignore: cast_nullable_to_non_nullable
as SpeedSettings?,globalSettings: null == globalSettings ? _self.globalSettings : globalSettings // ignore: cast_nullable_to_non_nullable
as GlobalSettings,extra: null == extra ? _self.extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpeedSettingsCopyWith<$Res>? get mouseSpeed {
    if (_self.mouseSpeed == null) {
    return null;
  }

  return $SpeedSettingsCopyWith<$Res>(_self.mouseSpeed!, (value) {
    return _then(_self.copyWith(mouseSpeed: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpeedSettingsCopyWith<$Res>? get touchpadSpeed {
    if (_self.touchpadSpeed == null) {
    return null;
  }

  return $SpeedSettingsCopyWith<$Res>(_self.touchpadSpeed!, (value) {
    return _then(_self.copyWith(touchpadSpeed: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpeedSettingsCopyWith<$Res>? get touchscreenSpeed {
    if (_self.touchscreenSpeed == null) {
    return null;
  }

  return $SpeedSettingsCopyWith<$Res>(_self.touchscreenSpeed!, (value) {
    return _then(_self.copyWith(touchscreenSpeed: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalSettingsCopyWith<$Res> get globalSettings {
  
  return $GlobalSettingsCopyWith<$Res>(_self.globalSettings, (value) {
    return _then(_self.copyWith(globalSettings: value));
  });
}
}


/// Adds pattern-matching-related methods to [Config].
extension ConfigPatterns on Config {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Config value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Config() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Config value)  $default,){
final _that = this;
switch (_that) {
case _Config():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Config value)?  $default,){
final _that = this;
switch (_that) {
case _Config() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<GestureNode> mouseNodes,  List<GestureNode> keyboardNodes,  List<GestureNode> pointerNodes,  List<GestureNode> touchpadNodes,  List<GestureNode> touchscreenNodes,  List<DeviceRule> deviceRules,  SpeedSettings? mouseSpeed,  SpeedSettings? touchpadSpeed,  SpeedSettings? touchscreenSpeed,  GlobalSettings globalSettings,  Map<String, dynamic> extra)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.mouseNodes,_that.keyboardNodes,_that.pointerNodes,_that.touchpadNodes,_that.touchscreenNodes,_that.deviceRules,_that.mouseSpeed,_that.touchpadSpeed,_that.touchscreenSpeed,_that.globalSettings,_that.extra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<GestureNode> mouseNodes,  List<GestureNode> keyboardNodes,  List<GestureNode> pointerNodes,  List<GestureNode> touchpadNodes,  List<GestureNode> touchscreenNodes,  List<DeviceRule> deviceRules,  SpeedSettings? mouseSpeed,  SpeedSettings? touchpadSpeed,  SpeedSettings? touchscreenSpeed,  GlobalSettings globalSettings,  Map<String, dynamic> extra)  $default,) {final _that = this;
switch (_that) {
case _Config():
return $default(_that.mouseNodes,_that.keyboardNodes,_that.pointerNodes,_that.touchpadNodes,_that.touchscreenNodes,_that.deviceRules,_that.mouseSpeed,_that.touchpadSpeed,_that.touchscreenSpeed,_that.globalSettings,_that.extra);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<GestureNode> mouseNodes,  List<GestureNode> keyboardNodes,  List<GestureNode> pointerNodes,  List<GestureNode> touchpadNodes,  List<GestureNode> touchscreenNodes,  List<DeviceRule> deviceRules,  SpeedSettings? mouseSpeed,  SpeedSettings? touchpadSpeed,  SpeedSettings? touchscreenSpeed,  GlobalSettings globalSettings,  Map<String, dynamic> extra)?  $default,) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.mouseNodes,_that.keyboardNodes,_that.pointerNodes,_that.touchpadNodes,_that.touchscreenNodes,_that.deviceRules,_that.mouseSpeed,_that.touchpadSpeed,_that.touchscreenSpeed,_that.globalSettings,_that.extra);case _:
  return null;

}
}

}

/// @nodoc


class _Config extends Config {
  const _Config({final  List<GestureNode> mouseNodes = const [], final  List<GestureNode> keyboardNodes = const [], final  List<GestureNode> pointerNodes = const [], final  List<GestureNode> touchpadNodes = const [], final  List<GestureNode> touchscreenNodes = const [], final  List<DeviceRule> deviceRules = const [], this.mouseSpeed, this.touchpadSpeed, this.touchscreenSpeed, this.globalSettings = const GlobalSettings(), final  Map<String, dynamic> extra = const <String, dynamic>{}}): _mouseNodes = mouseNodes,_keyboardNodes = keyboardNodes,_pointerNodes = pointerNodes,_touchpadNodes = touchpadNodes,_touchscreenNodes = touchscreenNodes,_deviceRules = deviceRules,_extra = extra,super._();
  

 final  List<GestureNode> _mouseNodes;
@override@JsonKey() List<GestureNode> get mouseNodes {
  if (_mouseNodes is EqualUnmodifiableListView) return _mouseNodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mouseNodes);
}

 final  List<GestureNode> _keyboardNodes;
@override@JsonKey() List<GestureNode> get keyboardNodes {
  if (_keyboardNodes is EqualUnmodifiableListView) return _keyboardNodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keyboardNodes);
}

 final  List<GestureNode> _pointerNodes;
@override@JsonKey() List<GestureNode> get pointerNodes {
  if (_pointerNodes is EqualUnmodifiableListView) return _pointerNodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pointerNodes);
}

 final  List<GestureNode> _touchpadNodes;
@override@JsonKey() List<GestureNode> get touchpadNodes {
  if (_touchpadNodes is EqualUnmodifiableListView) return _touchpadNodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_touchpadNodes);
}

 final  List<GestureNode> _touchscreenNodes;
@override@JsonKey() List<GestureNode> get touchscreenNodes {
  if (_touchscreenNodes is EqualUnmodifiableListView) return _touchscreenNodes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_touchscreenNodes);
}

 final  List<DeviceRule> _deviceRules;
@override@JsonKey() List<DeviceRule> get deviceRules {
  if (_deviceRules is EqualUnmodifiableListView) return _deviceRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_deviceRules);
}

@override final  SpeedSettings? mouseSpeed;
@override final  SpeedSettings? touchpadSpeed;
@override final  SpeedSettings? touchscreenSpeed;
@override@JsonKey() final  GlobalSettings globalSettings;
/// Preserves any top-level YAML keys we don't model for round-trip
/// fidelity.
 final  Map<String, dynamic> _extra;
/// Preserves any top-level YAML keys we don't model for round-trip
/// fidelity.
@override@JsonKey() Map<String, dynamic> get extra {
  if (_extra is EqualUnmodifiableMapView) return _extra;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extra);
}


/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigCopyWith<_Config> get copyWith => __$ConfigCopyWithImpl<_Config>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Config&&const DeepCollectionEquality().equals(other._mouseNodes, _mouseNodes)&&const DeepCollectionEquality().equals(other._keyboardNodes, _keyboardNodes)&&const DeepCollectionEquality().equals(other._pointerNodes, _pointerNodes)&&const DeepCollectionEquality().equals(other._touchpadNodes, _touchpadNodes)&&const DeepCollectionEquality().equals(other._touchscreenNodes, _touchscreenNodes)&&const DeepCollectionEquality().equals(other._deviceRules, _deviceRules)&&(identical(other.mouseSpeed, mouseSpeed) || other.mouseSpeed == mouseSpeed)&&(identical(other.touchpadSpeed, touchpadSpeed) || other.touchpadSpeed == touchpadSpeed)&&(identical(other.touchscreenSpeed, touchscreenSpeed) || other.touchscreenSpeed == touchscreenSpeed)&&(identical(other.globalSettings, globalSettings) || other.globalSettings == globalSettings)&&const DeepCollectionEquality().equals(other._extra, _extra));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mouseNodes),const DeepCollectionEquality().hash(_keyboardNodes),const DeepCollectionEquality().hash(_pointerNodes),const DeepCollectionEquality().hash(_touchpadNodes),const DeepCollectionEquality().hash(_touchscreenNodes),const DeepCollectionEquality().hash(_deviceRules),mouseSpeed,touchpadSpeed,touchscreenSpeed,globalSettings,const DeepCollectionEquality().hash(_extra));

@override
String toString() {
  return 'Config(mouseNodes: $mouseNodes, keyboardNodes: $keyboardNodes, pointerNodes: $pointerNodes, touchpadNodes: $touchpadNodes, touchscreenNodes: $touchscreenNodes, deviceRules: $deviceRules, mouseSpeed: $mouseSpeed, touchpadSpeed: $touchpadSpeed, touchscreenSpeed: $touchscreenSpeed, globalSettings: $globalSettings, extra: $extra)';
}


}

/// @nodoc
abstract mixin class _$ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$ConfigCopyWith(_Config value, $Res Function(_Config) _then) = __$ConfigCopyWithImpl;
@override @useResult
$Res call({
 List<GestureNode> mouseNodes, List<GestureNode> keyboardNodes, List<GestureNode> pointerNodes, List<GestureNode> touchpadNodes, List<GestureNode> touchscreenNodes, List<DeviceRule> deviceRules, SpeedSettings? mouseSpeed, SpeedSettings? touchpadSpeed, SpeedSettings? touchscreenSpeed, GlobalSettings globalSettings, Map<String, dynamic> extra
});


@override $SpeedSettingsCopyWith<$Res>? get mouseSpeed;@override $SpeedSettingsCopyWith<$Res>? get touchpadSpeed;@override $SpeedSettingsCopyWith<$Res>? get touchscreenSpeed;@override $GlobalSettingsCopyWith<$Res> get globalSettings;

}
/// @nodoc
class __$ConfigCopyWithImpl<$Res>
    implements _$ConfigCopyWith<$Res> {
  __$ConfigCopyWithImpl(this._self, this._then);

  final _Config _self;
  final $Res Function(_Config) _then;

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mouseNodes = null,Object? keyboardNodes = null,Object? pointerNodes = null,Object? touchpadNodes = null,Object? touchscreenNodes = null,Object? deviceRules = null,Object? mouseSpeed = freezed,Object? touchpadSpeed = freezed,Object? touchscreenSpeed = freezed,Object? globalSettings = null,Object? extra = null,}) {
  return _then(_Config(
mouseNodes: null == mouseNodes ? _self._mouseNodes : mouseNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,keyboardNodes: null == keyboardNodes ? _self._keyboardNodes : keyboardNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,pointerNodes: null == pointerNodes ? _self._pointerNodes : pointerNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,touchpadNodes: null == touchpadNodes ? _self._touchpadNodes : touchpadNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,touchscreenNodes: null == touchscreenNodes ? _self._touchscreenNodes : touchscreenNodes // ignore: cast_nullable_to_non_nullable
as List<GestureNode>,deviceRules: null == deviceRules ? _self._deviceRules : deviceRules // ignore: cast_nullable_to_non_nullable
as List<DeviceRule>,mouseSpeed: freezed == mouseSpeed ? _self.mouseSpeed : mouseSpeed // ignore: cast_nullable_to_non_nullable
as SpeedSettings?,touchpadSpeed: freezed == touchpadSpeed ? _self.touchpadSpeed : touchpadSpeed // ignore: cast_nullable_to_non_nullable
as SpeedSettings?,touchscreenSpeed: freezed == touchscreenSpeed ? _self.touchscreenSpeed : touchscreenSpeed // ignore: cast_nullable_to_non_nullable
as SpeedSettings?,globalSettings: null == globalSettings ? _self.globalSettings : globalSettings // ignore: cast_nullable_to_non_nullable
as GlobalSettings,extra: null == extra ? _self._extra : extra // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpeedSettingsCopyWith<$Res>? get mouseSpeed {
    if (_self.mouseSpeed == null) {
    return null;
  }

  return $SpeedSettingsCopyWith<$Res>(_self.mouseSpeed!, (value) {
    return _then(_self.copyWith(mouseSpeed: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpeedSettingsCopyWith<$Res>? get touchpadSpeed {
    if (_self.touchpadSpeed == null) {
    return null;
  }

  return $SpeedSettingsCopyWith<$Res>(_self.touchpadSpeed!, (value) {
    return _then(_self.copyWith(touchpadSpeed: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpeedSettingsCopyWith<$Res>? get touchscreenSpeed {
    if (_self.touchscreenSpeed == null) {
    return null;
  }

  return $SpeedSettingsCopyWith<$Res>(_self.touchscreenSpeed!, (value) {
    return _then(_self.copyWith(touchscreenSpeed: value));
  });
}/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GlobalSettingsCopyWith<$Res> get globalSettings {
  
  return $GlobalSettingsCopyWith<$Res>(_self.globalSettings, (value) {
    return _then(_self.copyWith(globalSettings: value));
  });
}
}

// dart format on
