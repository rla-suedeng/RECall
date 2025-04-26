import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:template/app/api/api_service.dart';
import 'package:template/app/auth/auth_service.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/service/secure_storage_service.dart';

part 'service.dart';

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      await Service.initFlutter();
      await Service.initEnv();
      final serviceProviderContainer = Service.registerServices();

      //final router = RouterService.I.router;

      runApp(UncontrolledProviderScope(
        container: serviceProviderContainer,
        child: MaterialApp.router(
          title: 'RECall',
          theme: ThemeData(
            textTheme: GoogleFonts.quicksandTextTheme(),
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFFE67553)),
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
        ),
      ));
    },
    (error, stackTrace) {
      log('runZonedGuarded: ', error: error, stackTrace: stackTrace);
      debugPrint('runZonedGuarded: $error');
    },
  );
}
