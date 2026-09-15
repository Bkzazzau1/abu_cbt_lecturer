import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import 'workspaces/ict_hall_time_approval_panel.dart';

class IctAvailabilityShell extends StatelessWidget {
  const IctAvailabilityShell({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final wideHeader = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.admin_panel_settings_outlined,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'General ICT Admin',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Hall & Time Operations',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (wideHeader)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Operational Access',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (wideHeader) const SizedBox(width: 8),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => AuthSession.instance.signOut(),
            icon: const Icon(Icons.logout_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            wideHeader ? 20 : 12,
            20,
            wideHeader ? 20 : 12,
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: const IctHallTimeApprovalPanel(),
            ),
          ),
        ),
      ),
    );
  }
}
