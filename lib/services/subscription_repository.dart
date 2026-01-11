import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pit_care/models/subscription.dart';
import 'package:pit_care/services/dio_client.dart';

/// Exception for subscription-related API errors
class SubscriptionException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  SubscriptionException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'SubscriptionException: $message (Status: $statusCode)';
}

/// Repository for managing subscriptions from API
class SubscriptionRepository {
  final DioClient _dioClient;

  SubscriptionRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetch all subscription plans
  /// Endpoint: GET /api/subscriptions/plans
  Future<List<SubscriptionPlan>> fetchPlans() async {
    try {
      final response = await _dioClient.dio.get(
        '/api/subscriptions/plans',
        options: Options(extra: {'ttl': const Duration(seconds: 30)}),
      );
      final planResponse = SubscriptionPlanResponse.fromJson(response.data);
      return planResponse.data;
    } on DioException catch (e) {
      throw SubscriptionException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw SubscriptionException(
        message: 'Unexpected error: $e',
        originalError: e,
      );
    }
  }

  /// Get current user's active subscription
  /// Endpoint: GET /api/subscriptions/current
  Future<UserSubscription> getCurrentSubscription() async {
    try {
      final response = await _dioClient.dio.get('/api/subscriptions/current');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return UserSubscription.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        return UserSubscription.fromJson(data);
      }
      throw SubscriptionException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw SubscriptionException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Subscribe to a plan
  /// Endpoint: POST /api/subscriptions/subscribe
  Future<UserSubscription> subscribe(int planId) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/subscriptions/subscribe',
        data: {'plan_id': planId},
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return UserSubscription.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        return UserSubscription.fromJson(data);
      }
      throw SubscriptionException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw SubscriptionException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Cancel current subscription
  /// Endpoint: POST /api/subscriptions/cancel
  Future<UserSubscription> cancelSubscription({String? reason}) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/subscriptions/cancel',
        data: reason != null ? {'reason': reason} : null,
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return UserSubscription.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        return UserSubscription.fromJson(data);
      }
      throw SubscriptionException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw SubscriptionException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Renew subscription
  /// Endpoint: POST /api/subscriptions/renew
  Future<UserSubscription> renewSubscription() async {
    try {
      final response = await _dioClient.dio.post('/api/subscriptions/renew');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return UserSubscription.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        return UserSubscription.fromJson(data);
      }
      throw SubscriptionException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw SubscriptionException(
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
