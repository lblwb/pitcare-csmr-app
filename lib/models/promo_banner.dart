import 'package:flutter/material.dart';

/// Text style configuration for banner
class TextStyleModel {
  final double fontSize;
  final int fontWeight;
  final String fontFamily;
  final String color;
  final double? lineHeight;
  final TextAlign? textAlign;

  TextStyleModel({
    required this.fontSize,
    required this.fontWeight,
    required this.fontFamily,
    required this.color,
    this.lineHeight,
    this.textAlign,
  });

  factory TextStyleModel.fromJson(Map<String, dynamic> json) {
    return TextStyleModel(
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 16.0,
      fontWeight: json['font_weight'] as int? ?? 400,
      fontFamily: json['font_family'] as String? ?? 'Roboto',
      color: json['color'] as String? ?? '#000000',
      lineHeight: (json['line_height'] as num?)?.toDouble(),
      textAlign: _parseTextAlign(json['text_align'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
    'font_size': fontSize,
    'font_weight': fontWeight,
    'font_family': fontFamily,
    'color': color,
    'line_height': lineHeight,
    'text_align': textAlign?.toString(),
  };

  TextStyle toTextStyle() {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: _fontWeightFromInt(fontWeight),
      fontFamily: fontFamily,
      color: _colorFromHex(color),
      height: lineHeight,
    );
  }

  static TextAlign? _parseTextAlign(String? value) {
    switch (value?.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
        return TextAlign.left;
      default:
        return null;
    }
  }

  static FontWeight _fontWeightFromInt(int weight) {
    switch (weight) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  static Color _colorFromHex(String hexColor) {
    final hexString = hexColor.replaceFirst('#', '');
    return Color(int.parse(hexString, radix: 16) + 0xFF000000);
  }
}

/// Button style configuration for banner
class ButtonStyleModel {
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final String? backgroundColor;
  final String? textColor;
  final double? fontSize;

  ButtonStyleModel({
    required this.borderRadius,
    required this.paddingHorizontal,
    required this.paddingVertical,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  factory ButtonStyleModel.fromJson(Map<String, dynamic> json) {
    return ButtonStyleModel(
      borderRadius: (json['border_radius'] as num?)?.toDouble() ?? 8.0,
      paddingHorizontal:
          (json['padding_horizontal'] as num?)?.toDouble() ?? 16.0,
      paddingVertical: (json['padding_vertical'] as num?)?.toDouble() ?? 12.0,
      backgroundColor: json['background_color'] as String?,
      textColor: json['text_color'] as String?,
      fontSize: (json['font_size'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'border_radius': borderRadius,
    'padding_horizontal': paddingHorizontal,
    'padding_vertical': paddingVertical,
    'background_color': backgroundColor,
    'text_color': textColor,
    'font_size': fontSize,
  };
}

/// Promo banner model
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

  /// Check if banner is currently valid (within date range)
  bool get isValid {
    final now = DateTime.now();
    final afterStart = startDate == null || now.isAfter(startDate!);
    final beforeEnd = endDate == null || now.isBefore(endDate!);
    return isActive && afterStart && beforeEnd;
  }

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
}

/// Response wrapper for banner API calls
class PromoBannerResponse {
  final bool success;
  final List<PromoBannerModel> data;
  final String? message;

  PromoBannerResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory PromoBannerResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return PromoBannerResponse(
      success: json['success'] as bool? ?? false,
      data: dataList
          .map((b) => PromoBannerModel.fromJson(b as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}
