import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pit_care/components/ui/navigation/custom_app_bar.dart';
import 'package:pit_care/routes/route_names.dart';
import '../../components/ui/carousel.dart';
// import 'package:go_router/go_router.dart';
// import 'package:fltr_easy_analyz/components/home/home_header_block.dart';
// import 'package:fltr_easy_analyz/components/home/home_panel_block.dart';
// import 'package:fltr_easy_analyz/components/home/popular_analysis_block.dart';
// import 'package:fltr_easy_analyz/components/home/examination_profiles_block.dart';
// import 'package:fltr_easy_analyz/components/home/articles_block.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 70),
        child: Column(
          children: [
            _buildHomeHeaderBlock(context),
            const SizedBox(height: 14),
            _buildSlider(context),
            const SizedBox(height: 24),
            _buildOurGarageBlock(context),
            // HomePanelBlock(),
            // SizedBox(height: 20),
            // PopularAnalysisBlock(),
            // ExaminationProfilesBlock(),
            // SizedBox(height: 20),
            // ArticlesBlock(),
            // SizedBox(height: 20),
            // Другой контент главной страницы
          ],
        ),
      ),
    );
  }
}

Widget buildCmpLogoType(BuildContext ctx, VoidCallback? onTap) {
  return GestureDetector(
    onTap: () {
      if (onTap != null) {
        // Переход на главную страницу
        // ctx.go(RouteNames.home);
        onTap();
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Вы получили скидку 25% на первый заказ!'),
        ),
      );
    },
    child: Row(
      children: [
        SvgPicture.asset(
          'assets/icons/ui/primary/logotype.svg',
          // colorFilter: ColorFilter.mode(
          //   BlendMode.srcIn,
          // ),
        ),
        // const SizedBox(width: 5),
        // const Text('PitCare'),
      ],
    ),
  );
}

Widget _buildHomeHeaderBlock(BuildContext ctx) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // LOGOTYPE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //LOGOTYPE
                buildCmpLogoType(ctx, null),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Переход на страницу уведомлений
                        // ctx.go(RouteNames.notifications);
                      },
                      child: SvgPicture.asset(
                        'assets/icons/ui/primary/notification.svg',
                        // colorFilter: ColorFilter.mode(
                        //   BlendMode.srcIn,
                        // ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        // Переход на страницу профиля
                        // ctx.go(RouteNames.profile);
                      },
                      child: SvgPicture.asset(
                        'assets/icons/ui/primary/avatar.svg',
                        // colorFilter: ColorFilter.mode(
                        //   BlendMode.srcIn,
                        // ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      const Divider(height: 1, color: Colors.black12),
    ],
  );
}

Widget _buildSlider(BuildContext ctx) {
  return AppCarousel(
    height: 200,
    borderRadius: const BorderRadius.all(Radius.circular(24)),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    slides: [
      CarouselSlide.promo(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00E676), // Modern mint green
                Color(0xFF1DE9B6), // Fresh teal accent
                Color(0xFFFFFFFF), // Clean white
              ],
              stops: [0.0, 0.65, 1.0],
              transform: GradientRotation(128 * 3.1415927 / 180),
            ),
          ),
        ),
        margin: const EdgeInsets.only(right: 10),
        blurSigmaX: 3, // Remove blur for clarity
        blurSigmaY: 3,
        blurOverlayColor: Colors.transparent,
        contentAlignment: Alignment.centerLeft,
        titleMain: 'Выездной ремонт',
        titleAccent: 'за 30 минут!',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black26),
          ],
        ),
        accentStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black26),
          ],
        ),
        buttonText: 'Вызвать мастера',
        buttonStyle: TextButton.styleFrom(
          backgroundColor: Colors.white70,
          foregroundColor: const Color(0xFF00C853),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFF00C853), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onButtonPressed: () {
          // ctx.go(RouteNames.callMaster);
        },
      ),
      CarouselSlide.promo(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3D5AFE), // Indigo A400
                Color(0xFF00E5FF), // Cyan A400
                Color(0xFFFFFFFF), // Clean white
              ],
              stops: [0.0, 0.62, 1.0],
              transform: GradientRotation(128 * 3.1415927 / 180),
            ),
          ),
        ),
        margin: const EdgeInsets.only(right: 10),
        blurSigmaX: 3,
        blurSigmaY: 3,
        blurOverlayColor: Colors.transparent,
        contentAlignment: Alignment.centerLeft,
        titleMain: 'Диагностика',
        titleAccent: 'бесплатно до 15 км',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black26),
          ],
        ),
        accentStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black26),
          ],
        ),
        buttonText: 'Заказать',
        buttonStyle: TextButton.styleFrom(
          backgroundColor: Colors.white70,
          foregroundColor: const Color(0xFF2979FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFF2979FF), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onButtonPressed: () {
          // ctx.go(RouteNames.diagnostic);
        },
      ),
      CarouselSlide.promo(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6D00), // Orange A700
                Color(0xFFFFC400), // Amber A400
                Color(0xFFFFFFFF), // Clean white
              ],
              stops: [0.0, 0.60, 1.0],
              transform: GradientRotation(128 * 3.1415927 / 180),
            ),
          ),
        ),
        margin: const EdgeInsets.only(right: 10),
        blurSigmaX: 3,
        blurSigmaY: 3,
        blurOverlayColor: Colors.transparent,
        contentAlignment: Alignment.centerLeft,
        titleMain: 'Эвакуатор',
        titleAccent: 'со скидкой 20%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black26),
          ],
        ),
        accentStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black26),
          ],
        ),
        buttonText: 'Срочно',
        buttonStyle: TextButton.styleFrom(
          backgroundColor: Colors.white70,
          foregroundColor: const Color(0xFFFF3D00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFFFF3D00), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onButtonPressed: () {
          // ctx.go(RouteNames.towTruck);
        },
      ),
      // CarouselSlide.color(
      //   color: Colors.red,
      //   margin: const EdgeInsets.only(right: 10),
      //   content: Text(
      //     'Slide 1',
      //     style: Theme.of(
      //       ctx,
      //     ).textTheme.headlineMedium?.copyWith(color: Colors.white),
      //   ),
      // ),
      // CarouselSlide.color(
      //   color: Colors.blue,
      //   content: Text(
      //     'Slide 3',
      //     style: Theme.of(
      //       ctx,
      //     ).textTheme.headlineMedium?.copyWith(color: Colors.white),
      //   ),
      // ),
    ],
  );
}

Widget _buildOurGarageBlock(BuildContext ctx) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        const SizedBox(height: 24),
        // MY GARAGE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Мой гараж',
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: () {
                // Переход на страницу гаража
                // ctx.go(RouteNames.garage);
              },
              child: Text(
                'все',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black26,
                ),
              ),
            ),
          ],
        ),
        //
        const SizedBox(height: 12),
        // GARAGE CARDS
        _buildGarageCards(ctx),
      ],
    ),
  );
}

Widget _buildGarageCards(BuildContext ctx) {
  return Container(
    // padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        // GARAGE CARDS / Slider
        AppCarousel(
          showDots: false,
          viewportFraction: 0.70,
          height: 120,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 0),
          slides: [
            // GARAGE CARD
            _buildGarageCard(
              ctx,
              "Exxed",
              Text(
                '1234567890123456',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.black26,
                ),
              ),
            ),
            // GARAGE CARD
            _buildGarageCard(
              ctx,
              "Ford Mustang",
              Text(
                '1234567890123456',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.black26,
                ),
              ),
            ),
          ],
        ),

        // Row(
        //   children: [
        //     // GARAGE CARD
        //     _buildGarageCard(ctx),
        //   ],
        // ),
      ],
    ),
  );
}

CarouselSlide _buildGarageCard(
  BuildContext ctx,
  String carName,
  Widget carContent,
) {
  return CarouselSlide.widget(
    background: GestureDetector(
      onTap: () {
        // Переход на страницу автомобиля
        ctx.go(RouteNames.garage);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF582FFF).withValues(alpha: 0.04),
          border: BoxBorder.all(color: const Color(0xFFD7D7D7), width: 1),
          // color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
      ),
    ),
    content: GestureDetector(
      onTap: () {
        // Переход на страницу автомобиля
        ctx.go(RouteNames.garage);
      },
      child: Row(
        children: [
          // GARAGE CARD IMAGE
          SizedBox(
            width: 90,
            height: 50,
            // decoration: BoxDecoration(
            //   // color: Colors.grey[300],
            //   borderRadius: BorderRadius.circular(12),
            // ),
            child: Image.asset(
              'assets/images/ui/garage/garage_car.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          // GARAGE CARD INFO
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                carName,
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              carContent,
              // Text(
              //   '1234567890123456',
              //   style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
              //     fontWeight: FontWeight.w400,
              //     color: Colors.black26,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    ),
  );
}
