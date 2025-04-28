// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'some_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SomeModel _$SomeModelFromJson(Map<String, dynamic> json) {
  return _SomeModel.fromJson(json);
}

/// @nodoc
mixin _$SomeModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this SomeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SomeModelCopyWith<SomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SomeModelCopyWith<$Res> {
  factory $SomeModelCopyWith(SomeModel value, $Res Function(SomeModel) then) =
      _$SomeModelCopyWithImpl<$Res, SomeModel>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$SomeModelCopyWithImpl<$Res, $Val extends SomeModel>
    implements $SomeModelCopyWith<$Res> {
  _$SomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SomeModelImplCopyWith<$Res>
    implements $SomeModelCopyWith<$Res> {
  factory _$$SomeModelImplCopyWith(
          _$SomeModelImpl value, $Res Function(_$SomeModelImpl) then) =
      __$$SomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$SomeModelImplCopyWithImpl<$Res>
    extends _$SomeModelCopyWithImpl<$Res, _$SomeModelImpl>
    implements _$$SomeModelImplCopyWith<$Res> {
  __$$SomeModelImplCopyWithImpl(
      _$SomeModelImpl _value, $Res Function(_$SomeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$SomeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SomeModelImpl implements _SomeModel {
  _$SomeModelImpl({required this.id, required this.name});

  factory _$SomeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SomeModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'SomeModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SomeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of SomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SomeModelImplCopyWith<_$SomeModelImpl> get copyWith =>
      __$$SomeModelImplCopyWithImpl<_$SomeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SomeModelImplToJson(
      this,
    );
  }
}

abstract class _SomeModel implements SomeModel {
  factory _SomeModel({required final int id, required final String name}) =
      _$SomeModelImpl;

  factory _SomeModel.fromJson(Map<String, dynamic> json) =
      _$SomeModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;

  /// Create a copy of SomeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SomeModelImplCopyWith<_$SomeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
