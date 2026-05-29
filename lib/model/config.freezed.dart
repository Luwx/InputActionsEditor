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

 List<MouseGesture> get mouseGestures; List<KeyboardGesture> get keyboardGestures; List<PointerGesture> get pointerGestures; List<TouchpadGesture> get touchpadGestures; List<TouchscreenGesture> get touchscreenGestures;/// UI-only grouping metadata; not read by the KWin plugin.
 List<GestureGroup> get gestureGroups; List<DeviceRule> get deviceRules; SpeedSettings? get mouseSpeed; SpeedSettings? get touchpadSpeed; SpeedSettings? get touchscreenSpeed; GlobalSettings get globalSettings;/// Preserves any top-level YAML keys we don't model for round-trip
/// fidelity.
 Map<String, dynamic> get extra;
/// Create a copy of Config
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigCopyWith<Config> get copyWith => _$ConfigCopyWithImpl<Config>(this as Config, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Config&&const DeepCollectionEquality().equals(other.mouseGestures, mouseGestures)&&const DeepCollectionEquality().equals(other.keyboardGestures, keyboardGestures)&&const DeepCollectionEquality().equals(other.pointerGestures, pointerGestures)&&const DeepCollectionEquality().equals(other.touchpadGestures, touchpadGestures)&&const DeepCollectionEquality().equals(other.touchscreenGestures, touchscreenGestures)&&const DeepCollectionEquality().equals(other.gestureGroups, gestureGroups)&&const DeepCollectionEquality().equals(other.deviceRules, deviceRules)&&(identical(other.mouseSpeed, mouseSpeed) || other.mouseSpeed == mouseSpeed)&&(identical(other.touchpadSpeed, touchpadSpeed) || other.touchpadSpeed == touchpadSpeed)&&(identical(other.touchscreenSpeed, touchscreenSpeed) || other.touchscreenSpeed == touchscreenSpeed)&&(identical(other.globalSettings, globalSettings) || other.globalSettings == globalSettings)&&const DeepCollectionEquality().equals(other.extra, extra));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(mouseGestures),const DeepCollectionEquality().hash(keyboardGestures),const DeepCollectionEquality().hash(pointerGestures),const DeepCollectionEquality().hash(touchpadGestures),const DeepCollectionEquality().hash(touchscreenGestures),const DeepCollectionEquality().hash(gestureGroups),const DeepCollectionEquality().hash(deviceRules),mouseSpeed,touchpadSpeed,touchscreenSpeed,globalSettings,const DeepCollectionEquality().hash(extra));

@override
String toString() {
  return 'Config(mouseGestures: $mouseGestures, keyboardGestures: $keyboardGestures, pointerGestures: $pointerGestures, touchpadGestures: $touchpadGestures, touchscreenGestures: $touchscreenGestures, gestureGroups: $gestureGroups, deviceRules: $deviceRules, mouseSpeed: $mouseSpeed, touchpadSpeed: $touchpadSpeed, touchscreenSpeed: $touchscreenSpeed, globalSettings: $globalSettings, extra: $extra)';
}


}

/// @nodoc
abstract mixin class $ConfigCopyWith<$Res>  {
  factory $ConfigCopyWith(Config value, $Res Function(Config) _then) = _$ConfigCopyWithImpl;
@useResult
$Res call({
 List<MouseGesture> mouseGestures, List<KeyboardGesture> keyboardGestures, List<PointerGesture> pointerGestures, List<TouchpadGesture> touchpadGestures, List<TouchscreenGesture> touchscreenGestures, List<GestureGroup> gestureGroups, List<DeviceRule> deviceRules, SpeedSettings? mouseSpeed, SpeedSettings? touchpadSpeed, SpeedSettings? touchscreenSpeed, GlobalSettings globalSettings, Map<String, dynamic> extra
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
@pragma('vm:prefer-inline') @override $Res call({Object? mouseGestures = null,Object? keyboardGestures = null,Object? pointerGestures = null,Object? touchpadGestures = null,Object? touchscreenGestures = null,Object? gestureGroups = null,Object? deviceRules = null,Object? mouseSpeed = freezed,Object? touchpadSpeed = freezed,Object? touchscreenSpeed = freezed,Object? globalSettings = null,Object? extra = null,}) {
  return _then(_self.copyWith(
mouseGestures: null == mouseGestures ? _self.mouseGestures : mouseGestures // ignore: cast_nullable_to_non_nullable
as List<MouseGesture>,keyboardGestures: null == keyboardGestures ? _self.keyboardGestures : keyboardGestures // ignore: cast_nullable_to_non_nullable
as List<KeyboardGesture>,pointerGestures: null == pointerGestures ? _self.pointerGestures : pointerGestures // ignore: cast_nullable_to_non_nullable
as List<PointerGesture>,touchpadGestures: null == touchpadGestures ? _self.touchpadGestures : touchpadGestures // ignore: cast_nullable_to_non_nullable
as List<TouchpadGesture>,touchscreenGestures: null == touchscreenGestures ? _self.touchscreenGestures : touchscreenGestures // ignore: cast_nullable_to_non_nullable
as List<TouchscreenGesture>,gestureGroups: null == gestureGroups ? _self.gestureGroups : gestureGroups // ignore: cast_nullable_to_non_nullable
as List<GestureGroup>,deviceRules: null == deviceRules ? _self.deviceRules : deviceRules // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MouseGesture> mouseGestures,  List<KeyboardGesture> keyboardGestures,  List<PointerGesture> pointerGestures,  List<TouchpadGesture> touchpadGestures,  List<TouchscreenGesture> touchscreenGestures,  List<GestureGroup> gestureGroups,  List<DeviceRule> deviceRules,  SpeedSettings? mouseSpeed,  SpeedSettings? touchpadSpeed,  SpeedSettings? touchscreenSpeed,  GlobalSettings globalSettings,  Map<String, dynamic> extra)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.mouseGestures,_that.keyboardGestures,_that.pointerGestures,_that.touchpadGestures,_that.touchscreenGestures,_that.gestureGroups,_that.deviceRules,_that.mouseSpeed,_that.touchpadSpeed,_that.touchscreenSpeed,_that.globalSettings,_that.extra);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MouseGesture> mouseGestures,  List<KeyboardGesture> keyboardGestures,  List<PointerGesture> pointerGestures,  List<TouchpadGesture> touchpadGestures,  List<TouchscreenGesture> touchscreenGestures,  List<GestureGroup> gestureGroups,  List<DeviceRule> deviceRules,  SpeedSettings? mouseSpeed,  SpeedSettings? touchpadSpeed,  SpeedSettings? touchscreenSpeed,  GlobalSettings globalSettings,  Map<String, dynamic> extra)  $default,) {final _that = this;
switch (_that) {
case _Config():
return $default(_that.mouseGestures,_that.keyboardGestures,_that.pointerGestures,_that.touchpadGestures,_that.touchscreenGestures,_that.gestureGroups,_that.deviceRules,_that.mouseSpeed,_that.touchpadSpeed,_that.touchscreenSpeed,_that.globalSettings,_that.extra);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MouseGesture> mouseGestures,  List<KeyboardGesture> keyboardGestures,  List<PointerGesture> pointerGestures,  List<TouchpadGesture> touchpadGestures,  List<TouchscreenGesture> touchscreenGestures,  List<GestureGroup> gestureGroups,  List<DeviceRule> deviceRules,  SpeedSettings? mouseSpeed,  SpeedSettings? touchpadSpeed,  SpeedSettings? touchscreenSpeed,  GlobalSettings globalSettings,  Map<String, dynamic> extra)?  $default,) {final _that = this;
switch (_that) {
case _Config() when $default != null:
return $default(_that.mouseGestures,_that.keyboardGestures,_that.pointerGestures,_that.touchpadGestures,_that.touchscreenGestures,_that.gestureGroups,_that.deviceRules,_that.mouseSpeed,_that.touchpadSpeed,_that.touchscreenSpeed,_that.globalSettings,_that.extra);case _:
  return null;

}
}

}

/// @nodoc


class _Config extends Config {
  const _Config({final  List<MouseGesture> mouseGestures = const [], final  List<KeyboardGesture> keyboardGestures = const [], final  List<PointerGesture> pointerGestures = const [], final  List<TouchpadGesture> touchpadGestures = const [], final  List<TouchscreenGesture> touchscreenGestures = const [], final  List<GestureGroup> gestureGroups = const [], final  List<DeviceRule> deviceRules = const [], this.mouseSpeed, this.touchpadSpeed, this.touchscreenSpeed, this.globalSettings = const GlobalSettings(), final  Map<String, dynamic> extra = const <String, dynamic>{}}): _mouseGestures = mouseGestures,_keyboardGestures = keyboardGestures,_pointerGestures = pointerGestures,_touchpadGestures = touchpadGestures,_touchscreenGestures = touchscreenGestures,_gestureGroups = gestureGroups,_deviceRules = deviceRules,_extra = extra,super._();
  

 final  List<MouseGesture> _mouseGestures;
@override@JsonKey() List<MouseGesture> get mouseGestures {
  if (_mouseGestures is EqualUnmodifiableListView) return _mouseGestures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mouseGestures);
}

 final  List<KeyboardGesture> _keyboardGestures;
@override@JsonKey() List<KeyboardGesture> get keyboardGestures {
  if (_keyboardGestures is EqualUnmodifiableListView) return _keyboardGestures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keyboardGestures);
}

 final  List<PointerGesture> _pointerGestures;
@override@JsonKey() List<PointerGesture> get pointerGestures {
  if (_pointerGestures is EqualUnmodifiableListView) return _pointerGestures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pointerGestures);
}

 final  List<TouchpadGesture> _touchpadGestures;
@override@JsonKey() List<TouchpadGesture> get touchpadGestures {
  if (_touchpadGestures is EqualUnmodifiableListView) return _touchpadGestures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_touchpadGestures);
}

 final  List<TouchscreenGesture> _touchscreenGestures;
@override@JsonKey() List<TouchscreenGesture> get touchscreenGestures {
  if (_touchscreenGestures is EqualUnmodifiableListView) return _touchscreenGestures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_touchscreenGestures);
}

/// UI-only grouping metadata; not read by the KWin plugin.
 final  List<GestureGroup> _gestureGroups;
/// UI-only grouping metadata; not read by the KWin plugin.
@override@JsonKey() List<GestureGroup> get gestureGroups {
  if (_gestureGroups is EqualUnmodifiableListView) return _gestureGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gestureGroups);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Config&&const DeepCollectionEquality().equals(other._mouseGestures, _mouseGestures)&&const DeepCollectionEquality().equals(other._keyboardGestures, _keyboardGestures)&&const DeepCollectionEquality().equals(other._pointerGestures, _pointerGestures)&&const DeepCollectionEquality().equals(other._touchpadGestures, _touchpadGestures)&&const DeepCollectionEquality().equals(other._touchscreenGestures, _touchscreenGestures)&&const DeepCollectionEquality().equals(other._gestureGroups, _gestureGroups)&&const DeepCollectionEquality().equals(other._deviceRules, _deviceRules)&&(identical(other.mouseSpeed, mouseSpeed) || other.mouseSpeed == mouseSpeed)&&(identical(other.touchpadSpeed, touchpadSpeed) || other.touchpadSpeed == touchpadSpeed)&&(identical(other.touchscreenSpeed, touchscreenSpeed) || other.touchscreenSpeed == touchscreenSpeed)&&(identical(other.globalSettings, globalSettings) || other.globalSettings == globalSettings)&&const DeepCollectionEquality().equals(other._extra, _extra));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_mouseGestures),const DeepCollectionEquality().hash(_keyboardGestures),const DeepCollectionEquality().hash(_pointerGestures),const DeepCollectionEquality().hash(_touchpadGestures),const DeepCollectionEquality().hash(_touchscreenGestures),const DeepCollectionEquality().hash(_gestureGroups),const DeepCollectionEquality().hash(_deviceRules),mouseSpeed,touchpadSpeed,touchscreenSpeed,globalSettings,const DeepCollectionEquality().hash(_extra));

@override
String toString() {
  return 'Config(mouseGestures: $mouseGestures, keyboardGestures: $keyboardGestures, pointerGestures: $pointerGestures, touchpadGestures: $touchpadGestures, touchscreenGestures: $touchscreenGestures, gestureGroups: $gestureGroups, deviceRules: $deviceRules, mouseSpeed: $mouseSpeed, touchpadSpeed: $touchpadSpeed, touchscreenSpeed: $touchscreenSpeed, globalSettings: $globalSettings, extra: $extra)';
}


}

/// @nodoc
abstract mixin class _$ConfigCopyWith<$Res> implements $ConfigCopyWith<$Res> {
  factory _$ConfigCopyWith(_Config value, $Res Function(_Config) _then) = __$ConfigCopyWithImpl;
@override @useResult
$Res call({
 List<MouseGesture> mouseGestures, List<KeyboardGesture> keyboardGestures, List<PointerGesture> pointerGestures, List<TouchpadGesture> touchpadGestures, List<TouchscreenGesture> touchscreenGestures, List<GestureGroup> gestureGroups, List<DeviceRule> deviceRules, SpeedSettings? mouseSpeed, SpeedSettings? touchpadSpeed, SpeedSettings? touchscreenSpeed, GlobalSettings globalSettings, Map<String, dynamic> extra
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
@override @pragma('vm:prefer-inline') $Res call({Object? mouseGestures = null,Object? keyboardGestures = null,Object? pointerGestures = null,Object? touchpadGestures = null,Object? touchscreenGestures = null,Object? gestureGroups = null,Object? deviceRules = null,Object? mouseSpeed = freezed,Object? touchpadSpeed = freezed,Object? touchscreenSpeed = freezed,Object? globalSettings = null,Object? extra = null,}) {
  return _then(_Config(
mouseGestures: null == mouseGestures ? _self._mouseGestures : mouseGestures // ignore: cast_nullable_to_non_nullable
as List<MouseGesture>,keyboardGestures: null == keyboardGestures ? _self._keyboardGestures : keyboardGestures // ignore: cast_nullable_to_non_nullable
as List<KeyboardGesture>,pointerGestures: null == pointerGestures ? _self._pointerGestures : pointerGestures // ignore: cast_nullable_to_non_nullable
as List<PointerGesture>,touchpadGestures: null == touchpadGestures ? _self._touchpadGestures : touchpadGestures // ignore: cast_nullable_to_non_nullable
as List<TouchpadGesture>,touchscreenGestures: null == touchscreenGestures ? _self._touchscreenGestures : touchscreenGestures // ignore: cast_nullable_to_non_nullable
as List<TouchscreenGesture>,gestureGroups: null == gestureGroups ? _self._gestureGroups : gestureGroups // ignore: cast_nullable_to_non_nullable
as List<GestureGroup>,deviceRules: null == deviceRules ? _self._deviceRules : deviceRules // ignore: cast_nullable_to_non_nullable
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
