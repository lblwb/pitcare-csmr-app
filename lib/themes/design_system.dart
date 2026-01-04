import 'package:flutter/material.dart';

/// Дизайн-система приложения на основе макета Figma
class AppDesignSystem {
  // Цветовая палитра
  static const Color primaryColor = Color(0xFF3A8DA7); // Основной синий
  static const Color backgroundColor = Color(0xFFF8F9FA); // Фоновый цвет
  static const Color surfaceColor = Color(0xFFFFFFFF); // Цвет поверхности
  static const Color textPrimary = Color(0xFF1C1C1E); // Основной текст
  static const Color textSecondary = Color(0xFF8E8E93); // Вторичный текст
  static const Color accentColor = Color(0xFFFF9500); // Акцентный оранжевый
  static const Color successColor = Color(0xFF34C759); // Зеленый успех
  static const Color errorColor = Color(0xFFFF3B30); // Красный ошибка
  static const Color borderColor = Color(0xFFE5E5EA); // Цвет границ
  static const Color borderColorBtn = Color(0xFFF1F5F8); // Цвет границ
  static const Color shadowColor = Color(0x0F000000); // Тень
  static const Color bonusColor = Color(0xFFFFF2CC); // Фон бонусов
  static const Color searchFieldBackground = Color(
    0xFFF1F5F8,
  ); // Фон поля поиска
  static const Color searchIconColor = Color(0xFF324349); // Цвет иконки поиска
  static const Color searchHintColor =
      // ignore: deprecated_member_use
      const Color(0x99324349); // Цвет подсказки поиска

  // Радиусы скруглений
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 20.0;
  static const double radiusRound = 100.0;

  // Отступы
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;

  // Размеры элементов
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double buttonHeight = 48.0;
  static const double cardElevation = 2.0;

  // Размеры поля поиска
  static const double searchFieldHeight = 30.0;
  static const double searchFieldWidth = 370.0;
  static const double searchIconSize = 16.0;
  static const double searchFieldPaddingHorizontal = 10.0;
  static const double searchFieldPaddingVertical = 7.0;
  static const double searchIconGap = 4.0;

  // Константы для диалога подтверждения смены города
  static const Color dialogBackgroundColor = Color(0xFFFFFFFF);
  static const Color dialogTextColor = Color(0xFF324349);
  static const Color dialogIconColor = Color(0xFF98A1A4);
  static const Color dialogButtonColor = Color(0xFF3A8DA7);
  static const Color dialogButtonTextColor = Color(0xFFFFFFFF);
  static const double dialogWidth = 370.0;
  static const double dialogHeight = 240.0;
  static const double dialogBorderRadius = 20.0;
  static const double dialogPadding = 20.0;
  static const double dialogButtonHeight = 36.0;
  static const double dialogIconSize = 20.0;

  // Типографика
  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: surfaceColor,
  );

  static const TextStyle priceText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle searchHintText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.25,
    color: searchHintColor,
  );

  static const TextStyle oldPriceText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: textSecondary,
    decoration: TextDecoration.lineThrough,
  );

  // Стили текста для диалога подтверждения смены города
  static const TextStyle dialogTitleText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: dialogTextColor,
  );

  static const TextStyle dialogBodyText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: dialogTextColor,
  );

  static const TextStyle dialogButtonText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: dialogButtonTextColor,
  );

  static const TextStyle dialogBackButtonText = TextStyle(
    fontFamily: 'Manrope',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.25,
    color: dialogTextColor,
    letterSpacing: 0,
  );

  // Тени
  static const BoxShadow cardShadow = BoxShadow(
    color: shadowColor,
    offset: Offset(0, 2),
    blurRadius: 8,
    spreadRadius: 0,
  );

  static const BoxShadow buttonShadow = BoxShadow(
    color: shadowColor,
    offset: Offset(0, 1),
    blurRadius: 4,
    spreadRadius: 0,
  );

  // Состояния интерактивных элементов
  static Color getButtonColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return borderColor;
    }
    if (states.contains(MaterialState.pressed)) {
      return primaryColor.withOpacity(0.8);
    }
    if (states.contains(MaterialState.hovered)) {
      return primaryColor.withOpacity(0.9);
    }
    return primaryColor;
  }

  static Color getTextButtonColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return textSecondary;
    }
    if (states.contains(MaterialState.pressed)) {
      return primaryColor.withOpacity(0.8);
    }
    if (states.contains(MaterialState.hovered)) {
      return primaryColor.withOpacity(0.9);
    }
    return primaryColor;
  }

  // Стили кнопок
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: MaterialStateColor.resolveWith(getButtonColor),
    foregroundColor: surfaceColor,
    textStyle: buttonText,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    elevation: cardElevation,
    shadowColor: shadowColor,
    minimumSize: const Size(double.infinity, buttonHeight),
  );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: MaterialStateColor.resolveWith(getTextButtonColor),
    textStyle: buttonText.copyWith(color: primaryColor),
    side: const BorderSide(color: primaryColor, width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    minimumSize: const Size(double.infinity, buttonHeight),
  );

  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    foregroundColor: MaterialStateColor.resolveWith(getTextButtonColor),
    textStyle: buttonText.copyWith(color: primaryColor),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    minimumSize: const Size(double.infinity, buttonHeight),
  );
}

/// Расширение для удобного доступа к дизайн-системе
extension AppDesignSystemExtension on BuildContext {
  AppDesignSystem get design => AppDesignSystem();
}
