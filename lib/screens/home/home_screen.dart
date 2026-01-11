// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pit_care/providers/service_providers.dart';
import 'package:pit_care/routes/route_names.dart';
// import 'package:pit_care/widgets/promo_banner_widget.dart';
import '../../components/ui/carousel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initial data fetch or setup can be done here if needed

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    ref
      ..invalidate(servicesProvider)
      ..invalidate(activePromoBannersProvider)
      ..invalidate(vehicleRepositoryProvider);
    debugPrint('HomeScreen: _refreshData - refreshing data providers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 70),
        child: Column(
          children: [
            _buildHomeHeaderBlock(context),
            const SizedBox(height: 14),
            // Promo Banners - Dynamic banners carousel
            _buildPromoBannerCarousel(context, ref),
            // const SizedBox(height: 14),
            // _buildSlider(context),
            const SizedBox(height: 24),
            _buildOurGarageBlock(context),
            // Services Grid Block
            const SizedBox(height: 20),
            _buildServicesBlock(context, ref),
            const SizedBox(height: 20),
            _buildArticlesBlock(context),
            // const SizedBox(height: 20),
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
                        ctx.go(RouteNames.notificationProfile);
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

// Banner [Promo]

Widget _buildPromoBannerCarousel(BuildContext ctx, WidgetRef ref) {
  final bannersAsync = ref.watch(activePromoBannersProvider);

  return bannersAsync.when(
    data: (banners) {
      if (banners.isEmpty) {
        return SizedBox.shrink();
      }

      return AppCarousel(
        height: 200,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        slides: banners
            .map(
              (banner) => CarouselSlide.promo(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: banner.gradientColors.isNotEmpty
                        ? LinearGradient(
                            colors: banner.gradientColors
                                .map((c) => _colorFromHex(c))
                                .toList(),
                            stops: banner.gradientStops,
                            transform: GradientRotation(
                              banner.gradientRotation * 3.1415927 / 180,
                            ),
                          )
                        : LinearGradient(
                            colors: [Colors.grey[300]!, Colors.grey[100]!],
                          ),
                  ),
                ),
                margin: const EdgeInsets.only(right: 10),
                blurSigmaX: 3,
                blurSigmaY: 3,
                blurOverlayColor: Colors.transparent,
                contentAlignment: Alignment.centerLeft,
                titleMain: banner.titleMain,
                titleAccent: banner.titleAccent,
                titleStyle: TextStyle(
                  color: banner.titleStyle.color.isNotEmpty
                      ? _colorFromHex(banner.titleStyle.color)
                      : Colors.white,
                  fontSize: banner.titleStyle.fontSize > 0
                      ? banner.titleStyle.fontSize.toDouble()
                      : 20.0,
                  fontWeight: banner.titleStyle.fontWeight > 0
                      ? _fontWeightFromInt(banner.titleStyle.fontWeight)
                      : FontWeight.w700,
                  shadows: const [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
                accentStyle: TextStyle(
                  color: banner.titleStyle.color.isNotEmpty
                      ? _colorFromHex(banner.titleStyle.color)
                      : Colors.white,
                  fontSize: banner.titleStyle.fontSize > 0
                      ? banner.titleStyle.fontSize.toDouble()
                      : 20.0,
                  fontWeight: FontWeight.w800,
                  shadows: const [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
                buttonText: banner.buttonText,
                buttonStyle: TextButton.styleFrom(
                  backgroundColor: banner.buttonStyle.backgroundColor != null
                      ? _colorFromHex(
                          banner.buttonStyle.backgroundColor!,
                        ).withOpacity(0.7)
                      : Colors.white10,
                  foregroundColor: banner.buttonStyle.textColor != null
                      ? _colorFromHex(banner.buttonStyle.textColor!)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      banner.buttonStyle.borderRadius.toDouble(),
                    ),
                  ),
                  side: BorderSide(
                    color: banner.buttonStyle.textColor != null
                        ? _colorFromHex(banner.buttonStyle.textColor!)
                        : Colors.white,
                    width: 1,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: banner.buttonStyle.paddingHorizontal.toDouble(),
                    vertical: banner.buttonStyle.paddingVertical.toDouble(),
                  ),
                ),
                onButtonPressed: () {
                  ref
                      .read(promoBannerRepositoryProvider)
                      .recordClick(banner.id);

                  if (banner.routeName != null &&
                      banner.routeName!.isNotEmpty) {
                    ctx.go(banner.routeName!);
                  }
                },
              ),
            )
            .toList(),
      );
    },
    loading: () => Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[200],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    ),
    error: (error, stackTrace) => SizedBox.shrink(),
  );
}

Color _colorFromHex(String hexColor) {
  final hexString = hexColor.replaceFirst('#', '');
  return Color(int.parse(hexString, radix: 16) + 0xFF000000);
}

FontWeight _fontWeightFromInt(int weight) {
  return switch (weight) {
    300 => FontWeight.w300,
    400 => FontWeight.w400,
    500 => FontWeight.w500,
    600 => FontWeight.w600,
    700 => FontWeight.w700,
    800 => FontWeight.w800,
    900 => FontWeight.w900,
    _ => FontWeight.w700,
  };
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

// Garage

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
        // ctx.go(RouteNames.garage);
        ctx.go(RouteNames.garageDetail, extra: {'vehicleId': 1});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF582FFF).withValues(alpha: 0.04),
          // border: BoxBorder.all(color: const Color(0xFFD7D7D7), width: 1),
          border: BoxBorder.all(color: const Color(0xFFD7D7D7), width: 0.8),
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
        // ctx.go(RouteNames.garage);
        ctx.go(RouteNames.garageDetail, extra: {'vehicleId': 1});
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

// Services

Widget _buildServicesBlock(BuildContext ctx, WidgetRef ref) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        // const SizedBox(height: 24),
        // SERVICES
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Сервис',
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: () {
                // Переход на страницу всех услуг
                // ctx.go(RouteNames.services);
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
        // SERVICES GRID
        _buildServicesGrid(ctx, ref),
      ],
    ),
  );
}

Widget _buildServicesGrid(BuildContext ctx, WidgetRef ref) {
  final servicesAsync = ref.watch(servicesProvider);

  return servicesAsync.when(
    data: (services) {
      // Show only first 4 services for grid display
      final displayServices = services.take(10).toList();

      if (displayServices.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Нет доступных услуг',
              style: Theme.of(ctx).textTheme.bodyLarge,
            ),
          ),
        );
      }

      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        children: displayServices
            .map(
              (service) => Center(
                child: _buildServiceItem(
                  ctx,
                  // service.iconPath,
                  "",
                  service.name,
                  service.basePrice.toString(),
                  () {
                    // Переход на страницу услуги
                    ctx.push(
                      RouteNames.serviceDetail,

                      extra: {'serviceId': service.id},
                    );
                  },
                  hasDiscount: service.hasDiscount,
                  discountText: service.discountText,
                ),
              ),
            )
            .toList(),
      );
    },
    loading: () => GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1,
      children: List.generate(
        4,
        (index) => Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(ctx).primaryColor,
              ),
            ),
          ),
        ),
      ),
    ),
    error: (error, stackTrace) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки услуг',
              style: Theme.of(ctx).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            // Text(
            //   error.toString(),
            //   style: Theme.of(
            //     ctx,
            //   ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(servicesProvider),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildServiceItem(
  BuildContext ctx,
  String iconPath,
  String title,
  String price,
  VoidCallback onTap, {
  bool hasDiscount = false,
  String? discountText,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SERVICE ICON
            // SvgPicture.asset(
            //   iconPath,
            //   width: 40,
            //   height: 40,
            //   placeholderBuilder: (context) => const Icon(Icons.image),
            // ),
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) =>
                  // const Icon(Icons.car_crash_rounded),
                  const Icon(Icons.car_repair),
            ),
            const SizedBox(height: 8),
            // SERVICE TITLE
            Text(
              title,
              style: Theme.of(
                ctx,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              "$price руб.",
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: hasDiscount ? Colors.red : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        // DISCOUNT BADGE
        if (hasDiscount && discountText != null)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                discountText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// Articles

Widget _buildArticlesBlock(BuildContext ctx) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        const SizedBox(height: 24),
        // ARTICLES
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Статьи',
              style: Theme.of(
                ctx,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: () {
                // Переход на страницу всех статей
                // ctx.go(RouteNames.articles);
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
        // ARTICLES LIST
        _buildArticlesList(ctx),
      ],
    ),
  );
}

Widget _buildArticlesList(BuildContext ctx) {
  return Column(
    children: [
      // ARTICLES GRID
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
        children: [
          // ARTICLE CARD
          // _buildArticleCard(ctx, "Как выбрать надежного мастера на выезд?"),
          // ARTICLE CARD
          _buildArticleCard(ctx, "5 советов по уходу за автомобилем зимой"),
          // ARTICLE CARD
          _buildArticleCard(ctx, "Преимущества мобильного сервиса PitCare"),
          // ARTICLE CARD
          _buildArticleCard(ctx, "Что делать при поломке на дороге?"),
          // ARTICLE CARD
          // _buildArticleCard(ctx, "ТО автомобиля: когда и зачем?"),
          // ARTICLE CARD
          _buildArticleCard(
            ctx,
            "Как подготовить автомобиль к дальнему путешествию?",
          ),
        ],
      ),
    ],
  );
}

_buildArticleCard(BuildContext ctx, String articleTitle) {
  return GestureDetector(
    onTap: () {
      // Переход на страницу статьи
      // ctx.go(RouteNames.articleDetail);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ARTICLE IMAGE
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              // image: const DecorationImage(
              //   // image: AssetImage(
              //   //   'assets/images/ui/articles/article_sample.png',
              //   // ),
              //   image: NetworkImage(
              //     'https://images.unsplash.com/photo-1502877338535-766e1452684a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Y2FyJTIwd29ya3Nob3B8ZW58MHx8MHx8fDA%3D&w=1000&q=80',
              //   ),
              //   fit: BoxFit.cover,
              // ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const Icon(
                Icons.car_repair_sharp,
                size: 50,
                color: Colors.white54,
              ),
              // child: Image.asset(
              //   'assets/images/ui/articles/article_sample.png',
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          const SizedBox(height: 8),
          // ARTICLE TITLE
          Text(
            articleTitle,
            style: Theme.of(
              ctx,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
