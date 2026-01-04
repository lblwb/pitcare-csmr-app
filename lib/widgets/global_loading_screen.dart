// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/loading_provider.dart';

// /// Глобальный экран загрузки с логотипом по центру
// class GlobalLoadingScreen extends ConsumerWidget {
//   const GlobalLoadingScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isLoading = ref.watch(isLoadingProvider);
//     final loadingMessage = ref.watch(loadingMessageProvider);

//     if (!isLoading) {
//       return const SizedBox.shrink();
//     }

//     return Material(
//       // color: Colors.black.withOpacity(0.7),
//       color: Colors.white,
//       child: Container(
//         padding: const EdgeInsets.all(0),
//         width: double.infinity,
//         height: double.infinity,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Логотип с анимацией
//             Container(
//               padding: const EdgeInsets.all(0),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text.rich(
//                     TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'А',
//                           style: TextStyle(
//                             fontFamily: 'Open Sans',
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             fontStyle: FontStyle.italic,
//                             height: 1.25,
//                             letterSpacing: -0.5,
//                             color: Color(0xFF324349),
//                           ),
//                         ),
//                         TextSpan(
//                           text: 'П',
//                           style: TextStyle(
//                             fontFamily: 'Open Sans',
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             fontStyle: FontStyle.italic,
//                             height: 1.25,
//                             letterSpacing: -0.5,
//                             color: Color(0xFF3A8DA7),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Text(
//                   //   'Анализы',
//                   //   style: TextStyle(
//                   //     fontFamily: 'Manrope',
//                   //     fontWeight: FontWeight.w600,
//                   //     fontSize: 24,
//                   //     color: Color(0xFF324349),
//                   //   ),
//                   // ),
//                   // Text(
//                   //   'Просто',
//                   //   style: TextStyle(
//                   //     fontFamily: 'Manrope',
//                   //     fontWeight: FontWeight.w600,
//                   //     fontSize: 24,
//                   //     color: Color(0xFF3A8DA7),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Анимированный логотип для экрана загрузки
// class AnimatedLogo extends StatefulWidget {
//   final double size;
//   final Color backgroundColor;
//   final Color iconColor;

//   const AnimatedLogo({
//     super.key,
//     this.size = 120,
//     this.backgroundColor = Colors.white,
//     this.iconColor = Colors.blue,
//   });

//   @override
//   State<AnimatedLogo> createState() => _AnimatedLogoState();
// }

// class _AnimatedLogoState extends State<AnimatedLogo>
//     with TickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late AnimationController _rotationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _rotationAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Анимация масштабирования
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
//       CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
//     );

//     // Анимация вращения
//     _rotationController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _rotationController, curve: Curves.linear),
//     );

//     // Запускаем анимации
//     _scaleController.repeat(reverse: true);
//     _rotationController.repeat();
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     _rotationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Transform.rotate(
//             angle: _rotationAnimation.value * 2 * 3.14159,
//             child: Container(
//               width: widget.size,
//               height: widget.size,
//               decoration: BoxDecoration(
//                 color: widget.backgroundColor,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//               child: Icon(
//                 Icons.analytics_outlined,
//                 size: widget.size * 0.5,
//                 color: widget.iconColor,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
