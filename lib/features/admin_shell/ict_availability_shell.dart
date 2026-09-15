import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import 'workspaces/ict_hall_time_approval_panel.dart';

class IctAvailabilityShell extends StatelessWidget {
  const IctAvailabilityShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('General ICT Admin'),
            Text(
              'Hall & time availability only',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => AuthSession.instance.signOut(),
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IctHallTimeApprovalPanel(),
        ),
      ),
    );
  }
}
