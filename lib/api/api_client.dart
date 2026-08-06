import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// CHANGE THIS to your deployed backend.
/// Must be HTTPS for release/TestFlight builds (see README).
/// For local testing against the AWS box over plain HTTP you'll need to
/// allow cleartext traffic for that host — see README "Testing over HTTP".
const String kApiBaseUrl = 'https://YOUR_DOMAIN_HERE';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

/// Thin wrapper around Dio that:
///  - stores the JWT in secure storage after login/register
///  - attaches it as `Authorization: Bearer <token>` to every request
///  - exposes the same endpoints your Next.js app already calls under /api/*
///
/// NOTE: today /api/auth/login and /api/auth/register only set an
/// httpOnly cookie. For this client to work you need to also return the
/// token in the JSON body — see the 3-line backend change in the README.
class ApiClient {
  ApiClient._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: kApiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();

  final Dio _dio;
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'fm_token';

  Future<void> _saveTokenFromResponse(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  Future<bool> get isLoggedIn async => (await _storage.read(key: _tokenKey)) != null;

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    try {
      await _dio.post('/api/auth/logout');
    } catch (_) {
      // ignore network errors on logout, token is already cleared locally
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      await _saveTokenFromResponse(data);
      return data;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      await _saveTokenFromResponse(data);
      return data;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> me() async {
    try {
      final res = await _dio.get('/api/auth/me');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> dashboard() async {
    try {
      final res = await _dio.get('/api/dashboard');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  /// Generic GET helper for the rest of the /api/* endpoints
  /// (transactions, accounts, budgets, goals, credits, subscriptions, ...).
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await _dio.get(path, queryParameters: query);
      return res.data;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) return data['error'] as String;
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'Не удалось подключиться к серверу. Проверь адрес backend и сеть.';
    }
    return e.message ?? 'Что-то пошло не так. Попробуйте ещё раз.';
  }
}
