// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_editor_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsEditorVm {

 Config? get config;
/// Create a copy of SettingsEditorVm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsEditorVmCopyWith<SettingsEditorVm> get copyWith => _$SettingsEditorVmCopyWithImpl<SettingsEditorVm>(this as SettingsEditorVm, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsEditorVm&&(identical(other.config, config) || other.config == config));
}


@override
int get hashCode => Object.hash(runtimeType,config);

@override
String toString() {
  return 'SettingsEditorVm(config: $config)';
}


}

/// @nodoc
abstract mixin class $SettingsEditorVmCopyWith<$Res>  {
  factory $SettingsEditorVmCopyWith(SettingsEditorVm value, $Res Function(SettingsEditorVm) _then) = _$SettingsEditorVmCopyWithImpl;
@useResult
$Res call({
 Config? config
});


$ConfigCopyWith<$Res>? get config;

}
/// @nodoc
class _$SettingsEditorVmCopyWithImpl<$Res>
    implements $SettingsEditorVmCopyWith<$Res> {
  _$SettingsEditorVmCopyWithImpl(this._self, this._then);

  final SettingsEditorVm _self;
  final $Res Function(SettingsEditorVm) _then;

/// Create a copy of SettingsEditorVm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? config = freezed,}) {
  return _then(_self.copyWith(
config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Config?,
  ));
}
/// Create a copy of SettingsEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfigCopyWith<$Res>? get config {
    if (_self.config == null) {
    return null;
  }

  return $ConfigCopyWith<$Res>(_self.config!, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [SettingsEditorVm].
extension SettingsEditorVmPatterns on SettingsEditorVm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsEditorVm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsEditorVm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsEditorVm value)  $default,){
final _that = this;
switch (_that) {
case _SettingsEditorVm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsEditorVm value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsEditorVm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Config? config)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsEditorVm() when $default != null:
return $default(_that.config);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Config? config)  $default,) {final _that = this;
switch (_that) {
case _SettingsEditorVm():
return $default(_that.config);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Config? config)?  $default,) {final _that = this;
switch (_that) {
case _SettingsEditorVm() when $default != null:
return $default(_that.config);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsEditorVm extends SettingsEditorVm {
  const _SettingsEditorVm({required this.config}): super._();
  

@override final  Config? config;

/// Create a copy of SettingsEditorVm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsEditorVmCopyWith<_SettingsEditorVm> get copyWith => __$SettingsEditorVmCopyWithImpl<_SettingsEditorVm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsEditorVm&&(identical(other.config, config) || other.config == config));
}


@override
int get hashCode => Object.hash(runtimeType,config);

@override
String toString() {
  return 'SettingsEditorVm(config: $config)';
}


}

/// @nodoc
abstract mixin class _$SettingsEditorVmCopyWith<$Res> implements $SettingsEditorVmCopyWith<$Res> {
  factory _$SettingsEditorVmCopyWith(_SettingsEditorVm value, $Res Function(_SettingsEditorVm) _then) = __$SettingsEditorVmCopyWithImpl;
@override @useResult
$Res call({
 Config? config
});


@override $ConfigCopyWith<$Res>? get config;

}
/// @nodoc
class __$SettingsEditorVmCopyWithImpl<$Res>
    implements _$SettingsEditorVmCopyWith<$Res> {
  __$SettingsEditorVmCopyWithImpl(this._self, this._then);

  final _SettingsEditorVm _self;
  final $Res Function(_SettingsEditorVm) _then;

/// Create a copy of SettingsEditorVm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? config = freezed,}) {
  return _then(_SettingsEditorVm(
config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Config?,
  ));
}

/// Create a copy of SettingsEditorVm
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfigCopyWith<$Res>? get config {
    if (_self.config == null) {
    return null;
  }

  return $ConfigCopyWith<$Res>(_self.config!, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}

// dart format on
