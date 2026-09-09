// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'advisor_recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdvisorRecommendationModel {

 String get id; AdvisorRecommendationType get type; AdvisorSeverity get severity; int? get amount; double? get ratio; String? get relatedName; bool get isSalaryRelated;
/// Create a copy of AdvisorRecommendationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdvisorRecommendationModelCopyWith<AdvisorRecommendationModel> get copyWith => _$AdvisorRecommendationModelCopyWithImpl<AdvisorRecommendationModel>(this as AdvisorRecommendationModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AdvisorRecommendationModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdvisorRecommendationModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.ratio, _this.ratio) || other.ratio == _this.ratio)&&(identical(other.relatedName, _this.relatedName) || other.relatedName == _this.relatedName)&&(identical(other.isSalaryRelated, _this.isSalaryRelated) || other.isSalaryRelated == _this.isSalaryRelated));
}


@override
int get hashCode {
  final _this = this as AdvisorRecommendationModel;
  return Object.hash(runtimeType,_this.id,_this.type,_this.severity,_this.amount,_this.ratio,_this.relatedName,_this.isSalaryRelated);
}

@override
String toString() {
  final _this = this as AdvisorRecommendationModel;
  return 'AdvisorRecommendationModel(id: ${_this.id}, type: ${_this.type}, severity: ${_this.severity}, amount: ${_this.amount}, ratio: ${_this.ratio}, relatedName: ${_this.relatedName}, isSalaryRelated: ${_this.isSalaryRelated})';
}


}

/// @nodoc
abstract mixin class $AdvisorRecommendationModelCopyWith<$Res>  {
  factory $AdvisorRecommendationModelCopyWith(AdvisorRecommendationModel value, $Res Function(AdvisorRecommendationModel) _then) = _$AdvisorRecommendationModelCopyWithImpl;
@useResult
$Res call({
 String id, AdvisorRecommendationType type, AdvisorSeverity severity, int? amount, double? ratio, String? relatedName, bool isSalaryRelated
});




}
/// @nodoc
class _$AdvisorRecommendationModelCopyWithImpl<$Res>
    implements $AdvisorRecommendationModelCopyWith<$Res> {
  _$AdvisorRecommendationModelCopyWithImpl(this._self, this._then);

  final AdvisorRecommendationModel _self;
  final $Res Function(AdvisorRecommendationModel) _then;

/// Create a copy of AdvisorRecommendationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? severity = null,Object? amount = freezed,Object? ratio = freezed,Object? relatedName = freezed,Object? isSalaryRelated = null,}) {
  return _then(AdvisorRecommendationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AdvisorRecommendationType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AdvisorSeverity,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,ratio: freezed == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as double?,relatedName: freezed == relatedName ? _self.relatedName : relatedName // ignore: cast_nullable_to_non_nullable
as String?,isSalaryRelated: null == isSalaryRelated ? _self.isSalaryRelated : isSalaryRelated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AdvisorRecommendationModel].
extension AdvisorRecommendationModelPatterns on AdvisorRecommendationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdvisorRecommendationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdvisorRecommendationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdvisorRecommendationModel value)  $default,){
final _that = this;
switch (_that) {
case _AdvisorRecommendationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdvisorRecommendationModel value)?  $default,){
final _that = this;
switch (_that) {
case _AdvisorRecommendationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AdvisorRecommendationType type,  AdvisorSeverity severity,  int? amount,  double? ratio,  String? relatedName,  bool isSalaryRelated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdvisorRecommendationModel() when $default != null:
return $default(_that.id,_that.type,_that.severity,_that.amount,_that.ratio,_that.relatedName,_that.isSalaryRelated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AdvisorRecommendationType type,  AdvisorSeverity severity,  int? amount,  double? ratio,  String? relatedName,  bool isSalaryRelated)  $default,) {final _that = this;
switch (_that) {
case _AdvisorRecommendationModel():
return $default(_that.id,_that.type,_that.severity,_that.amount,_that.ratio,_that.relatedName,_that.isSalaryRelated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AdvisorRecommendationType type,  AdvisorSeverity severity,  int? amount,  double? ratio,  String? relatedName,  bool isSalaryRelated)?  $default,) {final _that = this;
switch (_that) {
case _AdvisorRecommendationModel() when $default != null:
return $default(_that.id,_that.type,_that.severity,_that.amount,_that.ratio,_that.relatedName,_that.isSalaryRelated);case _:
  return null;

}
}

}

/// @nodoc


class _AdvisorRecommendationModel extends AdvisorRecommendationModel {
  const _AdvisorRecommendationModel({required this.id, required this.type, required this.severity, this.amount, this.ratio, this.relatedName, this.isSalaryRelated = false}): super._();
  

@override final  String id;
@override final  AdvisorRecommendationType type;
@override final  AdvisorSeverity severity;
@override final  int? amount;
@override final  double? ratio;
@override final  String? relatedName;
@override@JsonKey() final  bool isSalaryRelated;

/// Create a copy of AdvisorRecommendationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdvisorRecommendationModelCopyWith<_AdvisorRecommendationModel> get copyWith => __$AdvisorRecommendationModelCopyWithImpl<_AdvisorRecommendationModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdvisorRecommendationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.relatedName, relatedName) || other.relatedName == relatedName)&&(identical(other.isSalaryRelated, isSalaryRelated) || other.isSalaryRelated == isSalaryRelated));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,type,severity,amount,ratio,relatedName,isSalaryRelated);
}

@override
String toString() {
    return 'AdvisorRecommendationModel(id: $id, type: $type, severity: $severity, amount: $amount, ratio: $ratio, relatedName: $relatedName, isSalaryRelated: $isSalaryRelated)';
}


}

/// @nodoc
abstract mixin class _$AdvisorRecommendationModelCopyWith<$Res> implements $AdvisorRecommendationModelCopyWith<$Res> {
  factory _$AdvisorRecommendationModelCopyWith(_AdvisorRecommendationModel value, $Res Function(_AdvisorRecommendationModel) _then) = __$AdvisorRecommendationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, AdvisorRecommendationType type, AdvisorSeverity severity, int? amount, double? ratio, String? relatedName, bool isSalaryRelated
});




}
/// @nodoc
class __$AdvisorRecommendationModelCopyWithImpl<$Res>
    implements _$AdvisorRecommendationModelCopyWith<$Res> {
  __$AdvisorRecommendationModelCopyWithImpl(this._self, this._then);

  final _AdvisorRecommendationModel _self;
  final $Res Function(_AdvisorRecommendationModel) _then;

/// Create a copy of AdvisorRecommendationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? severity = null,Object? amount = freezed,Object? ratio = freezed,Object? relatedName = freezed,Object? isSalaryRelated = null,}) {
  return _then(_AdvisorRecommendationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AdvisorRecommendationType,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AdvisorSeverity,amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int?,ratio: freezed == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as double?,relatedName: freezed == relatedName ? _self.relatedName : relatedName // ignore: cast_nullable_to_non_nullable
as String?,isSalaryRelated: null == isSalaryRelated ? _self.isSalaryRelated : isSalaryRelated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
