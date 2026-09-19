import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_malpractice_state.dart';

class ExamMalpracticePage extends StatefulWidget {
  const ExamMalpracticePage({super.key});

  @override
  State<ExamMalpracticePage> createState() => _ExamMalpracticePageState();
}

class _ExamMalpracticePageState extends State<ExamMalpracticePage> {
  final ExamMalpracticeState _state = ExamMalpracticeState.instance;
  ExamMalpracticeStatus? _status;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Malpractice & Incident Management'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'register-malpractice-incident',
        onPressed: _registerIncident,
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Register Incident'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _state,
          builder: (context, _) {
            final visible = _state.cases.where((item) {
              final statusOk = _status == null || item.status == _status;
              final q = _query.trim().toLowerCase();
              final searchOk = q.isEmpty ||
                  item.id.toLowerCase().contains(q) ||
                  item.studentName.toLowerCase().contains(q) ||
                  item.matricNumber.toLowerCase().contains(q) ||
                  item.courseCode.toLowerCase().contains(q) ||
                  item.incidentType.toLowerCase().contains(q);
              return statusOk && searchOk;
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(context),
                  const SizedBox(height: 16),
                  _kpis(),
                  const SizedBox(height: 16),
                  _governanceNotice(context),
                  const SizedBox(height: 16),
                  _filters(),
                  const SizedBox(height: 16),
                  _workflowStrip(context),
                  const SizedBox(height: 16),
                  _caseQueue(context, visible),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 18,
          runSpacing: 14,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: scheme.errorContainer,
                        foregroundColor: scheme.onErrorContainer,
                        child: const Icon(Icons.gavel_outlined),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Examination Malpractice Case Control',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Register incidents, preserve evidence, collect statements, maintain chain-of-custody references, prepare case files and escalate completed cases to the HoD or authorized disciplinary body.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Chip(
              avatar: const Icon(Icons.shield_outlined, size: 18),
              label: Text('${_state.openCases} open cases'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpis() {
    final items = [
      ('Open Cases', '${_state.openCases}', Icons.folder_open_outlined),
      (
        'Evidence / Statements',
        '${_state.awaitingEvidenceOrStatement}',
        Icons.fact_check_outlined,
      ),
      (
        'Ready to Escalate',
        '${_state.readyForEscalation}',
        Icons.outbox_outlined,
      ),
      ('With HoD / Committee', '${_state.escalated}', Icons.account_tree_outlined),
      ('Concluded', '${_state.concluded}', Icons.task_alt_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 1150
            ? (constraints.maxWidth - 48) / 5
            : constraints.maxWidth >= 720
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _KpiCard(
                  label: item.$1,
                  value: item.$2,
                  icon: item.$3,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _governanceNotice(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.policy_outlined),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Governance boundary: the Exam Officer manages the case file and escalation. The system does not determine guilt or impose sanctions. Final disciplinary findings must come from the authorized HoD/committee/university authority and are only recorded here afterward.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 340,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search case / student / matric / course',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            SizedBox(
              width: 240,
              child: DropdownButtonFormField<ExamMalpracticeStatus?>(
                initialValue: _status,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Case status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<ExamMalpracticeStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  for (final status in ExamMalpracticeStatus.values)
                    DropdownMenuItem<ExamMalpracticeStatus?>(
                      value: status,
                      child: Text(status.label),
                    ),
                ],
                onChanged: (value) => setState(() => _status = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workflowStrip(BuildContext context) {
    final stages = [
      'Report',
      'Secure Evidence',
      'Collect Statements',
      'Exam Officer Review',
      'Escalate to HoD',
      'Committee / Authority',
      'Record Decision',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Case workflow',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var i = 0; i < stages.length; i++) ...[
                  Chip(
                    avatar: CircleAvatar(
                      radius: 10,
                      child: Text('${i + 1}'),
                    ),
                    label: Text(stages[i]),
                  ),
                  if (i != stages.length - 1)
                    const Icon(Icons.arrow_forward, size: 18),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _caseQueue(BuildContext context, List<ExamMalpracticeCase> cases) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Malpractice & Incident Case Queue',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                Chip(label: Text('${cases.length} shown')),
              ],
            ),
            const SizedBox(height: 14),
            if (cases.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: Text('No case matches the current filters.')),
              )
            else
              for (final item in cases) _caseCard(context, item),
          ],
        ),
      ),
    );
  }

  Widget _caseCard(BuildContext context, ExamMalpracticeCase item) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.id} • ${item.studentName}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.matricNumber} • ${item.courseCode} • ${item.incidentType}',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Chip(label: Text(item.status.label)),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.summary),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('${item.evidence.length} evidence item(s)'),
              _pill('${item.statements.length} statement(s)'),
              _pill(item.venue),
              _pill(item.sitting),
              if (item.escalationReference != null)
                _pill(item.escalationReference!),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openCase(item),
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Open Case File'),
              ),
              if (item.status == ExamMalpracticeStatus.reported)
                FilledButton.tonalIcon(
                  onPressed: () => _state.startEvidenceReview(item.id),
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Start Evidence Review'),
                ),
              if (item.status == ExamMalpracticeStatus.evidenceReview ||
                  item.status == ExamMalpracticeStatus.statementPending)
                OutlinedButton.icon(
                  onPressed: () => _addEvidence(item),
                  icon: const Icon(Icons.attach_file_outlined),
                  label: const Text('Add Evidence'),
                ),
              if (item.status == ExamMalpracticeStatus.evidenceReview)
                FilledButton.tonalIcon(
                  onPressed: () => _noteAction(
                    title: 'Request Statement',
                    hint:
                        'State whose statement is required and any instructions.',
                    onSubmit: (note) =>
                        _state.requestStatement(item.id, note),
                  ),
                  icon: const Icon(Icons.record_voice_over_outlined),
                  label: const Text('Request Statement'),
                ),
              if (item.status == ExamMalpracticeStatus.statementPending)
                FilledButton.tonalIcon(
                  onPressed: () => _addStatement(item),
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Record Statement'),
                ),
              if (item.status == ExamMalpracticeStatus.evidenceReview ||
                  item.status == ExamMalpracticeStatus.statementPending)
                FilledButton.icon(
                  onPressed: () => _noteAction(
                    title: 'Prepare Case for Escalation',
                    hint:
                        'Summarize the completed evidence/statement review. Do not determine guilt.',
                    onSubmit: (note) =>
                        _state.markReadyForEscalation(item.id, note),
                  ),
                  icon: const Icon(Icons.assignment_turned_in_outlined),
                  label: const Text('Ready for Escalation'),
                ),
              if (item.status == ExamMalpracticeStatus.readyForEscalation)
                FilledButton.icon(
                  onPressed: () => _noteAction(
                    title: 'Escalate to HoD',
                    hint:
                        'Add a neutral case-file handoff note for authorized review.',
                    onSubmit: (note) => _state.escalateToHod(item.id, note),
                  ),
                  icon: const Icon(Icons.outbox_outlined),
                  label: const Text('Escalate to HoD'),
                ),
              if (item.status == ExamMalpracticeStatus.escalatedToHod)
                OutlinedButton.icon(
                  onPressed: () => _noteAction(
                    title: 'Record Committee Review',
                    hint: 'Record the official review status or meeting reference.',
                    onSubmit: (note) =>
                        _state.markCommitteeReview(item.id, note),
                  ),
                  icon: const Icon(Icons.groups_2_outlined),
                  label: const Text('Committee Review'),
                ),
              if (item.status == ExamMalpracticeStatus.escalatedToHod ||
                  item.status == ExamMalpracticeStatus.committeeReview)
                FilledButton.tonalIcon(
                  onPressed: () => _recordDecision(item),
                  icon: const Icon(Icons.verified_user_outlined),
                  label: const Text('Record Authorized Decision'),
                ),
              if (item.status == ExamMalpracticeStatus.reported ||
                  item.status == ExamMalpracticeStatus.evidenceReview ||
                  item.status == ExamMalpracticeStatus.statementPending ||
                  item.status == ExamMalpracticeStatus.readyForEscalation)
                TextButton.icon(
                  onPressed: () => _noteAction(
                    title: 'Close — No Case Established',
                    hint: 'Document why escalation is not required.',
                    onSubmit: (note) => _state.closeNoCase(item.id, note),
                  ),
                  icon: const Icon(Icons.close_outlined),
                  label: const Text('Close No Case'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) => Chip(
        visualDensity: VisualDensity.compact,
        label: Text(text),
      );

  Future<void> _registerIncident() async {
    final student = TextEditingController();
    final matric = TextEditingController();
    final course = TextEditingController();
    final exam = TextEditingController();
    final sitting = TextEditingController();
    final venue = TextEditingController();
    final reporter = TextEditingController();
    final summary = TextEditingController();
    var incidentType = ExamMalpracticeState.incidentTypes.first;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Register Examination Incident'),
          content: SizedBox(
            width: 760,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _field(student, 'Student name'),
                  _field(matric, 'Matric number'),
                  _field(course, 'Course code'),
                  _field(exam, 'Examination title'),
                  _field(sitting, 'Sitting / date / time'),
                  _field(venue, 'Venue'),
                  _field(reporter, 'Reported by'),
                  DropdownButtonFormField<String>(
                    initialValue: incidentType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Incident type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final type in ExamMalpracticeState.incidentTypes)
                        DropdownMenuItem(value: type, child: Text(type)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => incidentType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: summary,
                    minLines: 4,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      labelText: 'Neutral incident summary',
                      hintText:
                          'Record what was reported/observed without declaring guilt.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Register Case'),
            ),
          ],
        ),
      ),
    );

    if (ok == true &&
        student.text.trim().isNotEmpty &&
        matric.text.trim().isNotEmpty &&
        course.text.trim().isNotEmpty &&
        summary.text.trim().isNotEmpty) {
      _state.registerIncident(
        studentName: student.text,
        matricNumber: matric.text,
        courseCode: course.text,
        examTitle: exam.text,
        sitting: sitting.text,
        venue: venue.text,
        reportedBy: reporter.text,
        incidentType: incidentType,
        summary: summary.text,
      );
    }

    for (final controller in [
      student,
      matric,
      course,
      exam,
      sitting,
      venue,
      reporter,
      summary,
    ]) {
      controller.dispose();
    }
  }

  Widget _field(TextEditingController controller, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Future<void> _addEvidence(ExamMalpracticeCase item) async {
    final label = TextEditingController();
    final type = TextEditingController();
    final source = TextEditingController();
    final reference = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Evidence • ${item.id}'),
        content: SizedBox(
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(label, 'Evidence label'),
              _field(type, 'Evidence type'),
              _field(source, 'Source / custodian'),
              _field(reference, 'Evidence / custody reference'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Evidence Record'),
          ),
        ],
      ),
    );
    if (ok == true && label.text.trim().isNotEmpty) {
      _state.addEvidence(
        caseId: item.id,
        label: label.text,
        type: type.text,
        source: source.text,
        reference: reference.text,
      );
    }
    label.dispose();
    type.dispose();
    source.dispose();
    reference.dispose();
  }

  Future<void> _addStatement(ExamMalpracticeCase item) async {
    final actor = TextEditingController();
    final role = TextEditingController();
    final statement = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Statement • ${item.id}'),
        content: SizedBox(
          width: 680,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(actor, 'Person giving statement'),
              _field(role, 'Role (Candidate / Invigilator / Witness)'),
              TextField(
                controller: statement,
                minLines: 5,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Statement',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Record Statement'),
          ),
        ],
      ),
    );
    if (ok == true && actor.text.trim().isNotEmpty && statement.text.trim().isNotEmpty) {
      _state.addStatement(
        caseId: item.id,
        actor: actor.text,
        role: role.text,
        statement: statement.text,
      );
    }
    actor.dispose();
    role.dispose();
    statement.dispose();
  }

  Future<void> _noteAction({
    required String title,
    required String hint,
    required ValueChanged<String> onSubmit,
  }) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 7,
          decoration: InputDecoration(
            labelText: 'Case note',
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note != null) onSubmit(note);
  }

  Future<void> _recordDecision(ExamMalpracticeCase item) async {
    final authority = TextEditingController();
    final decision = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Authorized Decision • ${item.id}'),
        content: SizedBox(
          width: 680,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(authority, 'Decision authority / committee'),
              TextField(
                controller: decision,
                minLines: 4,
                maxLines: 7,
                decoration: const InputDecoration(
                  labelText: 'Official decision / outcome',
                  helperText:
                      'Record an already-authorized decision; do not create the sanction here.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Record Decision'),
          ),
        ],
      ),
    );
    if (ok == true && authority.text.trim().isNotEmpty && decision.text.trim().isNotEmpty) {
      _state.recordExternalDecision(
        caseId: item.id,
        authority: authority.text,
        decision: decision.text,
      );
    }
    authority.dispose();
    decision.dispose();
  }

  void _openCase(ExamMalpracticeCase item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item.id} • ${item.studentName}'),
        content: SizedBox(
          width: 900,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(item.status.label),
                    _pill(item.matricNumber),
                    _pill(item.courseCode),
                    _pill(item.incidentType),
                  ],
                ),
                const SizedBox(height: 16),
                _detail('Exam', item.examTitle),
                _detail('Sitting', item.sitting),
                _detail('Venue', item.venue),
                _detail('Reported by', item.reportedBy),
                _detail('Incident summary', item.summary),
                if (item.escalationReference != null)
                  _detail('Escalation reference', item.escalationReference!),
                if (item.externalDecision != null)
                  _detail('Authorized decision', item.externalDecision!),
                const SizedBox(height: 16),
                const Text(
                  'Evidence & Chain-of-Custody Records',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                if (item.evidence.isEmpty)
                  const Text('No evidence record has been attached yet.')
                else
                  for (final evidence in item.evidence)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.attach_file_outlined),
                      ),
                      title: Text(evidence.label),
                      subtitle: Text(
                        '${evidence.type} • ${evidence.source}\nReference: ${evidence.reference}',
                      ),
                    ),
                const Divider(height: 28),
                const Text(
                  'Statements',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                if (item.statements.isEmpty)
                  const Text('No statement has been recorded yet.')
                else
                  for (final statement in item.statements)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        child: Icon(Icons.record_voice_over_outlined),
                      ),
                      title: Text('${statement.actor} • ${statement.role}'),
                      subtitle: Text(statement.statement),
                    ),
                const Divider(height: 28),
                const Text(
                  'Case Audit Trail',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                for (final audit in item.audit.reversed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history_outlined),
                    title: Text('${audit.actor} • ${audit.action}'),
                    subtitle: Text(audit.note),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              TextSpan(text: value),
            ],
          ),
        ),
      );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
