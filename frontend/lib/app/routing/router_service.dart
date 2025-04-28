import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/feature/error/error_page.dart';
import 'package:template/app/feature/home/home_page.dart';
import 'package:template/app/feature/login/login_page.dart';
import 'package:template/app/feature/register/record_register_page.dart';
import 'package:template/app/feature/register/register_page.dart';
import 'package:template/app/feature/chat/chat_page.dart';
import 'package:template/app/feature/record/add_record_page.dart';

extension GoRouterX on GoRouter {
  BuildContext? get context => configuration.navigatorKey.currentContext;
  OverlayState? get overlayState {
    final context = this.context;
    if (context == null) return null;
    return Overlay.of(context);
  }

  Uri get currentUri {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri;
  }
}

abstract class Routes {
  static const String home = '/';
  static const String error = '/error';
  static const String login = '/login';
  static const String register = '/register';
  static const String recorderRegister = '/recorder_register';
  static const String chat = '/chat';
  static const String addRecord = '/record';
}

class RouterService {
  static RouterService get I => GetIt.I<RouterService>();

  late final GoRouter router;

  String? queryParameter(String key) => router.currentUri.queryParameters[key];

  void init() {
    router = GoRouter(
      initialLocation: Routes.login,
      routes: [
        GoRoute(
          path: Routes.login,
          builder: (context, state) {
            return const LoginPage();
          },
        ),
        GoRoute(
            path: Routes.register,
            builder: (context, state) {
              return const RegisterPage();
            }),
        GoRoute(
          path: Routes.recorderRegister,
          builder: (context, state) {
            // var args = state.extra;
            return const RecorderRegisterPage();
          },
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            // var args = state.extra;
            return const HomePage();
          },
        ),
        GoRoute(
          path: Routes.addRecord,
          builder: (context, state) {
            // var args = state.extra;
            return const AddRecordPage();
          },
        ),
        GoRoute(
          path: Routes.chat,
          builder: (context, state) {
            // var args = state.extra;
            return const ChatPage();
          },
        ),
      ], // TODO: Add routes

      errorBuilder: (context, state) {
        return const ErrorPage();
      },
    );
  }
}
