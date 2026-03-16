import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);
  }

  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Attempt to refresh expired access token using stored refresh token.
  static Future<bool> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>> get(String path) async {
    var response = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    if (response.statusCode == 401 && await _refreshToken()) {
      response = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    }
    return _handleResponse(response);
  }

  static Future<List<dynamic>> getList(String path) async {
    var response = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    if (response.statusCode == 401 && await _refreshToken()) {
      response = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw ApiException(_extractError(response));
  }

  static Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    var response = await http.post(Uri.parse('$baseUrl$path'), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    if (response.statusCode == 401 && await _refreshToken()) {
      response = await http.post(Uri.parse('$baseUrl$path'), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    }
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    var response = await http.put(Uri.parse('$baseUrl$path'), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    if (response.statusCode == 401 && await _refreshToken()) {
      response = await http.put(Uri.parse('$baseUrl$path'), headers: await _headers(), body: body != null ? jsonEncode(body) : null);
    }
    return _handleResponse(response);
  }

  static Future<void> delete(String path) async {
    var response = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
    if (response.statusCode == 401 && await _refreshToken()) {
      response = await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers());
    }
    if (response.statusCode >= 300) {
      throw ApiException(_extractError(response));
    }
  }

  static Future<Map<String, dynamic>> uploadFile(
    String path, String filePath, String fieldName,
    {Map<String, String>? fields}
  ) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
    if (fields != null) request.fields.addAll(fields);
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(_extractError(response));
  }

  static String _extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['error'] ?? 'Request failed (${response.statusCode})';
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
