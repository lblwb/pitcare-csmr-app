// lib/services/promo_banner_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'promo_banner_model.dart';

class PromoBannerService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
  };

  /// Получить список активных баннеров
  Future<List<PromoBannerModel>> getActiveBanners() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/banners/active'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'] as List;

        return data
            .map(
              (item) => PromoBannerModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching banners: $e');
    }
  }

  /// Получить один баннер по ID (требуется admin токен)
  Future<PromoBannerModel> getBannerById(int id, String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/admin/banners/$id'),
            headers: {..._headers, 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PromoBannerModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load banner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching banner: $e');
    }
  }

  /// Записать просмотр баннера
  Future<void> recordDisplay(int bannerId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/banners/$bannerId/display'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Warning: Failed to record display: ${response.statusCode}');
      }
    } catch (e) {
      print('Error recording display: $e');
      // Не выбрасываем исключение, это не критично
    }
  }

  /// Записать клик по баннеру
  Future<void> recordClick(int bannerId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/banners/$bannerId/click'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Warning: Failed to record click: ${response.statusCode}');
      }
    } catch (e) {
      print('Error recording click: $e');
      // Не выбрасываем исключение, это не критично
    }
  }

  /// Создать новый баннер (требуется admin токен)
  Future<PromoBannerModel> createBanner(
    String token,
    Map<String, dynamic> bannerData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/admin/banners'),
            headers: {..._headers, 'Authorization': 'Bearer $token'},
            body: jsonEncode(bannerData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PromoBannerModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create banner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating banner: $e');
    }
  }

  /// Обновить баннер (требуется admin токен)
  Future<PromoBannerModel> updateBanner(
    String token,
    int bannerId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/admin/banners/$bannerId'),
            headers: {..._headers, 'Authorization': 'Bearer $token'},
            body: jsonEncode(updates),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PromoBannerModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update banner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating banner: $e');
    }
  }

  /// Удалить баннер (требуется admin токен)
  Future<void> deleteBanner(String token, int bannerId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/admin/banners/$bannerId'),
            headers: {..._headers, 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete banner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting banner: $e');
    }
  }

  /// Получить список всех баннеров с пагинацией (требуется admin токен)
  Future<Map<String, dynamic>> getAllBanners(
    String token, {
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/admin/banners?page=$page&per_page=$perPage',
            ),
            headers: {..._headers, 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final banners = (json['data'] as List)
            .map(
              (item) => PromoBannerModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        return {'banners': banners, 'pagination': json['pagination']};
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching banners: $e');
    }
  }

  /// Получить аналитику (требуется admin токен)
  Future<Map<String, dynamic>> getAnalytics(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/admin/banners/analytics'),
            headers: {..._headers, 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching analytics: $e');
    }
  }

  /// Переупорядочить баннеры (требуется admin токен)
  Future<void> reorderBanners(
    String token,
    List<Map<String, dynamic>> orders,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/admin/banners/reorder'),
            headers: {..._headers, 'Authorization': 'Bearer $token'},
            body: jsonEncode({'orders': orders}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to reorder banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error reordering banners: $e');
    }
  }

  /// Включить/выключить баннер (требуется admin токен)
  Future<PromoBannerModel> toggleBannerStatus(
    String token,
    int bannerId,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/admin/banners/$bannerId/toggle'),
            headers: {..._headers, 'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return PromoBannerModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to toggle banner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error toggling banner: $e');
    }
  }
}
