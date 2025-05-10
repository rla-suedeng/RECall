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
import 'package:template/app/feature/album/album_page.dart';
import 'package:template/app/feature/history/chat_history_page.dart';
import 'package:template/app/feature/user/profile_page.dart';
import 'package:template/app/feature/record/record_page.dart';
import 'package:template/app/models/rec_model.dart';

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
  static const String addRecord = '/add_record';
  static const String album = '/album';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String record = '/record';
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
        GoRoute(
          name: Routes.album,
          path: Routes.album,
          builder: (context, state) {
            final category =
                state.uri.queryParameters['category'] ?? 'All Categories';
            return AlbumPage(initialCategory: category);
          },
        ),
        GoRoute(
          name: Routes.history,
          path: Routes.history,
          builder: (context, state) {
            final recIdParam = state.uri.queryParameters['recId'];
            final recId = recIdParam != null ? int.tryParse(recIdParam) : null;
            return ChatHistoryPage(recId: recId);
          },
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) {
            // var args = state.extra;
            return const ProfilePage();
          },
        ),
        GoRoute(
          path: '/record/:id',
          name: Routes.record,
          pageBuilder: (context, state) {
            final recId = int.tryParse(state.pathParameters['id'] ?? '');
            return recId != null
                ? MaterialPage(child: RecordPage(recId: recId))
                : const MaterialPage(child: ErrorPage()); // 예외 처리
          },
        ),
      ], // TODO: Add routes

      errorBuilder: (context, state) {
        return const ErrorPage();
      },
    );
  }
}
