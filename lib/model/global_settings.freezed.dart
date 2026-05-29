// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GlobalSettings {

 bool? get autoreload; List<String>? get emergencyCombination; bool? get externalVariableAccess; bool? get notificationsConfigError;
/// Create a copy of GlobalSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GlobalSettingsCopyWith<GlobalSettings> get copyWith => _$GlobalSettingsCopyWithImpl<GlobalSettings>(this as GlobalSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlobalSettings&&(identical(other.autoreload, autoreload) || other.autoreload == autoreload)&&const DeepCollectionEquality().equals(other.emergencyCombination, emergencyCombination)&&(identical(other.externalVariableAccess, externalVariableAccess) || other.externalVariableAccess == externalVariableAccess)&&(identical(other.notificationsConfigError, notificationsConfigError) || other.notificationsConfigError == notificationsConfigError));
}


@override
int get hashCode => Object.hash(runtimeType,autoreload,const DeepCollectionEquality().hash(emergencyCombination),externalVariableAccess,notificationsConfigError);

@override
String toString() {
  return 'GlobalSettings(autoreload: $autoreload, emergencyCombination: $emergencyCombination, externalVariableAccess: $externalVariableAccess, notificationsConfigError: $notificationsConfigError)';
}


}

/// @nodoc
abstract mixin class $GlobalSettingsCopyWith<$Res>  {
  factory $GlobalSettingsCopyWith(GlobalSettings value, $Res Function(GlobalSettings) _then) = _$GlobalSettingsCopyWithImpl;
@useResult
$Res call({
 bool? autoreload, List<String>? emergencyCombination, bool? externalVariableAccess, bool? notificationsConfigError
});




}
/// @nodoc
class _$GlobalSettingsCopyWithImpl<$Res>
    implements $GlobalSettingsCopyWith<$Res> {
  _$GlobalSettingsCopyWithImpl(this._self, this._then);

  final GlobalSettings _self;
  final $Res Function(GlobalSettings) _then;

/// Create a copy of GlobalSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? autoreload = freezed,Object? emergencyCombination = freezed,Object? externalVariableAccess = freezed,Object? notificationsConfigError = freezed,}) {
  return _then(_self.copyWith(
autoreload: freezed == autoreload ? _self.autoreload : autoreload // ignore: cast_nullable_to_non_nullable
as bool?,emergencyCombination: freezed == emergencyCombination ? _self.emergencyCombination : emergencyCombination // ignore: cast_nullable_to_non_nullable
as List<String>?,externalVariableAccess: freezed == externalVariableAccess ? _self.externalVariableAccess : externalVariableAccess // ignore: cast_nullable_to_non_nullable
as bool?,notificationsConfigError: freezed == notificationsConfigError ? _self.notificationsConfigError : notificationsConfigError // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [GlobalSettings].
extension GlobalSettingsPatterns on GlobalSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GlobalSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GlobalSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GlobalSettings value)  $default,){
final _that = this;
switch (_that) {
case _GlobalSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GlobalSettings value)?  $default,){
final _that = this;
switch (_that) {
case _GlobalSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool? autoreload,  List<String>? emergencyCombination,  bool? externalVariableAccess,  bool? notificationsConfigError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GlobalSettings() when $default != null:
return $default(_that.autoreload,_that.emergencyCombination,_that.externalVariableAccess,_that.notificationsConfigError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool? autoreload,  List<String>? emergencyCombination,  bool? externalVariableAccess,  bool? notificationsConfigError)  $default,) {final _that = this;
switch (_that) {
case _GlobalSettings():
return $default(_that.autoreload,_that.emergencyCombination,_that.externalVariableAccess,_that.notificationsConfigError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool? autoreload,  List<String>? emergencyCombination,  bool? externalVariableAccess,  bool? notificationsConfigError)?  $default,) {final _that = this;
switch (_that) {
case _GlobalSettings() when $default != null:
return $default(_that.autoreload,_that.emergencyCombination,_that.externalVariableAccess,_that.notificationsConfigError);case _:
  return null;

}
}

}

/// @nodoc


class _GlobalSettings implements GlobalSettings {
  const _GlobalSettings({this.autoreload, final  List<String>? emergencyCombination, this.externalVariableAccess, this.notificationsConfigError}): _emergencyCombination = emergencyCombination;
  

@override final  bool? autoreload;
 final  List<String>? _emergencyCombination;
@override List<String>? get emergencyCombination {
  final value = _emergencyCombination;
  if (value == null) return null;
  if (_emergencyCombination is EqualUnmodifiableListView) return _emergencyCombination;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? externalVariableAccess;
@override final  bool? notificationsConfigError;

/// Create a copy of GlobalSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GlobalSettingsCopyWith<_GlobalSettings> get copyWith => __$GlobalSettingsCopyWithImpl<_GlobalSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GlobalSettings&&(identical(other.autoreload, autoreload) || other.autoreload == autoreload)&&const DeepCollectionEquality().equals(other._emergencyCombination, _emergencyCombination)&&(identical(other.externalVariableAccess, externalVariableAccess) || other.externalVariableAccess == externalVariableAccess)&&(identical(other.notificationsConfigError, notificationsConfigError) || other.notificationsConfigError == notificationsConfigError));
}


@override
int get hashCode => Object.hash(runtimeType,autoreload,const DeepCollectionEquality().hash(_emergencyCombination),externalVariableAccess,notificationsConfigError);

@override
String toString() {
  return 'GlobalSettings(autoreload: $autoreload, emergencyCombination: $emergencyCombination, externalVariableAccess: $externalVariableAccess, notificationsConfigError: $notificationsConfigError)';
}


}

/// @nodoc
abstract mixin class _$GlobalSettingsCopyWith<$Res> implements $GlobalSettingsCopyWith<$Res> {
  factory _$GlobalSettingsCopyWith(_GlobalSettings value, $Res Function(_GlobalSettings) _then) = __$GlobalSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool? autoreload, List<String>? emergencyCombination, bool? externalVariableAccess, bool? notificationsConfigError
});




}
/// @nodoc
class __$GlobalSettingsCopyWithImpl<$Res>
    implements _$GlobalSettingsCopyWith<$Res> {
  __$GlobalSettingsCopyWithImpl(this._self, this._then);

  final _GlobalSettings _self;
  final $Res Function(_GlobalSettings) _then;

/// Create a copy of GlobalSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? autoreload = freezed,Object? emergencyCombination = freezed,Object? externalVariableAccess = freezed,Object? notificationsConfigError = freezed,}) {
  return _then(_GlobalSettings(
autoreload: freezed == autoreload ? _self.autoreload : autoreload // ignore: cast_nullable_to_non_nullable
as bool?,emergencyCombination: freezed == emergencyCombination ? _self._emergencyCombination : emergencyCombination // ignore: cast_nullable_to_non_nullable
as List<String>?,externalVariableAccess: freezed == externalVariableAccess ? _self.externalVariableAccess : externalVariableAccess // ignore: cast_nullable_to_non_nullable
as bool?,notificationsConfigError: freezed == notificationsConfigError ? _self.notificationsConfigError : notificationsConfigError // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
