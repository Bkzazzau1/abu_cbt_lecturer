import 'package:flutter/material.dart';

class AcademicStructurePanel extends StatefulWidget {
  const AcademicStructurePanel({super.key});

  @override
  State<AcademicStructurePanel> createState() => _AcademicStructurePanelState();
}

class _AcademicStructurePanelState extends State<AcademicStructurePanel> {
  String _selectedFaculty = 'All';
  String _selectedStatus = 'All';

  static const _programmes = [
    _ProgrammeStructure(
      faculty: 'Computing',
      department: 'Software Engineering',
      programme: 'B.Sc Software Engineering',
      code: 'BSC-SENG',
      levels: '100-500',
      semesters: '1-2',
      courses: 64,
      cohorts: 5,
      status: 'Active',
    ),
    _ProgrammeStructure(
      faculty: 'Computing',
      department: 'Computer Science',
      programme: 'B.Sc Computer Science',
      code: 'BSC-CSC',
      levels: '100-400',
      semesters: '1-2',
      courses: 58,
      cohorts: 6,
      status: 'Active',
    ),
    _ProgrammeStructure(
      faculty: 'General Studies',
      department: 'GST Unit',
      programme: 'General Studies Courses',
      code: 'GST-CORE',
      levels: '100-400',
      semesters: '1-2',
      courses: 18,
      cohorts: 12,
      status: 'Shared',
    ),
    _ProgrammeStructure(
      faculty: 'Distance Learning',
      department: 'DLC Computing',
      programme: 'B.Sc Software Engineering DLC',
      code: 'DLC-SENG',
      levels: '100-500',
      semesters: '1-3',
      courses: 64,
      cohorts: 3,
      status: 'Review',
    ),
  ];

  static const _curriculumItems = [
    _CurriculumItem(
      courseCode: 'CSC 305',
      title: 'Data Structures',
      programme: 'B.Sc Software Engineering',
      level: 300,
      semester: 1,
      credits: 3,
      type: 'Core',
      status: 'Mapped',
    ),
    _CurriculumItem(
      courseCode: 'CSC 311',
      title: 'Mobile Application Development',
      programme: 'B.Sc Software Engineering',
      level: 300,
      semester: 1,
      credits: 2,
      type: 'Elective',
      status: 'Mapped',
    ),
    _CurriculumItem(
      courseCode: 'GST 303',
      title: 'Communication in English',
      programme: 'General Studies Courses',
      level: 300,
      semester: 1,
      credits: 2,
      type: 'Shared',
      status: 'Mapped',
    ),
    _CurriculumItem(
      courseCode: 'SEN 499',
      title: 'Final Year Project',
      programme: 'B.Sc Software Engineering',
      level: 500,
      semester: 2,
      credits: 6,
      type: 'Core',
      status: 'Needs Review',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filteredProgrammes = _programmes
        .where(
          (item) =>
              _selectedFaculty == 'All' || item.faculty == _selectedFaculty,
        )
        .where(
          (item) => _selectedStatus == 'All' || item.status == _selectedStatus,
        )
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Department / Faculty Academic Structure',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add structure'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _StructureChip(
                  label: 'Faculties: 8',
                  icon: Icons.account_balance_outlined,
                ),
                _StructureChip(
                  label: 'Departments: 42',
                  icon: Icons.account_tree_outlined,
                ),
                _StructureChip(
                  label: 'Programmes: 96',
                  icon: Icons.school_outlined,
                ),
                _StructureChip(
                  label: 'Curriculum maps: 1,248',
                  icon: Icons.menu_book_outlined,
                ),
                _StructureChip(
                  label: 'Active cohorts: 62',
                  icon: Icons.groups_2_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedFaculty,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All faculties'),
                      ),
                      DropdownMenuItem(
                        value: 'Computing',
                        child: Text('Computing'),
                      ),
                      DropdownMenuItem(
                        value: 'General Studies',
                        child: Text('General Studies'),
                      ),
                      DropdownMenuItem(
                        value: 'Distance Learning',
                        child: Text('Distance Learning'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedFaculty = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Faculty'),
                  ),
                ),
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'All',
                        child: Text('All statuses'),
                      ),
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Shared', child: Text('Shared')),
                      DropdownMenuItem(value: 'Review', child: Text('Review')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value ?? 'All'),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Programme structure',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final item in filteredProgrammes) _ProgrammeTile(item: item),
            const SizedBox(height: 18),
            Text(
              'Curriculum mapping',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final item in _curriculumItems) _CurriculumTile(item: item),
          ],
        ),
      ),
    );
  }
}

class _ProgrammeTile extends StatelessWidget {
  const _ProgrammeTile({required this.item});

  final _ProgrammeStructure item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = item.status == 'Review'
        ? scheme.error
        : item.status == 'Shared'
        ? scheme.secondary
        : scheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.status == 'Review'
              ? scheme.error.withValues(alpha: 0.4)
              : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.programme} • ${item.code}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.faculty} • ${item.department}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _StatusBadge(text: item.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(label: 'Levels ${item.levels}'),
              _MiniPill(label: 'Semesters ${item.semesters}'),
              _MiniPill(label: '${item.courses} courses'),
              _MiniPill(label: '${item.cohorts} cohorts'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Curriculum'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.groups_2_outlined),
                label: const Text('Cohorts'),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit structure'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurriculumTile extends StatelessWidget {
  const _CurriculumTile({required this.item});

  final _CurriculumItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = item.status == 'Needs Review'
        ? scheme.error
        : scheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.12),
        foregroundColor: statusColor,
        child: const Icon(Icons.menu_book_outlined),
      ),
      title: Text(
        '${item.courseCode} • ${item.title}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${item.programme} • ${item.level} Level • Semester ${item.semester} • ${item.credits} credits • ${item.type}',
      ),
      trailing: _StatusBadge(text: item.status, color: statusColor),
    );
  }
}

class _StructureChip extends StatelessWidget {
  const _StructureChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ProgrammeStructure {
  const _ProgrammeStructure({
    required this.faculty,
    required this.department,
    required this.programme,
    required this.code,
    required this.levels,
    required this.semesters,
    required this.courses,
    required this.cohorts,
    required this.status,
  });

  final String faculty;
  final String department;
  final String programme;
  final String code;
  final String levels;
  final String semesters;
  final int courses;
  final int cohorts;
  final String status;
}

class _CurriculumItem {
  const _CurriculumItem({
    required this.courseCode,
    required this.title,
    required this.programme,
    required this.level,
    required this.semester,
    required this.credits,
    required this.type,
    required this.status,
  });

  final String courseCode;
  final String title;
  final String programme;
  final int level;
  final int semester;
  final int credits;
  final String type;
  final String status;
}
