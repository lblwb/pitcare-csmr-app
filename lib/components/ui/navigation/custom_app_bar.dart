import 'package:flutter/material.dart';
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
  final bool? centerTitle;
  final TextStyle? titleStyle;
  final double? titleSize;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.showPoints = false,
    // this.colorElements = const Color(0xFF324349),
    this.colorElements = const Color(0xFF000000),
    this.borderBottomRadius = const BorderRadius.vertical(
      bottom: Radius.circular(20),
    ),
    this.backgroundBar = const Color(0xFFFFFFFF),
    this.backButtonAction = null,
    this.centerTitle = false,
    this.titleStyle,
    this.titleSize = 18,
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
        centerTitle: centerTitle ?? false,
        leading: showBackButton
            ? ElevatedButton(
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
                style: const ButtonStyle(
                  // minimumSize: MaterialStatePropertyAll<Size>(Size(24, 24)),
                  padding: MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.all(0),
                  ),
                  backgroundColor: WidgetStatePropertyAll<Color>(
                    Colors.transparent,
                  ),
                  elevation: WidgetStatePropertyAll<double>(0),
                  // iconColor: colorElements,
                ),
                child: Icon(
                  Icons.arrow_back_sharp,
                  size: 20,
                  color: colorElements,
                ),
              )
            : null,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style:
              titleStyle ??
              TextStyle(
                color: colorElements,
                fontSize: titleSize,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
        ),
        forceMaterialTransparency: true,
        actions: actions != null
            ? [
                Container(
                  margin: const EdgeInsets.only(right: 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //
                      // SizedBox(width: 4),
                      ...?actions,
                    ],
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
