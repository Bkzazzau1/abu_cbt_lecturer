import '../../../core/network/api_client.dart' show ApiException;
import 'demo_staff_accounts.dart';

/// Runs locally — no backend is required to demo staff sign-in. Matching one
/// of the demo staff emails (any non-empty password) signs in as that
/// portal, exactly like the "Continue as ..." shortcuts below the form. When
/// a real backend is ready, this is the file to swap back to an `ApiClient`
/// call against the documented `/api/auth/login` contract — the response
/// shape already matches it.
class StaffAuthApi {
  StaffAuthApi();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (password.trim().isEmpty) {
      throw const ApiException('Password is required');
    }

    final identity = email.trim().toLowerCase();
    for (final account in demoStaffAccounts) {
      if (account.email.toLowerCase() == identity) {
        return account.toLoginPayload();
      }
    }

    throw const ApiException('Invalid email or password');
  }

  void close() {}
}
