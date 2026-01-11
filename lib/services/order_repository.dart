import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pit_care/models/order.dart';
import 'package:pit_care/services/dio_client.dart';

/// Exception for order-related API errors
class OrderException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  OrderException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => 'OrderException: $message (Status: $statusCode)';
}

/// Repository for managing orders from API
class OrderRepository {
  final DioClient _dioClient;

  OrderRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetch all user orders
  /// Endpoint: GET /api/orders
  Future<List<Order>> fetchOrders({int? status}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/orders',
        queryParameters: status != null ? {'status': status} : null,
        options: Options(extra: {'ttl': const Duration(seconds: 30)}),
      );
      final orderResponse = OrderResponse.fromJson(response.data);
      return orderResponse.data;
    } on DioException catch (e) {
      throw OrderException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw OrderException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Fetch a single order by ID
  /// Endpoint: GET /api/orders/{id}
  Future<Order> fetchOrderById(int orderId) async {
    try {
      final response = await _dioClient.dio.get('/api/orders/$orderId');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Order.fromJson(data['data'] as Map<String, dynamic>);
        }
        return Order.fromJson(data);
      }
      throw OrderException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw OrderException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Create a new order
  /// Endpoint: POST /api/orders
  Future<Order> createOrder({
    required int serviceId,
    int? vehicleId,
    required DateTime scheduledDate,
    String? notes,
    String? couponCode,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/orders',
        data: {
          'service_id': serviceId,
          'vehicle_id': vehicleId,
          'scheduled_date': scheduledDate.toIso8601String(),
          'notes': notes,
          'coupon_code': couponCode,
        },
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Order.fromJson(data['data'] as Map<String, dynamic>);
        }
        return Order.fromJson(data);
      }
      throw OrderException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw OrderException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Update an order
  /// Endpoint: PUT /api/orders/{id}
  Future<Order> updateOrder(
    int orderId, {
    DateTime? scheduledDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (scheduledDate != null)
        data['scheduled_date'] = scheduledDate.toIso8601String();
      if (notes != null) data['notes'] = notes;

      final response = await _dioClient.dio.put(
        '/api/orders/$orderId',
        data: data,
      );
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['data'] != null) {
          return Order.fromJson(responseData['data'] as Map<String, dynamic>);
        }
      }
      throw OrderException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw OrderException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Cancel an order
  /// Endpoint: POST /api/orders/{id}/cancel
  Future<Order> cancelOrder(int orderId, {String? reason}) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/orders/$orderId/cancel',
        data: reason != null ? {'reason': reason} : null,
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Order.fromJson(data['data'] as Map<String, dynamic>);
        }
        return Order.fromJson(data);
      }
      throw OrderException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw OrderException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Add review to a completed order
  /// Endpoint: POST /api/orders/{id}/review
  Future<Order> addReview(
    int orderId, {
    required int rating,
    required String review,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/orders/$orderId/review',
        data: {'rating': rating, 'review': review},
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Order.fromJson(data['data'] as Map<String, dynamic>);
        }
        return Order.fromJson(data);
      }
      throw OrderException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw OrderException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Get orders by status
  /// Endpoint: GET /api/orders?status={status}
  Future<List<Order>> fetchOrdersByStatus(String status) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/orders',
        queryParameters: {'status': status},
      );
      final orderResponse = OrderResponse.fromJson(response.data);
      return orderResponse.data;
    } on DioException catch (e) {
      throw OrderException(
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
