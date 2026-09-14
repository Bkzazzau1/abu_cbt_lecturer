class ApiConfig {
  const ApiConfig._();

  static const String _definedBaseUrl = String.fromEnvironment(
    'KSLAS_API_BASE_URL',
    defaultValue: '',
  );

  static const String productionAdminOrigin = 'https://admin.fazam.tech';
  static const String productionApiOrigin = 'https://api.fazam.tech';

  static String get baseUrl {
    final defined = _definedBaseUrl.trim();
    if (defined.isNotEmpty && !_isPlaceholder(defined)) {
      return _stripTrailingSlash(defined);
    }

    final currentOrigin = Uri.base.origin;
    if (currentOrigin == productionAdminOrigin) {
      return productionApiOrigin;
    }
    if (currentOrigin.startsWith('http')) {
      return _stripTrailingSlash(currentOrigin);
    }

    return 'http://localhost:8080';
  }

  static Uri uri(String path, [Map<String, String>? queryParameters]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$cleanPath').replace(
      queryParameters: queryParameters,
    );
  }

  static bool _isPlaceholder(String value) {
    final lower = value.toLowerCase();
    return lower.contains('your_backend_host') ||
        lower.contains('your-backend-host') ||
        lower.contains('your_backend_domain') ||
        lower.contains('example.com');
  }

  static String _stripTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
