// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detection_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionDetectionModel {

 String get id; String get fingerprint; String get sourcePackage; DetectionTransactionType get type; int get amount; double get confidence; ConfidenceTier get confidenceTier; PaymentMethod get method; String get parserVersion; DetectionStatus get status; DateTime get occurredAt; DateTime get createdAt; String? get merchant; String? get counterparty; String? get referenceId; String? get categoryId; String? get accountId;
/// Create a copy of TransactionDetectionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionDetectionModelCopyWith<TransactionDetectionModel> get copyWith => _$TransactionDetectionModelCopyWithImpl<TransactionDetectionModel>(this as TransactionDetectionModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransactionDetectionModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionDetectionModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fingerprint, _this.fingerprint) || other.fingerprint == _this.fingerprint)&&(identical(other.sourcePackage, _this.sourcePackage) || other.sourcePackage == _this.sourcePackage)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.confidenceTier, _this.confidenceTier) || other.confidenceTier == _this.confidenceTier)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.parserVersion, _this.parserVersion) || other.parserVersion == _this.parserVersion)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.merchant, _this.merchant) || other.merchant == _this.merchant)&&(identical(other.counterparty, _this.counterparty) || other.counterparty == _this.counterparty)&&(identical(other.referenceId, _this.referenceId) || other.referenceId == _this.referenceId)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId));
}


@override
int get hashCode {
  final _this = this as TransactionDetectionModel;
  return Object.hash(runtimeType,_this.id,_this.fingerprint,_this.sourcePackage,_this.type,_this.amount,_this.confidence,_this.confidenceTier,_this.method,_this.parserVersion,_this.status,_this.occurredAt,_this.createdAt,_this.merchant,_this.counterparty,_this.referenceId,_this.categoryId,_this.accountId);
}

@override
String toString() {
  final _this = this as TransactionDetectionModel;
  return 'TransactionDetectionModel(id: ${_this.id}, fingerprint: ${_this.fingerprint}, sourcePackage: ${_this.sourcePackage}, type: ${_this.type}, amount: ${_this.amount}, confidence: ${_this.confidence}, confidenceTier: ${_this.confidenceTier}, method: ${_this.method}, parserVersion: ${_this.parserVersion}, status: ${_this.status}, occurredAt: ${_this.occurredAt}, createdAt: ${_this.createdAt}, merchant: ${_this.merchant}, counterparty: ${_this.counterparty}, referenceId: ${_this.referenceId}, categoryId: ${_this.categoryId}, accountId: ${_this.accountId})';
}


}

/// @nodoc
abstract mixin class $TransactionDetectionModelCopyWith<$Res>  {
  factory $TransactionDetectionModelCopyWith(TransactionDetectionModel value, $Res Function(TransactionDetectionModel) _then) = _$TransactionDetectionModelCopyWithImpl;
@useResult
$Res call({
 String id, String fingerprint, String sourcePackage, DetectionTransactionType type, int amount, double confidence, ConfidenceTier confidenceTier, PaymentMethod method, String parserVersion, DetectionStatus status, DateTime occurredAt, DateTime createdAt, String? merchant, String? counterparty, String? referenceId, String? categoryId, String? accountId
});




}
/// @nodoc
class _$TransactionDetectionModelCopyWithImpl<$Res>
    implements $TransactionDetectionModelCopyWith<$Res> {
  _$TransactionDetectionModelCopyWithImpl(this._self, this._then);

  final TransactionDetectionModel _self;
  final $Res Function(TransactionDetectionModel) _then;

/// Create a copy of TransactionDetectionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fingerprint = null,Object? sourcePackage = null,Object? type = null,Object? amount = null,Object? confidence = null,Object? confidenceTier = null,Object? method = null,Object? parserVersion = null,Object? status = null,Object? occurredAt = null,Object? createdAt = null,Object? merchant = freezed,Object? counterparty = freezed,Object? referenceId = freezed,Object? categoryId = freezed,Object? accountId = freezed,}) {
  return _then(TransactionDetectionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,sourcePackage: null == sourcePackage ? _self.sourcePackage : sourcePackage // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DetectionTransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,confidenceTier: null == confidenceTier ? _self.confidenceTier : confidenceTier // ignore: cast_nullable_to_non_nullable
as ConfidenceTier,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,parserVersion: null == parserVersion ? _self.parserVersion : parserVersion // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DetectionStatus,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,counterparty: freezed == counterparty ? _self.counterparty : counterparty // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionDetectionModel].
extension TransactionDetectionModelPatterns on TransactionDetectionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionDetectionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionDetectionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionDetectionModel value)  $default,){
final _that = this;
switch (_that) {
case _TransactionDetectionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionDetectionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionDetectionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fingerprint,  String sourcePackage,  DetectionTransactionType type,  int amount,  double confidence,  ConfidenceTier confidenceTier,  PaymentMethod method,  String parserVersion,  DetectionStatus status,  DateTime occurredAt,  DateTime createdAt,  String? merchant,  String? counterparty,  String? referenceId,  String? categoryId,  String? accountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionDetectionModel() when $default != null:
return $default(_that.id,_that.fingerprint,_that.sourcePackage,_that.type,_that.amount,_that.confidence,_that.confidenceTier,_that.method,_that.parserVersion,_that.status,_that.occurredAt,_that.createdAt,_that.merchant,_that.counterparty,_that.referenceId,_that.categoryId,_that.accountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fingerprint,  String sourcePackage,  DetectionTransactionType type,  int amount,  double confidence,  ConfidenceTier confidenceTier,  PaymentMethod method,  String parserVersion,  DetectionStatus status,  DateTime occurredAt,  DateTime createdAt,  String? merchant,  String? counterparty,  String? referenceId,  String? categoryId,  String? accountId)  $default,) {final _that = this;
switch (_that) {
case _TransactionDetectionModel():
return $default(_that.id,_that.fingerprint,_that.sourcePackage,_that.type,_that.amount,_that.confidence,_that.confidenceTier,_that.method,_that.parserVersion,_that.status,_that.occurredAt,_that.createdAt,_that.merchant,_that.counterparty,_that.referenceId,_that.categoryId,_that.accountId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fingerprint,  String sourcePackage,  DetectionTransactionType type,  int amount,  double confidence,  ConfidenceTier confidenceTier,  PaymentMethod method,  String parserVersion,  DetectionStatus status,  DateTime occurredAt,  DateTime createdAt,  String? merchant,  String? counterparty,  String? referenceId,  String? categoryId,  String? accountId)?  $default,) {final _that = this;
switch (_that) {
case _TransactionDetectionModel() when $default != null:
return $default(_that.id,_that.fingerprint,_that.sourcePackage,_that.type,_that.amount,_that.confidence,_that.confidenceTier,_that.method,_that.parserVersion,_that.status,_that.occurredAt,_that.createdAt,_that.merchant,_that.counterparty,_that.referenceId,_that.categoryId,_that.accountId);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionDetectionModel extends TransactionDetectionModel {
  const _TransactionDetectionModel({required this.id, required this.fingerprint, required this.sourcePackage, required this.type, required this.amount, required this.confidence, required this.confidenceTier, required this.method, required this.parserVersion, required this.status, required this.occurredAt, required this.createdAt, this.merchant, this.counterparty, this.referenceId, this.categoryId, this.accountId}): super._();
  

@override final  String id;
@override final  String fingerprint;
@override final  String sourcePackage;
@override final  DetectionTransactionType type;
@override final  int amount;
@override final  double confidence;
@override final  ConfidenceTier confidenceTier;
@override final  PaymentMethod method;
@override final  String parserVersion;
@override final  DetectionStatus status;
@override final  DateTime occurredAt;
@override final  DateTime createdAt;
@override final  String? merchant;
@override final  String? counterparty;
@override final  String? referenceId;
@override final  String? categoryId;
@override final  String? accountId;

/// Create a copy of TransactionDetectionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionDetectionModelCopyWith<_TransactionDetectionModel> get copyWith => __$TransactionDetectionModelCopyWithImpl<_TransactionDetectionModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionDetectionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint)&&(identical(other.sourcePackage, sourcePackage) || other.sourcePackage == sourcePackage)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.confidenceTier, confidenceTier) || other.confidenceTier == confidenceTier)&&(identical(other.method, method) || other.method == method)&&(identical(other.parserVersion, parserVersion) || other.parserVersion == parserVersion)&&(identical(other.status, status) || other.status == status)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.counterparty, counterparty) || other.counterparty == counterparty)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,fingerprint,sourcePackage,type,amount,confidence,confidenceTier,method,parserVersion,status,occurredAt,createdAt,merchant,counterparty,referenceId,categoryId,accountId);
}

@override
String toString() {
    return 'TransactionDetectionModel(id: $id, fingerprint: $fingerprint, sourcePackage: $sourcePackage, type: $type, amount: $amount, confidence: $confidence, confidenceTier: $confidenceTier, method: $method, parserVersion: $parserVersion, status: $status, occurredAt: $occurredAt, createdAt: $createdAt, merchant: $merchant, counterparty: $counterparty, referenceId: $referenceId, categoryId: $categoryId, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class _$TransactionDetectionModelCopyWith<$Res> implements $TransactionDetectionModelCopyWith<$Res> {
  factory _$TransactionDetectionModelCopyWith(_TransactionDetectionModel value, $Res Function(_TransactionDetectionModel) _then) = __$TransactionDetectionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String fingerprint, String sourcePackage, DetectionTransactionType type, int amount, double confidence, ConfidenceTier confidenceTier, PaymentMethod method, String parserVersion, DetectionStatus status, DateTime occurredAt, DateTime createdAt, String? merchant, String? counterparty, String? referenceId, String? categoryId, String? accountId
});




}
/// @nodoc
class __$TransactionDetectionModelCopyWithImpl<$Res>
    implements _$TransactionDetectionModelCopyWith<$Res> {
  __$TransactionDetectionModelCopyWithImpl(this._self, this._then);

  final _TransactionDetectionModel _self;
  final $Res Function(_TransactionDetectionModel) _then;

/// Create a copy of TransactionDetectionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fingerprint = null,Object? sourcePackage = null,Object? type = null,Object? amount = null,Object? confidence = null,Object? confidenceTier = null,Object? method = null,Object? parserVersion = null,Object? status = null,Object? occurredAt = null,Object? createdAt = null,Object? merchant = freezed,Object? counterparty = freezed,Object? referenceId = freezed,Object? categoryId = freezed,Object? accountId = freezed,}) {
  return _then(_TransactionDetectionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,sourcePackage: null == sourcePackage ? _self.sourcePackage : sourcePackage // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DetectionTransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,confidenceTier: null == confidenceTier ? _self.confidenceTier : confidenceTier // ignore: cast_nullable_to_non_nullable
as ConfidenceTier,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,parserVersion: null == parserVersion ? _self.parserVersion : parserVersion // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DetectionStatus,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,counterparty: freezed == counterparty ? _self.counterparty : counterparty // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SalaryProfileModel {

 String get id; int get amount; int get dayOfMonth; double get averageConfidence; int get occurrenceCount; DateTime? get lastDetectedAt;
/// Create a copy of SalaryProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalaryProfileModelCopyWith<SalaryProfileModel> get copyWith => _$SalaryProfileModelCopyWithImpl<SalaryProfileModel>(this as SalaryProfileModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SalaryProfileModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalaryProfileModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.dayOfMonth, _this.dayOfMonth) || other.dayOfMonth == _this.dayOfMonth)&&(identical(other.averageConfidence, _this.averageConfidence) || other.averageConfidence == _this.averageConfidence)&&(identical(other.occurrenceCount, _this.occurrenceCount) || other.occurrenceCount == _this.occurrenceCount)&&(identical(other.lastDetectedAt, _this.lastDetectedAt) || other.lastDetectedAt == _this.lastDetectedAt));
}


@override
int get hashCode {
  final _this = this as SalaryProfileModel;
  return Object.hash(runtimeType,_this.id,_this.amount,_this.dayOfMonth,_this.averageConfidence,_this.occurrenceCount,_this.lastDetectedAt);
}

@override
String toString() {
  final _this = this as SalaryProfileModel;
  return 'SalaryProfileModel(id: ${_this.id}, amount: ${_this.amount}, dayOfMonth: ${_this.dayOfMonth}, averageConfidence: ${_this.averageConfidence}, occurrenceCount: ${_this.occurrenceCount}, lastDetectedAt: ${_this.lastDetectedAt})';
}


}

/// @nodoc
abstract mixin class $SalaryProfileModelCopyWith<$Res>  {
  factory $SalaryProfileModelCopyWith(SalaryProfileModel value, $Res Function(SalaryProfileModel) _then) = _$SalaryProfileModelCopyWithImpl;
@useResult
$Res call({
 String id, int amount, int dayOfMonth, double averageConfidence, int occurrenceCount, DateTime? lastDetectedAt
});




}
/// @nodoc
class _$SalaryProfileModelCopyWithImpl<$Res>
    implements $SalaryProfileModelCopyWith<$Res> {
  _$SalaryProfileModelCopyWithImpl(this._self, this._then);

  final SalaryProfileModel _self;
  final $Res Function(SalaryProfileModel) _then;

/// Create a copy of SalaryProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? dayOfMonth = null,Object? averageConfidence = null,Object? occurrenceCount = null,Object? lastDetectedAt = freezed,}) {
  return _then(SalaryProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,averageConfidence: null == averageConfidence ? _self.averageConfidence : averageConfidence // ignore: cast_nullable_to_non_nullable
as double,occurrenceCount: null == occurrenceCount ? _self.occurrenceCount : occurrenceCount // ignore: cast_nullable_to_non_nullable
as int,lastDetectedAt: freezed == lastDetectedAt ? _self.lastDetectedAt : lastDetectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalaryProfileModel].
extension SalaryProfileModelPatterns on SalaryProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalaryProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalaryProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalaryProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _SalaryProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalaryProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _SalaryProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int amount,  int dayOfMonth,  double averageConfidence,  int occurrenceCount,  DateTime? lastDetectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalaryProfileModel() when $default != null:
return $default(_that.id,_that.amount,_that.dayOfMonth,_that.averageConfidence,_that.occurrenceCount,_that.lastDetectedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int amount,  int dayOfMonth,  double averageConfidence,  int occurrenceCount,  DateTime? lastDetectedAt)  $default,) {final _that = this;
switch (_that) {
case _SalaryProfileModel():
return $default(_that.id,_that.amount,_that.dayOfMonth,_that.averageConfidence,_that.occurrenceCount,_that.lastDetectedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int amount,  int dayOfMonth,  double averageConfidence,  int occurrenceCount,  DateTime? lastDetectedAt)?  $default,) {final _that = this;
switch (_that) {
case _SalaryProfileModel() when $default != null:
return $default(_that.id,_that.amount,_that.dayOfMonth,_that.averageConfidence,_that.occurrenceCount,_that.lastDetectedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SalaryProfileModel extends SalaryProfileModel {
  const _SalaryProfileModel({required this.id, required this.amount, required this.dayOfMonth, required this.averageConfidence, required this.occurrenceCount, this.lastDetectedAt}): super._();
  

@override final  String id;
@override final  int amount;
@override final  int dayOfMonth;
@override final  double averageConfidence;
@override final  int occurrenceCount;
@override final  DateTime? lastDetectedAt;

/// Create a copy of SalaryProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalaryProfileModelCopyWith<_SalaryProfileModel> get copyWith => __$SalaryProfileModelCopyWithImpl<_SalaryProfileModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalaryProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dayOfMonth, dayOfMonth) || other.dayOfMonth == dayOfMonth)&&(identical(other.averageConfidence, averageConfidence) || other.averageConfidence == averageConfidence)&&(identical(other.occurrenceCount, occurrenceCount) || other.occurrenceCount == occurrenceCount)&&(identical(other.lastDetectedAt, lastDetectedAt) || other.lastDetectedAt == lastDetectedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,amount,dayOfMonth,averageConfidence,occurrenceCount,lastDetectedAt);
}

@override
String toString() {
    return 'SalaryProfileModel(id: $id, amount: $amount, dayOfMonth: $dayOfMonth, averageConfidence: $averageConfidence, occurrenceCount: $occurrenceCount, lastDetectedAt: $lastDetectedAt)';
}


}

/// @nodoc
abstract mixin class _$SalaryProfileModelCopyWith<$Res> implements $SalaryProfileModelCopyWith<$Res> {
  factory _$SalaryProfileModelCopyWith(_SalaryProfileModel value, $Res Function(_SalaryProfileModel) _then) = __$SalaryProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int amount, int dayOfMonth, double averageConfidence, int occurrenceCount, DateTime? lastDetectedAt
});




}
/// @nodoc
class __$SalaryProfileModelCopyWithImpl<$Res>
    implements _$SalaryProfileModelCopyWith<$Res> {
  __$SalaryProfileModelCopyWithImpl(this._self, this._then);

  final _SalaryProfileModel _self;
  final $Res Function(_SalaryProfileModel) _then;

/// Create a copy of SalaryProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? dayOfMonth = null,Object? averageConfidence = null,Object? occurrenceCount = null,Object? lastDetectedAt = freezed,}) {
  return _then(_SalaryProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,dayOfMonth: null == dayOfMonth ? _self.dayOfMonth : dayOfMonth // ignore: cast_nullable_to_non_nullable
as int,averageConfidence: null == averageConfidence ? _self.averageConfidence : averageConfidence // ignore: cast_nullable_to_non_nullable
as double,occurrenceCount: null == occurrenceCount ? _self.occurrenceCount : occurrenceCount // ignore: cast_nullable_to_non_nullable
as int,lastDetectedAt: freezed == lastDetectedAt ? _self.lastDetectedAt : lastDetectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
