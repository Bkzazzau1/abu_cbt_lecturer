import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../data/academic_setup_api.dart';

class AcademicSetupPanel extends StatefulWidget {
  const AcademicSetupPanel({super.key});

  @override
  State<AcademicSetupPanel> createState() => _AcademicSetupPanelState();
}

class _AcademicSetupPanelState extends State<AcademicSetupPanel> {
  late final AcademicSetupApi _api;
  late Future<AcademicSetupData> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _api = AcademicSetupApi();
    _future = _api.fetchSetup();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _future = _api.fetchSetup());

  Future<void> _run(Future<void> Function() action, String message) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _reload();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createFaculty() async {
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => const _FacultyDialog());
    if (payload == null) return;
    await _run(() => _api.createFaculty(payload), 'Faculty created');
  }

  Future<void> _createDepartment(AcademicSetupData data) async {
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => _DepartmentDialog(faculties: data.faculties));
    if (payload == null) return;
    await _run(() => _api.createDepartment(payload), 'Department created');
  }

  Future<void> _createProgramme(AcademicSetupData data) async {
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => _ProgrammeDialog(departments: data.departments));
    if (payload == null) return;
    await _run(() => _api.createProgramme(payload), 'Programme created');
  }

  Future<void> _createCourse(AcademicSetupData data) async {
    final payload = await showDialog<Map<String, dynamic>>(context: context, builder: (_) => _CourseDialog(departments: data.departments, programmes: data.programmes));
    if (payload == null) return;
    await _run(() => _api.createCourse(payload), 'Course created');
  }

  Future<void> _assignLecturer(AcademicSetupData data, AcademicCourse course) async {
    final lecturerId = await showDialog<String>(context: context, builder: (_) => _AssignLecturerDialog(course: course, lecturers: data.lecturers));
    if (lecturerId == null || lecturerId.isEmpty) return;
    await _run(() => _api.assignLecturer(courseId: course.id, lecturerId: lecturerId), 'Lecturer assigned');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<AcademicSetupData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.account_tree_outlined, color: scheme.primary),
                      const SizedBox(width: 10),
                      Text('Academic setup', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    ]),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      OutlinedButton.icon(onPressed: _busy ? null : _reload, icon: const Icon(Icons.refresh_outlined), label: const Text('Refresh')),
                      FilledButton.icon(onPressed: _busy ? null : _createFaculty, icon: const Icon(Icons.account_balance_outlined), label: const Text('Faculty')),
                      FilledButton.icon(onPressed: _busy || data == null ? null : () => _createDepartment(data), icon: const Icon(Icons.apartment_outlined), label: const Text('Department')),
                      FilledButton.icon(onPressed: _busy || data == null ? null : () => _createProgramme(data), icon: const Icon(Icons.school_outlined), label: const Text('Programme')),
                      FilledButton.icon(onPressed: _busy || data == null ? null : () => _createCourse(data), icon: const Icon(Icons.menu_book_outlined), label: const Text('Course')),
                    ]),
                  ],
                ),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting && data == null)
                  const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
                else if (snapshot.hasError)
                  _ErrorBox(message: snapshot.error.toString(), onRetry: _reload)
                else if (data != null) ...[
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    _CountChip(label: 'Faculties: ${data.faculties.length}', icon: Icons.account_balance_outlined),
                    _CountChip(label: 'Departments: ${data.departments.length}', icon: Icons.apartment_outlined),
                    _CountChip(label: 'Programmes: ${data.programmes.length}', icon: Icons.school_outlined),
                    _CountChip(label: 'Courses: ${data.courses.length}', icon: Icons.menu_book_outlined),
                    _CountChip(label: 'Lecturers: ${data.lecturers.length}', icon: Icons.groups_outlined),
                  ]),
                  const SizedBox(height: 18),
                  _SectionTitle('Departments and programmes'),
                  for (final department in data.departments) _DepartmentTile(department: department, programmes: data.programmes.where((programme) => programme.departmentId == department.id).toList()),
                  const SizedBox(height: 18),
                  _SectionTitle('Courses'),
                  if (data.courses.isEmpty)
                    const _EmptyBox('No course created yet.')
                  else
                    for (final course in data.courses) _CourseTile(course: course, onAssign: () => _assignLecturer(data, course)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
  );
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Chip(avatar: Icon(icon, size: 18), label: Text(label), visualDensity: VisualDensity.compact);
}

class _DepartmentTile extends StatelessWidget {
  const _DepartmentTile({required this.department, required this.programmes});
  final AcademicDepartment department;
  final List<AcademicProgramme> programmes;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${department.code} • ${department.name}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (programmes.isEmpty)
          Text('No programme yet', style: TextStyle(color: scheme.onSurfaceVariant))
        else
          Wrap(spacing: 8, runSpacing: 8, children: [for (final programme in programmes) Chip(label: Text('${programme.code} • ${programme.name}'))]),
      ]),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course, required this.onAssign});
  final AcademicCourse course;
  final VoidCallback onAssign;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: scheme.outlineVariant), color: scheme.surface),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${course.code} • ${course.title}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('${course.unit} units • ${course.level} level • ${course.semester}', style: TextStyle(color: scheme.onSurfaceVariant)),
            ]),
          ),
          FilledButton.icon(onPressed: onAssign, icon: const Icon(Icons.person_add_alt_outlined), label: const Text('Assign lecturer')),
        ],
      ),
    );
  }
}

class _FacultyDialog extends StatefulWidget {
  const _FacultyDialog();
  @override
  State<_FacultyDialog> createState() => _FacultyDialogState();
}

class _FacultyDialogState extends State<_FacultyDialog> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  @override
  void dispose() { _name.dispose(); _code.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create faculty'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Faculty name')),
      const SizedBox(height: 10),
      TextField(controller: _code, decoration: const InputDecoration(labelText: 'Code')),
    ]),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, {'name': _name.text.trim(), 'code': _code.text.trim()}), child: const Text('Create'))],
  );
}

class _DepartmentDialog extends StatefulWidget {
  const _DepartmentDialog({required this.faculties});
  final List<AcademicFaculty> faculties;
  @override
  State<_DepartmentDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends State<_DepartmentDialog> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  String? _facultyId;
  @override
  void dispose() { _name.dispose(); _code.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create department'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _facultyId,
          decoration: const InputDecoration(labelText: 'Faculty'),
          items: [
            for (final item in widget.faculties)
              DropdownMenuItem(
                value: item.id,
                child: Text('${item.code} • ${item.name}'),
              ),
          ],
          onChanged: (value) => setState(() => _facultyId = value),
        ),
      const SizedBox(height: 10),
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Department name')),
      const SizedBox(height: 10),
      TextField(controller: _code, decoration: const InputDecoration(labelText: 'Code')),
    ]),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, {'faculty_id': int.tryParse(_facultyId ?? ''), 'name': _name.text.trim(), 'code': _code.text.trim()}), child: const Text('Create'))],
  );
}

class _ProgrammeDialog extends StatefulWidget {
  const _ProgrammeDialog({required this.departments});
  final List<AcademicDepartment> departments;
  @override
  State<_ProgrammeDialog> createState() => _ProgrammeDialogState();
}

class _ProgrammeDialogState extends State<_ProgrammeDialog> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  String? _departmentId;
  String _levelType = 'undergraduate';
  @override
  void dispose() { _name.dispose(); _code.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create programme'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _departmentId,
          decoration: const InputDecoration(labelText: 'Department'),
          items: [
            for (final item in widget.departments)
              DropdownMenuItem(
                value: item.id,
                child: Text('${item.code} • ${item.name}'),
              ),
          ],
          onChanged: (value) => setState(() => _departmentId = value),
        ),
      const SizedBox(height: 10),
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Programme name')),
      const SizedBox(height: 10),
      TextField(controller: _code, decoration: const InputDecoration(labelText: 'Code')),
      const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: _levelType,
          decoration: const InputDecoration(labelText: 'Level type'),
          items: const [
            DropdownMenuItem(
              value: 'undergraduate',
              child: Text('Undergraduate'),
            ),
            DropdownMenuItem(
              value: 'postgraduate',
              child: Text('Postgraduate'),
            ),
          ],
          onChanged: (value) =>
              setState(() => _levelType = value ?? 'undergraduate'),
        ),
    ]),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, {'department_id': int.tryParse(_departmentId ?? ''), 'name': _name.text.trim(), 'code': _code.text.trim(), 'level_type': _levelType}), child: const Text('Create'))],
  );
}

class _CourseDialog extends StatefulWidget {
  const _CourseDialog({required this.departments, required this.programmes});
  final List<AcademicDepartment> departments;
  final List<AcademicProgramme> programmes;
  @override
  State<_CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends State<_CourseDialog> {
  final _title = TextEditingController();
  final _code = TextEditingController();
  final _unit = TextEditingController(text: '3');
  final _level = TextEditingController(text: '100');
  String? _departmentId;
  String? _programmeId;
  String _semester = 'First Semester';
  @override
  void dispose() { _title.dispose(); _code.dispose(); _unit.dispose(); _level.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create course'),
    content: SizedBox(width: 560, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _departmentId,
              decoration: const InputDecoration(labelText: 'Department'),
              items: [
                for (final item in widget.departments)
                  DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.code} • ${item.name}'),
                  ),
              ],
              onChanged: (value) => setState(() => _departmentId = value),
            ),
      const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _programmeId,
              decoration: const InputDecoration(labelText: 'Programme'),
              items: [
                for (final item in widget.programmes)
                  DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.code} • ${item.name}'),
                  ),
              ],
              onChanged: (value) => setState(() => _programmeId = value),
            ),
      const SizedBox(height: 10),
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Course title')),
      const SizedBox(height: 10),
      TextField(controller: _code, decoration: const InputDecoration(labelText: 'Course code')),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: TextField(controller: _unit, decoration: const InputDecoration(labelText: 'Units'))), const SizedBox(width: 10), Expanded(child: TextField(controller: _level, decoration: const InputDecoration(labelText: 'Level')))]),
      const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _semester,
              decoration: const InputDecoration(labelText: 'Semester'),
              items: const [
                DropdownMenuItem(
                  value: 'First Semester',
                  child: Text('First Semester'),
                ),
                DropdownMenuItem(
                  value: 'Second Semester',
                  child: Text('Second Semester'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _semester = value ?? 'First Semester'),
            ),
    ]))),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, {'department_id': int.tryParse(_departmentId ?? ''), 'programme_id': int.tryParse(_programmeId ?? ''), 'title': _title.text.trim(), 'code': _code.text.trim(), 'unit': int.tryParse(_unit.text.trim()) ?? 0, 'semester': _semester, 'level': _level.text.trim(), 'is_active': true}), child: const Text('Create'))],
  );
}

class _AssignLecturerDialog extends StatefulWidget {
  const _AssignLecturerDialog({required this.course, required this.lecturers});
  final AcademicCourse course;
  final List<AcademicStaff> lecturers;
  @override
  State<_AssignLecturerDialog> createState() => _AssignLecturerDialogState();
}

class _AssignLecturerDialogState extends State<_AssignLecturerDialog> {
  String? _lecturerId;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Assign lecturer to ${widget.course.code}'),
    content: DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: _lecturerId,
      decoration: const InputDecoration(labelText: 'Lecturer'),
      items: [
        for (final item in widget.lecturers)
          DropdownMenuItem(
            value: item.id,
            child: Text('${item.name} • ${item.email}'),
          ),
      ],
      onChanged: (value) => setState(() => _lecturerId = value),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, _lecturerId), child: const Text('Assign'))],
  );
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).colorScheme.outlineVariant)), child: Text(text));
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Theme.of(context).colorScheme.errorContainer), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Could not load academic setup', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text(message), const SizedBox(height: 10), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_outlined), label: const Text('Try again'))]));
}
