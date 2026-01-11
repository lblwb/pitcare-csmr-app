import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pit_care/models/promo_banner.dart';
import 'package:pit_care/services/dio_client.dart';

/// Exception for promo banner-related API errors
class PromoBannerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  PromoBannerException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'PromoBannerException: $message (Status: $statusCode)';
}

/// Repository for managing promo banners from API
class PromoBannerRepository {
  final DioClient _dioClient;

  PromoBannerRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetch all active promo banners
  /// Endpoint: GET /api/banners/active
  Future<List<PromoBannerModel>> fetchActiveBanners() async {
    try {
      final response = await _dioClient.dio.get(
        '/api/banners/active',
        options: Options(extra: {'ttl': const Duration(seconds: 60)}),
      );
      final bannerResponse = PromoBannerResponse.fromJson(response.data);

      // Filter by date range
      return bannerResponse.data.where((banner) => banner.isValid).toList();
    } on DioException catch (e) {
      throw PromoBannerException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw PromoBannerException(
        message: 'Unexpected error: $e',
        originalError: e,
      );
    }
  }

  /// Fetch all banners (including inactive)
  /// Endpoint: GET /api/banners
  Future<List<PromoBannerModel>> fetchAllBanners() async {
    try {
      final response = await _dioClient.dio.get('/api/banners');
      final bannerResponse = PromoBannerResponse.fromJson(response.data);
      return bannerResponse.data;
    } on DioException catch (e) {
      throw PromoBannerException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    } catch (e) {
      debugPrint(e.toString());
      throw PromoBannerException(
        message: 'Unexpected error: $e',
        originalError: e,
      );
    }
  }

  /// Fetch single banner by ID
  /// Endpoint: GET /api/banners/{id}
  Future<PromoBannerModel> fetchBannerById(int bannerId) async {
    try {
      final response = await _dioClient.dio.get('/api/banners/$bannerId');
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          return PromoBannerModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        }
        return PromoBannerModel.fromJson(data);
      }
      throw PromoBannerException(message: 'Invalid response format');
    } on DioException catch (e) {
      throw PromoBannerException(
        message: _parseErrorMessage(e),
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// Record banner display
  /// Endpoint: POST /api/banners/{id}/display
  Future<void> recordDisplay(int bannerId) async {
    try {
      await _dioClient.dio.post('/api/banners/$bannerId/display');
    } on DioException catch (e) {
      debugPrint('Failed to record display: ${_parseErrorMessage(e)}');
      // Don't throw - this is not critical
    } catch (e) {
      debugPrint('Error recording display: $e');
    }
  }

  /// Record banner click
  /// Endpoint: POST /api/banners/{id}/click
  Future<void> recordClick(int bannerId) async {
    try {
      await _dioClient.dio.post('/api/banners/$bannerId/click');
    } on DioException catch (e) {
      debugPrint('Failed to record click: ${_parseErrorMessage(e)}');
      // Don't throw - this is not critical
    } catch (e) {
      debugPrint('Error recording click: $e');
    }
  }

  /// Record banner impression and click together
  /// Endpoint: POST /api/banners/{id}/impression
  Future<void> recordImpression(int bannerId) async {
    try {
      await _dioClient.dio.post('/api/banners/$bannerId/impression');
    } on DioException catch (e) {
      debugPrint('Failed to record impression: ${_parseErrorMessage(e)}');
    } catch (e) {
      debugPrint('Error recording impression: $e');
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
