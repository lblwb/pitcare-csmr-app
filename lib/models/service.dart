import 'package:flutter/foundation.dart';

/// Service model representing a single service in the catalog
@immutable
class Service {
  final int? id;
  final String name;
  final String slug;
  final String description;
  final String? category;
  final int basePrice;
  final int currentPrice;
  final bool hasDiscount;
  final int estimatedDurationMinutes;
  final String? iconUrl;
  final String? imageUrl;
  final String difficultyLevel;
  final int popularityScore;
  final int ordersCount;

  const Service({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.category,
    required this.basePrice,
    required this.currentPrice,
    required this.hasDiscount,
    required this.estimatedDurationMinutes,
    this.iconUrl,
    this.imageUrl,
    required this.difficultyLevel,
    required this.popularityScore,
    required this.ordersCount,
  });

  /// Calculate discount percentage
  int get discountPercentage {
    if (basePrice == 0) return 0;
    return (((basePrice - currentPrice) / basePrice) * 100).toInt();
  }

  /// Get display price
  String get displayPrice {
    return '$currentPrice ₽';
  }

  /// Get discount display text
  String? get discountText {
    if (!hasDiscount) return null;
    return '-${discountPercentage}%';
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString() ?? '0'),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String?,
      basePrice: json['base_price'] is int
          ? json['base_price']
          : int.tryParse(json['base_price'].toString() ?? '0') ?? 0,
      currentPrice: json['current_price'] is int
          ? json['current_price']
          : int.tryParse(json['current_price'].toString() ?? '0') ?? 0,
      hasDiscount: json['has_discount'] is bool ? json['has_discount'] : false,
      estimatedDurationMinutes: json['estimated_duration_minutes'] is int
          ? json['estimated_duration_minutes']
          : int.tryParse(
                  json['estimated_duration_minutes'].toString() ?? '0',
                ) ??
                0,
      iconUrl: json['icon_url'] as String?,
      imageUrl: json['image_url'] as String?,
      difficultyLevel: json['difficulty_level'] as String? ?? 'Unknown',
      popularityScore: json['popularity_score'] is int
          ? json['popularity_score']
          : int.tryParse(json['popularity_score'].toString() ?? '0') ?? 0,
      ordersCount: json['orders_count'] is int
          ? json['orders_count']
          : int.tryParse(json['orders_count'].toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'category': category,
      'base_price': basePrice,
      'current_price': currentPrice,
      'has_discount': hasDiscount,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'icon_url': iconUrl,
      'image_url': imageUrl,
      'difficulty_level': difficultyLevel,
      'popularity_score': popularityScore,
      'orders_count': ordersCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Service &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          slug == other.slug;

  @override
  int get hashCode => id.hashCode ^ slug.hashCode;

  @override
  String toString() => 'Service(id: $id, name: $name, category: $category)';
}

/// Response wrapper for services API
@immutable
class ServiceResponse {
  final bool success;
  final List<Service> data;

  const ServiceResponse({required this.success, required this.data});

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() =>
      'ServiceResponse(success: $success, items: ${data.length})';
}
