import 'package:flutter/material.dart';
import 'package:pit_care/components/ui/navigation/custom_app_bar.dart';
import 'package:pit_care/providers/service_providers.dart';
import 'package:pit_care/routes/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({super.key});

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  @override
  void initState() {
    super.initState();
    // Initial data fetch or setup can be done here if needed

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    ref.invalidate(vehicleRepositoryProvider);
    debugPrint('GarageScreen: _refreshData - refreshing data providers');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Гараж',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          children: [
            // _buildGarageHeader(),
            const SizedBox(height: 20),
            _buildCarList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCarList(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          // Список автомобилей
          ListView.builder(
            itemCount: 10,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
              return _buildCarItem(ctx);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGarageHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.garage),
          const SizedBox(width: 10),
          const Text(
            'Гараж',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Добавить новый автомобиль
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarItem(BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      // color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
      child: GestureDetector(
        onTap: () {
          // Переход на страницу автомобиля
          ctx.push(
            RouteNames.garageDetail,
            extra: {
              // 'carId': ctx,
              'carID': '1234567890123456',
            },
          );
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
                  "Test",
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // carContent,
                // SizedBox(height: 20),
                Text(
                  '1234567890123456',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.black26,
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
