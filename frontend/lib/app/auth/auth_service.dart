import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:template/app/api/api_service.dart';
import 'package:template/app/auth/auth_state.dart';
import 'package:template/app/service/secure_storage_service.dart';

class AuthService {
  static AuthService get I => GetIt.I<AuthService>();

  late final ProviderContainer container;
  final ApiService _api;
  final SecureStorageService secureStorageService;

  AuthState get state => container.read(authStateProvider);

  AuthService({
    required ApiService api,
    required this.secureStorageService,
    required this.container,
  }) : _api = api {
    _api.setAuthService(this);
  }

  Future<void> refreshAccessToken() async {
    throw UnimplementedError(); // TODO
  }

  Future<void> handleTokenExpiration() async {
    throw UnimplementedError(); // TODO
  }
}
