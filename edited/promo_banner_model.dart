// lib/models/promo_banner_model.dart

import 'package:flutter/material.dart';

class PromoBannerModel {
  final int id;
  final String titleMain;
  final String titleAccent;
  final String? description;
  final String buttonText;
  final String? routeName;
  final List<String> gradientColors;
  final List<double>? gradientStops;
  final int gradientRotation;
  final TextStyleModel titleStyle;
  final TextStyleModel accentStyle;
  final ButtonStyleModel buttonStyle;
  final String? buttonColor;
  final int order;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final int displayCount;
  final int clickCount;

  PromoBannerModel({
    required this.id,
    required this.titleMain,
    required this.titleAccent,
    this.description,
    required this.buttonText,
    this.routeName,
    required this.gradientColors,
    this.gradientStops,
    required this.gradientRotation,
    required this.titleStyle,
    required this.accentStyle,
    required this.buttonStyle,
    this.buttonColor,
    required this.order,
    required this.isActive,
    this.startDate,
    this.endDate,
    required this.displayCount,
    required this.clickCount,
  });

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) {
    return PromoBannerModel(
      id: json['id'] as int,
      titleMain: json['title_main'] as String,
      titleAccent: json['title_accent'] as String,
      description: json['description'] as String?,
      buttonText: json['button_text'] as String,
      routeName: json['route_name'] as String?,
      gradientColors: List<String>.from(json['gradient_colors'] as List),
      gradientStops: json['gradient_stops'] != null
          ? List<double>.from(
              (json['gradient_stops'] as List).map(
                (e) => (e as num).toDouble(),
              ),
            )
          : null,
      gradientRotation: json['gradient_rotation'] as int? ?? 128,
      titleStyle: TextStyleModel.fromJson(
        json['title_style'] as Map<String, dynamic>,
      ),
      accentStyle: TextStyleModel.fromJson(
        json['accent_style'] as Map<String, dynamic>,
      ),
      buttonStyle: ButtonStyleModel.fromJson(
        json['button_style'] as Map<String, dynamic>,
      ),
      buttonColor: json['button_color'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      displayCount: json['display_count'] as int? ?? 0,
      clickCount: json['click_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_main': titleMain,
      'title_accent': titleAccent,
      'description': description,
      'button_text': buttonText,
      'route_name': routeName,
      'gradient_colors': gradientColors,
      'gradient_stops': gradientStops,
      'gradient_rotation': gradientRotation,
      'title_style': titleStyle.toJson(),
      'accent_style': accentStyle.toJson(),
      'button_style': buttonStyle.toJson(),
      'button_color': buttonColor,
      'order': order,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'display_count': displayCount,
      'click_count': clickCount,
    };
  }

  /// Получить Click-Through Rate в процентах
  double getClickThroughRate() {
    if (displayCount == 0) return 0;
    return (clickCount / displayCount) * 100;
  }

  /// Преобразовать Color из HEX строки
  static Color colorFromHex(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 6) {
      hexColor = 'ff$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  /// Получить LinearGradient для баннера
  LinearGradient getGradient() {
    final colors = gradientColors.map((c) => colorFromHex(c)).toList();
    final stops =
        gradientStops ??
        List.generate(colors.length, (i) => i / (colors.length - 1));

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: stops,
      transform: GradientRotation(gradientRotation * 3.1415927 / 180),
    );
  }

  /// Получить TextStyle для заголовка
  TextStyle getTitleTextStyle() {
    return titleStyle.toTextStyle();
  }

  /// Получить TextStyle для акцента
  TextStyle getAccentTextStyle() {
    return accentStyle.toTextStyle();
  }

  /// Получить ButtonStyle для кнопки
  ButtonStyle getButtonStyle() {
    return buttonStyle.toButtonStyle();
  }
}

class TextStyleModel {
  final String color;
  final double fontSize;
  final String fontWeight;
  final double? letterSpacing;
  final bool? shadows;

  TextStyleModel({
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    this.letterSpacing,
    this.shadows,
  });

  factory TextStyleModel.fromJson(Map<String, dynamic> json) {
    return TextStyleModel(
      color: json['color'] as String? ?? '#FFFFFF',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      fontWeight: json['fontWeight'] as String? ?? '600',
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble(),
      shadows: json['shadows'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'letterSpacing': letterSpacing,
      'shadows': shadows,
    };
  }

  TextStyle toTextStyle() {
    FontWeight fontWeightValue = FontWeight.w600;

    switch (fontWeight.toLowerCase()) {
      case '400':
      case 'normal':
        fontWeightValue = FontWeight.w400;
        break;
      case '500':
        fontWeightValue = FontWeight.w500;
        break;
      case '600':
      case 'semibold':
        fontWeightValue = FontWeight.w600;
        break;
      case '700':
      case 'bold':
        fontWeightValue = FontWeight.w700;
        break;
      case '800':
      case 'extrabold':
        fontWeightValue = FontWeight.w800;
        break;
      case '900':
      case 'black':
        fontWeightValue = FontWeight.w900;
        break;
    }

    return TextStyle(
      color: PromoBannerModel.colorFromHex(color),
      fontSize: fontSize,
      fontWeight: fontWeightValue,
      letterSpacing: letterSpacing,
    );
  }
}

class ButtonStyleModel {
  final String? backgroundColor;
  final String? foregroundColor;
  final int? borderRadius;
  final String? borderColor;
  final int? borderWidth;

  ButtonStyleModel({
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
  });

  factory ButtonStyleModel.fromJson(Map<String, dynamic> json) {
    return ButtonStyleModel(
      backgroundColor: json['backgroundColor'] as String?,
      foregroundColor: json['foregroundColor'] as String?,
      borderRadius: json['borderRadius'] as int?,
      borderColor: json['borderColor'] as String?,
      borderWidth: json['borderWidth'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor,
      'foregroundColor': foregroundColor,
      'borderRadius': borderRadius,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
    };
  }

  ButtonStyle toButtonStyle() {
    final bgColor = backgroundColor != null
        ? PromoBannerModel.colorFromHex(backgroundColor!)
        : Colors.white;

    final fgColor = foregroundColor != null
        ? PromoBannerModel.colorFromHex(foregroundColor!)
        : Colors.black;

    return TextButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular((borderRadius ?? 12).toDouble()),
        side: borderColor != null
            ? BorderSide(
                color: PromoBannerModel.colorFromHex(borderColor!),
                width: (borderWidth ?? 1).toDouble(),
              )
            : BorderSide.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
