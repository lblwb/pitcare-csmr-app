import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pit_care/themes/design_system.dart';
// import '../../../providers/cart_provider.dart';
// import '../../../models/cart_models.dart';

class BottomNavBar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final activeColorBtn = const Color(0xFF582FFF);
  final deactivateColorBtn = const Color(0xFFA2A2A2);

  // Determine active color based on selected index
  Color getActiveColorBtn() {
    debugPrint('getActiveColorBtn: Selected Index: $selectedIndex');
    switch (selectedIndex) {
      case 2:
        return Colors.redAccent;
      default:
        return activeColorBtn;
    }
  }

  Color getDeactivateColorBtn() {
    debugPrint('getDeactivateColorBtn: Selected Index: $selectedIndex');
    switch (selectedIndex) {
      // case 2:
      //   return Colors.redAccent;
      default:
        return deactivateColorBtn;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final cartState = ref.watch(cartProvider);
    // final cartItemCount = cartState.calculatedTotalItems;

    return Container(
      color: AppDesignSystem.backgroundColor,
      // padding: const EdgeInsets.only(
      //     top: 14,
      //     bottom: 14,
      //     right: 14,
      //     left: 14
      // ),
      //
      // color: AppDesignSystem.backgroundColor,
      // decoration: BoxDecoration(
      //   // color: Colors.transparent,
      //   color: AppDesignSystem.backgroundColor,
      //   borderRadius: BorderRadius.circular(20),
      // ),
      // foregroundDecoration: BoxDecoration(
      //   color: AppDesignSystem.backgroundColor,
      //   borderRadius: BorderRadius.circular(20),
      // ),
      // borderRadius: BorderRadius.circular(10),
      //borderRadius: BorderRadius.circular(10),
      child: BottomNavigationBar(
        elevation: 0, // to get rid of the shadow
        backgroundColor: AppDesignSystem.backgroundColor,
        // fixedColor: activeColorBtn,
        // fixedColor: Colors.white,
        // useLegacyColorScheme: true,
        type: BottomNavigationBarType.fixed,
        mouseCursor: MouseCursor.defer,
        //
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        //
        enableFeedback: true,
        selectedItemColor: getActiveColorBtn(),
        unselectedItemColor: getDeactivateColorBtn(),
        //
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        //
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),

        //
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ui/nav/home.svg',
              colorFilter: ColorFilter.mode(
                selectedIndex == 0 ? activeColorBtn : deactivateColorBtn,
                BlendMode.srcIn,
              ),
            ),
            label: 'Главная',
            tooltip: "Удобная панель быстрого доступа и статьи",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ui/nav/garage.svg',
              colorFilter: ColorFilter.mode(
                selectedIndex == 1 ? activeColorBtn : deactivateColorBtn,
                BlendMode.srcIn,
              ),
            ),
            label: 'Гараж',
            tooltip: "Ваш гараж с автомобилями",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            label: 'SOS',
            tooltip: "Быстрая помощь на дороге",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ui/nav/map_point.svg',
              colorFilter: ColorFilter.mode(
                selectedIndex == 3 ? activeColorBtn : deactivateColorBtn,
                BlendMode.srcIn,
              ),
            ),
            label: 'Карта',
            tooltip: "Где вы находитесь на карте",
          ),

          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/ui/nav/settings.svg',
              colorFilter: ColorFilter.mode(
                selectedIndex == 4 ? activeColorBtn : deactivateColorBtn,
                BlendMode.srcIn,
              ),
            ),
            label: 'Настройки',
            // tooltip: "Профиль пользователя",
          ),
        ],
      ),
    );
  }
}
