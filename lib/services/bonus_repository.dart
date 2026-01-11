import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pit_care/models/bonus.dart';
import 'package:pit_care/services/dio_client.dart';

/// Exception for bonus-related API errors
class BonusException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  BonusException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => 'BonusException: $message (Status: $statusCode)';
}

/// Repository for managing bonuses and coupons from API
class BonusRepository {
  final DioClient _dioClient;

  BonusRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetch all user bonuses
  /// Endpoint: GET /api/bonuses
  Future<List<Bonus>> fetchBonuses() async {
    try {
      final response = await _dioClient.dio.get('/api/bonuses');
      final bonusResponse = BonusResponse.fromJson(response.data);
      return bonusResponse.data;
    } on DioException catch (e) {
      throw BonusException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw BonusException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Fetch active bonuses only
  /// Endpoint: GET /api/bonuses/active
  Future<List<Bonus>> fetchActiveBonuses() async {
    try {
      final response = await _dioClient.dio.get('/api/bonuses/active');
      final bonusResponse = BonusResponse.fromJson(response.data);
      return bonusResponse.data;
    } on DioException catch (e) {
      throw BonusException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Get bonus statistics
  /// Endpoint: GET /api/bonuses/stats
  Future<Map<String, dynamic>> getBonusStats() async {
    try {
      final response = await _dioClient.dio.get('/api/bonuses/stats');
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw BonusException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw BonusException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Get bonus history
  /// Endpoint: GET /api/bonuses/history
  Future<List<Bonus>> getBonusHistory({int? limit}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/bonuses/history',
        queryParameters: limit != null ? {'limit': limit} : null,
      );
      final bonusResponse = BonusResponse.fromJson(response.data);
      return bonusResponse.data;
    } on DioException catch (e) {
      throw BonusException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Apply bonuses to an order
  /// Endpoint: POST /api/bonuses/apply
  Future<Map<String, dynamic>> applyBonuses({
    required int orderId,
    required int bonusAmount,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/bonuses/apply',
        data: {'order_id': orderId, 'bonus_amount': bonusAmount},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw BonusException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw BonusException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Fetch all available coupons
  /// Endpoint: GET /api/bonuses/coupons
  Future<List<Coupon>> fetchCoupons() async {
    try {
      final response = await _dioClient.dio.get('/api/bonuses/coupons');
      final couponResponse = CouponResponse.fromJson(response.data);
      return couponResponse.data;
    } on DioException catch (e) {
      throw BonusException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Use a coupon
  /// Endpoint: POST /api/bonuses/use-coupon
  Future<Map<String, dynamic>> useCoupon({
    required String couponCode,
    int? orderId,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/bonuses/use-coupon',
        data: {'coupon_code': couponCode, 'order_id': orderId},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw BonusException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw BonusException(
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
