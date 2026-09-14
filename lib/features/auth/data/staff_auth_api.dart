import '../../../core/network/api_client.dart';

class StaffAuthApi {
  StaffAuthApi({ApiClient? client}) : _client = client ?? ApiClient(token: '');

  final ApiClient _client;

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final data = await _client.post(
      '/api/auth/login',
      body: {'identity': email.trim(), 'password': password},
    );
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.map((key, value) => MapEntry(key.toString(), value));
    throw const ApiException('Unexpected login response');
  }

  void close() => _client.close();
}
