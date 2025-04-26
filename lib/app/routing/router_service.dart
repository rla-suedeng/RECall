import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/feature/error/error_page.dart';
import 'package:template/app/feature/home/home_page.dart';

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
}

class RouterService {
  static RouterService get I => GetIt.I<RouterService>();

  late final GoRouter router;

  String? queryParameter(String key) => router.currentUri.queryParameters[key];

  void init() {
    router = GoRouter(
      initialLocation: Routes.home,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            // var args = state.extra;
            return const HomePage();
          },
        ),
      ], // TODO: Add routes

      errorBuilder: (context, state) {
        return const ErrorPage();
      },
    );
  }
}
