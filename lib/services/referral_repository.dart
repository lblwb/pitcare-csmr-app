import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pit_care/models/referral.dart';
import 'package:pit_care/services/dio_client.dart';

/// Exception for referral-related API errors
class ReferralException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ReferralException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ReferralException: $message (Status: $statusCode)';
}

/// Repository for managing referral program from API
class ReferralRepository {
  final DioClient _dioClient;

  ReferralRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Get or generate user's referral code
  /// Endpoint: GET /api/referrals/code
  Future<String> getReferralCode() async {
    try {
      final response = await _dioClient.dio.get('/api/referrals/code');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return data['code'] as String? ?? '';
      }
      throw ReferralException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ReferralException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw ReferralException(
        message: 'Unexpected error: $e',
        originalError: e,
      );
    }
  }

  /// Get referral code information
  /// Endpoint: GET /api/referrals/code/{code}
  Future<Referral> getReferralCodeInfo(String code) async {
    try {
      final response = await _dioClient.dio.get('/api/referrals/code/$code');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Referral.fromJson(data['data'] as Map<String, dynamic>);
        }
        return Referral.fromJson(data);
      }
      throw ReferralException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ReferralException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Get all referrals made by user
  /// Endpoint: GET /api/referrals
  Future<List<Referral>> fetchReferrals() async {
    try {
      final response = await _dioClient.dio.get('/api/referrals');
      if (response.data is Map<String, dynamic>) {
        final dataList =
            (response.data as Map<String, dynamic>)['data'] as List<dynamic>? ??
            [];
        return dataList
            .map((r) => Referral.fromJson(r as Map<String, dynamic>))
            .toList();
      }
      throw ReferralException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ReferralException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Get referral statistics
  /// Endpoint: GET /api/referrals/stats
  Future<ReferralStats> getReferralStats() async {
    try {
      final response = await _dioClient.dio.get('/api/referrals/stats');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return ReferralStats.fromJson(data['data'] as Map<String, dynamic>);
        }
        return ReferralStats.fromJson(data);
      }
      throw ReferralException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ReferralException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Register using a referral code
  /// Endpoint: POST /api/referrals/register
  Future<Map<String, dynamic>> registerWithReferralCode(
    String referralCode,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/referrals/register',
        data: {'referral_code': referralCode},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw ReferralException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ReferralException(
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
