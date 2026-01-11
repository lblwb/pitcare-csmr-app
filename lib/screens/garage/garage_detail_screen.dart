import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pit_care/components/ui/navigation/custom_app_bar.dart';

class GarageDetailScreen extends StatefulWidget {
  const GarageDetailScreen({super.key, required this.stateRoute});

  final GoRouterState stateRoute;

  @override
  State<GarageDetailScreen> createState() => _GarageDetailScreenState();
}

class _GarageDetailScreenState extends State<GarageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        backgroundBar: Colors.transparent,
        title: 'Профиль автомобиля',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        centerTitle: false,
        showPoints: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildCarHero(context),
            const SizedBox(height: 16),
            _buildCarQuickInfo(context),
            const SizedBox(height: 24),
            _buildServiceStats(context),
            const SizedBox(height: 24),
            // _buildPartnerScoring(context),
            // const SizedBox(height: 24),
            _buildSubscriptionBlock(context),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  // =========================
  // HERO: АВТО СРАЗУ ПОСЛЕ ХЕДЕРА
  // =========================
  Widget _buildCarHero(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 275,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.25), Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // glow / glass background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const SizedBox(),
            ),
          ),

          // car image placeholder
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // SvgPicture.asset(
              //   'assets/svg/car_placeholder.svg',
              //   height: 140,
              //   colorFilter: ColorFilter.mode(
              //     Colors.white.withOpacity(0.9),
              //     BlendMode.srcIn,
              //   ),
              // ),
              Image.asset(
                'assets/images/ui/garage/garage_car.png',
                fit: BoxFit.cover,
                height: 140,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 16),
              Text(
                'BMW X5 · 2021',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Персональный профиль автомобиля',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // КРАТКАЯ ИНФОРМАЦИЯ
  // =========================
  Widget _buildCarQuickInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
          children: [
            // _infoChip(label: 'VIN проверен', icon: Icons.verified),
            _infoChip(label: 'VIN проверен', icon: Icons.gpp_good_outlined),
            const SizedBox(width: 8),
            _infoChip(label: 'Без ДТП', icon: Icons.shield_outlined),
            const SizedBox(width: 8),
            _infoChip(label: 'В подписке', icon: Icons.payment),
            const SizedBox(width: 8),
            _infoChip(
              label: 'Максимальная выгода',
              icon: Icons.discount_rounded,
              iconColor: Colors.green,
              labelColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip({
    required String label,
    required IconData icon,
    Color? labelColor,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            fontWeight: FontWeight.w500,
            color: iconColor ?? Colors.black,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: labelColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // СТАТИСТИКА ОБСЛУЖИВАНИЯ
  // =========================
  Widget _buildServiceStats(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('О вашем авто'),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard(
                title: '12',
                subtitle: 'выездов',
                icon: Icons.build_outlined,
              ),
              const SizedBox(width: 12),
              _statCard(
                title: '98%',
                subtitle: 'успешных работ',
                icon: Icons.trending_up,
              ),
              const SizedBox(width: 12),
              _statCard(
                title: '4.9',
                subtitle: 'рейтинг авто',
                icon: Icons.star_border,
              ),
            ],
          ),
          // Блок действий и сервисов по автомобилю
          Column(
            children: [
              const SizedBox(height: 12),
              _buildServiceActionBlocks(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ПАРТНЁРСКИЙ СКОРИНГ
  // =========================
  Widget _buildPartnerScoring(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Скоринг и партнёрские данные'),
          const SizedBox(height: 12),
          _partnerCard(
            title: 'Страховой скоринг',
            description:
                'Мы анализируем данные авто и подбираем лучшие условия KASKO / OSAGO',
            action: 'Посмотреть предложения',
          ),
          const SizedBox(height: 12),
          _partnerCard(
            title: 'Пробег и история',
            description:
                'Проверка пробега и истории эксплуатации по партнёрским API',
            action: 'Открыть отчёт',
          ),
        ],
      ),
    );
  }

  Widget _partnerCard({
    required String title,
    required String description,
    required String action,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () {}, child: Text(action)),
        ],
      ),
    );
  }

  // =========================
  // ПОДПИСКА / МАРКЕТИНГ
  // =========================
  Widget _buildSubscriptionBlock(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.2),
              Colors.purpleAccent.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Подписка Plus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Расширенный пакет услуг, приоритетный выезд, партнёрские скидки и отчёты',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(0),
                shape: WidgetStateProperty.all(
                  const RoundedRectangleBorder(
                    // Change your radius here
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(16)),
                  ),
                ),
              ),
              onPressed: () {},
              child: const Text('Управлять подпиской'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildServiceActionBlocks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Обслуживание авто'),
          const SizedBox(height: 12),

          /// Основное действие — продажа сервиса
          _primaryServiceAction(context),

          const SizedBox(height: 16),

          /// Информационные и партнёрские блоки
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                Expanded(
                  child: _actionInfoCard(
                    icon: Icons.history,
                    title: 'История обслуживания',
                    subtitle: 'Все работы и выезды',
                    onTap: () {
                      // context.push(RouteNames.serviceHistory);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionInfoCard(
                    icon: Icons.shield_outlined,
                    title: 'Страховка',
                    subtitle: 'КАСКО / ОСАГО',
                    badge: 'Выгодно',
                    onTap: () {
                      // context.push(RouteNames.insurance);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// Скоринг / партнёрский апселл
          _actionInfoCardWide(
            icon: Icons.analytics_outlined,
            title: 'Отчет об автомобиле',
            subtitle: 'Анализ состояния, пробега и рекомендации',
            actionText: 'Посмотреть отчёт',
            onTap: () {
              // context.push(RouteNames.carScoring);
            },
          ),
        ],
      ),
    );
  }

  Widget _primaryServiceAction(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // context.push(RouteNames.orderService);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: BoxBorder.all(color: const Color(0xFFD7D7D7), width: 0.3),
          gradient: LinearGradient(
            colors: [
              Colors.greenAccent.withOpacity(0.10),
              Color(0xFF582FFF).withOpacity(0.35),
            ],
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.car_repair, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Обслужить автомобиль',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Подобранные услуги именно для вашего авто',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _actionInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: BoxBorder.all(color: const Color(0xFFD7D7D7), width: 0.3),
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionInfoCardWide({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF582FFF).withValues(alpha: 0.08),
              const Color(0xFF582FFF).withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              actionText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
