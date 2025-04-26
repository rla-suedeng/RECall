import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';
part 'auth_state.g.dart';

final authStateProvider = NotifierProvider<_AuthStateNotifier, AuthState>(
  _AuthStateNotifier.new,
);

class _AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState(isLoggedIn: false);
  }
}

@freezed
class AuthState with _$AuthState {
  factory AuthState({
    required bool isLoggedIn,
    String? accessToken,
    String? refreshToken,
  }) = _AuthState;

  factory AuthState.fromJson(Map<String, dynamic> json) =>
      _$AuthStateFromJson(json);
}
