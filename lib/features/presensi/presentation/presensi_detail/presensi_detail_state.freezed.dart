// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presensi_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PresensiDetailState {

 PresensiType get type; String? get presensi; String? get errorPresensi; bool? get loading; bool get isFormValid;
/// Create a copy of PresensiDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresensiDetailStateCopyWith<PresensiDetailState> get copyWith => _$PresensiDetailStateCopyWithImpl<PresensiDetailState>(this as PresensiDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresensiDetailState&&(identical(other.type, type) || other.type == type)&&(identical(other.presensi, presensi) || other.presensi == presensi)&&(identical(other.errorPresensi, errorPresensi) || other.errorPresensi == errorPresensi)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.isFormValid, isFormValid) || other.isFormValid == isFormValid));
}


@override
int get hashCode => Object.hash(runtimeType,type,presensi,errorPresensi,loading,isFormValid);

@override
String toString() {
  return 'PresensiDetailState(type: $type, presensi: $presensi, errorPresensi: $errorPresensi, loading: $loading, isFormValid: $isFormValid)';
}


}

/// @nodoc
abstract mixin class $PresensiDetailStateCopyWith<$Res>  {
  factory $PresensiDetailStateCopyWith(PresensiDetailState value, $Res Function(PresensiDetailState) _then) = _$PresensiDetailStateCopyWithImpl;
@useResult
$Res call({
 PresensiType type, String? presensi, String? errorPresensi, bool? loading, bool isFormValid
});




}
/// @nodoc
class _$PresensiDetailStateCopyWithImpl<$Res>
    implements $PresensiDetailStateCopyWith<$Res> {
  _$PresensiDetailStateCopyWithImpl(this._self, this._then);

  final PresensiDetailState _self;
  final $Res Function(PresensiDetailState) _then;

/// Create a copy of PresensiDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? presensi = freezed,Object? errorPresensi = freezed,Object? loading = freezed,Object? isFormValid = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PresensiType,presensi: freezed == presensi ? _self.presensi : presensi // ignore: cast_nullable_to_non_nullable
as String?,errorPresensi: freezed == errorPresensi ? _self.errorPresensi : errorPresensi // ignore: cast_nullable_to_non_nullable
as String?,loading: freezed == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool?,isFormValid: null == isFormValid ? _self.isFormValid : isFormValid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PresensiDetailState].
extension PresensiDetailStatePatterns on PresensiDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresensiDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresensiDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresensiDetailState value)  $default,){
final _that = this;
switch (_that) {
case _PresensiDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresensiDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _PresensiDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PresensiType type,  String? presensi,  String? errorPresensi,  bool? loading,  bool isFormValid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresensiDetailState() when $default != null:
return $default(_that.type,_that.presensi,_that.errorPresensi,_that.loading,_that.isFormValid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PresensiType type,  String? presensi,  String? errorPresensi,  bool? loading,  bool isFormValid)  $default,) {final _that = this;
switch (_that) {
case _PresensiDetailState():
return $default(_that.type,_that.presensi,_that.errorPresensi,_that.loading,_that.isFormValid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PresensiType type,  String? presensi,  String? errorPresensi,  bool? loading,  bool isFormValid)?  $default,) {final _that = this;
switch (_that) {
case _PresensiDetailState() when $default != null:
return $default(_that.type,_that.presensi,_that.errorPresensi,_that.loading,_that.isFormValid);case _:
  return null;

}
}

}

/// @nodoc


class _PresensiDetailState implements PresensiDetailState {
  const _PresensiDetailState({required this.type, this.presensi, this.errorPresensi, this.loading, this.isFormValid = false});
  

@override final  PresensiType type;
@override final  String? presensi;
@override final  String? errorPresensi;
@override final  bool? loading;
@override@JsonKey() final  bool isFormValid;

/// Create a copy of PresensiDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresensiDetailStateCopyWith<_PresensiDetailState> get copyWith => __$PresensiDetailStateCopyWithImpl<_PresensiDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresensiDetailState&&(identical(other.type, type) || other.type == type)&&(identical(other.presensi, presensi) || other.presensi == presensi)&&(identical(other.errorPresensi, errorPresensi) || other.errorPresensi == errorPresensi)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.isFormValid, isFormValid) || other.isFormValid == isFormValid));
}


@override
int get hashCode => Object.hash(runtimeType,type,presensi,errorPresensi,loading,isFormValid);

@override
String toString() {
  return 'PresensiDetailState(type: $type, presensi: $presensi, errorPresensi: $errorPresensi, loading: $loading, isFormValid: $isFormValid)';
}


}

/// @nodoc
abstract mixin class _$PresensiDetailStateCopyWith<$Res> implements $PresensiDetailStateCopyWith<$Res> {
  factory _$PresensiDetailStateCopyWith(_PresensiDetailState value, $Res Function(_PresensiDetailState) _then) = __$PresensiDetailStateCopyWithImpl;
@override @useResult
$Res call({
 PresensiType type, String? presensi, String? errorPresensi, bool? loading, bool isFormValid
});




}
/// @nodoc
class __$PresensiDetailStateCopyWithImpl<$Res>
    implements _$PresensiDetailStateCopyWith<$Res> {
  __$PresensiDetailStateCopyWithImpl(this._self, this._then);

  final _PresensiDetailState _self;
  final $Res Function(_PresensiDetailState) _then;

/// Create a copy of PresensiDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? presensi = freezed,Object? errorPresensi = freezed,Object? loading = freezed,Object? isFormValid = null,}) {
  return _then(_PresensiDetailState(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PresensiType,presensi: freezed == presensi ? _self.presensi : presensi // ignore: cast_nullable_to_non_nullable
as String?,errorPresensi: freezed == errorPresensi ? _self.errorPresensi : errorPresensi // ignore: cast_nullable_to_non_nullable
as String?,loading: freezed == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool?,isFormValid: null == isFormValid ? _self.isFormValid : isFormValid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
