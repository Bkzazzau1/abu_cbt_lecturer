import 'package:flutter/material.dart';

import 'auth_gate.dart';
import 'kslas_theme.dart';

class KslasAdminApp extends StatelessWidget {
  const KslasAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KSLAS Admin',
      theme: KslasTheme.light(),
      darkTheme: KslasTheme.dark(),
      home: const AuthGate(),
    );
  }
}
