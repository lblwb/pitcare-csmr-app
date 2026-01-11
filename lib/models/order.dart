import 'package:flutter/foundation.dart';

/// Order model representing a service order
@immutable
class Order {
  final int id;
  final int userId;
  final int serviceId;
  final int? vehicleId;
  final String status;
  final double totalPrice;
  final double? discountApplied;
  final String? notes;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String? masterNotes;
  final int? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.serviceId,
    this.vehicleId,
    required this.status,
    required this.totalPrice,
    this.discountApplied,
    this.notes,
    required this.scheduledDate,
    this.completedDate,
    this.masterNotes,
    this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if order is completed
  bool get isCompleted => status == 'completed';

  /// Check if order is pending
  bool get isPending => status == 'pending';

  /// Check if order is in progress
  bool get isInProgress => status == 'in_progress';

  /// Check if order is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Get status label in Russian
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'В ожидании';
      case 'confirmed':
        return 'Подтверждено';
      case 'in_progress':
        return 'В процессе';
      case 'completed':
        return 'Завершено';
      case 'cancelled':
        return 'Отменено';
      default:
        return status;
    }
  }

  /// Calculate final price after discount
  double get finalPrice => totalPrice - (discountApplied ?? 0);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      serviceId: json['service_id'] as int,
      vehicleId: json['vehicle_id'] as int?,
      status: json['status'] as String,
      totalPrice: double.parse((json['total_price'] ?? 0).toString()),
      discountApplied: json['discount_applied'] != null
          ? double.parse(json['discount_applied'].toString())
          : null,
      notes: json['notes'] as String?,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      masterNotes: json['master_notes'] as String?,
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'vehicle_id': vehicleId,
      'status': status,
      'total_price': totalPrice,
      'discount_applied': discountApplied,
      'notes': notes,
      'scheduled_date': scheduledDate.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'master_notes': masterNotes,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Response wrapper for order API calls
@immutable
class OrderResponse {
  final bool success;
  final List<Order> data;
  final String? message;

  const OrderResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return OrderResponse(
      success: json['success'] as bool? ?? false,
      data: dataList
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}
