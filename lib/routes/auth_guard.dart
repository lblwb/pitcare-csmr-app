import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '../providers/auth_providers.dart';
// import '../models/auth_models.dart';
import 'route_names.dart';

// Публичные маршруты, доступные без авторизации
const Set<String> _publicRoutes = {RouteNames.login, RouteNames.smsCode};

/// Guard для проверки авторизации пользователя
class AuthGuard {
  static String? redirect(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
  ) {
    // Проверяем DEBUG режим
    final isDebugMode = dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
    final isLoginRoute = state.matchedLocation == RouteNames.login;
    final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

    debugPrint('DEBUG: AuthGuard.redirect called');
    debugPrint('DEBUG: isDebugMode = $isDebugMode');
    debugPrint('DEBUG: isLoginRoute = $isLoginRoute');
    debugPrint('DEBUG: isPublicRoute = $isPublicRoute');
    debugPrint('DEBUG: current location = ${state.matchedLocation}');

    // В DEBUG режиме пропускаем авторизацию и переходим на главную
    if (isDebugMode && isLoginRoute) {
      debugPrint('DEBUG: Redirecting from login to home');
      return RouteNames.home;
    }

    // В DEBUG режиме разрешаем доступ ко всем страницам
    if (isDebugMode) {
      debugPrint('DEBUG: Debug mode - allowing access to all pages');
      return null;
    }

    // final authState = ref.read(authNotifierProvider);

    // // Если состояние загружается, не перенаправляем
    // if (authState.status == AuthStatus.loading) {
    //   return null;
    // }

    // // Если пользователь не авторизован и не на странице логина
    // if (authState.status != AuthStatus.authenticated && !isPublicRoute) {
    //   return RouteNames.login;
    // }

    // // Если пользователь авторизован и на странице логина
    // if (authState.status == AuthStatus.authenticated && isLoginRoute) {
    //   return RouteNames.home;
    // }

    // Во всех остальных случаях не перенаправляем
    return null;
  }
}

/// Wrapper для создания защищенных маршрутов
class AuthGuardWrapper extends ConsumerWidget {
  final Widget child;

  const AuthGuardWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Проверяем DEBUG режим
    final isDebugMode = dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

    // В DEBUG режиме сразу показываем контент без проверки авторизации
    if (isDebugMode) {
      return child;
    }

    // final authState = ref.watch(authNotifierProvider);

    // Показываем загрузку во время проверки авторизации
    // if (authState.status == AuthStatus.loading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    // Если пользователь не авторизован, показываем экран входа
    // if (authState.status != AuthStatus.authenticated) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     context.go(RouteNames.login);
    //   });
    //   return const SizedBox.shrink();
    // }

    // Пользователь авторизован, показываем контент
    return child;
  }
}
