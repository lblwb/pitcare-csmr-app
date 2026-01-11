import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pit_care/models/user.dart';
import 'package:pit_care/services/dio_client.dart';

/// Exception for user/auth-related API errors
class AuthException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  AuthException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => 'AuthException: $message (Status: $statusCode)';
}

/// Repository for managing authentication and user profile from API
class AuthRepository {
  final DioClient _dioClient;

  AuthRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Register a new user
  /// Endpoint: POST /api/auth/register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'referral_code': referralCode,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token != null) {
        _dioClient.setAuthToken(authResponse.token!);
      }
      return authResponse;
    } on DioException catch (e) {
      throw AuthException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw AuthException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Login user
  /// Endpoint: POST /api/auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token != null) {
        _dioClient.setAuthToken(authResponse.token!);
      }
      return authResponse;
    } on DioException catch (e) {
      throw AuthException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Get current user profile
  /// Endpoint: GET /api/auth/me
  Future<User> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get('/api/auth/me');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return User.fromJson(data['data'] as Map<String, dynamic>);
        }
        return User.fromJson(data);
      }
      throw AuthException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw AuthException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Update user profile
  /// Endpoint: PUT /api/auth/profile
  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (avatar != null) data['avatar'] = avatar;

      final response = await _dioClient.dio.put(
        '/api/auth/profile',
        data: data,
      );
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['data'] != null) {
          return User.fromJson(responseData['data'] as Map<String, dynamic>);
        }
        return User.fromJson(responseData);
      }
      throw AuthException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw AuthException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Change password
  /// Endpoint: POST /api/auth/change-password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw AuthException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw AuthException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Logout user
  /// Endpoint: POST /api/auth/logout
  Future<void> logout() async {
    try {
      await _dioClient.dio.post('/api/auth/logout');
      _dioClient.removeAuthToken();
    } on DioException catch (e) {
      throw AuthException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Request password reset
  /// Endpoint: POST /api/auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw AuthException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw AuthException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Reset password with token
  /// Endpoint: POST /api/auth/reset-password
  Future<AuthResponse> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/auth/reset-password',
        data: {'token': token, 'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token != null) {
        _dioClient.setAuthToken(authResponse.token!);
      }
      return authResponse;
    } on DioException catch (e) {
      throw AuthException(
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
