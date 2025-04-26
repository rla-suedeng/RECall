import 'package:freezed_annotation/freezed_annotation.dart';

part 'some_model.freezed.dart';
part 'some_model.g.dart';

@freezed
class SomeModel with _$SomeModel {
  factory SomeModel({
    required int id,
    required String name,
  }) = _SomeModel;

  factory SomeModel.fromJson(Map<String, dynamic> json) =>
      _$SomeModelFromJson(json);
}
