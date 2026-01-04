// import 'package:fltr_easy_analyz/components/profile/bonus_widget.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showPoints;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundBar;
  final Color? colorElements;
  final BorderRadius? borderBottomRadius;
  final VoidCallback? backButtonAction;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.showPoints = false,
    this.colorElements = const Color(0xFF324349),
    this.borderBottomRadius = const BorderRadius.vertical(
      bottom: Radius.circular(20),
    ),
    this.backgroundBar = const Color(0xFFFFFFFF),
    this.backButtonAction = null,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundBar,
        borderRadius: borderBottomRadius,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        // useDefaultSemanticsOrder: false,
        // excludeHeaderSemantics: false,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              // color: Colors.transparent,
              borderRadius: borderBottomRadius,
            ),
            height: 1,
            // color: const Color(0xFFE5E5E0),
          ),
        ),

        // backgroundColor: backgroundBar,
        // foregroundColor: Colors.transparent,
        // shadowColor: Colors.amber,
        // bottomOpacity: 0.7,
        // backgroundColor: Colors.black12,
        // shadowColor: ShapeBorderTween(begin: ShapeBorder),
        // backgroundColor: Colors.white10,
        elevation: 0,
        actionsPadding: const EdgeInsets.all(0),
        // actionsPadding:
        //     const EdgeInsets.only(top: 10, bottom: 11, right: 0, left: 0),
        centerTitle: true,
        leading: showBackButton
            ? IconButton(
                enableFeedback: true,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: SvgPicture.asset(
                  'assets/icons/arrow_left.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    colorElements!,
                    BlendMode.srcIn,
                  ),
                ),
                // onPressed: () => Navigator.of(context).pop(),
                onPressed: () {
                  if (backButtonAction == null) {
                    if (!GoRouter.of(context).canPop()) {
                      debugPrint(
                        "Маршрут назад не найден -> возращаю на главную!",
                      );
                      context.goNamed("home");
                    } else {
                      context.pop();
                      debugPrint("Возвращаю к ${context.namedLocation}");
                    }
                  }
                  backButtonAction?.call();
                },
              )
            : null,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorElements,
            fontSize: 14,
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        forceMaterialTransparency: true,
        actions: showPoints
            ? [
                Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0.0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // BonusWidget(
                      //   bonus: null,
                      // ),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
