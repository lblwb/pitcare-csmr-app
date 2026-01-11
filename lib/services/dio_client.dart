import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Singleton class for managing Dio HTTP client configuration
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    final String baseUrl =
        dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: dotenv.env['LOG_REQUEST_BODY'] == 'true',
        responseBody: dotenv.env['LOG_RESPONSE_BODY'] == 'true',
        error: dotenv.env['LOG_ERRORS'] == 'true',
        requestHeader: dotenv.env['LOG_REQUEST_HEADER'] == 'true',
        responseHeader: dotenv.env['LOG_RESPONSE_HEADER'] == 'true',
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );

    final cacheStore = DioCacheStore();

    // Add caching interceptor
    _dio.interceptors.add(DioTtlCacheInterceptor(cacheStore));

    // Add error handling interceptor
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;

  /// Update base URL dynamically
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Add authentication token to headers
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authentication token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

/// Custom error interceptor for handling API errors
class _ErrorInterceptor extends QueuedInterceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('API Error: ${err.message}');
    debugPrint('Status Code: ${err.response?.statusCode}');
    debugPrint('Response Data: ${err.response?.data}');
    super.onError(err, handler);
  }
}

class DioTtlCacheInterceptor extends Interceptor {
  final DioCacheStore cacheStore;

  DioTtlCacheInterceptor(this.cacheStore);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final ttl = options.extra['ttl'] as Duration?;
    if (ttl == null || options.method != 'GET') {
      return handler.next(options);
    }

    final key = _cacheKey(options);
    final cached = cacheStore.get(key);

    if (cached != null) {
      return handler.resolve(cached.response);
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final ttl = response.requestOptions.extra['ttl'] as Duration?;
    if (ttl != null && response.requestOptions.method == 'GET') {
      final key = _cacheKey(response.requestOptions);
      cacheStore.set(key, response, ttl);
    }

    handler.next(response);
  }

  String _cacheKey(RequestOptions o) => '${o.method}:${o.uri}';
}

/// Simple in-memory cache store for Dio responses
class DioCacheStore {
  final _cache = <String, CacheEntry>{};

  CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry;
  }

  void set(String key, Response response, Duration ttl) {
    _cache[key] = CacheEntry(
      response: response,
      expiry: DateTime.now().add(ttl),
    );
  }

  void clear() => _cache.clear();
}

class CacheEntry {
  final Response response;
  final DateTime expiry;

  CacheEntry({required this.response, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}
