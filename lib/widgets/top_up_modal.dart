// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fltr_easy_analyz/theme/design_system.dart';
// import 'package:fltr_easy_analyz/providers/network_connectivity_provider.dart';
// import 'package:go_router/go_router.dart';
// import 'package:permission_handler/permission_handler.dart';

// class TopUpModal extends ConsumerWidget {
//   const TopUpModal({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(networkConnectivityProvider);
//     final notifier = ref.read(networkConnectivityProvider.notifier);

//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 250),
//       switchInCurve: Curves.easeOut,
//       switchOutCurve: Curves.easeIn,
//       child: state.isModalVisible
//           ? _ModalContent(
//               isOnline: state.isOnline,
//               isChecking: state.isChecking,
//               onRefreshApp: () => _refreshApp(context),
//               onOpenSettings: _openNetworkSettings,
//               onRetry: notifier.retryCheck,
//             )
//           : const SizedBox.shrink(),
//     );
//   }

//   void _refreshApp(BuildContext context) {
//     // Веб: попытка перезагрузки страницы — навигации достаточно
//     if (kIsWeb) {
//       // Навигация на начальный маршрут
//       context.go('/');
//       return;
//     }
//     // Мобильные/десктоп: перезапуск навигации на начальный маршрут
//     context.go('/');
//   }

//   Future<void> _openNetworkSettings() async {
//     try {
//       // Универсальный переход в настройки приложения (часто достаточно для сети)
//       final opened = await openAppSettings();
//       if (!opened) {
//         debugPrint('[TopUpModal] Не удалось открыть настройки приложения');
//       }
//     } catch (e) {
//       debugPrint('[TopUpModal] Ошибка открытия настроек: $e');
//     }
//   }
// }

// class _ModalContent extends StatelessWidget {
//   const _ModalContent({
//     required this.isOnline,
//     required this.isChecking,
//     required this.onRefreshApp,
//     required this.onOpenSettings,
//     required this.onRetry,
//   });

//   final bool isOnline;
//   final bool isChecking;
//   final VoidCallback onRefreshApp;
//   final VoidCallback onOpenSettings;
//   final VoidCallback onRetry;

//   @override
//   Widget build(BuildContext context) {
//     return Positioned.fill(
//       child: IgnorePointer(
//         ignoring: false,
//         child: AnimatedOpacity(
//           opacity: 1.0,
//           duration: const Duration(milliseconds: 200),
//           child: Container(
//             color: Colors.black.withOpacity(0.3),
//             alignment: Alignment.center,
//             child: SafeArea(
//               child: LayoutBuilder(
//                 builder: (ctx, constraints) {
//                   final double maxWidth = constraints.maxWidth;
//                   final double dialogW = maxWidth < 420
//                       ? maxWidth * 0.92
//                       : AppDesignSystem.dialogWidth;

//                   return Container(
//                     width: dialogW,
//                     padding: const EdgeInsets.all(AppDesignSystem.dialogPadding),
//                     decoration: BoxDecoration(
//                       color: AppDesignSystem.dialogBackgroundColor,
//                       borderRadius: BorderRadius.circular(
//                           AppDesignSystem.dialogBorderRadius),
//                       boxShadow: const [AppDesignSystem.cardShadow],
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               isOnline ? Icons.wifi : Icons.wifi_off,
//                               color: isOnline
//                                   ? AppDesignSystem.successColor
//                                   : AppDesignSystem.errorColor,
//                               size: AppDesignSystem.dialogIconSize,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               isOnline ? 'Онлайн' : 'Оффлайн',
//                               style: AppDesignSystem.dialogTitleText,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           isOnline
//                               ? 'Соединение восстановлено'
//                               : 'Проблема с интернет-соединением. Проверьте настройки сети.',
//                           style: AppDesignSystem.dialogBodyText,
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 onPressed: isOnline ? null : onRefreshApp,
//                                 style: AppDesignSystem.primaryButtonStyle,
//                                 child: const Text('Обновить приложение'),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: onOpenSettings,
//                                 style: AppDesignSystem.secondaryButtonStyle,
//                                 child: const Text('Настройки сети'),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: OutlinedButton(
//                                 onPressed: isChecking ? null : onRetry,
//                                 style: AppDesignSystem.secondaryButtonStyle,
//                                 child:
//                                     Text(isChecking ? 'Проверяем…' : 'Повторить'),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
