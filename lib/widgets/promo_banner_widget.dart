import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pit_care/models/promo_banner.dart';
import 'package:pit_care/providers/service_providers.dart';
import 'package:go_router/go_router.dart';

/// Widget for displaying a single promo banner
class PromoBannerWidget extends ConsumerWidget {
  final PromoBannerModel banner;
  final VoidCallback? onDismiss;
  final EdgeInsets? padding;

  const PromoBannerWidget({
    Key? key,
    required this.banner,
    this.onDismiss,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Record display when widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(promoBannerRepositoryProvider).recordDisplay(banner.id);
    });

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: _buildGradient(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main title
                  Text(
                    banner.titleMain,
                    style: banner.titleStyle.toTextStyle().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Accent title
                  Text(
                    banner.titleAccent,
                    style: banner.accentStyle.toTextStyle().copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Description (if present)
                  if (banner.description != null &&
                      banner.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      banner.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _parseButtonColor(),
                        padding: EdgeInsets.symmetric(
                          horizontal: banner.buttonStyle.paddingHorizontal,
                          vertical: banner.buttonStyle.paddingVertical,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            banner.buttonStyle.borderRadius,
                          ),
                        ),
                      ),
                      onPressed: () => _onButtonPressed(context, ref),
                      child: Text(
                        banner.buttonText,
                        style: TextStyle(
                          color: _parseTextColor(),
                          fontSize: banner.buttonStyle.fontSize ?? 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Close button (top right)
            if (onDismiss != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onDismiss,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build gradient from colors and stops
  Gradient _buildGradient() {
    try {
      final colors = banner.gradientColors
          .map((colorStr) => _colorFromHex(colorStr))
          .toList();

      return LinearGradient(
        colors: colors,
        stops: banner.gradientStops,
        begin: const Alignment(0, -1),
        end: const Alignment(1, 1),
      );
    } catch (e) {
      // Fallback gradient
      return LinearGradient(
        colors: [Colors.blue, Colors.purple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// Parse button color
  Color _parseButtonColor() {
    try {
      if (banner.buttonColor != null && banner.buttonColor!.isNotEmpty) {
        return _colorFromHex(banner.buttonColor!);
      }
    } catch (e) {
      debugPrint('Error parsing button color: $e');
    }
    return Colors.white;
  }

  /// Parse text color
  Color _parseTextColor() {
    try {
      if (banner.buttonStyle.textColor != null &&
          banner.buttonStyle.textColor!.isNotEmpty) {
        return _colorFromHex(banner.buttonStyle.textColor!);
      }
    } catch (e) {
      debugPrint('Error parsing text color: $e');
    }
    return Colors.black;
  }

  /// Convert hex color string to Color
  static Color _colorFromHex(String hexColor) {
    final hexString = hexColor.replaceFirst('#', '');
    return Color(int.parse(hexString, radix: 16) + 0xFF000000);
  }

  /// Handle button press
  void _onButtonPressed(BuildContext context, WidgetRef ref) {
    // Record click
    ref.read(promoBannerRepositoryProvider).recordClick(banner.id);

    // Navigate if route is specified
    if (banner.routeName != null && banner.routeName!.isNotEmpty) {
      context.go(banner.routeName!);
    }
  }
}

/// Widget for displaying carousel of multiple banners
class PromoBannerCarouselWidget extends ConsumerWidget {
  final EdgeInsets? padding;
  final double? height;

  const PromoBannerCarouselWidget({
    Key? key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.height = 180,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(sortedPromoBannersProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: height,
          child: PageView(
            children: banners
                .map(
                  (banner) =>
                      PromoBannerWidget(banner: banner, padding: padding),
                )
                .toList(),
          ),
        );
      },
      loading: () => Container(
        height: height,
        margin: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

/// Widget for displaying the first active banner
class PromoBannerSingleWidget extends ConsumerWidget {
  final EdgeInsets? padding;
  final VoidCallback? onDismiss;

  const PromoBannerSingleWidget({
    Key? key,
    this.padding = const EdgeInsets.all(16),
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAsync = ref.watch(firstPromoBannerProvider);

    return bannerAsync.when(
      data: (banner) {
        if (banner == null) {
          return const SizedBox.shrink();
        }

        return PromoBannerWidget(
          banner: banner,
          padding: padding,
          onDismiss: onDismiss,
        );
      },
      loading: () => Container(
        margin: padding,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[300],
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
