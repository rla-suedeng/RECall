import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:template/app/auth/firebase_auth_service.dart';

import 'package:template/app/api/api_service.dart';
import 'package:template/app/auth/auth_service.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/service/secure_storage_service.dart';
import 'package:template/app/theme/colors.dart';

part 'service.dart';

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      await Service.initFlutter();
      await Service.initEnv();
      await Firebase.initializeApp();
      final serviceProviderContainer = Service.registerServices();

      RouterService.I.init();

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
    return MaterialApp.router(
      title: 'RECall',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.quicksandTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      routerConfig: RouterService.I.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (context) => child!),
          ],
        );
      },
    );
  }
}
