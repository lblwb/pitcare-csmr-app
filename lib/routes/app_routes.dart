import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pit_care/layout/main_layout.dart';
import 'package:pit_care/routes/auth_guard.dart';
import 'package:pit_care/routes/route_names.dart';
import 'package:pit_care/screens/auth/login.dart';
import 'package:pit_care/screens/garage/garage_screen.dart';
import 'package:pit_care/screens/home/home_screen.dart';
import 'package:pit_care/screens/map_view/map_view_screen.dart';
// import 'package:fltr_easy_analyz/providers/auth_providers.dart';
// import 'package:fltr_easy_analyz/models/auth_models.dart';

class AppRoutes {
  // Определяем начальный маршрут на основе DEBUG_MODE из .env
  static String get initialLocation {
    final debugMode = dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
    return debugMode ? RouteNames.home : RouteNames.login;
  }

  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) => AuthGuard.redirect(context, state, ref),
      routes: [
        GoRoute(
          path: RouteNames.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        //
        //
        ShellRoute(
          builder: (context, state, child) {
            return MainLayout(child: child);
          },
          routes: [
            GoRoute(
              path: RouteNames.home,
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: RouteNames.garage,
              name: 'garage',
              builder: (context, state) => const GarageScreen(),
            ),
            GoRoute(
              path: RouteNames.addresses,
              name: 'addresses',
              builder: (context, state) => const MapViewScreen(),
            ),
            GoRoute(
              path: RouteNames.settings,
              name: 'settings',
              builder: (context, state) => const HomeScreen(),
            ),

            //
          ],
        ),
      ],
      debugLogDiagnostics: true,
    );
  }
}
