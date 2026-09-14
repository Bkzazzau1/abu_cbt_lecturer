import 'package:flutter/material.dart';

import 'auth_gate.dart';
import 'abu_theme.dart';

class AbuCbtAdminApp extends StatelessWidget {
  const AbuCbtAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ABU CBT Admin',
      theme: AbuTheme.light(),
      darkTheme: AbuTheme.dark(),
      home: const AuthGate(),
    );
  }
}
