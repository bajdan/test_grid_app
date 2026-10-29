import 'dart:convert';

import 'package:http/http.dart' as http;

class TaskApiClient {
  TaskApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 30);

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(_timeout);
    _checkStatus(response);
    final decoded = _decode(response.body);
    if (decoded is! Map) {
      throw const ApiException('The server returned an invalid response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> postJson(Uri uri, Object body) async {
    final response = await _client
        .post(
          uri,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    _checkStatus(response);
    if (response.body.trim().isEmpty) return;

    final decoded = _decode(response.body);
    if (decoded is Map && decoded['error'] == true) {
      final message = decoded['message'];
      throw ApiException(
        message is String && message.isNotEmpty
            ? message
            : 'The server rejected the results.',
      );
    }
  }

  void close() => _client.close();

  Object? _decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const ApiException('The server returned invalid JSON.');
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Request failed (HTTP ${response.statusCode}).');
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
