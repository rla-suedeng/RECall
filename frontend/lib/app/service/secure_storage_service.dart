import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

class SecureStorageService {
  static SecureStorageService get I => GetIt.I<SecureStorageService>();

  late final FlutterSecureStorage secureStorage;

  Future<String?> get accessToken => secureStorage.read(key: "jwtAccessToken");
  Future<String?> get refreshToken =>
      secureStorage.read(key: "jwtRefreshToken");

  void init() {
    secureStorage = const FlutterSecureStorage();
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      secureStorage.write(key: "jwtAccessToken", value: accessToken),
      secureStorage.write(key: "jwtRefreshToken", value: refreshToken),
    ]);
  }

  Future<void> deleteAll() async {
    await secureStorage.deleteAll();
  }
}
