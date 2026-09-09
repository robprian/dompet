// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allocation_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AllocationConfig {

 int get needsPercent; int get savingsPercent; int get debtPercent; int get lifestylePercent; int get bufferPercent;
/// Create a copy of AllocationConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllocationConfigCopyWith<AllocationConfig> get copyWith => _$AllocationConfigCopyWithImpl<AllocationConfig>(this as AllocationConfig, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AllocationConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllocationConfig&&(identical(other.needsPercent, _this.needsPercent) || other.needsPercent == _this.needsPercent)&&(identical(other.savingsPercent, _this.savingsPercent) || other.savingsPercent == _this.savingsPercent)&&(identical(other.debtPercent, _this.debtPercent) || other.debtPercent == _this.debtPercent)&&(identical(other.lifestylePercent, _this.lifestylePercent) || other.lifestylePercent == _this.lifestylePercent)&&(identical(other.bufferPercent, _this.bufferPercent) || other.bufferPercent == _this.bufferPercent));
}


@override
int get hashCode {
  final _this = this as AllocationConfig;
  return Object.hash(runtimeType,_this.needsPercent,_this.savingsPercent,_this.debtPercent,_this.lifestylePercent,_this.bufferPercent);
}

@override
String toString() {
  final _this = this as AllocationConfig;
  return 'AllocationConfig(needsPercent: ${_this.needsPercent}, savingsPercent: ${_this.savingsPercent}, debtPercent: ${_this.debtPercent}, lifestylePercent: ${_this.lifestylePercent}, bufferPercent: ${_this.bufferPercent})';
}


}

/// @nodoc
abstract mixin class $AllocationConfigCopyWith<$Res>  {
  factory $AllocationConfigCopyWith(AllocationConfig value, $Res Function(AllocationConfig) _then) = _$AllocationConfigCopyWithImpl;
@useResult
$Res call({
 int needsPercent, int savingsPercent, int debtPercent, int lifestylePercent, int bufferPercent
});




}
/// @nodoc
class _$AllocationConfigCopyWithImpl<$Res>
    implements $AllocationConfigCopyWith<$Res> {
  _$AllocationConfigCopyWithImpl(this._self, this._then);

  final AllocationConfig _self;
  final $Res Function(AllocationConfig) _then;

/// Create a copy of AllocationConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? needsPercent = null,Object? savingsPercent = null,Object? debtPercent = null,Object? lifestylePercent = null,Object? bufferPercent = null,}) {
  return _then(AllocationConfig(
needsPercent: null == needsPercent ? _self.needsPercent : needsPercent // ignore: cast_nullable_to_non_nullable
as int,savingsPercent: null == savingsPercent ? _self.savingsPercent : savingsPercent // ignore: cast_nullable_to_non_nullable
as int,debtPercent: null == debtPercent ? _self.debtPercent : debtPercent // ignore: cast_nullable_to_non_nullable
as int,lifestylePercent: null == lifestylePercent ? _self.lifestylePercent : lifestylePercent // ignore: cast_nullable_to_non_nullable
as int,bufferPercent: null == bufferPercent ? _self.bufferPercent : bufferPercent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AllocationConfig].
extension AllocationConfigPatterns on AllocationConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllocationConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllocationConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllocationConfig value)  $default,){
final _that = this;
switch (_that) {
case _AllocationConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllocationConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AllocationConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int needsPercent,  int savingsPercent,  int debtPercent,  int lifestylePercent,  int bufferPercent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllocationConfig() when $default != null:
return $default(_that.needsPercent,_that.savingsPercent,_that.debtPercent,_that.lifestylePercent,_that.bufferPercent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int needsPercent,  int savingsPercent,  int debtPercent,  int lifestylePercent,  int bufferPercent)  $default,) {final _that = this;
switch (_that) {
case _AllocationConfig():
return $default(_that.needsPercent,_that.savingsPercent,_that.debtPercent,_that.lifestylePercent,_that.bufferPercent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int needsPercent,  int savingsPercent,  int debtPercent,  int lifestylePercent,  int bufferPercent)?  $default,) {final _that = this;
switch (_that) {
case _AllocationConfig() when $default != null:
return $default(_that.needsPercent,_that.savingsPercent,_that.debtPercent,_that.lifestylePercent,_that.bufferPercent);case _:
  return null;

}
}

}

/// @nodoc


class _AllocationConfig extends AllocationConfig {
  const _AllocationConfig({this.needsPercent = 50, this.savingsPercent = 20, this.debtPercent = 15, this.lifestylePercent = 10, this.bufferPercent = 5}): super._();
  

@override@JsonKey() final  int needsPercent;
@override@JsonKey() final  int savingsPercent;
@override@JsonKey() final  int debtPercent;
@override@JsonKey() final  int lifestylePercent;
@override@JsonKey() final  int bufferPercent;

/// Create a copy of AllocationConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllocationConfigCopyWith<_AllocationConfig> get copyWith => __$AllocationConfigCopyWithImpl<_AllocationConfig>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllocationConfig&&(identical(other.needsPercent, needsPercent) || other.needsPercent == needsPercent)&&(identical(other.savingsPercent, savingsPercent) || other.savingsPercent == savingsPercent)&&(identical(other.debtPercent, debtPercent) || other.debtPercent == debtPercent)&&(identical(other.lifestylePercent, lifestylePercent) || other.lifestylePercent == lifestylePercent)&&(identical(other.bufferPercent, bufferPercent) || other.bufferPercent == bufferPercent));
}


@override
int get hashCode {
    return Object.hash(runtimeType,needsPercent,savingsPercent,debtPercent,lifestylePercent,bufferPercent);
}

@override
String toString() {
    return 'AllocationConfig(needsPercent: $needsPercent, savingsPercent: $savingsPercent, debtPercent: $debtPercent, lifestylePercent: $lifestylePercent, bufferPercent: $bufferPercent)';
}


}

/// @nodoc
abstract mixin class _$AllocationConfigCopyWith<$Res> implements $AllocationConfigCopyWith<$Res> {
  factory _$AllocationConfigCopyWith(_AllocationConfig value, $Res Function(_AllocationConfig) _then) = __$AllocationConfigCopyWithImpl;
@override @useResult
$Res call({
 int needsPercent, int savingsPercent, int debtPercent, int lifestylePercent, int bufferPercent
});




}
/// @nodoc
class __$AllocationConfigCopyWithImpl<$Res>
    implements _$AllocationConfigCopyWith<$Res> {
  __$AllocationConfigCopyWithImpl(this._self, this._then);

  final _AllocationConfig _self;
  final $Res Function(_AllocationConfig) _then;

/// Create a copy of AllocationConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? needsPercent = null,Object? savingsPercent = null,Object? debtPercent = null,Object? lifestylePercent = null,Object? bufferPercent = null,}) {
  return _then(_AllocationConfig(
needsPercent: null == needsPercent ? _self.needsPercent : needsPercent // ignore: cast_nullable_to_non_nullable
as int,savingsPercent: null == savingsPercent ? _self.savingsPercent : savingsPercent // ignore: cast_nullable_to_non_nullable
as int,debtPercent: null == debtPercent ? _self.debtPercent : debtPercent // ignore: cast_nullable_to_non_nullable
as int,lifestylePercent: null == lifestylePercent ? _self.lifestylePercent : lifestylePercent // ignore: cast_nullable_to_non_nullable
as int,bufferPercent: null == bufferPercent ? _self.bufferPercent : bufferPercent // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AllocationPlanModel {

 int get income; int get needs; int get savings; int get debt; int get lifestyle; int get buffer;
/// Create a copy of AllocationPlanModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllocationPlanModelCopyWith<AllocationPlanModel> get copyWith => _$AllocationPlanModelCopyWithImpl<AllocationPlanModel>(this as AllocationPlanModel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AllocationPlanModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllocationPlanModel&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.needs, _this.needs) || other.needs == _this.needs)&&(identical(other.savings, _this.savings) || other.savings == _this.savings)&&(identical(other.debt, _this.debt) || other.debt == _this.debt)&&(identical(other.lifestyle, _this.lifestyle) || other.lifestyle == _this.lifestyle)&&(identical(other.buffer, _this.buffer) || other.buffer == _this.buffer));
}


@override
int get hashCode {
  final _this = this as AllocationPlanModel;
  return Object.hash(runtimeType,_this.income,_this.needs,_this.savings,_this.debt,_this.lifestyle,_this.buffer);
}

@override
String toString() {
  final _this = this as AllocationPlanModel;
  return 'AllocationPlanModel(income: ${_this.income}, needs: ${_this.needs}, savings: ${_this.savings}, debt: ${_this.debt}, lifestyle: ${_this.lifestyle}, buffer: ${_this.buffer})';
}


}

/// @nodoc
abstract mixin class $AllocationPlanModelCopyWith<$Res>  {
  factory $AllocationPlanModelCopyWith(AllocationPlanModel value, $Res Function(AllocationPlanModel) _then) = _$AllocationPlanModelCopyWithImpl;
@useResult
$Res call({
 int income, int needs, int savings, int debt, int lifestyle, int buffer
});




}
/// @nodoc
class _$AllocationPlanModelCopyWithImpl<$Res>
    implements $AllocationPlanModelCopyWith<$Res> {
  _$AllocationPlanModelCopyWithImpl(this._self, this._then);

  final AllocationPlanModel _self;
  final $Res Function(AllocationPlanModel) _then;

/// Create a copy of AllocationPlanModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? income = null,Object? needs = null,Object? savings = null,Object? debt = null,Object? lifestyle = null,Object? buffer = null,}) {
  return _then(AllocationPlanModel(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,needs: null == needs ? _self.needs : needs // ignore: cast_nullable_to_non_nullable
as int,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as int,debt: null == debt ? _self.debt : debt // ignore: cast_nullable_to_non_nullable
as int,lifestyle: null == lifestyle ? _self.lifestyle : lifestyle // ignore: cast_nullable_to_non_nullable
as int,buffer: null == buffer ? _self.buffer : buffer // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AllocationPlanModel].
extension AllocationPlanModelPatterns on AllocationPlanModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllocationPlanModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllocationPlanModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllocationPlanModel value)  $default,){
final _that = this;
switch (_that) {
case _AllocationPlanModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllocationPlanModel value)?  $default,){
final _that = this;
switch (_that) {
case _AllocationPlanModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int income,  int needs,  int savings,  int debt,  int lifestyle,  int buffer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllocationPlanModel() when $default != null:
return $default(_that.income,_that.needs,_that.savings,_that.debt,_that.lifestyle,_that.buffer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int income,  int needs,  int savings,  int debt,  int lifestyle,  int buffer)  $default,) {final _that = this;
switch (_that) {
case _AllocationPlanModel():
return $default(_that.income,_that.needs,_that.savings,_that.debt,_that.lifestyle,_that.buffer);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int income,  int needs,  int savings,  int debt,  int lifestyle,  int buffer)?  $default,) {final _that = this;
switch (_that) {
case _AllocationPlanModel() when $default != null:
return $default(_that.income,_that.needs,_that.savings,_that.debt,_that.lifestyle,_that.buffer);case _:
  return null;

}
}

}

/// @nodoc


class _AllocationPlanModel extends AllocationPlanModel {
  const _AllocationPlanModel({required this.income, required this.needs, required this.savings, required this.debt, required this.lifestyle, required this.buffer}): super._();
  

@override final  int income;
@override final  int needs;
@override final  int savings;
@override final  int debt;
@override final  int lifestyle;
@override final  int buffer;

/// Create a copy of AllocationPlanModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllocationPlanModelCopyWith<_AllocationPlanModel> get copyWith => __$AllocationPlanModelCopyWithImpl<_AllocationPlanModel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllocationPlanModel&&(identical(other.income, income) || other.income == income)&&(identical(other.needs, needs) || other.needs == needs)&&(identical(other.savings, savings) || other.savings == savings)&&(identical(other.debt, debt) || other.debt == debt)&&(identical(other.lifestyle, lifestyle) || other.lifestyle == lifestyle)&&(identical(other.buffer, buffer) || other.buffer == buffer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,income,needs,savings,debt,lifestyle,buffer);
}

@override
String toString() {
    return 'AllocationPlanModel(income: $income, needs: $needs, savings: $savings, debt: $debt, lifestyle: $lifestyle, buffer: $buffer)';
}


}

/// @nodoc
abstract mixin class _$AllocationPlanModelCopyWith<$Res> implements $AllocationPlanModelCopyWith<$Res> {
  factory _$AllocationPlanModelCopyWith(_AllocationPlanModel value, $Res Function(_AllocationPlanModel) _then) = __$AllocationPlanModelCopyWithImpl;
@override @useResult
$Res call({
 int income, int needs, int savings, int debt, int lifestyle, int buffer
});




}
/// @nodoc
class __$AllocationPlanModelCopyWithImpl<$Res>
    implements _$AllocationPlanModelCopyWith<$Res> {
  __$AllocationPlanModelCopyWithImpl(this._self, this._then);

  final _AllocationPlanModel _self;
  final $Res Function(_AllocationPlanModel) _then;

/// Create a copy of AllocationPlanModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? needs = null,Object? savings = null,Object? debt = null,Object? lifestyle = null,Object? buffer = null,}) {
  return _then(_AllocationPlanModel(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,needs: null == needs ? _self.needs : needs // ignore: cast_nullable_to_non_nullable
as int,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as int,debt: null == debt ? _self.debt : debt // ignore: cast_nullable_to_non_nullable
as int,lifestyle: null == lifestyle ? _self.lifestyle : lifestyle // ignore: cast_nullable_to_non_nullable
as int,buffer: null == buffer ? _self.buffer : buffer // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
