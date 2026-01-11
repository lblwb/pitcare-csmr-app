import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pit_care/models/service.dart';
import 'package:pit_care/services/dio_client.dart';

/// Exception for service-related API errors
class ServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ServiceException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'ServiceException: $message (Status: $statusCode)';
}

/// Repository for managing service data from API
class ServiceRepository {
  final DioClient _dioClient;

  ServiceRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetch all services from the API
  /// Endpoint: GET /api/services
  Future<List<Service>> fetchServices() async {
    try {
      final response = await _dioClient.dio.get(
        '/api/services',
        options: Options(extra: {'ttl': const Duration(seconds: 60)}),
      );
      final serviceResponse = ServiceResponse.fromJson(response.data);
      return serviceResponse.data;
    } on DioException catch (e) {
      throw ServiceException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw ServiceException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Fetch services by category
  /// Endpoint: GET /api/services/categories/{categoryId}/services
  Future<List<Service>> fetchServicesByCategory(String categorySlug) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/services',
        queryParameters: {'category': categorySlug},
        options: Options(extra: {'ttl': const Duration(seconds: 60)}),
      );
      final serviceResponse = ServiceResponse.fromJson(response.data);
      return serviceResponse.data;
    } on DioException catch (e) {
      throw ServiceException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw ServiceException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Fetch popular services
  /// Endpoint: GET /api/services/popular
  Future<List<Service>> fetchPopularServices() async {
    try {
      final response = await _dioClient.dio.get('/api/services/popular');
      final serviceResponse = ServiceResponse.fromJson(response.data);
      return serviceResponse.data;
    } on DioException catch (e) {
      throw ServiceException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw ServiceException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Fetch services with discounts (deals)
  /// Endpoint: GET /api/shop/services/deals
  Future<List<Service>> fetchServiceDeals() async {
    try {
      final response = await _dioClient.dio.get('/api/shop/services/deals');
      final serviceResponse = ServiceResponse.fromJson(response.data);
      return serviceResponse.data;
    } on DioException catch (e) {
      throw ServiceException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw ServiceException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Fetch trending services
  /// Endpoint: GET /api/shop/services/trending
  Future<List<Service>> fetchTrendingServices() async {
    try {
      final response = await _dioClient.dio.get('/api/shop/services/trending');
      final serviceResponse = ServiceResponse.fromJson(response.data);
      return serviceResponse.data;
    } on DioException catch (e) {
      throw ServiceException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw ServiceException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Search services by query
  /// Endpoint: GET /api/services/search?q={query}
  Future<List<Service>> searchServices(String query) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/services/search',
        queryParameters: {'q': query},
      );
      final serviceResponse = ServiceResponse.fromJson(response.data);
      return serviceResponse.data;
    } on DioException catch (e) {
      throw ServiceException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw ServiceException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Fetch service details by ID
  /// Endpoint: GET /api/services/{id}
  Future<Service> fetchServiceById(int serviceId) async {
    try {
      serviceId = serviceId.toInt();
      final response = await _dioClient.dio.get(
        '/api/services/$serviceId',
        options: Options(extra: {'ttl': const Duration(seconds: 1)}),
      );

      // Handle different response formats
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return Service.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          // If no 'data' wrapper, parse directly
          return Service.fromJson(data);
        }
      }

      throw ServiceException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw ServiceException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      throw ServiceException(message: 'Unexpected error: $e', originalError: e);
    }
  }

  /// Parse error message from DioException
  String _parseErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return error.response?.data['message'] ?? 'Server error occurred';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        return 'Unknown error occurred: ${error.message}';
      case DioExceptionType.badCertificate:
        return 'Certificate error occurred';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet.';
    }
  }
}
