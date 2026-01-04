import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;

/// Универсальная карусель с поддержкой произвольного фона (Widget/Color)
/// и произвольного контента, а также индикатором страниц.
class AppCarousel extends StatefulWidget {
  final List<CarouselSlide> slides;
  final double height;
  final double viewportFraction;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showDots;
  final Color dotsBackdropColor;

  const AppCarousel({
    super.key,
    required this.slides,
    this.height = 200,
    this.viewportFraction = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.showDots = true,
    this.dotsBackdropColor = const Color(
      0x66000000,
    ), // Colors.black.withOpacity(0.4)
  });

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  late final PageController _controller;
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.viewportFraction);
    _controller.addListener(() {
      final newPage = _controller.page?.round() ?? 0;
      if (newPage != _currentPage.value) {
        _currentPage.value = newPage;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(borderRadius: widget.borderRadius),
      height: widget.height,
      child: Stack(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _currentPage,
            builder: (context, currentPage, _) {
              return Stack(
                children: [
                  PageView(
                    controller: _controller,
                    padEnds: false,
                    onPageChanged: (index) => _currentPage.value = index,
                    children: widget.slides
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildSlide(
                            context,
                            entry.value,
                            isLast: entry.key == widget.slides.length - 1,
                          ),
                        )
                        .toList(),
                  ),
                  if (widget.showDots)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.dotsBackdropColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(widget.slides.length, (
                              index,
                            ) {
                              final isActive = index == currentPage;
                              return GestureDetector(
                                onTap: () => _controller.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: isActive ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.white70,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context,
    CarouselSlide slide, {
    required bool isLast,
  }) {
    final BorderRadius slideRadius = slide.borderRadius ?? widget.borderRadius;
    return Container(
      margin: slide.margin ?? EdgeInsets.only(right: isLast ? 0 : 10),
      decoration: BoxDecoration(borderRadius: slideRadius),
      child: ClipRRect(
        borderRadius: slideRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  slide.background ??
                  ColoredBox(
                    color: slide.backgroundColor ?? Colors.transparent,
                  ),
            ),
            // Blur-слой перед контентом (между фоном и контентом)
            if (slide.hasBlur)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: slide.blurSigmaX ?? 0,
                    sigmaY: slide.blurSigmaY ?? 0,
                  ),
                  child: ColoredBox(
                    color: slide.blurOverlayColor ?? Colors.transparent,
                  ),
                ),
              ),
            Positioned.fill(
              child: Align(
                alignment: slide.contentAlignment,
                child: slide.content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Данные одного слайда карусели.
class CarouselSlide {
  final Widget?
  background; // Любой виджет на фоне (изображение, видео, градиент и т.д.)
  final Color? backgroundColor; // Простой цвет как фон
  final Widget content; // Произвольный контент поверх
  final Alignment contentAlignment; // Выравнивание контента
  final EdgeInsetsGeometry? margin; // Отступы карточки (например, справа)
  final BorderRadius?
  borderRadius; // Индивидуальный радиус у конкретного слайда
  // Настройки размытия (между фоном и контентом)
  final double? blurSigmaX;
  final double? blurSigmaY;
  final Color?
  blurOverlayColor; // Дополнительный цвет поверх blur для маски/тонировки

  bool get hasBlur {
    final bool hasSigma = ((blurSigmaX ?? 0) > 0) || ((blurSigmaY ?? 0) > 0);
    final bool hasOverlay =
        (blurOverlayColor != null) && (blurOverlayColor!.alpha > 0);
    return hasSigma || hasOverlay;
  }

  const CarouselSlide({
    this.background,
    this.backgroundColor,
    required this.content,
    this.contentAlignment = Alignment.center,
    this.margin,
    this.borderRadius,
    this.blurSigmaX,
    this.blurSigmaY,
    this.blurOverlayColor,
  });

  /// Удобный конструктор для фона-цвета
  factory CarouselSlide.color({
    required Color color,
    required Widget content,
    Alignment contentAlignment = Alignment.center,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    double? blurSigmaX,
    double? blurSigmaY,
    Color? blurOverlayColor,
  }) {
    return CarouselSlide(
      backgroundColor: color,
      content: content,
      contentAlignment: contentAlignment,
      margin: margin,
      borderRadius: borderRadius,
      blurSigmaX: blurSigmaX,
      blurSigmaY: blurSigmaY,
      blurOverlayColor: blurOverlayColor,
    );
  }

  /// Удобный конструктор для фонового виджета
  factory CarouselSlide.widget({
    required Widget background,
    required Widget content,
    Alignment contentAlignment = Alignment.center,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    double? blurSigmaX,
    double? blurSigmaY,
    Color? blurOverlayColor,
  }) {
    return CarouselSlide(
      background: background,
      content: content,
      contentAlignment: contentAlignment,
      margin: margin,
      borderRadius: borderRadius,
      blurSigmaX: blurSigmaX,
      blurSigmaY: blurSigmaY,
      blurOverlayColor: blurOverlayColor,
    );
  }

  /// Готовый промо‑слайд: фон (виджет/цвет), заголовок с акцентом и кнопка.
  factory CarouselSlide.promo({
    Widget? background,
    Color? backgroundColor,
    required String titleMain,
    required String titleAccent,
    Color accentColor = const Color(0xFF582FFF),
    TextStyle? titleStyle,
    TextStyle? accentStyle,
    String buttonText = 'Подробнее',
    VoidCallback? onButtonPressed,
    ButtonStyle? buttonStyle,
    Alignment contentAlignment = Alignment.centerLeft,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
    ),
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    double? blurSigmaX,
    double? blurSigmaY,
    Color? blurOverlayColor,
    double titleMaxWidthFraction = 0.4,
  }) {
    final TextStyle mainStyle =
        titleStyle ??
        const TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
    final TextStyle computedAccentStyle =
        accentStyle ?? mainStyle.copyWith(color: accentColor);

    final Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth * titleMaxWidthFraction;
        return Container(
          padding: contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: maxWidth,
                child: RichText(
                  textAlign: TextAlign.left,
                  softWrap: true,
                  text: TextSpan(
                    children: [
                      TextSpan(text: "$titleMain ", style: mainStyle),
                      TextSpan(text: titleAccent, style: computedAccentStyle),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                style:
                    buttonStyle ??
                    TextButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white24,
                      minimumSize: const Size(106, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                onPressed: onButtonPressed,
                child: Text(buttonText),
              ),
            ],
          ),
        );
      },
    );

    return CarouselSlide(
      background: background,
      backgroundColor: backgroundColor,
      content: content,
      contentAlignment: contentAlignment,
      margin: margin,
      borderRadius: borderRadius,
      blurSigmaX: blurSigmaX,
      blurSigmaY: blurSigmaY,
      blurOverlayColor: blurOverlayColor,
    );
  }

  //

  /// Удобный конструктор для пустого слайда (только контент)
  factory CarouselSlide.empty({
    required Widget content,
    Alignment contentAlignment = Alignment.center,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
  }) {
    return CarouselSlide(
      content: content,
      contentAlignment: contentAlignment,
      margin: margin,
      borderRadius: borderRadius,
    );
  }
}
