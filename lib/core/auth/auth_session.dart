import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffSession {
  const StaffSession({
    required this.token,
    required this.staffId,
    required this.email,
    required this.name,
    required this.primaryRole,
    required this.roles,
  });

  final String token;
  final String staffId;
  final String email;
  final String name;
  final String primaryRole;
  final List<String> roles;
}

class AuthSession extends ChangeNotifier {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  static const _tokenKey = 'kslas_staff_token';
  static const _staffIdKey = 'kslas_staff_id';
  static const _emailKey = 'kslas_staff_email';
  static const _nameKey = 'kslas_staff_name';
  static const _primaryRoleKey = 'kslas_staff_primary_role';
  static const _rolesKey = 'kslas_staff_roles';
  static const _envToken = String.fromEnvironment('KSLAS_STAFF_TOKEN');

  StaffSession? _session;

  StaffSession? get session => _session;
  bool get isSignedIn => _session?.token.isNotEmpty == true;
  String get token => _session?.token ?? _envToken;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey) ?? '';
    final token = savedToken.isNotEmpty ? savedToken : _envToken;

    if (token.isEmpty) {
      _session = null;
      notifyListeners();
      return;
    }

    _session = StaffSession(
      token: token,
      staffId: prefs.getString(_staffIdKey) ?? '',
      email: prefs.getString(_emailKey) ?? '',
      name: prefs.getString(_nameKey) ?? 'Staff member',
      primaryRole: prefs.getString(_primaryRoleKey) ?? '',
      roles: prefs.getStringList(_rolesKey) ?? const [],
    );

    notifyListeners();
  }

  Future<void> saveLogin(Map<String, dynamic> json) async {
    final token =
        json['access_token']?.toString() ?? json['token']?.toString() ?? '';

    final staff = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json['staff'] is Map
        ? Map<String, dynamic>.from(json['staff'] as Map)
        : <String, dynamic>{};

    final rawRoles = staff['roles'] ?? json['roles'];
    final roles = <String>[];
    var primaryRole = '';

    if (rawRoles is List) {
      for (final item in rawRoles) {
        if (item is Map) {
          final role =
              item['code']?.toString() ?? item['name']?.toString() ?? '';
          if (role.isNotEmpty) roles.add(role);

          final isPrimary = item['is_primary'] == true;
          if (isPrimary && role.isNotEmpty) {
            primaryRole = role;
          }
        } else {
          final role = item.toString();
          if (role.isNotEmpty) roles.add(role);
        }
      }
    }

    if (primaryRole.isEmpty && roles.isNotEmpty) {
      primaryRole = roles.first;
    }

    final nameParts = [
      staff['title']?.toString() ?? '',
      staff['first_name']?.toString() ?? '',
      staff['last_name']?.toString() ?? '',
    ].where((part) => part.trim().isNotEmpty).join(' ');

    _session = StaffSession(
      token: token,
      staffId: staff['id']?.toString() ?? '',
      email: staff['email']?.toString() ?? staff['identity']?.toString() ?? '',
      name: nameParts.isEmpty ? 'Staff member' : nameParts,
      primaryRole: primaryRole,
      roles: roles,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_staffIdKey, _session!.staffId);
    await prefs.setString(_emailKey, _session!.email);
    await prefs.setString(_nameKey, _session!.name);
    await prefs.setString(_primaryRoleKey, _session!.primaryRole);
    await prefs.setStringList(_rolesKey, roles);

    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_staffIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_primaryRoleKey);
    await prefs.remove(_rolesKey);

    _session = null;
    notifyListeners();
  }
}
