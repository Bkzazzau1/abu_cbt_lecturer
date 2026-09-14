import 'package:flutter/material.dart';

import '../../data/mock_admin_repository.dart';
import '../../models/admin_role.dart';
import '../../models/dashboard_models.dart';
import 'widgets/admin_metric_card.dart';

const _adminPages = [
  _PageItem('Dashboard', Icons.dashboard_outlined),
  _PageItem('Notices', Icons.campaign_outlined),
  _PageItem('Course Registration', Icons.app_registration_outlined),
  _PageItem('Assignments', Icons.assignment_ind_outlined),
  _PageItem('Exams', Icons.assignment_outlined),
  _PageItem('Results', Icons.workspace_premium_outlined),
  _PageItem('Records', Icons.badge_outlined),
  _PageItem('Approvals', Icons.fact_check_outlined),
  _PageItem('People', Icons.groups_outlined),
];

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final MockAdminRepository _repository = const MockAdminRepository();
  AdminRole _selectedRole = AdminRole.superAdmin;
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final compactSelectedPage = _selectedPage > 4 ? 4 : _selectedPage;

    return Scaffold(
      appBar: compact
          ? AppBar(
              title: const Text('KSLAS Admin'),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_outlined),
                ),
              ],
            )
          : null,
      drawer: compact
          ? _AdminDrawer(
              selectedRole: _selectedRole,
              onRoleChanged: _changeRole,
            )
          : null,
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: compactSelectedPage,
              onDestinationSelected: (value) {
                setState(() => _selectedPage = value);
              },
              destinations: [
                for (final page in _adminPages.take(5))
                  NavigationDestination(
                    icon: Icon(page.icon),
                    label: page.label,
                  ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!compact)
            _SideRail(
              selectedPage: _selectedPage,
              selectedRole: _selectedRole,
              onPageChanged: (value) {
                setState(() => _selectedPage = value);
              },
              onRoleChanged: _changeRole,
            ),
          Expanded(
            child: _AdminWorkspace(
              pageLabel: _adminPages[_selectedPage].label,
              selectedRole: _selectedRole,
              repository: _repository,
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }

  void _changeRole(AdminRole role) {
    setState(() => _selectedRole = role);
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.selectedPage,
    required this.selectedRole,
    required this.onPageChanged,
    required this.onRoleChanged,
  });

  final int selectedPage;
  final AdminRole selectedRole;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<AdminRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 292,
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: const Icon(Icons.account_balance_outlined),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'KSLAS Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (var index = 0; index < _adminPages.length; index++)
                    _NavTile(
                      label: _adminPages[index].label,
                      icon: _adminPages[index].icon,
                      selected: selectedPage == index,
                      onTap: () => onPageChanged(index),
                    ),
                  const Divider(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Role view',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        for (final role in AdminRole.values)
                          _RoleTile(
                            role: role,
                            selected: role == selectedRole,
                            onTap: () => onRoleChanged(role),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({required this.selectedRole, required this.onRoleChanged});

  final AdminRole selectedRole;
  final ValueChanged<AdminRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const ListTile(
              leading: Icon(Icons.account_balance_outlined),
              title: Text('KSLAS Admin'),
              subtitle: Text('Operational console'),
            ),
            const Divider(),
            for (final role in AdminRole.values)
              _RoleTile(
                role: role,
                selected: role == selectedRole,
                onTap: () {
                  Navigator.pop(context);
                  onRoleChanged(role);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminWorkspace extends StatelessWidget {
  const _AdminWorkspace({
    required this.pageLabel,
    required this.selectedRole,
    required this.repository,
    required this.compact,
  });

  final String pageLabel;
  final AdminRole selectedRole;
  final MockAdminRepository repository;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final metrics = repository.metricsFor(selectedRole);
    final tasks = repository.tasksFor(selectedRole, pageLabel: pageLabel);
    final rooms = repository.examRooms();
    final alerts = repository.alerts();
    final workflows = repository.workflowsFor(pageLabel);
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 28,
              compact ? 8 : 24,
              compact ? 16 : 28,
              16,
            ),
            sliver: SliverToBoxAdapter(
              child: _WorkspaceHeader(role: selectedRole, pageLabel: pageLabel),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 28),
            sliver: SliverGrid.builder(
              itemCount: metrics.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: compact
                    ? 1
                    : width > 1180
                    ? 4
                    : 2,
                mainAxisExtent: AdminMetricCard.gridExtent,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return AdminMetricCard(metric: metrics[index]);
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 28,
              18,
              compact ? 16 : 28,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: _WorkflowPanel(workflows: workflows),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(compact ? 16 : 28),
            sliver: SliverToBoxAdapter(
              child: compact
                  ? Column(
                      children: [
                        _TaskPanel(tasks: tasks),
                        const SizedBox(height: 16),
                        _ExamPanel(rooms: rooms),
                        const SizedBox(height: 16),
                        _AlertPanel(alerts: alerts),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _TaskPanel(tasks: tasks)),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _ExamPanel(rooms: rooms),
                              const SizedBox(height: 16),
                              _AlertPanel(alerts: alerts),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.role, required this.pageLabel});

  final AdminRole role;
  final String pageLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pageLabel, style: text.labelLarge),
              const SizedBox(height: 4),
              Text(
                '${role.label} workspace',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(role.scope, style: text.bodyLarge),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_task_outlined),
          label: Text(pageLabel == 'Notices' ? 'Publish notice' : 'New action'),
        ),
      ],
    );
  }
}

class _WorkflowPanel extends StatelessWidget {
  const _WorkflowPanel({required this.workflows});

  final List<String> workflows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workspace coverage',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final workflow in workflows)
                  Chip(
                    avatar: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(workflow),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskPanel extends StatelessWidget {
  const _TaskPanel({required this.tasks});

  final List<AdminTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority work queue',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final task in tasks) _TaskTile(task: task),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final AdminTask task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = task.status.color(scheme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(task.ownerRole.icon, color: statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(task.description),
                const SizedBox(height: 4),
                Text(
                  '${task.ownerRole.label} • ${task.due}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          _StatusPill(status: task.status),
        ],
      ),
    );
  }
}

class _ExamPanel extends StatelessWidget {
  const _ExamPanel({required this.rooms});

  final List<ExamRoom> rooms;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam operations',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final room in rooms) _ExamRoomTile(room: room),
          ],
        ),
      ),
    );
  }
}

class _ExamRoomTile extends StatelessWidget {
  const _ExamRoomTile({required this.room});

  final ExamRoom room;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.meeting_room_outlined),
      title: Text('${room.courseCode} • ${room.room}'),
      subtitle: Text(
        '${room.time} • ${room.invigilator} • ${room.candidateCount} candidates',
      ),
      trailing: _StatusPill(status: room.status),
    );
  }
}

class _AlertPanel extends StatelessWidget {
  const _AlertPanel({required this.alerts});

  final List<AdminAlert> alerts;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live alerts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final alert in alerts) _AlertTile(alert: alert),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});

  final AdminAlert alert;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.circle,
        size: 12,
        color: alert.status.color(Theme.of(context).colorScheme),
      ),
      title: Text(alert.title),
      subtitle: Text(alert.message),
      trailing: Text(alert.time),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final WorkStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color(Theme.of(context).colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status.label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final AdminRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Icon(role.icon),
      title: Text(role.label),
      subtitle: Text(role.scope, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        selected: selected,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(icon),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}

class _PageItem {
  const _PageItem(this.label, this.icon);

  final String label;
  final IconData icon;
}
