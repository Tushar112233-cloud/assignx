import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

/// HTTP client wrapper for the Express API backend.
///
/// Handles Bearer token authentication, auto-refresh on 401,
/// and provides convenience methods for all HTTP verbs.
class ApiClient {
  /// Base URL for the API server.
  /// Override with --dart-define=API_BASE_URL=https://api.assignx.com
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Production API URL
  static const String _productionUrl = 'https://api.assignx.com';

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    // Use production URL for release builds, localhost for debug
    const isRelease = bool.fromEnvironment('dart.vm.product');
    if (isRelease) return _productionUrl;
    // Debug: localhost for simulators/emulators
    if (Platform.isAndroid) return 'http://10.0.2.2:4000';
    return 'http://localhost:4000';
  }

  static final http.Client _httpClient = http.Client();

  /// Default timeout for API requests.
  static const Duration _timeout = Duration(seconds: 15);

  /// Build headers with optional auth token.
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Attempt to refresh the access token using the refresh token.
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await TokenStorage.saveTokens(
          data['accessToken'] as String,
          data['refreshToken'] as String,
        );
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    return false;
  }

  /// Process an HTTP response, retrying with a refreshed token on 401.
  static Future<http.Response> _withRetry(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    var headers = await _headers();
    var response = await request(headers);

    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        headers = await _headers();
        response = await request(headers);
      }
    }

    return response;
  }

  /// GET request.
  static Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl/api$path').replace(queryParameters: queryParams);
    final response = await _withRetry(
      (headers) => _httpClient.get(uri, headers: headers).timeout(_timeout),
    );
    return _handleResponse(response);
  }

  /// POST request.
  static Future<dynamic> post(String path, [dynamic body]) async {
    final uri = Uri.parse('$baseUrl/api$path');
    final response = await _withRetry(
      (headers) => _httpClient.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(_timeout),
    );
    return _handleResponse(response);
  }

  /// PUT request.
  static Future<dynamic> put(String path, [dynamic body]) async {
    final uri = Uri.parse('$baseUrl/api$path');
    final response = await _withRetry(
      (headers) => _httpClient.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(_timeout),
    );
    return _handleResponse(response);
  }

  /// DELETE request.
  static Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl/api$path');
    final response = await _withRetry(
      (headers) => _httpClient.delete(uri, headers: headers).timeout(_timeout),
    );
    return _handleResponse(response);
  }

  /// Upload a file via multipart POST.
  static Future<dynamic> uploadFile(
    String path,
    File file, {
    String fieldName = 'file',
    String? folder,
  }) async {
    final uri = Uri.parse('$baseUrl/api$path');
    final token = await TokenStorage.getAccessToken();

    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (folder != null) {
      request.fields['folder'] = folder;
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// Handle the HTTP response, throwing on errors.
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    String message;
    try {
      final body = jsonDecode(response.body);
      message = body['error'] ?? body['message'] ?? 'Request failed';
    } catch (_) {
      message = 'Request failed with status ${response.statusCode}';
    }

    throw ApiException(message, response.statusCode);
  }
}

/// Exception thrown by API calls.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
