// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_scope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditScope {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditScope()';
}


}

/// @nodoc
class $EditScopeCopyWith<$Res>  {
$EditScopeCopyWith(EditScope _, $Res Function(EditScope) __);
}


/// Adds pattern-matching-related methods to [EditScope].
extension EditScopePatterns on EditScope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GesturesScope value)?  gestures,TResult Function( SettingsScope value)?  settings,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GesturesScope() when gestures != null:
return gestures(_that);case SettingsScope() when settings != null:
return settings(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GesturesScope value)  gestures,required TResult Function( SettingsScope value)  settings,}){
final _that = this;
switch (_that) {
case GesturesScope():
return gestures(_that);case SettingsScope():
return settings(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GesturesScope value)?  gestures,TResult? Function( SettingsScope value)?  settings,}){
final _that = this;
switch (_that) {
case GesturesScope() when gestures != null:
return gestures(_that);case SettingsScope() when settings != null:
return settings(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  gestures,TResult Function()?  settings,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GesturesScope() when gestures != null:
return gestures();case SettingsScope() when settings != null:
return settings();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  gestures,required TResult Function()  settings,}) {final _that = this;
switch (_that) {
case GesturesScope():
return gestures();case SettingsScope():
return settings();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  gestures,TResult? Function()?  settings,}) {final _that = this;
switch (_that) {
case GesturesScope() when gestures != null:
return gestures();case SettingsScope() when settings != null:
return settings();case _:
  return null;

}
}

}

/// @nodoc


class GesturesScope implements EditScope {
  const GesturesScope();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GesturesScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditScope.gestures()';
}


}




/// @nodoc


class SettingsScope implements EditScope {
  const SettingsScope();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsScope);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditScope.settings()';
}


}




// dart format on
