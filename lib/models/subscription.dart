import 'package:flutter/foundation.dart';

/// Subscription plan model
@immutable
class SubscriptionPlan {
  final int id;
  final String name;
  final String slug;
  final double price;
  final int durationDays;
  final Map<String, dynamic>? features;
  final int maxVehicles;
  final double bonusMultiplier;
  final bool referralProgram;
  final bool isFree;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.durationDays,
    this.features,
    required this.maxVehicles,
    required this.bonusMultiplier,
    required this.referralProgram,
    required this.isFree,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get formatted price with currency
  String get formattedPrice => '$price ₽';

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: double.parse((json['price'] ?? 0).toString()),
      durationDays: json['duration_days'] as int,
      features: json['features'] as Map<String, dynamic>?,
      maxVehicles: json['max_vehicles'] as int? ?? 1,
      bonusMultiplier: double.parse((json['bonus_multiplier'] ?? 1).toString()),
      referralProgram: json['referral_program'] as bool? ?? false,
      isFree: json['is_free'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'duration_days': durationDays,
      'features': features,
      'max_vehicles': maxVehicles,
      'bonus_multiplier': bonusMultiplier,
      'referral_program': referralProgram,
      'is_free': isFree,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// User subscription model
@immutable
class UserSubscription {
  final int id;
  final int userId;
  final int planId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.cancelReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if subscription is expired
  bool get isExpired => DateTime.now().isAfter(endDate);

  /// Get days remaining
  int get daysRemaining {
    final remaining = endDate.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      planId: json['plan_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? false,
      cancelReason: json['cancel_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'cancel_reason': cancelReason,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Response wrapper for subscription API calls
@immutable
class SubscriptionPlanResponse {
  final bool success;
  final List<SubscriptionPlan> data;
  final int? count;

  const SubscriptionPlanResponse({
    required this.success,
    required this.data,
    this.count,
  });

  factory SubscriptionPlanResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return SubscriptionPlanResponse(
      success: json['success'] as bool? ?? false,
      data: dataList
          .map((s) => SubscriptionPlan.fromJson(s as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );
  }
}
