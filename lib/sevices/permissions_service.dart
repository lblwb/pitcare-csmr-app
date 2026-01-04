import 'dart:io' show Platform;

import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Единая точка входа для запросов на старте приложения
  static Future<void> requestInitialPermissions() async {
    // Запрос разрешений на уведомления (Android 13+ и iOS)
    await _requestNotificationPermission();

    // Если в будущем потребуется геолокация/камера/медиа — добавим здесь
  }

  static Future<void> _requestNotificationPermission() async {
    try {
      // На Android до 13 разрешение не требуется, вызов безопасен
      // На iOS вернет статус и покажет системный диалог при необходимости
      final status = await Permission.notification.request();

      // Дополнительно можем направить пользователя в настройки, если отказал навсегда
      if (status.isPermanentlyDenied) {
        // Открываем настройки приложения для включения уведомлений
        await openAppSettings();
      }
    } catch (_) {
      // Не блокируем запуск приложения из-за ошибок запроса разрешений
    }
  }
}