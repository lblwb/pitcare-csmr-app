import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pit_care/components/ui/navigation/custom_app_bar.dart';
import 'package:pit_care/models/service.dart';
import 'package:pit_care/models/vehicle.dart';
import 'package:pit_care/providers/service_providers.dart';
import 'package:pit_care/routes/route_names.dart';
import 'package:pit_care/services/service_repository.dart';
import 'package:pit_care/services/vehicle_repository.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  const ServiceDetailScreen({super.key, required this.stateRoute});

  final GoRouterState stateRoute;

  @override
  ConsumerState<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  late final int serviceId;
  late final ServiceRepository serviceRepository;
  late final VehicleRepository vehicleRepository;

  Service? service;
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      // Безопасно извлекаем serviceId
      final extra = widget.stateRoute.extra;
      final Map<String, dynamic>? extraMap = extra is Map<String, dynamic>
          ? extra
          : null;
      final idParam = extraMap?['serviceId'];
      serviceId = idParam is int ? idParam : int.parse(idParam.toString());

      // debugPrint("Service ID: ${serviceId}");

      // Инициализация репозиториев через Riverpod
      serviceRepository = ref.read(serviceRepositoryProvider);
      vehicleRepository = ref.read(vehicleRepositoryProvider);

      await _refreshData();
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load service details: $e';
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      setState(() => isLoading = true);

      final serviceResult = await serviceRepository.fetchServiceById(serviceId);

      debugPrint(serviceResult.name);

      try {
        final vehiclesResult = await ref
            .read(vehicleRepositoryProvider)
            .fetchVehicles();
        setState(() {
          vehicles = vehiclesResult;
        });
      } catch (e) {
        setState(() {
          vehicles = .empty();
        });
      }

      setState(() {
        service = serviceResult;
        selectedVehicle = vehicles.isNotEmpty ? vehicles.first : null;
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      debugPrint('${e.toString()}');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data';
      });
    }
  }

  Future<void> _showVehicleSelectionBottomSheet() async {
    if (vehicles.isEmpty) return;

    final selected = await showModalBottomSheet<Vehicle>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Выберите автомобиль',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  final isSelected = selectedVehicle?.id == vehicle.id;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.directions_car, size: 20),
                    ),
                    title: Text(
                      vehicle.displayName,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${vehicle.make} ${vehicle.model} · ${vehicle.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () => Navigator.pop(context, vehicle),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Готово'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => selectedVehicle = selected);
    }
  }

  Future<void> _handleOrderService() async {
    if (selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите автомобиль')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение заказа'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Услуга: ${service?.name ?? '-'}'),
            const SizedBox(height: 8),
            Text('Автомобиль: ${selectedVehicle?.displayName ?? '-'}'),
            const SizedBox(height: 8),
            Text('Стоимость: ${service?.displayPrice ?? '-'}'),
            if (service?.hasDiscount == true)
              Text('Скидка: ${service?.discountText ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заказ оформлен!')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          backgroundBar: Colors.transparent,
          title: 'Загрузка...',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          centerTitle: false,
          showPoints: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: CustomAppBar(
          backgroundBar: Colors.transparent,
          title: 'Ошибка',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          centerTitle: false,
          showPoints: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Ошибка загрузки услуги'),
              Text(errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (service == null) {
      return Scaffold(
        appBar: CustomAppBar(
          backgroundBar: Colors.transparent,
          title: 'Услуга не найдена',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          centerTitle: false,
          showPoints: false,
        ),
        body: const Center(child: Text('Услуга не найдена')),
      );
    }

    // Основной экран услуги
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        backgroundBar: Colors.transparent,
        title: 'Услуга',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
        centerTitle: false,
        showPoints: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildServiceHero(context, service!),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsetsGeometry.only(right: 16, left: 16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //
                children: [
                  _buildServiceInfo(context, service!),
                  const SizedBox(height: 16),
                  _buildVehicleSelection(context),
                  const SizedBox(height: 16),
                  _buildServiceFeatures(context, service!),
                  const SizedBox(height: 16),
                  _buildOrderActions(context),
                  const SizedBox(height: 72),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // HERO: Сервис СРАЗУ ПОСЛЕ ХЕДЕРА
  // =========================
  Widget _buildServiceHero(BuildContext context, Service service) {
    final theme = Theme.of(context);

    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.3), Colors.black87],
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

          // Text('${service.imageUrl}'),

          // Service image or icon
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              service.imageUrl != null
                  ? Image.network(
                      service.imageUrl!,
                      height: 160,
                      width: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.car_repair,
                        size: 120,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.car_repair,
                      size: 120,
                      color: Colors.white,
                    ),

              const SizedBox(height: 16),
              Text(
                service.name,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                service.category ?? 'Автосервис',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
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
  // Информация об услуге
  // =========================
  Widget _buildServiceInfo(BuildContext context, Service service) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price and discount
          Row(
            children: [
              Text(
                service.displayPrice,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (service.hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service.discountText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Duration
          Row(
            children: [
              const Icon(Icons.timer, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${service.estimatedDurationMinutes} мин',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${service.popularityScore}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            service.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // Выбор автомобиля
  // =========================
  Widget _buildVehicleSelection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: Colors.white,
          color: Colors.transparent,
          border: BoxBorder.all(color: Colors.grey.withValues(alpha: 0.8)),
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 10,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  'Обслуживаемый автомобиль',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showVehicleSelectionBottomSheet,
              child: Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.ads_click, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedVehicle?.displayName ?? 'Не выбран',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            selectedVehicle != null
                                ? '${selectedVehicle!.make} ${selectedVehicle!.model} · ${selectedVehicle!.year}'
                                : 'Выберите автомобиль для заказа',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Особенности услуги
  // =========================
  Widget _buildServiceFeatures(BuildContext context, Service service) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        // width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // color: Colors.white,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: BoxBorder.all(color: Colors.grey.withValues(alpha: 0.8)),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 10,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Особенности услуги',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // _featureChip(
                //   'Сложность: ${_getMasterDiffLevel(service.difficultyLevel)}',
                // ),
                _featureChip('${service.estimatedDurationMinutes} мин'),
                _featureChip('Гарантия'),
                _featureChip('Профессионально'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(
          color: Colors.blueAccent.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  // =========================
  // Действия по заказу
  // =========================
  Widget _buildOrderActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.white.withOpacity(0.1),
          //     blurRadius: 10,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[50]!),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Add to favorites
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Добавлено в избранное')),
                      );
                    },
                    child: const Row(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.black),
                        Text('В избранное'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[50]!),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // TODO: Share service
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ссылка скопирована')),
                      );
                    },

                    child: const Row(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.share, size: 16, color: Colors.black),
                        Text('Поделиться'),
                      ],
                    ),

                    // const Text('Поделиться'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.black,
                      // overlayColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _handleOrderService,
                    child: const Text('Оформить услугу'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
