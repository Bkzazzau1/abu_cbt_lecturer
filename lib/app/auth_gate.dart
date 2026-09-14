import 'package:flutter/material.dart';

import '../core/auth/auth_session.dart';
import '../features/auth/widgets/staff_login_screen.dart';
import 'connected_admin_home.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = AuthSession.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return AnimatedBuilder(
          animation: AuthSession.instance,
          builder: (context, _) {
            if (AuthSession.instance.isSignedIn) {
              return const ConnectedAdminHome();
            }
            return const StaffLoginScreen();
          },
        );
      },
    );
  }
}
