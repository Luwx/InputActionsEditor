// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keyboard_gesture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KeyboardGesture {

 TriggerCommon get common; List<String> get keys;
/// Create a copy of KeyboardGesture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeyboardGestureCopyWith<KeyboardGesture> get copyWith => _$KeyboardGestureCopyWithImpl<KeyboardGesture>(this as KeyboardGesture, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeyboardGesture&&(identical(other.common, common) || other.common == common)&&const DeepCollectionEquality().equals(other.keys, keys));
}


@override
int get hashCode => Object.hash(runtimeType,common,const DeepCollectionEquality().hash(keys));

@override
String toString() {
  return 'KeyboardGesture(common: $common, keys: $keys)';
}


}

/// @nodoc
abstract mixin class $KeyboardGestureCopyWith<$Res>  {
  factory $KeyboardGestureCopyWith(KeyboardGesture value, $Res Function(KeyboardGesture) _then) = _$KeyboardGestureCopyWithImpl;
@useResult
$Res call({
 TriggerCommon common, List<String> keys
});


$TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$KeyboardGestureCopyWithImpl<$Res>
    implements $KeyboardGestureCopyWith<$Res> {
  _$KeyboardGestureCopyWithImpl(this._self, this._then);

  final KeyboardGesture _self;
  final $Res Function(KeyboardGesture) _then;

/// Create a copy of KeyboardGesture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? common = null,Object? keys = null,}) {
  return _then(_self.copyWith(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,keys: null == keys ? _self.keys : keys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of KeyboardGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}


/// Adds pattern-matching-related methods to [KeyboardGesture].
extension KeyboardGesturePatterns on KeyboardGesture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ShortcutGesture value)?  shortcut,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ShortcutGesture() when shortcut != null:
return shortcut(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ShortcutGesture value)  shortcut,}){
final _that = this;
switch (_that) {
case ShortcutGesture():
return shortcut(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ShortcutGesture value)?  shortcut,}){
final _that = this;
switch (_that) {
case ShortcutGesture() when shortcut != null:
return shortcut(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TriggerCommon common,  List<String> keys)?  shortcut,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ShortcutGesture() when shortcut != null:
return shortcut(_that.common,_that.keys);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TriggerCommon common,  List<String> keys)  shortcut,}) {final _that = this;
switch (_that) {
case ShortcutGesture():
return shortcut(_that.common,_that.keys);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TriggerCommon common,  List<String> keys)?  shortcut,}) {final _that = this;
switch (_that) {
case ShortcutGesture() when shortcut != null:
return shortcut(_that.common,_that.keys);case _:
  return null;

}
}

}

/// @nodoc


class ShortcutGesture extends KeyboardGesture {
  const ShortcutGesture({required this.common, final  List<String> keys = const []}): _keys = keys,super._();
  

@override final  TriggerCommon common;
 final  List<String> _keys;
@override@JsonKey() List<String> get keys {
  if (_keys is EqualUnmodifiableListView) return _keys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keys);
}


/// Create a copy of KeyboardGesture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShortcutGestureCopyWith<ShortcutGesture> get copyWith => _$ShortcutGestureCopyWithImpl<ShortcutGesture>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShortcutGesture&&(identical(other.common, common) || other.common == common)&&const DeepCollectionEquality().equals(other._keys, _keys));
}


@override
int get hashCode => Object.hash(runtimeType,common,const DeepCollectionEquality().hash(_keys));

@override
String toString() {
  return 'KeyboardGesture.shortcut(common: $common, keys: $keys)';
}


}

/// @nodoc
abstract mixin class $ShortcutGestureCopyWith<$Res> implements $KeyboardGestureCopyWith<$Res> {
  factory $ShortcutGestureCopyWith(ShortcutGesture value, $Res Function(ShortcutGesture) _then) = _$ShortcutGestureCopyWithImpl;
@override @useResult
$Res call({
 TriggerCommon common, List<String> keys
});


@override $TriggerCommonCopyWith<$Res> get common;

}
/// @nodoc
class _$ShortcutGestureCopyWithImpl<$Res>
    implements $ShortcutGestureCopyWith<$Res> {
  _$ShortcutGestureCopyWithImpl(this._self, this._then);

  final ShortcutGesture _self;
  final $Res Function(ShortcutGesture) _then;

/// Create a copy of KeyboardGesture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? common = null,Object? keys = null,}) {
  return _then(ShortcutGesture(
common: null == common ? _self.common : common // ignore: cast_nullable_to_non_nullable
as TriggerCommon,keys: null == keys ? _self._keys : keys // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of KeyboardGesture
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriggerCommonCopyWith<$Res> get common {
  
  return $TriggerCommonCopyWith<$Res>(_self.common, (value) {
    return _then(_self.copyWith(common: value));
  });
}
}

// dart format on
