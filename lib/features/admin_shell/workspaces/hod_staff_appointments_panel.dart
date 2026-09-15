import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_academic_registry.dart';
import '../../staff_management/data/department_staff_appointments_state.dart';
import '../../staff_management/data/staff_management_api.dart';

class HodStaffAppointmentsPanel extends StatefulWidget {
  const HodStaffAppointmentsPanel({super.key});

  @override
  State<HodStaffAppointmentsPanel> createState() =>
      _HodStaffAppointmentsPanelState();
}

class _HodStaffAppointmentsPanelState extends State<HodStaffAppointmentsPanel> {
  static const _allowedRoles = ['lecturer', 'moderator', 'exam_officer'];

  final StaffManagementApi _api = StaffManagementApi();
  final ExamOfficerAcademicRegistry _registry = ExamOfficerAcademicRegistry.instance;
  final DepartmentStaffAppointmentsState _appointments =
      DepartmentStaffAppointmentsState.instance;

  late Future<List<StaffItem>> _staffFuture;
  bool _busy = false;
  String _section = 'Staff Accounts';

  @override
  void initState() {
    super.initState();
    _staffFuture = _api.fetchStaff();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _staffFuture = _api.fetchStaff());

  List<StaffItem> _departmentStaff(List<StaffItem> staff) => staff
      .where(
        (item) =>
            item.departmentId == '1' && _allowedRoles.contains(item.primaryRole),
      )
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appointments,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Staff Accounts',
                    icon: Icon(Icons.badge_outlined),
                    label: Text('Staff Accounts'),
                  ),
                  ButtonSegment(
                    value: 'Course Appointments',
                    icon: Icon(Icons.assignment_ind_outlined),
                    label: Text('Course Appointments'),
                  ),
                ],
                selected: {_section},
                onSelectionChanged: (value) =>
                    setState(() => _section = value.first),
              ),
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<StaffItem>>(
            future: _staffFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(42),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Text(snapshot.error.toString()),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh_outlined),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final staff = _departmentStaff(snapshot.data ?? const []);
              if (_section == 'Course Appointments') {
                return _courseAppointments(context, staff);
              }
              return _staffAccounts(context, staff);
            },
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 18,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Department Staff & Academic Appointments',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'As Head of Department and Chief Exam Officer, the HoD creates Lecturer, Moderator and Exam Officer accounts, appoints lecturers to courses, and defines the departmental moderator pool. ICT and HoD accounts are outside this page.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: _busy ? null : _createStaff,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Create Department Staff'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staffAccounts(BuildContext context, List<StaffItem> staff) {
    final lecturers = staff.where((item) => item.primaryRole == 'lecturer').length;
    final moderators = staff.where((item) => item.primaryRole == 'moderator').length;
    final examOfficers =
        staff.where((item) => item.primaryRole == 'exam_officer').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 900
                ? (constraints.maxWidth - 24) / 3
                : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    icon: Icons.school_outlined,
                    label: 'Lecturers',
                    value: '$lecturers',
                    detail: 'Teaching staff accounts',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    icon: Icons.rule_folder_outlined,
                    label: 'Moderators',
                    value: '$moderators',
                    detail: 'Assessment moderation pool',
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _MetricCard(
                    icon: Icons.assignment_turned_in_outlined,
                    label: 'Exam Officers',
                    value: '$examOfficers',
                    detail: 'Delegated departmental exam officers',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Department Staff Accounts',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _busy ? null : _reload,
                      icon: const Icon(Icons.refresh_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (staff.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No department staff accounts found.')),
                  )
                else
                  for (final item in staff) _staffCard(context, item),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _staffCard(BuildContext context, StaffItem item) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text('${item.staffNumber} • ${item.email}'),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(_roleLabel(item.primaryRole))),
              Chip(label: Text(item.active ? 'Active' : 'Inactive')),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _changeRole(item),
                icon: const Icon(Icons.manage_accounts_outlined),
                label: const Text('Change Appointment'),
              ),
              TextButton.icon(
                onPressed: _busy ? null : () => _toggleStatus(item),
                icon: Icon(item.active ? Icons.block_outlined : Icons.check_circle_outline),
                label: Text(item.active ? 'Deactivate' : 'Activate'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _courseAppointments(BuildContext context, List<StaffItem> staff) {
    final activeLecturers = staff
        .where((item) => item.active && item.primaryRole == 'lecturer')
        .toList(growable: false);
    final activeModerators = staff
        .where((item) => item.active && item.primaryRole == 'moderator')
        .toList(growable: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Lecturer & Moderator Appointments',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
            const SizedBox(height: 5),
            Text(
              'Teaching appointment is controlled by the HoD. Examination marking and invigilation remain separate duties and do not automatically follow the course lecturer.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            for (final course in _registry.courses)
              _courseCard(
                context,
                course,
                activeLecturers: activeLecturers,
                activeModerators: activeModerators,
              ),
          ],
        ),
      ),
    );
  }

  Widget _courseCard(
    BuildContext context,
    ExamOfficerCourseRegistration course, {
    required List<StaffItem> activeLecturers,
    required List<StaffItem> activeModerators,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final lecturers = _appointments.lecturersFor(course.courseCode);
    final moderators = _appointments.moderatorsFor(course.courseCode);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${course.courseCode} — ${course.courseTitle}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text('${course.level} • ${course.semester} • ${course.totalRegistered} registered'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Lecturer(s)', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final lecturer in lecturers)
                InputChip(
                  label: Text(lecturer),
                  onDeleted: () => _appointments.removeLecturer(
                    courseCode: course.courseCode,
                    lecturer: lecturer,
                  ),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Assign Lecturer'),
                onPressed: () => _assignPerson(
                  title: 'Assign Lecturer — ${course.courseCode}',
                  candidates: activeLecturers,
                  alreadyAssigned: lecturers,
                  onSelected: (name) => _appointments.assignLecturer(
                    courseCode: course.courseCode,
                    lecturer: name,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Moderator(s)', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final moderator in moderators)
                InputChip(
                  label: Text(moderator),
                  onDeleted: () => _appointments.removeModerator(
                    courseCode: course.courseCode,
                    moderator: moderator,
                  ),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Assign Moderator'),
                onPressed: () => _assignPerson(
                  title: 'Assign Moderator — ${course.courseCode}',
                  candidates: activeModerators,
                  alreadyAssigned: moderators,
                  onSelected: (name) => _appointments.assignModerator(
                    courseCode: course.courseCode,
                    moderator: name,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createStaff() async {
    final payload = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _CreateDepartmentStaffDialog(),
    );
    if (payload == null) return;
    setState(() => _busy = true);
    try {
      await _api.createStaff({
        'staff_number': payload['staff_number'],
        'first_name': payload['first_name'],
        'last_name': payload['last_name'],
        'email': payload['email'],
        'phone': payload['phone'],
        'role_code': payload['role'],
        'department_id': '1',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_roleLabel(payload['role'] ?? '')} account created.')),
      );
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _changeRole(StaffItem item) async {
    final role = await showDialog<String>(
      context: context,
      builder: (_) => _RoleAppointmentDialog(currentRole: item.primaryRole),
    );
    if (role == null || role == item.primaryRole) return;
    setState(() => _busy = true);
    try {
      await _api.assignRole(staffId: item.id, role: role, departmentId: '1');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} appointed as ${_roleLabel(role)}.')),
      );
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleStatus(StaffItem item) async {
    setState(() => _busy = true);
    try {
      await _api.updateStaffStatus(staffId: item.id, active: !item.active);
      _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _assignPerson({
    required String title,
    required List<StaffItem> candidates,
    required List<String> alreadyAssigned,
    required ValueChanged<String> onSelected,
  }) async {
    final available = candidates
        .where(
          (item) => !alreadyAssigned.any(
            (name) => name.trim().toLowerCase() == item.name.trim().toLowerCase(),
          ),
        )
        .toList(growable: false);

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No additional active staff are available for this appointment.')),
      );
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          for (final person in available)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, person.name),
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(person.name),
                subtitle: Text(person.staffNumber),
              ),
            ),
        ],
      ),
    );
    if (selected != null) onSelected(selected);
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'lecturer':
        return 'Lecturer';
      case 'moderator':
        return 'Moderator';
      case 'exam_officer':
        return 'Exam Officer';
      default:
        return role;
    }
  }
}

class _CreateDepartmentStaffDialog extends StatefulWidget {
  const _CreateDepartmentStaffDialog();

  @override
  State<_CreateDepartmentStaffDialog> createState() =>
      _CreateDepartmentStaffDialogState();
}

class _CreateDepartmentStaffDialogState
    extends State<_CreateDepartmentStaffDialog> {
  final _staffNumber = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'lecturer';

  @override
  void dispose() {
    _staffNumber.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Department Staff Account'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _staffNumber,
                decoration: const InputDecoration(labelText: 'Staff number'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstName,
                      decoration: const InputDecoration(labelText: 'First name'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lastName,
                      decoration: const InputDecoration(labelText: 'Last name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email address'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Department role'),
                items: const [
                  DropdownMenuItem(value: 'lecturer', child: Text('Lecturer')),
                  DropdownMenuItem(value: 'moderator', child: Text('Moderator')),
                  DropdownMenuItem(value: 'exam_officer', child: Text('Exam Officer')),
                ],
                onChanged: (value) => setState(() => _role = value ?? 'lecturer'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_staffNumber.text.trim().isEmpty ||
                _firstName.text.trim().isEmpty ||
                _lastName.text.trim().isEmpty ||
                _email.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Staff number, name and email are required.')),
              );
              return;
            }
            Navigator.pop(context, <String, String>{
              'staff_number': _staffNumber.text.trim(),
              'first_name': _firstName.text.trim(),
              'last_name': _lastName.text.trim(),
              'email': _email.text.trim(),
              'phone': _phone.text.trim(),
              'role': _role,
            });
          },
          child: const Text('Create Account'),
        ),
      ],
    );
  }
}

class _RoleAppointmentDialog extends StatefulWidget {
  const _RoleAppointmentDialog({required this.currentRole});

  final String currentRole;

  @override
  State<_RoleAppointmentDialog> createState() => _RoleAppointmentDialogState();
}

class _RoleAppointmentDialogState extends State<_RoleAppointmentDialog> {
  late String _role;

  @override
  void initState() {
    super.initState();
    _role = const ['lecturer', 'moderator', 'exam_officer'].contains(widget.currentRole)
        ? widget.currentRole
        : 'lecturer';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Department Appointment'),
      content: DropdownButtonFormField<String>(
        initialValue: _role,
        decoration: const InputDecoration(labelText: 'Role'),
        items: const [
          DropdownMenuItem(value: 'lecturer', child: Text('Lecturer')),
          DropdownMenuItem(value: 'moderator', child: Text('Moderator')),
          DropdownMenuItem(value: 'exam_officer', child: Text('Exam Officer')),
        ],
        onChanged: (value) => setState(() => _role = value ?? _role),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _role),
          child: const Text('Save Appointment'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(detail, style: TextStyle(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
