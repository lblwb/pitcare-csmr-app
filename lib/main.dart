import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pit_care/routes/app_routes.dart';
import 'package:pit_care/sevices/permissions_service.dart';
//
import 'package:go_router/go_router.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализируем Hive с новыми моделями
  // await HiveService.init();

  // Инициализируем сервис уведомлений
  // await NotificationStorageService.init();

  // Загружаем переменные окружения из .env файла
  await dotenv.load(fileName: ".env");

  // Запрашиваем необходимые разрешения (например, уведомления)
  try {
    await PermissionsService.requestInitialPermissions();
  } catch (_) {
    // Игнорируем ошибки запроса прав на старте, чтобы не блокировать запуск
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      color: const Color(0xFF82A6A8),
      title: 'PitCare',
      theme: ThemeData(useMaterial3: false, fontFamily: 'Manrope'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
      routerConfig: AppRoutes.createRouter(ref),
      // Ленточка - debug вверху экрана!
      debugShowCheckedModeBanner: false,
    );
  }
}
