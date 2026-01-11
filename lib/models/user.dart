import 'package:flutter/foundation.dart';

/// User model representing an authenticated user
@immutable
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? subscriptionPlan;
  final int bonusBalance;
  final bool emailVerified;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.subscriptionPlan,
    required this.bonusBalance,
    required this.emailVerified,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      subscriptionPlan: json['subscription_plan'] as String?,
      bonusBalance: json['bonus_balance'] as int? ?? 0,
      emailVerified: json['email_verified'] as bool? ?? false,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'subscription_plan': subscriptionPlan,
      'bonus_balance': bonusBalance,
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// User authentication response
@immutable
class AuthResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? message;

  const AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      token: json['token'] as String?,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}
