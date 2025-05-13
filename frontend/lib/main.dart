import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:template/app/api/dio_client.dart';
import 'package:template/app/auth/firebase_auth_service.dart';
import 'package:template/app/state/accessibility_settings.dart';

import 'package:dio/dio.dart';
import 'package:template/app/api/api_service.dart';
import 'package:template/app/api/user_api.dart';
import 'package:template/app/auth/auth_service.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/service/secure_storage_service.dart';

import 'package:template/app/models/user_model.dart';
import 'package:template/app/theme/theme_service.dart';

part 'service.dart';

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      await Service.initFlutter();
      await Service.initEnv();
      await Firebase.initializeApp();
      final serviceProviderContainer = Service.registerServices();

      RouterService.I.init();
      GetIt.I.registerSingleton<UserModel>(UserModel(
        uId: 'temp_uid',
        role: true, // Replace with appropriate role
        fName: 'John', // Replace with appropriate first name
        lName: 'Doe', // Replace with appropriate last name
        birthday: '2000-01-02', // Replace with appropriate birthday
        email: 'example@example.com', // Replace with appropriate email
      ));
      runApp(UncontrolledProviderScope(
        container: serviceProviderContainer,
        child: const App(),
      ));
    },
    (error, stackTrace) {
      log('runZonedGuarded: ', error: error, stackTrace: stackTrace);
      debugPrint('runZonedGuarded: $error');
    },
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AccessibilitySettings.highContrast,
      builder: (context, isHighContrast, _) {
        return MaterialApp.router(
          title: 'RECall',
          theme: isHighContrast
              ? AppThemes.highContrastTheme
              : AppThemes.lightTheme,
          routerConfig: RouterService.I.router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return ValueListenableBuilder<double>(
              valueListenable: AccessibilitySettings.textScaleFactor,
              builder: (context, scale, _) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: Overlay(
                    initialEntries: [
                      OverlayEntry(builder: (context) => child!),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
