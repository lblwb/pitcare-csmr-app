import 'package:flutter/foundation.dart';

/// Vehicle model representing a user's vehicle
@immutable
class Vehicle {
  final int id;
  final int userId;
  final String make;
  final String model;
  final int year;
  final String vin;
  final String licensePlate;
  final String color;
  final String fuelType;
  final int mileage;
  final Map<String, dynamic>? equipment;
  final bool isPrimary;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.licensePlate,
    required this.color,
    required this.fuelType,
    required this.mileage,
    this.equipment,
    required this.isPrimary,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get full vehicle name (e.g., "Toyota Camry 2020")
  String get fullName => '$make $model $year';

  /// Get display name with license plate (e.g., "Toyota Camry 2020 (А123БВ77)")
  String get displayName => '$fullName ($licensePlate)';

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      vin: json['vin'] as String,
      licensePlate: json['license_plate'] as String,
      color: json['color'] as String,
      fuelType: json['fuel_type'] as String,
      mileage: json['mileage'] as int,
      equipment: json['equipment'] as Map<String, dynamic>?,
      isPrimary: json['is_primary'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'license_plate': licensePlate,
      'color': color,
      'fuel_type': fuelType,
      'mileage': mileage,
      'equipment': equipment,
      'is_primary': isPrimary,
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Response wrapper for vehicle API calls
@immutable
class VehicleResponse {
  final bool success;
  final List<Vehicle> data;
  final String? message;

  const VehicleResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return VehicleResponse(
      success: json['success'] as bool? ?? false,
      data: dataList
          .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }
}
