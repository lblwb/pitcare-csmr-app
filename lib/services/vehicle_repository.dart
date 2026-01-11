import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pit_care/models/vehicle.dart';
import 'package:pit_care/services/dio_client.dart';

/// Exception for vehicle-related API errors
class VehicleException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  VehicleException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'VehicleException: $message (Status: $statusCode)';
}

/// Repository for managing vehicle data from API
class VehicleRepository {
  final DioClient _dioClient;

  VehicleRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetch all vehicles for current user
  /// Endpoint: GET /api/vehicles
  Future<List<Vehicle>> fetchVehicles() async {
    try {
      final response = await _dioClient.dio.get(
        '/api/vehicles',
        options: Options(extra: {'ttl': const Duration(seconds: 30)}),
      );
      final vehicleResponse = VehicleResponse.fromJson(response.data);
      return vehicleResponse.data;
    } on DioException catch (e) {
      throw VehicleException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw VehicleException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Fetch a single vehicle by ID
  /// Endpoint: GET /api/vehicles/{id}
  Future<Vehicle> fetchVehicleById(int vehicleId) async {
    try {
      final response = await _dioClient.dio.get('/api/vehicles/$vehicleId');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Vehicle.fromJson(data['data'] as Map<String, dynamic>);
        }
        return Vehicle.fromJson(data);
      }
      throw VehicleException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw VehicleException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Create a new vehicle
  /// Endpoint: POST /api/vehicles
  Future<Vehicle> createVehicle({
    required String make,
    required String model,
    required int year,
    required String vin,
    required String licensePlate,
    required String color,
    required String fuelType,
    required int mileage,
    Map<String, dynamic>? equipment,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/vehicles',
        data: {
          'make': make,
          'model': model,
          'year': year,
          'vin': vin,
          'license_plate': licensePlate,
          'color': color,
          'fuel_type': fuelType,
          'mileage': mileage,
          'equipment': equipment,
          'notes': notes,
        },
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Vehicle.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw VehicleException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw VehicleException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Update an existing vehicle
  /// Endpoint: PUT /api/vehicles/{id}
  Future<Vehicle> updateVehicle(
    int vehicleId, {
    String? make,
    String? model,
    int? year,
    String? color,
    String? fuelType,
    int? mileage,
    Map<String, dynamic>? equipment,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (make != null) data['make'] = make;
      if (model != null) data['model'] = model;
      if (year != null) data['year'] = year;
      if (color != null) data['color'] = color;
      if (fuelType != null) data['fuel_type'] = fuelType;
      if (mileage != null) data['mileage'] = mileage;
      if (equipment != null) data['equipment'] = equipment;
      if (notes != null) data['notes'] = notes;

      final response = await _dioClient.dio.put(
        '/api/vehicles/$vehicleId',
        data: data,
      );
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['data'] != null) {
          return Vehicle.fromJson(responseData['data'] as Map<String, dynamic>);
        }
      }
      throw VehicleException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw VehicleException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Delete a vehicle
  /// Endpoint: DELETE /api/vehicles/{id}
  Future<void> deleteVehicle(int vehicleId) async {
    try {
      await _dioClient.dio.delete('/api/vehicles/$vehicleId');
    } on DioException catch (e) {
      throw VehicleException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Set vehicle as primary
  /// Endpoint: POST /api/vehicles/{id}/set-primary
  Future<Vehicle> setAsPrimary(int vehicleId) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/vehicles/$vehicleId/set-primary',
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Vehicle.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      throw VehicleException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw VehicleException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  String _parseErrorMessage(DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      final data = error.response!.data as Map<String, dynamic>;
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return error.message ?? 'An error occurred';
  }
}
