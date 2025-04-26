// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeStateImpl _$$HomeStateImplFromJson(Map<String, dynamic> json) =>
    _$HomeStateImpl(
      filters:
          (json['filters'] as List<dynamic>).map((e) => e as String).toList(),
      sometings: (json['sometings'] as List<dynamic>)
          .map((e) => SomeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$HomeStateImplToJson(_$HomeStateImpl instance) =>
    <String, dynamic>{
      'filters': instance.filters,
      'sometings': instance.sometings,
    };
