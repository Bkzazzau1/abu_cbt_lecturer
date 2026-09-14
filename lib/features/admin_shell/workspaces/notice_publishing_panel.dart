import 'package:flutter/material.dart';

class NoticePublishingPanel extends StatefulWidget {
  const NoticePublishingPanel({super.key});

  @override
  State<NoticePublishingPanel> createState() => _NoticePublishingPanelState();
}

class _NoticePublishingPanelState extends State<NoticePublishingPanel> {
  final _titleController = TextEditingController(
    text: 'Exam briefing for 300 Level Software Engineering',
  );
  final _bodyController = TextEditingController(
    text:
        'All concerned students should attend the exam briefing by 10:00am. Attendance is compulsory.',
  );
  final _referenceController = TextEditingController(
    text: 'EXAM-OFFICE/2026/001',
  );
  final _departmentController = TextEditingController(text: 'dept-computing');
  final _programmeController = TextEditingController(
    text: 'bsc-software-engineering',
  );
  final _cohortController = TextEditingController(
    text: 'cohort-bsc-se-2023-regular',
  );
  final _courseController = TextEditingController();

  String _authorRole = 'Exam Officer';
  String _scope = 'Cohort';
  int? _level = 300;
  int? _semester = 1;
  bool _requiresAcknowledgement = true;
  bool _pinned = true;

  static const _published = [
    _PublishedNotice(
      title: 'Library hours extended for exam week',
      scope: 'General',
      target: 'All students',
      source: 'Records Department',
      acknowledgements: '0 / optional',
      status: 'Published',
    ),
    _PublishedNotice(
      title: 'CSC 305 exam coverage update',
      scope: 'Course',
      target: 'CSC 305 registered students',
      source: 'Lecturer',
      acknowledgements: '212 / 248',
      status: 'Published',
    ),
    _PublishedNotice(
      title: 'Carryover registration reminder',
      scope: 'Level',
      target: '300 Level Software Engineering',
      source: 'Exam Office',
      acknowledgements: '88 / 114',
      status: 'Pinned',
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _referenceController.dispose();
    _departmentController.dispose();
    _programmeController.dispose();
    _cohortController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notice Publishing',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _publish,
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Publish'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _NoticeChip(label: 'Drafts: 5', icon: Icons.edit_note_outlined),
                _NoticeChip(
                  label: 'Published: 24',
                  icon: Icons.check_circle_outline,
                ),
                _NoticeChip(
                  label: 'Needs acknowledgement: 9',
                  icon: Icons.how_to_reg_outlined,
                ),
                _NoticeChip(
                  label: 'Archived: 11',
                  icon: Icons.archive_outlined,
                ),
              ],
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth > 980;
                final editor = _NoticeEditor(
                  titleController: _titleController,
                  bodyController: _bodyController,
                  referenceController: _referenceController,
                  departmentController: _departmentController,
                  programmeController: _programmeController,
                  cohortController: _cohortController,
                  courseController: _courseController,
                  authorRole: _authorRole,
                  scope: _scope,
                  level: _level,
                  semester: _semester,
                  requiresAcknowledgement: _requiresAcknowledgement,
                  pinned: _pinned,
                  onTextChanged: () => setState(() {}),
                  onAuthorChanged: (value) =>
                      setState(() => _authorRole = value),
                  onScopeChanged: (value) => setState(() => _scope = value),
                  onLevelChanged: (value) => setState(() => _level = value),
                  onSemesterChanged: (value) =>
                      setState(() => _semester = value),
                  onAcknowledgementChanged: (value) =>
                      setState(() => _requiresAcknowledgement = value),
                  onPinnedChanged: (value) => setState(() => _pinned = value),
                );
                final preview = _NoticePreview(
                  title: _titleController.text,
                  body: _bodyController.text,
                  reference: _referenceController.text,
                  authorRole: _authorRole,
                  scope: _scope,
                  targetSummary: _targetSummary,
                  requiresAcknowledgement: _requiresAcknowledgement,
                  pinned: _pinned,
                );
                if (twoColumns) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: editor),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: preview),
                    ],
                  );
                }
                return Column(
                  children: [editor, const SizedBox(height: 16), preview],
                );
              },
            ),
            const SizedBox(height: 18),
            Text(
              'Recently published notices',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final notice in _published)
              _PublishedNoticeTile(notice: notice),
          ],
        ),
      ),
    );
  }

  String get _targetSummary {
    if (_scope == 'General') return 'All students';
    if (_scope == 'Course') {
      return _courseController.text.trim().isEmpty
          ? 'Selected course students'
          : '${_courseController.text.trim()} registered students';
    }
    final pieces = <String>[];
    if (_departmentController.text.trim().isNotEmpty) {
      pieces.add(_departmentController.text.trim());
    }
    if (_programmeController.text.trim().isNotEmpty) {
      pieces.add(_programmeController.text.trim());
    }
    if (_level != null) pieces.add('$_level Level');
    if (_semester != null) pieces.add('Semester $_semester');
    if (_cohortController.text.trim().isNotEmpty) {
      pieces.add(_cohortController.text.trim());
    }
    return pieces.isEmpty ? 'Targeted students' : pieces.join(' • ');
  }

  void _publish() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notice ready to publish to $_targetSummary')),
    );
  }
}

class _NoticeEditor extends StatelessWidget {
  const _NoticeEditor({
    required this.titleController,
    required this.bodyController,
    required this.referenceController,
    required this.departmentController,
    required this.programmeController,
    required this.cohortController,
    required this.courseController,
    required this.authorRole,
    required this.scope,
    required this.level,
    required this.semester,
    required this.requiresAcknowledgement,
    required this.pinned,
    required this.onTextChanged,
    required this.onAuthorChanged,
    required this.onScopeChanged,
    required this.onLevelChanged,
    required this.onSemesterChanged,
    required this.onAcknowledgementChanged,
    required this.onPinnedChanged,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final TextEditingController referenceController;
  final TextEditingController departmentController;
  final TextEditingController programmeController;
  final TextEditingController cohortController;
  final TextEditingController courseController;
  final String authorRole;
  final String scope;
  final int? level;
  final int? semester;
  final bool requiresAcknowledgement;
  final bool pinned;
  final VoidCallback onTextChanged;
  final ValueChanged<String> onAuthorChanged;
  final ValueChanged<String> onScopeChanged;
  final ValueChanged<int?> onLevelChanged;
  final ValueChanged<int?> onSemesterChanged;
  final ValueChanged<bool> onAcknowledgementChanged;
  final ValueChanged<bool> onPinnedChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Notice title',
            prefixIcon: Icon(Icons.title_outlined),
          ),
          onChanged: (_) => onTextChanged(),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: bodyController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Notice body',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
          onChanged: (_) => onTextChanged(),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: authorRole,
                items: const [
                  DropdownMenuItem(value: 'Lecturer', child: Text('Lecturer')),
                  DropdownMenuItem(
                    value: 'Exam Officer',
                    child: Text('Exam Officer'),
                  ),
                  DropdownMenuItem(
                    value: 'Records Department',
                    child: Text('Records Department'),
                  ),
                  DropdownMenuItem(
                    value: 'Department Admin',
                    child: Text('Department Admin'),
                  ),
                ],
                onChanged: (value) =>
                    value == null ? null : onAuthorChanged(value),
                decoration: const InputDecoration(labelText: 'Publishing role'),
              ),
            ),
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: scope,
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(
                    value: 'Department',
                    child: Text('Department'),
                  ),
                  DropdownMenuItem(
                    value: 'Programme',
                    child: Text('Programme'),
                  ),
                  DropdownMenuItem(
                    value: 'Level',
                    child: Text('Level / Semester'),
                  ),
                  DropdownMenuItem(value: 'Cohort', child: Text('Cohort')),
                  DropdownMenuItem(value: 'Course', child: Text('Course')),
                ],
                onChanged: (value) =>
                    value == null ? null : onScopeChanged(value),
                decoration: const InputDecoration(labelText: 'Target scope'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _TargetFields(
          scope: scope,
          departmentController: departmentController,
          programmeController: programmeController,
          cohortController: cohortController,
          courseController: courseController,
          level: level,
          semester: semester,
          onTextChanged: onTextChanged,
          onLevelChanged: onLevelChanged,
          onSemesterChanged: onSemesterChanged,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: referenceController,
          decoration: const InputDecoration(
            labelText: 'Reference / memo number',
            prefixIcon: Icon(Icons.tag_outlined),
          ),
          onChanged: (_) => onTextChanged(),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: requiresAcknowledgement,
          onChanged: onAcknowledgementChanged,
          title: const Text('Require student acknowledgement'),
          subtitle: const Text(
            'Track students who have read and acknowledged this notice.',
          ),
        ),
        SwitchListTile(
          value: pinned,
          onChanged: onPinnedChanged,
          title: const Text('Pin notice'),
          subtitle: const Text('Pinned notices appear above normal notices.'),
        ),
      ],
    );
  }
}

class _TargetFields extends StatelessWidget {
  const _TargetFields({
    required this.scope,
    required this.departmentController,
    required this.programmeController,
    required this.cohortController,
    required this.courseController,
    required this.level,
    required this.semester,
    required this.onTextChanged,
    required this.onLevelChanged,
    required this.onSemesterChanged,
  });

  final String scope;
  final TextEditingController departmentController;
  final TextEditingController programmeController;
  final TextEditingController cohortController;
  final TextEditingController courseController;
  final int? level;
  final int? semester;
  final VoidCallback onTextChanged;
  final ValueChanged<int?> onLevelChanged;
  final ValueChanged<int?> onSemesterChanged;

  @override
  Widget build(BuildContext context) {
    if (scope == 'General') {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          avatar: Icon(Icons.public_outlined),
          label: Text('Visible to all students'),
        ),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (scope == 'Department' ||
            scope == 'Programme' ||
            scope == 'Level' ||
            scope == 'Cohort')
          SizedBox(
            width: 260,
            child: TextFormField(
              controller: departmentController,
              decoration: const InputDecoration(labelText: 'Department ID'),
              onChanged: (_) => onTextChanged(),
            ),
          ),
        if (scope == 'Programme' || scope == 'Level' || scope == 'Cohort')
          SizedBox(
            width: 260,
            child: TextFormField(
              controller: programmeController,
              decoration: const InputDecoration(labelText: 'Programme ID'),
              onChanged: (_) => onTextChanged(),
            ),
          ),
        if (scope == 'Level' || scope == 'Cohort')
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: level,
              items: const [
                DropdownMenuItem(value: null, child: Text('All levels')),
                DropdownMenuItem(value: 100, child: Text('100 Level')),
                DropdownMenuItem(value: 200, child: Text('200 Level')),
                DropdownMenuItem(value: 300, child: Text('300 Level')),
                DropdownMenuItem(value: 400, child: Text('400 Level')),
                DropdownMenuItem(value: 500, child: Text('500 Level')),
              ],
              onChanged: onLevelChanged,
              decoration: const InputDecoration(labelText: 'Level'),
            ),
          ),
        if (scope == 'Level' || scope == 'Cohort')
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: semester,
              items: const [
                DropdownMenuItem(value: null, child: Text('All semesters')),
                DropdownMenuItem(value: 1, child: Text('Semester 1')),
                DropdownMenuItem(value: 2, child: Text('Semester 2')),
                DropdownMenuItem(value: 3, child: Text('Semester 3')),
              ],
              onChanged: onSemesterChanged,
              decoration: const InputDecoration(labelText: 'Semester'),
            ),
          ),
        if (scope == 'Cohort')
          SizedBox(
            width: 300,
            child: TextFormField(
              controller: cohortController,
              decoration: const InputDecoration(labelText: 'Cohort ID'),
              onChanged: (_) => onTextChanged(),
            ),
          ),
        if (scope == 'Course')
          SizedBox(
            width: 260,
            child: TextFormField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: 'Course code',
                hintText: 'CSC 305',
              ),
              onChanged: (_) => onTextChanged(),
            ),
          ),
      ],
    );
  }
}

class _NoticePreview extends StatelessWidget {
  const _NoticePreview({
    required this.title,
    required this.body,
    required this.reference,
    required this.authorRole,
    required this.scope,
    required this.targetSummary,
    required this.requiresAcknowledgement,
    required this.pinned,
  });

  final String title;
  final String body;
  final String reference;
  final String authorRole;
  final String scope;
  final String targetSummary;
  final bool requiresAcknowledgement;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student notice preview',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PreviewPill(
                label: scope,
                icon: Icons.center_focus_strong_outlined,
              ),
              _PreviewPill(
                label: authorRole,
                icon: Icons.account_circle_outlined,
              ),
              if (pinned)
                const _PreviewPill(
                  label: 'Pinned',
                  icon: Icons.push_pin_outlined,
                ),
              if (requiresAcknowledgement)
                const _PreviewPill(
                  label: 'Ack required',
                  icon: Icons.how_to_reg_outlined,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title.isEmpty ? 'Untitled notice' : title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(body.isEmpty ? 'Notice body will appear here.' : body),
          const SizedBox(height: 12),
          Text(
            'Target: $targetSummary',
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reference: ${reference.isEmpty ? 'Not set' : reference}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PublishedNoticeTile extends StatelessWidget {
  const _PublishedNoticeTile({required this.notice});

  final _PublishedNotice notice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.campaign_outlined, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('${notice.scope} • ${notice.target} • ${notice.source}'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniPill(label: notice.status),
                    _MiniPill(label: notice.acknowledgements),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'archive', child: Text('Archive')),
              PopupMenuItem(value: 'acks', child: Text('Acknowledgements')),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoticeChip extends StatelessWidget {
  const _NoticeChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
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

class _PublishedNotice {
  const _PublishedNotice({
    required this.title,
    required this.scope,
    required this.target,
    required this.source,
    required this.acknowledgements,
    required this.status,
  });

  final String title;
  final String scope;
  final String target;
  final String source;
  final String acknowledgements;
  final String status;
}
