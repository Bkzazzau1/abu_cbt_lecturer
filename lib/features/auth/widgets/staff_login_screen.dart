import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../data/staff_auth_api.dart';

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final StaffAuthApi _api;
  bool _isLoading = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = StaffAuthApi();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _api.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await AuthSession.instance.saveLogin(result);
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1060),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(child: _BrandPanel(scheme: scheme)),
                const SizedBox(width: 24),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Staff sign in',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use your K-SLAS staff account to continue.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'Email address',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Email is required'
                                  : null,
                              onFieldSubmitted: (_) => _login(),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword,
                                  ),
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Password is required'
                                  : null,
                              onFieldSubmitted: (_) => _login(),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: scheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: scheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isLoading ? null : _login,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.login_outlined),
                                label: Text(
                                  _isLoading ? 'Signing in...' : 'Sign in',
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Backend: ${ApiConfig.baseUrl}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: scheme.onPrimary,
            foregroundColor: scheme.primary,
            child: const Icon(Icons.school_outlined, size: 32),
          ),
          const SizedBox(height: 28),
          Text(
            'K-SLAS Administration',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Manage lecturers, questions, assessments, CA, marked scripts, and live work alerts from one secure console.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _BrandChip(label: 'Lecturer workflow'),
              _BrandChip(label: 'Exam Officer'),
              _BrandChip(label: 'Live alerts'),
              _BrandChip(label: 'Analytics'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}
