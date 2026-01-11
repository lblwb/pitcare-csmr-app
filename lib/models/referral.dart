import 'package:flutter/foundation.dart';

/// Referral model for referral program
@immutable
class Referral {
  final int id;
  final int referrerId;
  final int? referredUserId;
  final String referralCode;
  final int bonusAmount;
  final bool isUsed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? usedAt;

  const Referral({
    required this.id,
    required this.referrerId,
    this.referredUserId,
    required this.referralCode,
    required this.bonusAmount,
    required this.isUsed,
    required this.createdAt,
    required this.updatedAt,
    this.usedAt,
  });

  /// Check if referral is pending
  bool get isPending => !isUsed;

  /// Check if referral is completed
  bool get isCompleted => isUsed;

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as int,
      referrerId: json['referrer_id'] as int,
      referredUserId: json['referred_user_id'] as int?,
      referralCode: json['referral_code'] as String,
      bonusAmount: json['bonus_amount'] as int,
      isUsed: json['is_used'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referred_user_id': referredUserId,
      'referral_code': referralCode,
      'bonus_amount': bonusAmount,
      'is_used': isUsed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
    };
  }
}

/// Response wrapper for referral API calls
@immutable
class ReferralResponse {
  final bool success;
  final Referral? data;
  final String? message;

  const ReferralResponse({required this.success, this.data, this.message});

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null
          ? Referral.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}

/// Referral statistics model
@immutable
class ReferralStats {
  final int totalReferrals;
  final int completedReferrals;
  final int pendingReferrals;
  final int totalBonusEarned;

  const ReferralStats({
    required this.totalReferrals,
    required this.completedReferrals,
    required this.pendingReferrals,
    required this.totalBonusEarned,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      totalReferrals: json['total_referrals'] as int? ?? 0,
      completedReferrals: json['completed_referrals'] as int? ?? 0,
      pendingReferrals: json['pending_referrals'] as int? ?? 0,
      totalBonusEarned: json['total_bonus_earned'] as int? ?? 0,
    );
  }
}
