import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:template/app/model/some_model.dart';

part 'home_state.freezed.dart';
part 'home_state.g.dart';

@freezed
class HomeState with _$HomeState {
  factory HomeState({
    required List<String> filters,
    required List<SomeModel> sometings,
  }) = _HomeState;

  factory HomeState.fromJson(Map<String, dynamic> json) =>
      _$HomeStateFromJson(json);
}
