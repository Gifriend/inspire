// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presensi_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PresensiOverview {

 String get serial; String get title; PresensiType get type;
/// Create a copy of PresensiOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresensiOverviewCopyWith<PresensiOverview> get copyWith => _$PresensiOverviewCopyWithImpl<PresensiOverview>(this as PresensiOverview, _$identity);

  /// Serializes this PresensiOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresensiOverview&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serial,title,type);

@override
String toString() {
  return 'PresensiOverview(serial: $serial, title: $title, type: $type)';
}


}

/// @nodoc
abstract mixin class $PresensiOverviewCopyWith<$Res>  {
  factory $PresensiOverviewCopyWith(PresensiOverview value, $Res Function(PresensiOverview) _then) = _$PresensiOverviewCopyWithImpl;
@useResult
$Res call({
 String serial, String title, PresensiType type
});




}
/// @nodoc
class _$PresensiOverviewCopyWithImpl<$Res>
    implements $PresensiOverviewCopyWith<$Res> {
  _$PresensiOverviewCopyWithImpl(this._self, this._then);

  final PresensiOverview _self;
  final $Res Function(PresensiOverview) _then;

/// Create a copy of PresensiOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serial = null,Object? title = null,Object? type = null,}) {
  return _then(_self.copyWith(
serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PresensiType,
  ));
}

}


/// Adds pattern-matching-related methods to [PresensiOverview].
extension PresensiOverviewPatterns on PresensiOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresensiOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresensiOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresensiOverview value)  $default,){
final _that = this;
switch (_that) {
case _PresensiOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresensiOverview value)?  $default,){
final _that = this;
switch (_that) {
case _PresensiOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serial,  String title,  PresensiType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresensiOverview() when $default != null:
return $default(_that.serial,_that.title,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serial,  String title,  PresensiType type)  $default,) {final _that = this;
switch (_that) {
case _PresensiOverview():
return $default(_that.serial,_that.title,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serial,  String title,  PresensiType type)?  $default,) {final _that = this;
switch (_that) {
case _PresensiOverview() when $default != null:
return $default(_that.serial,_that.title,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresensiOverview implements PresensiOverview {
  const _PresensiOverview({required this.serial, required this.title, required this.type});
  factory _PresensiOverview.fromJson(Map<String, dynamic> json) => _$PresensiOverviewFromJson(json);

@override final  String serial;
@override final  String title;
@override final  PresensiType type;

/// Create a copy of PresensiOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresensiOverviewCopyWith<_PresensiOverview> get copyWith => __$PresensiOverviewCopyWithImpl<_PresensiOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresensiOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresensiOverview&&(identical(other.serial, serial) || other.serial == serial)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serial,title,type);

@override
String toString() {
  return 'PresensiOverview(serial: $serial, title: $title, type: $type)';
}


}

/// @nodoc
abstract mixin class _$PresensiOverviewCopyWith<$Res> implements $PresensiOverviewCopyWith<$Res> {
  factory _$PresensiOverviewCopyWith(_PresensiOverview value, $Res Function(_PresensiOverview) _then) = __$PresensiOverviewCopyWithImpl;
@override @useResult
$Res call({
 String serial, String title, PresensiType type
});




}
/// @nodoc
class __$PresensiOverviewCopyWithImpl<$Res>
    implements _$PresensiOverviewCopyWith<$Res> {
  __$PresensiOverviewCopyWithImpl(this._self, this._then);

  final _PresensiOverview _self;
  final $Res Function(_PresensiOverview) _then;

/// Create a copy of PresensiOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serial = null,Object? title = null,Object? type = null,}) {
  return _then(_PresensiOverview(
serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PresensiType,
  ));
}


}

// dart format on
