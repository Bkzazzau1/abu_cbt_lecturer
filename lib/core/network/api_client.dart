import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_session.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? client, String? token})
    : _client = client ?? http.Client(),
      _token = token;

  final http.Client _client;
  final String? _token;

  String get _resolvedToken => _token ?? AuthSession.instance.token;

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = _resolvedToken;
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, String> get _authHeaders {
    final headers = <String, String>{};
    final token = _resolvedToken;
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final response = await _client.get(
      ApiConfig.uri(path, query),
      headers: _headers,
    );
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final response = await _client.post(
      ApiConfig.uri(path, query),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final response = await _client.patch(
      ApiConfig.uri(path),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> uploadBytes({
    required String path,
    required List<int> bytes,
    required String fileName,
    String fieldName = 'file',
    String category = 'general',
  }) async {
    final request = http.MultipartRequest('POST', ApiConfig.uri(path));
    request.headers.addAll(_authHeaders);
    request.fields['category'] = category;
    request.files.add(
      http.MultipartFile.fromBytes(fieldName, bytes, filename: fileName),
    );
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    dynamic body;

    if (response.body.isEmpty) {
      body = null;
    } else {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map && body['message'] != null
          ? body['message'].toString()
          : body is Map && body['error'] != null
          ? body['error'].toString()
          : body is String && body.trim().isNotEmpty
          ? body.trim()
          : 'Request failed';
      throw ApiException(message, statusCode: response.statusCode);
    }

    return body;
  }

  void close() => _client.close();
}
