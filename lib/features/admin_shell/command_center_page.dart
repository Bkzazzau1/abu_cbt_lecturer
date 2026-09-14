import 'package:flutter/material.dart';

import '../../core/auth/auth_session.dart';
import '../live_dashboard/widgets/live_dashboard_panel.dart';
import '../role_dashboard/widgets/role_dashboard_panel.dart';
import '../staff_management/widgets/staff_management_panel.dart';
import '../workflow/widgets/workflow_live_panel.dart';

class CommandCenterPage extends StatelessWidget {
  const CommandCenterPage({
    super.key,
    required this.role,
    required this.onOpenPage,
  });

  final String role;
  final ValueChanged<String> onOpenPage;

  bool get _canManageStaff => const {
    'admin',
    'super_admin',
    'superadmin',
    'dlc_director',
    'hod',
  }.contains(role);
  bool get _canUseForms =>
      role == 'lecturer' || role == 'admin' || role == 'dlc_director';
  bool get _canSeeFullConsole => const {
    'admin',
    'super_admin',
    'superadmin',
    'dlc_director',
  }.contains(role);

  @override
  Widget build(BuildContext context) {
    final session = AuthSession.instance.session;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroHeader(
              sessionName: session?.name ?? 'Staff member',
              role: role,
              scheme: scheme,
            ),
            const SizedBox(height: 18),
            _ActionGrid(
              actions: [
                _CommandAction(
                  label: 'My role workspace',
                  description: 'Open the live queue for your signed-in role.',
                  icon: Icons.admin_panel_settings_outlined,
                  target: 'My role',
                ),
                if (_canManageStaff)
                  _CommandAction(
                    label: 'Staff management',
                    description: 'Create staff accounts and assign roles.',
                    icon: Icons.badge_outlined,
                    target: 'Staff management',
                  ),
                if (_canUseForms)
                  _CommandAction(
                    label: 'Smart forms',
                    description: 'Submit assignments, CA, and marked scripts.',
                    icon: Icons.dynamic_form_outlined,
                    target: 'Smart forms',
                  ),
                _CommandAction(
                  label: 'Live workflow',
                  description: 'See assignments, CA, and exam-script workflow.',
                  icon: Icons.account_tree_outlined,
                  target: 'Live workflow',
                ),
                _CommandAction(
                  label: 'Live dashboard',
                  description: 'View analytics, alerts, and current activity.',
                  icon: Icons.insights_outlined,
                  target: 'Live dashboard',
                ),
                if (_canSeeFullConsole)
                  _CommandAction(
                    label: 'Full console',
                    description: 'Open the complete administrative console.',
                    icon: Icons.dashboard_customize_outlined,
                    target: 'Full console',
                  ),
              ],
              onOpenPage: onOpenPage,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 1120;
                final left = Column(
                  children: const [
                    RoleDashboardPanel(),
                    SizedBox(height: 16),
                    LiveDashboardPanel(),
                  ],
                );
                final right = Column(
                  children: [
                    if (_canManageStaff) const StaffManagementPanel(),
                    if (_canManageStaff) const SizedBox(height: 16),
                    const WorkflowLivePanel(),
                  ],
                );
                if (!wide) {
                  return Column(
                    children: [left, const SizedBox(height: 16), right],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: left),
                    const SizedBox(width: 16),
                    Expanded(flex: 4, child: right),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.sessionName,
    required this.role,
    required this.scheme,
  });

  final String sessionName;
  final String role;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 18,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(label: Text(_roleLabel(role))),
                const SizedBox(height: 14),
                Text(
                  'Welcome, $sessionName',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your K-SLAS workspace is now role-aware, live-connected, and focused on the work that matters most for your responsibility.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroMetric(label: 'Role access', value: 'Locked'),
                const SizedBox(height: 10),
                _HeroMetric(label: 'Backend mode', value: 'Live'),
                const SizedBox(height: 10),
                _HeroMetric(label: 'Alerts', value: 'Enabled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'dlc_director':
        return 'DLC Director';
      case 'exam_officer':
        return 'Exam Officer';
      case 'academic_records':
        return 'Academic Records';
      case 'level_adviser':
        return 'Level Adviser';
      default:
        return role.replaceAll('_', ' ').toUpperCase();
    }
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_outline, color: scheme.onPrimary, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.78)),
        ),
        Text(
          value,
          style: TextStyle(
            color: scheme.onPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions, required this.onOpenPage});

  final List<_CommandAction> actions;
  final ValueChanged<String> onOpenPage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 1200
            ? 4
            : width > 840
            ? 3
            : width > 560
            ? 2
            : 1;
        final itemWidth = (width - ((columns - 1) * 12)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final action in actions)
              SizedBox(
                width: itemWidth,
                child: _ActionCard(
                  action: action,
                  onTap: () => onOpenPage(action.target),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.onTap});

  final _CommandAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(action.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }
}

class _CommandAction {
  const _CommandAction({
    required this.label,
    required this.description,
    required this.icon,
    required this.target,
  });

  final String label;
  final String description;
  final IconData icon;
  final String target;
}
