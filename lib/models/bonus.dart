import 'package:flutter/foundation.dart';

/// Bonus model representing bonus points earned by user
@immutable
class Bonus {
  final int id;
  final int userId;
  final int amount;
  final String type; // service, referral, milestone, promotion
  final String? description;
  final DateTime expiresAt;
  final bool isUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Bonus({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.description,
    required this.expiresAt,
    required this.isUsed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if bonus is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if bonus is available (not used and not expired)
  bool get isAvailable => !isUsed && !isExpired;

  /// Get bonus type label in Russian
  String get typeLabel {
    switch (type) {
      case 'service':
        return 'За услугу';
      case 'referral':
        return 'От реферала';
      case 'milestone':
        return 'За достижение';
      case 'promotion':
        return 'От акции';
      default:
        return type;
    }
  }

  factory Bonus.fromJson(Map<String, dynamic> json) {
    return Bonus(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      amount: json['amount'] as int,
      type: json['type'] as String,
      description: json['description'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isUsed: json['is_used'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'description': description,
      'expires_at': expiresAt.toIso8601String(),
      'is_used': isUsed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Coupon model for discount coupons
@immutable
class Coupon {
  final int id;
  final String code;
  final String description;
  final String discountType; // percentage, fixed
  final double discountValue;
  final int maxUses;
  final int currentUses;
  final int maxUsesPerUser;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maxUses,
    required this.currentUses,
    required this.maxUsesPerUser,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if coupon is valid
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(validFrom) &&
        now.isBefore(validUntil) &&
        currentUses < maxUses;
  }

  /// Get discount display text
  String get discountText {
    if (discountType == 'percentage') {
      return '-${discountValue.toStringAsFixed(0)}%';
    }
    return '-${discountValue.toStringAsFixed(0)} ₽';
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as int,
      code: json['code'] as String,
      description: json['description'] as String,
      discountType: json['discount_type'] as String,
      discountValue: double.parse((json['discount_value'] ?? 0).toString()),
      maxUses: json['max_uses'] as int,
      currentUses: json['current_uses'] as int? ?? 0,
      maxUsesPerUser: json['max_uses_per_user'] as int? ?? 1,
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_uses': maxUses,
      'current_uses': currentUses,
      'max_uses_per_user': maxUsesPerUser,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Response wrapper for bonus/coupon API calls
@immutable
class BonusResponse {
  final bool success;
  final List<Bonus> data;
  final String? message;

  const BonusResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory BonusResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return BonusResponse(
      success: json['success'] as bool? ?? false,
      data: dataList
          .map((b) => Bonus.fromJson(b as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}

/// Response wrapper for coupons
@immutable
class CouponResponse {
  final bool success;
  final List<Coupon> data;
  final String? message;

  const CouponResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return CouponResponse(
      success: json['success'] as bool? ?? false,
      data: dataList
          .map((c) => Coupon.fromJson(c as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}
