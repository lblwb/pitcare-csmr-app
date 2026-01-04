import 'package:flutter/material.dart';
//
import 'package:go_router/go_router.dart';
// import 'package:fltr_easy_analyz/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pit_care/components/ui/navigation/bottom_nav_bar.dart';
import 'package:pit_care/components/ui/navigation/custom_app_bar.dart';
import 'package:pit_care/routes/route_names.dart';
import 'package:pit_care/themes/design_system.dart';
// import 'package:pit_care/widgets/global_loading_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Router listener will be handled in build method
    _setupLoadingCallbacks();

    // Проверка региона при запуске приложения
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkRegionOnAppStart();
    // });

    // Запустить мониторинг сети через 10 секунд и только если пользователь авторизован
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(const Duration(seconds: 20), () {
    //     final isAuth = ref.read(isAuthenticatedProvider);
    //     if (isAuth) {
    //       // ref.read(networkConnectivityProvider.notifier).startMonitoring();
    //     }
    //   });
    // });
  }

  void _setupLoadingCallbacks() {
    // final loadingNotifier = ref.read(loadingProvider.notifier);

    // ApiService().setLoadingCallbacks(
    //   onLoadingStart: () {
    //     loadingNotifier.showLoading();
    //   },
    //   onLoadingEnd: () {
    //     loadingNotifier.hideLoading();
    //   },
    // );
  }

  @override
  void dispose() {
    // Router listener cleanup handled automatically
    super.dispose();
  }

  void _updateSelectedIndex() {
    final location = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
    int newIndex = 0;
    if (location == RouteNames.home) {
      newIndex = 0;
    } else if (location == RouteNames.garage) {
      newIndex = 1;
    } else if (location == RouteNames.addresses) {
      newIndex = 2;
    } else if (location == RouteNames.profile ||
        //Other pages profile
        // location == RouteNames.familyProfiles ||
        // location == RouteNames.myExaminations ||
        location == RouteNames.settings ||
        location == RouteNames.partnershipProgram ||
        location == RouteNames.aboutApp ||
        location == RouteNames.technicalSupport ||
        location == RouteNames.notificationSettings ||
        location == RouteNames.editProfile) {
      newIndex = 3;
    }
    if (_selectedIndex != newIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  /// Проверить регион при запуске приложения
  // Future<void> _checkRegionOnAppStart() async {
  //   try {
  //     await RegionCheckService.checkRegionOnAppStart(context, ref);
  //   } catch (e) {
  //     debugPrint('MainLayout: Ошибка при проверке региона при запуске: $e');
  //   }
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.garage);
        break;
      case 2:
        context.go(RouteNames.addresses);
        break;
      case 3:
        context.go(RouteNames.settings);
        break;
    }
  }

  Widget _buildBackArea(Widget child) {
    return Container(
      color: AppDesignSystem.backgroundColor,
      child: SafeArea(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateSelectedIndex();
    // Инициализируем/подписываемся на состояние сети через провайдер
    // final _ = ref.watch(networkConnectivityProvider);
    return _buildBackArea(
      Scaffold(
        // backgroundColor: Colors.white,
        extendBody: true,
        body: Stack(
          children: [
            // Основной контент
            widget.child,

            // Глобальный экран загрузки с максимальным z-index
            // const Positioned.fill(child: GlobalLoadingScreen()),

            // Модальное окно потери соединения (поверх всех слоев)
            // const TopUpModal(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
