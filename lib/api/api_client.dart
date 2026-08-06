import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// CHANGE THIS to your deployed backend.
/// Must be HTTPS for release/TestFlight builds (see README).
/// For local testing against the AWS box over plain HTTP you'll need to
/// allow cleartext traffic for that host — see README "Testing over HTTP".
const String kApiBaseUrl = 'http://3.80.51.211:3000/';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

/// Thin wrapper around Dio that:
///  - persists the backend's `fm_token` session cookie in a [PersistCookieJar]
///    and resends it automatically on every request
///  - exposes the same endpoints your Next.js app already calls under /api/*
///
/// NOTE: /api/auth/login, /api/auth/me, etc. authenticate purely via the
/// httpOnly `fm_token` cookie set on login/register — the backend does not
/// read an `Authorization: Bearer` header at all (verified: it 401s even
/// with a valid JWT there). So "logged in" here means "do we hold that
/// cookie", not "did the JSON body contain a token".
class ApiClient {
  ApiClient._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: kApiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        )) {
    _ready = _init();
  }

  static final ApiClient instance = ApiClient._internal();

  final Dio _dio;
  late final PersistCookieJar _cookieJar;
  late final Future<void> _ready;

  Future<void> _init() async {
    final dir = await getApplicationSupportDirectory();
    _cookieJar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies'));
    _dio.interceptors.add(CookieManager(_cookieJar));
    if (kDebugMode) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('--> ${options.method} ${options.uri}');
          if (options.data != null) debugPrint('    body: ${_redacted(options.data)}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
          debugPrint('    body: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint(
              '<-- ERROR ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.uri}: ${error.message}');
          if (error.response?.data != null) debugPrint('    body: ${error.response?.data}');
          handler.next(error);
        },
      ));
    }
  }

  dynamic _redacted(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('password')) {
      return {...data, 'password': '***'};
    }
    return data;
  }

  Future<bool> get isLoggedIn async {
    await _ready;
    final cookies = await _cookieJar.loadForRequest(Uri.parse(kApiBaseUrl));
    return cookies.any((c) => c.name == 'fm_token');
  }

  Future<void> logout() async {
    await _ready;
    try {
      await _dio.post('/api/auth/logout');
    } catch (_) {
      // ignore network errors on logout, cookie is cleared locally below
    }
    await _cookieJar.deleteAll();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await _ready;
    try {
      final res = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    await _ready;
    try {
      final res = await _dio.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> me() async {
    await _ready;
    try {
      final res = await _dio.get('/api/auth/me');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> dashboard() async {
    await _ready;
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
    await _ready;
    try {
      final res = await _dio.get(path, queryParameters: query);
      return res.data;
    } on DioException catch (e) {
      throw ApiException(_extractError(e), e.response?.statusCode);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    await _ready;
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
