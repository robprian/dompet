// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt_scan_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReceiptScanResult {

/// Total amount detected on the receipt, if any.
 double? get amount;/// Merchant or counterparty name, if detected.
 String? get merchant;/// Transaction date detected on the receipt, if any.
 DateTime? get date;/// Free-text note assembled from the receipt header lines.
 String? get note;/// Raw OCR text, kept for debugging and optional AI refinement.
 String get rawText;
/// Create a copy of ReceiptScanResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReceiptScanResultCopyWith<ReceiptScanResult> get copyWith => _$ReceiptScanResultCopyWithImpl<ReceiptScanResult>(this as ReceiptScanResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReceiptScanResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReceiptScanResult&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.merchant, _this.merchant) || other.merchant == _this.merchant)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.rawText, _this.rawText) || other.rawText == _this.rawText));
}


@override
int get hashCode {
  final _this = this as ReceiptScanResult;
  return Object.hash(runtimeType,_this.amount,_this.merchant,_this.date,_this.note,_this.rawText);
}

@override
String toString() {
  final _this = this as ReceiptScanResult;
  return 'ReceiptScanResult(amount: ${_this.amount}, merchant: ${_this.merchant}, date: ${_this.date}, note: ${_this.note}, rawText: ${_this.rawText})';
}


}

/// @nodoc
abstract mixin class $ReceiptScanResultCopyWith<$Res>  {
  factory $ReceiptScanResultCopyWith(ReceiptScanResult value, $Res Function(ReceiptScanResult) _then) = _$ReceiptScanResultCopyWithImpl;
@useResult
$Res call({
 double? amount, String? merchant, DateTime? date, String? note, String rawText
});




}
/// @nodoc
class _$ReceiptScanResultCopyWithImpl<$Res>
    implements $ReceiptScanResultCopyWith<$Res> {
  _$ReceiptScanResultCopyWithImpl(this._self, this._then);

  final ReceiptScanResult _self;
  final $Res Function(ReceiptScanResult) _then;

/// Create a copy of ReceiptScanResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = freezed,Object? merchant = freezed,Object? date = freezed,Object? note = freezed,Object? rawText = null,}) {
  return _then(ReceiptScanResult(
amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReceiptScanResult].
extension ReceiptScanResultPatterns on ReceiptScanResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReceiptScanResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReceiptScanResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReceiptScanResult value)  $default,){
final _that = this;
switch (_that) {
case _ReceiptScanResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReceiptScanResult value)?  $default,){
final _that = this;
switch (_that) {
case _ReceiptScanResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? amount,  String? merchant,  DateTime? date,  String? note,  String rawText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReceiptScanResult() when $default != null:
return $default(_that.amount,_that.merchant,_that.date,_that.note,_that.rawText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? amount,  String? merchant,  DateTime? date,  String? note,  String rawText)  $default,) {final _that = this;
switch (_that) {
case _ReceiptScanResult():
return $default(_that.amount,_that.merchant,_that.date,_that.note,_that.rawText);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? amount,  String? merchant,  DateTime? date,  String? note,  String rawText)?  $default,) {final _that = this;
switch (_that) {
case _ReceiptScanResult() when $default != null:
return $default(_that.amount,_that.merchant,_that.date,_that.note,_that.rawText);case _:
  return null;

}
}

}

/// @nodoc


class _ReceiptScanResult extends ReceiptScanResult {
  const _ReceiptScanResult({this.amount, this.merchant, this.date, this.note, this.rawText = ''}): super._();
  

/// Total amount detected on the receipt, if any.
@override final  double? amount;
/// Merchant or counterparty name, if detected.
@override final  String? merchant;
/// Transaction date detected on the receipt, if any.
@override final  DateTime? date;
/// Free-text note assembled from the receipt header lines.
@override final  String? note;
/// Raw OCR text, kept for debugging and optional AI refinement.
@override@JsonKey() final  String rawText;

/// Create a copy of ReceiptScanResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReceiptScanResultCopyWith<_ReceiptScanResult> get copyWith => __$ReceiptScanResultCopyWithImpl<_ReceiptScanResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReceiptScanResult&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.rawText, rawText) || other.rawText == rawText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,amount,merchant,date,note,rawText);
}

@override
String toString() {
    return 'ReceiptScanResult(amount: $amount, merchant: $merchant, date: $date, note: $note, rawText: $rawText)';
}


}

/// @nodoc
abstract mixin class _$ReceiptScanResultCopyWith<$Res> implements $ReceiptScanResultCopyWith<$Res> {
  factory _$ReceiptScanResultCopyWith(_ReceiptScanResult value, $Res Function(_ReceiptScanResult) _then) = __$ReceiptScanResultCopyWithImpl;
@override @useResult
$Res call({
 double? amount, String? merchant, DateTime? date, String? note, String rawText
});




}
/// @nodoc
class __$ReceiptScanResultCopyWithImpl<$Res>
    implements _$ReceiptScanResultCopyWith<$Res> {
  __$ReceiptScanResultCopyWithImpl(this._self, this._then);

  final _ReceiptScanResult _self;
  final $Res Function(_ReceiptScanResult) _then;

/// Create a copy of ReceiptScanResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = freezed,Object? merchant = freezed,Object? date = freezed,Object? note = freezed,Object? rawText = null,}) {
  return _then(_ReceiptScanResult(
amount: freezed == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double?,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
