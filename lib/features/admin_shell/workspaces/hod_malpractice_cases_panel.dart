import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_malpractice_state.dart';

class HodMalpracticeCasesPanel extends StatefulWidget {
  const HodMalpracticeCasesPanel({super.key});

  @override
  State<HodMalpracticeCasesPanel> createState() =>
      _HodMalpracticeCasesPanelState();
}

class _HodMalpracticeCasesPanelState extends State<HodMalpracticeCasesPanel> {
  final ExamMalpracticeState _state = ExamMalpracticeState.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final cases = _state.cases
            .where((item) =>
                item.status == ExamMalpracticeStatus.escalatedToHod ||
                item.status == ExamMalpracticeStatus.committeeReview ||
                item.status == ExamMalpracticeStatus.decisionRecorded)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final waiting = cases
            .where((item) => item.status == ExamMalpracticeStatus.escalatedToHod)
            .length;
        final committee = cases
            .where((item) => item.status == ExamMalpracticeStatus.committeeReview)
            .length;
        final concluded = cases
            .where((item) => item.status == ExamMalpracticeStatus.decisionRecorded)
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth >= 850
                    ? (constraints.maxWidth - 24) / 3
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: width,
                      child: _KpiCard(
                        label: 'Awaiting HoD review',
                        value: '$waiting',
                        icon: Icons.inbox_outlined,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _KpiCard(
                        label: 'Committee review',
                        value: '$committee',
                        icon: Icons.groups_2_outlined,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _KpiCard(
                        label: 'Decision recorded',
                        value: '$concluded',
                        icon: Icons.verified_outlined,
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
                    Text(
                      'Escalated malpractice case files',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'The HoD reviews the complete case file and may refer it for authorized committee review. Recording an official outcome does not mean the system determined guilt or sanction.',
                    ),
                    const SizedBox(height: 14),
                    if (cases.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Text('No malpractice case has been escalated to the HoD.'),
                        ),
                      )
                    else
                      for (final item in cases) _caseCard(context, item),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: scheme.errorContainer,
              foregroundColor: scheme.onErrorContainer,
              child: const Icon(Icons.gavel_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Malpractice Case Review',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review cases escalated by the Exam Officer with evidence, custody references, statements and audit history. The HoD does not use automated guilt scoring; disciplinary outcomes remain human and authority-driven.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _caseCard(BuildContext context, ExamMalpracticeCase item) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.id} • ${item.courseCode} • ${item.studentName}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text('${item.matricNumber} • ${item.incidentType}'),
                  ],
                ),
              ),
              Chip(label: Text(item.status.label)),
            ],
          ),
          const SizedBox(height: 9),
          Text(item.summary),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('${item.evidence.length} evidence item(s)')),
              Chip(label: Text('${item.statements.length} statement(s)')),
              Chip(label: Text(item.venue)),
              if (item.escalationReference != null)
                Chip(label: Text(item.escalationReference!)),
            ],
          ),
          if (item.externalDecision?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              'Official outcome: ${item.externalDecision}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _inspect(item),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Review Case File'),
              ),
              if (item.status == ExamMalpracticeStatus.escalatedToHod)
                FilledButton.tonalIcon(
                  onPressed: () => _referToCommittee(item),
                  icon: const Icon(Icons.groups_2_outlined),
                  label: const Text('Refer to Committee'),
                ),
              if (item.status == ExamMalpracticeStatus.escalatedToHod ||
                  item.status == ExamMalpracticeStatus.committeeReview)
                FilledButton.icon(
                  onPressed: () => _recordDecision(item),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Record Official Decision'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _referToCommittee(ExamMalpracticeCase item) async {
    final note = await _textDialog(
      title: 'Refer ${item.id} to Committee',
      label: 'Referral note',
      hint: 'State the authorized committee/review direction.',
    );
    if (note == null) return;
    _state.markCommitteeReview(item.id, note);
    _rewriteLastAuditAsHod(
      item,
      action: 'Referred to Committee',
      note: note.isEmpty ? 'Case referred for authorized committee review.' : note,
    );
  }

  Future<void> _recordDecision(ExamMalpracticeCase item) async {
    final authorityController = TextEditingController();
    final decisionController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Official Decision — ${item.id}'),
        content: SizedBox(
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Record only a decision already issued by the authorized HoD/departmental/university disciplinary authority.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorityController,
                decoration: const InputDecoration(
                  labelText: 'Issuing authority',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: decisionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Official decision / outcome',
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
            onPressed: () {
              if (authorityController.text.trim().isEmpty ||
                  decisionController.text.trim().isEmpty) return;
              Navigator.pop(context, true);
            },
            child: const Text('Record Decision'),
          ),
        ],
      ),
    );
    final authority = authorityController.text.trim();
    final decision = decisionController.text.trim();
    authorityController.dispose();
    decisionController.dispose();
    if (result != true) return;

    _state.recordExternalDecision(
      caseId: item.id,
      authority: authority,
      decision: decision,
    );
    _rewriteLastAuditAsHod(
      item,
      action: 'Official Decision Recorded',
      note: '$authority: $decision',
    );
  }

  void _rewriteLastAuditAsHod(
    ExamMalpracticeCase item, {
    required String action,
    required String note,
  }) {
    if (item.audit.isNotEmpty) item.audit.removeLast();
    item.audit.add(
      ExamMalpracticeAuditEntry(
        actor: 'HoD',
        action: action,
        note: note,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<String?> _textDialog({
    required String title,
    required String label,
    required String hint,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: label,
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
    return value;
  }

  void _inspect(ExamMalpracticeCase item) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item.id} — HoD Case Review'),
        content: SizedBox(
          width: 920,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.studentName} • ${item.matricNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${item.courseCode} • ${item.examTitle}'),
                Text('${item.sitting} • ${item.venue}'),
                const SizedBox(height: 12),
                Text(item.summary),
                const SizedBox(height: 16),
                const Text('Evidence',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                if (item.evidence.isEmpty)
                  const Text('No evidence record attached.')
                else
                  for (final evidence in item.evidence)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.attachment_outlined),
                      title: Text(evidence.label),
                      subtitle: Text(
                        '${evidence.type} • ${evidence.source}\nCustody/ref: ${evidence.reference}',
                      ),
                    ),
                const Divider(),
                const Text('Statements',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                if (item.statements.isEmpty)
                  const Text('No statement recorded.')
                else
                  for (final statement in item.statements)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.record_voice_over_outlined),
                      title: Text('${statement.actor} • ${statement.role}'),
                      subtitle: Text(statement.statement),
                    ),
                const Divider(),
                const Text('Audit Trail',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                for (final audit in item.audit)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text('${audit.actor} • ${audit.action}: ${audit.note}'),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
