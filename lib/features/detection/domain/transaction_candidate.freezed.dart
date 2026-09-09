// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_candidate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionCandidate {

 String get fingerprint; int get amount; DetectionTransactionType get type; PaymentMethod get method; double get confidence; ConfidenceTier get confidenceTier; DateTime get occurredAt; String get parserVersion; String get sourcePackage; String? get merchant; String? get counterparty; String? get referenceId; String? get maskedAccount; bool get likelySalary; String? get categoryHint; String get sourceText;
/// Create a copy of TransactionCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCandidateCopyWith<TransactionCandidate> get copyWith => _$TransactionCandidateCopyWithImpl<TransactionCandidate>(this as TransactionCandidate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TransactionCandidate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionCandidate&&(identical(other.fingerprint, _this.fingerprint) || other.fingerprint == _this.fingerprint)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&(identical(other.confidenceTier, _this.confidenceTier) || other.confidenceTier == _this.confidenceTier)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.parserVersion, _this.parserVersion) || other.parserVersion == _this.parserVersion)&&(identical(other.sourcePackage, _this.sourcePackage) || other.sourcePackage == _this.sourcePackage)&&(identical(other.merchant, _this.merchant) || other.merchant == _this.merchant)&&(identical(other.counterparty, _this.counterparty) || other.counterparty == _this.counterparty)&&(identical(other.referenceId, _this.referenceId) || other.referenceId == _this.referenceId)&&(identical(other.maskedAccount, _this.maskedAccount) || other.maskedAccount == _this.maskedAccount)&&(identical(other.likelySalary, _this.likelySalary) || other.likelySalary == _this.likelySalary)&&(identical(other.categoryHint, _this.categoryHint) || other.categoryHint == _this.categoryHint)&&(identical(other.sourceText, _this.sourceText) || other.sourceText == _this.sourceText));
}


@override
int get hashCode {
  final _this = this as TransactionCandidate;
  return Object.hash(runtimeType,_this.fingerprint,_this.amount,_this.type,_this.method,_this.confidence,_this.confidenceTier,_this.occurredAt,_this.parserVersion,_this.sourcePackage,_this.merchant,_this.counterparty,_this.referenceId,_this.maskedAccount,_this.likelySalary,_this.categoryHint,_this.sourceText);
}

@override
String toString() {
  final _this = this as TransactionCandidate;
  return 'TransactionCandidate(fingerprint: ${_this.fingerprint}, amount: ${_this.amount}, type: ${_this.type}, method: ${_this.method}, confidence: ${_this.confidence}, confidenceTier: ${_this.confidenceTier}, occurredAt: ${_this.occurredAt}, parserVersion: ${_this.parserVersion}, sourcePackage: ${_this.sourcePackage}, merchant: ${_this.merchant}, counterparty: ${_this.counterparty}, referenceId: ${_this.referenceId}, maskedAccount: ${_this.maskedAccount}, likelySalary: ${_this.likelySalary}, categoryHint: ${_this.categoryHint}, sourceText: ${_this.sourceText})';
}


}

/// @nodoc
abstract mixin class $TransactionCandidateCopyWith<$Res>  {
  factory $TransactionCandidateCopyWith(TransactionCandidate value, $Res Function(TransactionCandidate) _then) = _$TransactionCandidateCopyWithImpl;
@useResult
$Res call({
 String fingerprint, int amount, DetectionTransactionType type, PaymentMethod method, double confidence, ConfidenceTier confidenceTier, DateTime occurredAt, String parserVersion, String sourcePackage, String? merchant, String? counterparty, String? referenceId, String? maskedAccount, bool likelySalary, String? categoryHint, String sourceText
});




}
/// @nodoc
class _$TransactionCandidateCopyWithImpl<$Res>
    implements $TransactionCandidateCopyWith<$Res> {
  _$TransactionCandidateCopyWithImpl(this._self, this._then);

  final TransactionCandidate _self;
  final $Res Function(TransactionCandidate) _then;

/// Create a copy of TransactionCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fingerprint = null,Object? amount = null,Object? type = null,Object? method = null,Object? confidence = null,Object? confidenceTier = null,Object? occurredAt = null,Object? parserVersion = null,Object? sourcePackage = null,Object? merchant = freezed,Object? counterparty = freezed,Object? referenceId = freezed,Object? maskedAccount = freezed,Object? likelySalary = null,Object? categoryHint = freezed,Object? sourceText = null,}) {
  return _then(TransactionCandidate(
fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DetectionTransactionType,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,confidenceTier: null == confidenceTier ? _self.confidenceTier : confidenceTier // ignore: cast_nullable_to_non_nullable
as ConfidenceTier,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,parserVersion: null == parserVersion ? _self.parserVersion : parserVersion // ignore: cast_nullable_to_non_nullable
as String,sourcePackage: null == sourcePackage ? _self.sourcePackage : sourcePackage // ignore: cast_nullable_to_non_nullable
as String,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,counterparty: freezed == counterparty ? _self.counterparty : counterparty // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,maskedAccount: freezed == maskedAccount ? _self.maskedAccount : maskedAccount // ignore: cast_nullable_to_non_nullable
as String?,likelySalary: null == likelySalary ? _self.likelySalary : likelySalary // ignore: cast_nullable_to_non_nullable
as bool,categoryHint: freezed == categoryHint ? _self.categoryHint : categoryHint // ignore: cast_nullable_to_non_nullable
as String?,sourceText: null == sourceText ? _self.sourceText : sourceText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionCandidate].
extension TransactionCandidatePatterns on TransactionCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionCandidate value)  $default,){
final _that = this;
switch (_that) {
case _TransactionCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fingerprint,  int amount,  DetectionTransactionType type,  PaymentMethod method,  double confidence,  ConfidenceTier confidenceTier,  DateTime occurredAt,  String parserVersion,  String sourcePackage,  String? merchant,  String? counterparty,  String? referenceId,  String? maskedAccount,  bool likelySalary,  String? categoryHint,  String sourceText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionCandidate() when $default != null:
return $default(_that.fingerprint,_that.amount,_that.type,_that.method,_that.confidence,_that.confidenceTier,_that.occurredAt,_that.parserVersion,_that.sourcePackage,_that.merchant,_that.counterparty,_that.referenceId,_that.maskedAccount,_that.likelySalary,_that.categoryHint,_that.sourceText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fingerprint,  int amount,  DetectionTransactionType type,  PaymentMethod method,  double confidence,  ConfidenceTier confidenceTier,  DateTime occurredAt,  String parserVersion,  String sourcePackage,  String? merchant,  String? counterparty,  String? referenceId,  String? maskedAccount,  bool likelySalary,  String? categoryHint,  String sourceText)  $default,) {final _that = this;
switch (_that) {
case _TransactionCandidate():
return $default(_that.fingerprint,_that.amount,_that.type,_that.method,_that.confidence,_that.confidenceTier,_that.occurredAt,_that.parserVersion,_that.sourcePackage,_that.merchant,_that.counterparty,_that.referenceId,_that.maskedAccount,_that.likelySalary,_that.categoryHint,_that.sourceText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fingerprint,  int amount,  DetectionTransactionType type,  PaymentMethod method,  double confidence,  ConfidenceTier confidenceTier,  DateTime occurredAt,  String parserVersion,  String sourcePackage,  String? merchant,  String? counterparty,  String? referenceId,  String? maskedAccount,  bool likelySalary,  String? categoryHint,  String sourceText)?  $default,) {final _that = this;
switch (_that) {
case _TransactionCandidate() when $default != null:
return $default(_that.fingerprint,_that.amount,_that.type,_that.method,_that.confidence,_that.confidenceTier,_that.occurredAt,_that.parserVersion,_that.sourcePackage,_that.merchant,_that.counterparty,_that.referenceId,_that.maskedAccount,_that.likelySalary,_that.categoryHint,_that.sourceText);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionCandidate extends TransactionCandidate {
  const _TransactionCandidate({required this.fingerprint, required this.amount, required this.type, required this.method, required this.confidence, required this.confidenceTier, required this.occurredAt, required this.parserVersion, required this.sourcePackage, this.merchant, this.counterparty, this.referenceId, this.maskedAccount, this.likelySalary = false, this.categoryHint, this.sourceText = ''}): super._();
  

@override final  String fingerprint;
@override final  int amount;
@override final  DetectionTransactionType type;
@override final  PaymentMethod method;
@override final  double confidence;
@override final  ConfidenceTier confidenceTier;
@override final  DateTime occurredAt;
@override final  String parserVersion;
@override final  String sourcePackage;
@override final  String? merchant;
@override final  String? counterparty;
@override final  String? referenceId;
@override final  String? maskedAccount;
@override@JsonKey() final  bool likelySalary;
@override final  String? categoryHint;
@override@JsonKey() final  String sourceText;

/// Create a copy of TransactionCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCandidateCopyWith<_TransactionCandidate> get copyWith => __$TransactionCandidateCopyWithImpl<_TransactionCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionCandidate&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.type, type) || other.type == type)&&(identical(other.method, method) || other.method == method)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.confidenceTier, confidenceTier) || other.confidenceTier == confidenceTier)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.parserVersion, parserVersion) || other.parserVersion == parserVersion)&&(identical(other.sourcePackage, sourcePackage) || other.sourcePackage == sourcePackage)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.counterparty, counterparty) || other.counterparty == counterparty)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.maskedAccount, maskedAccount) || other.maskedAccount == maskedAccount)&&(identical(other.likelySalary, likelySalary) || other.likelySalary == likelySalary)&&(identical(other.categoryHint, categoryHint) || other.categoryHint == categoryHint)&&(identical(other.sourceText, sourceText) || other.sourceText == sourceText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,fingerprint,amount,type,method,confidence,confidenceTier,occurredAt,parserVersion,sourcePackage,merchant,counterparty,referenceId,maskedAccount,likelySalary,categoryHint,sourceText);
}

@override
String toString() {
    return 'TransactionCandidate(fingerprint: $fingerprint, amount: $amount, type: $type, method: $method, confidence: $confidence, confidenceTier: $confidenceTier, occurredAt: $occurredAt, parserVersion: $parserVersion, sourcePackage: $sourcePackage, merchant: $merchant, counterparty: $counterparty, referenceId: $referenceId, maskedAccount: $maskedAccount, likelySalary: $likelySalary, categoryHint: $categoryHint, sourceText: $sourceText)';
}


}

/// @nodoc
abstract mixin class _$TransactionCandidateCopyWith<$Res> implements $TransactionCandidateCopyWith<$Res> {
  factory _$TransactionCandidateCopyWith(_TransactionCandidate value, $Res Function(_TransactionCandidate) _then) = __$TransactionCandidateCopyWithImpl;
@override @useResult
$Res call({
 String fingerprint, int amount, DetectionTransactionType type, PaymentMethod method, double confidence, ConfidenceTier confidenceTier, DateTime occurredAt, String parserVersion, String sourcePackage, String? merchant, String? counterparty, String? referenceId, String? maskedAccount, bool likelySalary, String? categoryHint, String sourceText
});




}
/// @nodoc
class __$TransactionCandidateCopyWithImpl<$Res>
    implements _$TransactionCandidateCopyWith<$Res> {
  __$TransactionCandidateCopyWithImpl(this._self, this._then);

  final _TransactionCandidate _self;
  final $Res Function(_TransactionCandidate) _then;

/// Create a copy of TransactionCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fingerprint = null,Object? amount = null,Object? type = null,Object? method = null,Object? confidence = null,Object? confidenceTier = null,Object? occurredAt = null,Object? parserVersion = null,Object? sourcePackage = null,Object? merchant = freezed,Object? counterparty = freezed,Object? referenceId = freezed,Object? maskedAccount = freezed,Object? likelySalary = null,Object? categoryHint = freezed,Object? sourceText = null,}) {
  return _then(_TransactionCandidate(
fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as DetectionTransactionType,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as PaymentMethod,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,confidenceTier: null == confidenceTier ? _self.confidenceTier : confidenceTier // ignore: cast_nullable_to_non_nullable
as ConfidenceTier,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,parserVersion: null == parserVersion ? _self.parserVersion : parserVersion // ignore: cast_nullable_to_non_nullable
as String,sourcePackage: null == sourcePackage ? _self.sourcePackage : sourcePackage // ignore: cast_nullable_to_non_nullable
as String,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,counterparty: freezed == counterparty ? _self.counterparty : counterparty // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,maskedAccount: freezed == maskedAccount ? _self.maskedAccount : maskedAccount // ignore: cast_nullable_to_non_nullable
as String?,likelySalary: null == likelySalary ? _self.likelySalary : likelySalary // ignore: cast_nullable_to_non_nullable
as bool,categoryHint: freezed == categoryHint ? _self.categoryHint : categoryHint // ignore: cast_nullable_to_non_nullable
as String?,sourceText: null == sourceText ? _self.sourceText : sourceText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
