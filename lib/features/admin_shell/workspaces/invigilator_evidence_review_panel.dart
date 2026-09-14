import 'package:flutter/material.dart';

class InvigilatorEvidenceReviewPanel extends StatefulWidget {
  const InvigilatorEvidenceReviewPanel({super.key, this.section = 'Live Student Grid'});

  final String section;

  @override
  State<InvigilatorEvidenceReviewPanel> createState() =>
      _InvigilatorEvidenceReviewPanelState();
}

class _InvigilatorEvidenceReviewPanelState
    extends State<InvigilatorEvidenceReviewPanel> {
  String _severity = 'All';
  int _selectedIndex = 0;

  final List<_InvigilatorCase> _cases = const [
    _InvigilatorCase(
      student: 'Aisha Musa',
      matric: 'KASU/DLC/CSC/23/0142',
      course: 'CSC102 Programming Fundamentals',
      exam: 'CSC102 Mid-Semester CBT',
      time: '09:24',
      alert: 'Phone-like object detected',
      severity: 'Critical',
      risk: 92,
      confidence: 0.91,
      status: 'New alert',
      camera: 'Visible',
      mic: 'Human voice',
      screen: 'Locked',
      roomScan: 'Failed left side',
      evidence: ['Camera', 'Screenshot', 'Room scan'],
      recommendation:
          'Review camera frame and request immediate room scan before escalation.',
    ),
    _InvigilatorCase(
      student: 'Usman Bello',
      matric: 'KASU/DLC/CSC/23/0178',
      course: 'CSC101 Introduction to Computing',
      exam: 'CSC101 Final CBT',
      time: '09:31',
      alert: 'Multiple faces detected',
      severity: 'High',
      risk: 84,
      confidence: 0.87,
      status: 'Pending review',
      camera: 'Multiple faces',
      mic: 'Normal',
      screen: 'Locked',
      roomScan: 'Complete',
      evidence: ['Camera', 'Audio'],
      recommendation:
          'Confirm whether another person entered the candidate environment.',
    ),
    _InvigilatorCase(
      student: 'Maryam Yusuf',
      matric: 'KASU/DLC/SEN/23/0091',
      course: 'SEN201 Software Design',
      exam: 'SEN201 Online Exam',
      time: '09:41',
      alert: 'Repeated looking away',
      severity: 'Medium',
      risk: 67,
      confidence: 0.74,
      status: 'Warning recommended',
      camera: 'Visible',
      mic: 'Normal',
      screen: 'Locked',
      roomScan: 'Complete',
      evidence: ['Camera', 'Timeline'],
      recommendation:
          'Send warning and continue monitoring unless pattern increases.',
    ),
    _InvigilatorCase(
      student: 'Ibrahim Sani',
      matric: 'KASU/DLC/CSC/23/0209',
      course: 'CSC203 Data Structures',
      exam: 'CSC203 CBT',
      time: '09:53',
      alert: 'Student disconnected',
      severity: 'Low',
      risk: 38,
      confidence: 0.64,
      status: 'Technical watch',
      camera: 'Offline',
      mic: 'Offline',
      screen: 'Disconnected',
      roomScan: 'Not available',
      evidence: ['Network', 'Audit'],
      recommendation:
          'Wait for reconnection window and log technical interruption.',
    ),
  ];

  List<_InvigilatorCase> get _filteredCases {
    if (_severity == 'All') return _cases;
    return _cases.where((item) => item.severity == _severity).toList();
  }

  _InvigilatorCase? get _selectedCase {
    final cases = _filteredCases;
    if (cases.isEmpty) return null;
    return cases[_selectedIndex.clamp(0, cases.length - 1)];
  }

  void _decision(String action) {
    final item = _selectedCase;
    if (item == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action logged for ${item.student}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _titleForSection(widget.section);
    final subtitle = _subtitleForSection(widget.section);
    final icon = _iconForSection(widget.section);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(title: title, subtitle: subtitle, icon: icon),
            const SizedBox(height: 14),
            const _PolicyBanner(),
            const SizedBox(height: 14),
            _MetricStrip(cases: _cases),
            const SizedBox(height: 16),
            _sectionBody(),
          ],
        ),
      ),
    );
  }

  Widget _sectionBody() {
    switch (widget.section) {
      case 'Live Student Grid':
        return _LiveGrid(
          cases: _cases,
          onOpen: (index) => setState(() => _selectedIndex = index),
        );
      case 'AI Alert Queue':
        return _AlertQueue(
          cases: _filteredCases,
          selectedIndex: _selectedIndex,
          selectedSeverity: _severity,
          onSeverityChanged: (value) => setState(() {
            _severity = value;
            _selectedIndex = 0;
          }),
          onSelected: (index) => setState(() => _selectedIndex = index),
          onDecision: _decision,
        );
      case 'Student Session Detail':
        return _StudentSession(caseItem: _selectedCase ?? _cases.first);
      case 'Evidence Review':
        return _EvidenceReview(caseItem: _selectedCase ?? _cases.first, onDecision: _decision);
      case 'Manual Decisions':
        return _ManualDecisions(caseItem: _selectedCase ?? _cases.first, onDecision: _decision);
      case 'Room Scan Requests':
        return _RoomScan(caseItem: _selectedCase ?? _cases.first, onDecision: _decision);
      case 'Attendance & Check-in':
        return const _AttendanceCheckIn();
      case 'Risk Timeline':
        return _RiskTimeline(caseItem: _selectedCase ?? _cases.first);
      case 'Malpractice Drafts':
        return _IncidentReport(caseItem: _selectedCase ?? _cases.first, onDecision: _decision);
      case 'Evidence Sync Status':
        return const _EvidenceSync();
      case 'Audit Trail':
        return _AuditTrail(cases: _cases);
      default:
        return _EvidenceReview(caseItem: _selectedCase ?? _cases.first, onDecision: _decision);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 14,
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh live feed'),
        ),
      ],
    );
  }
}

class _PolicyBanner extends StatelessWidget {
  const _PolicyBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.policy_outlined, color: scheme.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Invigilator reviews evidence only. Final disciplinary decision goes to Exam Officer / Disciplinary Review.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.cases});

  final List<_InvigilatorCase> cases;

  @override
  Widget build(BuildContext context) {
    final highRisk = cases.where((e) => e.severity == 'High' || e.severity == 'Critical').length;
    final critical = cases.where((e) => e.severity == 'Critical').length;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _MetricTile(label: 'Live students', value: '118', icon: Icons.groups_2_outlined),
        _MetricTile(label: 'AI alerts', value: '${cases.length}', icon: Icons.notification_important_outlined),
        _MetricTile(label: 'High risk', value: '$highRisk', icon: Icons.warning_amber_outlined),
        _MetricTile(label: 'Critical', value: '$critical', icon: Icons.priority_high_outlined),
        const _MetricTile(label: 'Pending review', value: '12', icon: Icons.pending_actions_outlined),
        const _MetricTile(label: 'Escalated', value: '2', icon: Icons.escalator_warning_outlined),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 180,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _LiveGrid extends StatelessWidget {
  const _LiveGrid({required this.cases, required this.onOpen});

  final List<_InvigilatorCase> cases;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 1200 ? 4 : width > 850 ? 3 : width > 560 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cases.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 245,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => _StudentCard(caseItem: cases[index], onOpen: () => onOpen(index)),
        );
      },
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.caseItem, required this.onOpen});

  final _InvigilatorCase caseItem;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(caseItem.student.characters.first)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(caseItem.student, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                    Text(caseItem.matric, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              _SeverityBadge(severity: caseItem.severity),
            ],
          ),
          const SizedBox(height: 10),
          Text(caseItem.alert, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Pill(label: 'Risk ${caseItem.risk}'),
              _Pill(label: caseItem.camera),
              _Pill(label: caseItem.screen),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(onPressed: onOpen, icon: const Icon(Icons.open_in_new), label: const Text('Open')),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.video_camera_front_outlined), label: const Text('Scan')),
              FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.warning_amber_outlined), label: const Text('Warn')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertQueue extends StatelessWidget {
  const _AlertQueue({
    required this.cases,
    required this.selectedIndex,
    required this.selectedSeverity,
    required this.onSeverityChanged,
    required this.onSelected,
    required this.onDecision,
  });

  final List<_InvigilatorCase> cases;
  final int selectedIndex;
  final String selectedSeverity;
  final ValueChanged<String> onSeverityChanged;
  final ValueChanged<int> onSelected;
  final ValueChanged<String> onDecision;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              initialValue: selectedSeverity,
              decoration: const InputDecoration(labelText: 'Severity'),
              items: const ['All', 'Critical', 'High', 'Medium', 'Low']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => onSeverityChanged(value ?? 'All'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;
            final selected = cases.isEmpty ? null : cases[selectedIndex.clamp(0, cases.length - 1)];
            final list = _CaseList(cases: cases, selectedIndex: selectedIndex, onSelected: onSelected);
            final detail = _EvidenceReview(caseItem: selected, onDecision: onDecision);
            if (compact) {
              return Column(children: [list, const SizedBox(height: 12), detail]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [SizedBox(width: 390, child: list), const SizedBox(width: 14), Expanded(child: detail)],
            );
          },
        ),
      ],
    );
  }
}

class _CaseList extends StatelessWidget {
  const _CaseList({required this.cases, required this.selectedIndex, required this.onSelected});

  final List<_InvigilatorCase> cases;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) return const _EmptyBox(title: 'No alert matches this filter.');
    return Column(
      children: [
        for (var i = 0; i < cases.length; i++)
          _CaseTile(caseItem: cases[i], selected: selectedIndex == i, onTap: () => onSelected(i)),
      ],
    );
  }
}

class _CaseTile extends StatelessWidget {
  const _CaseTile({required this.caseItem, required this.selected, required this.onTap});

  final _InvigilatorCase caseItem;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? scheme.primaryContainer.withValues(alpha: 0.20) : scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Expanded(child: Text(caseItem.alert, style: const TextStyle(fontWeight: FontWeight.w900))), _SeverityBadge(severity: caseItem.severity)]),
            const SizedBox(height: 6),
            Text('${caseItem.student} • ${caseItem.matric}'),
            const SizedBox(height: 4),
            Text('${caseItem.exam} • ${caseItem.time}', style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [_Pill(label: 'Risk ${caseItem.risk}'), _Pill(label: caseItem.status), _Pill(label: '${(caseItem.confidence * 100).round()}% confidence')]),
          ],
        ),
      ),
    );
  }
}

class _EvidenceReview extends StatelessWidget {
  const _EvidenceReview({required this.caseItem, required this.onDecision});

  final _InvigilatorCase? caseItem;
  final ValueChanged<String> onDecision;

  @override
  Widget build(BuildContext context) {
    final item = caseItem;
    if (item == null) return const _EmptyBox(title: 'Select an alert to review.');
    return _SectionCard(
      title: '${item.student} evidence review',
      icon: Icons.perm_media_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            _Pill(label: item.matric),
            _Pill(label: item.course),
            _Pill(label: 'Risk ${item.risk}'),
            _Pill(label: '${(item.confidence * 100).round()}% AI confidence'),
          ]),
          const SizedBox(height: 12),
          _StatusLine(icon: Icons.sensors_outlined, text: item.alert),
          _StatusLine(icon: Icons.photo_camera_outlined, text: 'Camera: ${item.camera}'),
          _StatusLine(icon: Icons.mic_outlined, text: 'Microphone: ${item.mic}'),
          _StatusLine(icon: Icons.desktop_windows_outlined, text: 'Screen: ${item.screen}'),
          _StatusLine(icon: Icons.video_camera_front_outlined, text: 'Room scan: ${item.roomScan}'),
          const SizedBox(height: 10),
          Text('Evidence available', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final evidence in item.evidence) Chip(label: Text(evidence))]),
          const SizedBox(height: 14),
          Text('AI recommendation', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(item.recommendation),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            OutlinedButton.icon(onPressed: () => onDecision('False alert'), icon: const Icon(Icons.check_circle_outline), label: const Text('Dismiss false alert')),
            OutlinedButton.icon(onPressed: () => onDecision('Warning sent'), icon: const Icon(Icons.warning_amber_outlined), label: const Text('Send warning')),
            OutlinedButton.icon(onPressed: () => onDecision('Room scan requested'), icon: const Icon(Icons.video_camera_front_outlined), label: const Text('Request room scan')),
            FilledButton.icon(onPressed: () => onDecision('Escalated to Exam Officer'), icon: const Icon(Icons.escalator_warning_outlined), label: const Text('Escalate to Exam Officer')),
          ]),
        ],
      ),
    );
  }
}

class _StudentSession extends StatelessWidget {
  const _StudentSession({required this.caseItem});

  final _InvigilatorCase caseItem;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '${caseItem.student} session detail',
      icon: Icons.person_search_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: [_Pill(label: caseItem.matric), _Pill(label: caseItem.exam), _Pill(label: caseItem.course)]),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _MetricTile(label: 'Face status', value: caseItem.camera, icon: Icons.face_outlined),
          _MetricTile(label: 'Audio status', value: caseItem.mic, icon: Icons.graphic_eq_outlined),
          _MetricTile(label: 'Screen status', value: caseItem.screen, icon: Icons.lock_outline),
          _MetricTile(label: 'Room scan', value: caseItem.roomScan, icon: Icons.video_camera_front_outlined),
        ]),
      ]),
    );
  }
}

class _ManualDecisions extends StatelessWidget {
  const _ManualDecisions({required this.caseItem, required this.onDecision});

  final _InvigilatorCase caseItem;
  final ValueChanged<String> onDecision;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Manual decisions for ${caseItem.student}',
      icon: Icons.fact_check_outlined,
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        _ActionButton(icon: Icons.check_circle_outline, label: 'Clear candidate', onTap: onDecision),
        _ActionButton(icon: Icons.warning_amber_outlined, label: 'Send warning', onTap: onDecision),
        _ActionButton(icon: Icons.video_camera_front_outlined, label: 'Request 360 scan', onTap: onDecision),
        _ActionButton(icon: Icons.pause_circle_outline, label: 'Pause session', onTap: onDecision),
        _ActionButton(icon: Icons.play_circle_outline, label: 'Resume session', onTap: onDecision),
        _ActionButton(icon: Icons.escalator_warning_outlined, label: 'Escalate to Exam Officer', onTap: onDecision),
      ]),
    );
  }
}

class _RoomScan extends StatelessWidget {
  const _RoomScan({required this.caseItem, required this.onDecision});

  final _InvigilatorCase caseItem;
  final ValueChanged<String> onDecision;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Room scan / 360 check for ${caseItem.student}',
      icon: Icons.video_camera_front_outlined,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _StatusLine(icon: Icons.info_outline, text: 'Current scan status: ${caseItem.roomScan}'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _ActionButton(icon: Icons.desk_outlined, label: 'Desk scan', onTap: onDecision),
          _ActionButton(icon: Icons.keyboard_arrow_left, label: 'Left side scan', onTap: onDecision),
          _ActionButton(icon: Icons.keyboard_arrow_right, label: 'Right side scan', onTap: onDecision),
          _ActionButton(icon: Icons.desktop_windows_outlined, label: 'Behind monitor', onTap: onDecision),
          _ActionButton(icon: Icons.face_retouching_natural_outlined, label: 'Face recheck', onTap: onDecision),
        ]),
      ]),
    );
  }
}

class _AttendanceCheckIn extends StatelessWidget {
  const _AttendanceCheckIn();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Attendance and check-in control',
      icon: Icons.how_to_reg_outlined,
      child: Wrap(spacing: 10, runSpacing: 10, children: [
        _MetricTile(label: 'Registered', value: '124', icon: Icons.groups_2_outlined),
        _MetricTile(label: 'Checked in', value: '118', icon: Icons.how_to_reg_outlined),
        _MetricTile(label: 'Not checked in', value: '6', icon: Icons.person_off_outlined),
        _MetricTile(label: 'Identity failed', value: '2', icon: Icons.badge_outlined),
        _MetricTile(label: 'Late approval', value: '4', icon: Icons.schedule_outlined),
      ]),
    );
  }
}

class _RiskTimeline extends StatelessWidget {
  const _RiskTimeline({required this.caseItem});

  final _InvigilatorCase caseItem;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(title: 'Risk timeline for ${caseItem.student}', icon: Icons.timeline_outlined, child: Column(children: [
      _StatusLine(icon: Icons.face_outlined, text: '09:01 Face verified'),
      _StatusLine(icon: Icons.play_circle_outline, text: '09:05 Exam started'),
      _StatusLine(icon: Icons.visibility_outlined, text: '${caseItem.time} ${caseItem.alert}'),
      _StatusLine(icon: Icons.folder_outlined, text: 'Evidence captured'),
      _StatusLine(icon: Icons.rule_outlined, text: 'Awaiting invigilator decision'),
    ]));
  }
}

class _IncidentReport extends StatelessWidget {
  const _IncidentReport({required this.caseItem, required this.onDecision});

  final _InvigilatorCase caseItem;
  final ValueChanged<String> onDecision;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(title: 'Incident report draft', icon: Icons.gpp_maybe_outlined, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _StatusLine(icon: Icons.person_outline, text: '${caseItem.student} • ${caseItem.matric}'),
      _StatusLine(icon: Icons.menu_book_outlined, text: caseItem.course),
      _StatusLine(icon: Icons.sensors_outlined, text: caseItem.alert),
      _StatusLine(icon: Icons.percent_outlined, text: 'AI confidence ${(caseItem.confidence * 100).round()}%'),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _ActionButton(icon: Icons.save_outlined, label: 'Save draft', onTap: onDecision),
        _ActionButton(icon: Icons.assignment_turned_in_outlined, label: 'Submit to Exam Officer', onTap: onDecision),
        _ActionButton(icon: Icons.picture_as_pdf_outlined, label: 'Export PDF', onTap: onDecision),
      ]),
    ]));
  }
}

class _EvidenceSync extends StatelessWidget {
  const _EvidenceSync();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(title: 'Evidence sync status', icon: Icons.cloud_sync_outlined, child: Column(children: [
      _StatusLine(icon: Icons.cloud_done_outlined, text: 'Camera evidence: Synced'),
      _StatusLine(icon: Icons.cloud_queue_outlined, text: 'Audio evidence: Pending sync'),
      _StatusLine(icon: Icons.receipt_long_outlined, text: 'Integrity ledger: Pending'),
      _StatusLine(icon: Icons.cloud_off_outlined, text: 'Offline cache: 1 failed sync'),
    ]));
  }
}

class _AuditTrail extends StatelessWidget {
  const _AuditTrail({required this.cases});

  final List<_InvigilatorCase> cases;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(title: 'Invigilator audit trail', icon: Icons.manage_history_outlined, child: Column(children: [
      for (final item in cases) _StatusLine(icon: Icons.rule_outlined, text: '${item.time}: ${item.alert} • ${item.student} • ${item.status}'),
    ]));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: scheme.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: scheme.primary), const SizedBox(width: 8), Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)))]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(onPressed: () => onTap(label), icon: Icon(icon), label: Text(label));
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 8), Expanded(child: Text(text))]),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final String severity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = severity == 'Critical' || severity == 'High' ? scheme.error : severity == 'Medium' ? scheme.secondary : scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999), border: Border.all(color: color.withValues(alpha: 0.38))),
      child: Text(severity, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: scheme.outlineVariant)),
      child: Center(child: Text(title)),
    );
  }
}

class _InvigilatorCase {
  const _InvigilatorCase({
    required this.student,
    required this.matric,
    required this.course,
    required this.exam,
    required this.time,
    required this.alert,
    required this.severity,
    required this.risk,
    required this.confidence,
    required this.status,
    required this.camera,
    required this.mic,
    required this.screen,
    required this.roomScan,
    required this.evidence,
    required this.recommendation,
  });

  final String student;
  final String matric;
  final String course;
  final String exam;
  final String time;
  final String alert;
  final String severity;
  final int risk;
  final double confidence;
  final String status;
  final String camera;
  final String mic;
  final String screen;
  final String roomScan;
  final List<String> evidence;
  final String recommendation;
}

String _titleForSection(String section) {
  switch (section) {
    case 'Live Student Grid':
      return 'Live Exam Dashboard';
    case 'AI Alert Queue':
      return 'AI Alert Queue';
    case 'Evidence Review':
      return 'Evidence Review';
    case 'Manual Decisions':
      return 'Manual Decisions';
    case 'Student Session Detail':
      return 'Student Session Detail';
    case 'Room Scan Requests':
      return 'Room Scan / 360 Check';
    case 'Attendance & Check-in':
      return 'Attendance & Check-in';
    case 'Risk Timeline':
      return 'Risk Timeline';
    case 'Malpractice Drafts':
      return 'Incident Reports';
    case 'Evidence Sync Status':
      return 'Evidence Sync Status';
    case 'Audit Trail':
      return 'Audit Trail';
    default:
      return 'Invigilator Dashboard';
  }
}

String _subtitleForSection(String section) {
  switch (section) {
    case 'Live Student Grid':
      return 'Monitor live students, device health, risk score, and active alerts.';
    case 'AI Alert Queue':
      return 'Review AI alerts, confirm evidence, dismiss false alerts, or escalate to Exam Officer.';
    case 'Evidence Review':
      return 'Inspect camera, audio, screen, room scan, and timeline evidence before taking action.';
    case 'Manual Decisions':
      return 'Record invigilator decisions without directly punishing the student.';
    case 'Student Session Detail':
      return 'View one candidate session with camera, microphone, screen, scan, and risk status.';
    case 'Room Scan Requests':
      return 'Request guided desk, left, right, face, and environment scans.';
    case 'Attendance & Check-in':
      return 'Track registered, checked-in, absent, late, and identity-failed students.';
    case 'Risk Timeline':
      return 'Follow the chronological risk trail for each candidate.';
    case 'Malpractice Drafts':
      return 'Prepare incident report drafts and submit them to the Exam Officer.';
    case 'Evidence Sync Status':
      return 'Track evidence upload, offline cache, and integrity ledger sync.';
    case 'Audit Trail':
      return 'View all invigilator actions and alert review history.';
    default:
      return 'Live exam monitoring and evidence review workspace.';
  }
}

IconData _iconForSection(String section) {
  switch (section) {
    case 'Live Student Grid':
      return Icons.grid_view_outlined;
    case 'AI Alert Queue':
      return Icons.notification_important_outlined;
    case 'Evidence Review':
      return Icons.perm_media_outlined;
    case 'Manual Decisions':
      return Icons.fact_check_outlined;
    case 'Student Session Detail':
      return Icons.person_search_outlined;
    case 'Room Scan Requests':
      return Icons.video_camera_front_outlined;
    case 'Attendance & Check-in':
      return Icons.how_to_reg_outlined;
    case 'Risk Timeline':
      return Icons.timeline_outlined;
    case 'Malpractice Drafts':
      return Icons.gpp_maybe_outlined;
    case 'Evidence Sync Status':
      return Icons.cloud_sync_outlined;
    case 'Audit Trail':
      return Icons.manage_history_outlined;
    default:
      return Icons.verified_user_outlined;
  }
}
