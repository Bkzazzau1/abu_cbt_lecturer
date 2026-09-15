import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_script_archive_state.dart';
import '../../exam_officer/services/exam_officer_script_archive_pdf_service.dart';

class ExamOfficerScriptArchivePanel extends StatefulWidget {
  const ExamOfficerScriptArchivePanel({super.key});

  @override
  State<ExamOfficerScriptArchivePanel> createState() =>
      _ExamOfficerScriptArchivePanelState();
}

class _ExamOfficerScriptArchivePanelState
    extends State<ExamOfficerScriptArchivePanel> {
  final ExamScriptArchiveState _state = ExamScriptArchiveState.instance;
  final ExamOfficerScriptArchivePdfService _pdf =
      const ExamOfficerScriptArchivePdfService();

  String _session = 'All';
  String _semester = 'All';
  String _level = 'All';
  String _course = 'All';
  String _search = '';
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final records = _filteredRecords();
        final courses = <String>{
          for (final item in _state.records) item.courseCode,
        }.toList()
          ..sort();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.archive_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Examination Script History & Archive',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Chip(label: Text('${_state.records.length} archived scripts')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Finalized examination scripts are retained by academic session, semester, level, course and student. Print one script or print the complete filtered batch for a level, semester or session.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _dropdown(
                          width: 180,
                          label: 'Session',
                          value: _session,
                          values: ['All', ..._state.sessions],
                          onChanged: (value) =>
                              setState(() => _session = value ?? 'All'),
                        ),
                        _dropdown(
                          width: 180,
                          label: 'Semester',
                          value: _semester,
                          values: ['All', ..._state.semesters],
                          onChanged: (value) =>
                              setState(() => _semester = value ?? 'All'),
                        ),
                        _dropdown(
                          width: 170,
                          label: 'Level',
                          value: _level,
                          values: ['All', ..._state.levels],
                          onChanged: (value) =>
                              setState(() => _level = value ?? 'All'),
                        ),
                        _dropdown(
                          width: 170,
                          label: 'Course',
                          value: _course,
                          values: ['All', ...courses],
                          onChanged: (value) =>
                              setState(() => _course = value ?? 'All'),
                        ),
                        SizedBox(
                          width: 260,
                          child: TextField(
                            onChanged: (value) =>
                                setState(() => _search = value.trim()),
                            decoration: const InputDecoration(
                              labelText: 'Student / matric / course',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: _busy || records.isEmpty
                              ? null
                              : () => _run(
                                    () => _pdf.printScripts(
                                      records,
                                      label: _batchLabel(),
                                    ),
                                  ),
                          icon: const Icon(Icons.print_outlined),
                          label: Text(
                            _level == 'All'
                                ? 'Print Visible Batch (${records.length})'
                                : 'Print $_level Scripts (${records.length})',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy || records.isEmpty
                              ? null
                              : () => _run(
                                    () => _pdf.downloadScripts(
                                      records,
                                      label: _batchLabel(),
                                    ),
                                  ),
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download Visible Batch PDF'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Archived Scripts',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    if (records.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('No archived scripts match this filter.'),
                        ),
                      )
                    else
                      for (final record in records) _recordCard(context, record),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _recordCard(BuildContext context, ArchivedExamScript record) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.courseCode} • ${record.courseTitle}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text('${record.studentName} • ${record.matricNumber}'),
                    const SizedBox(height: 4),
                    Text(
                      record.archivePath,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(label: Text('Grade ${record.grade}')),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(record.academicSession)),
              Chip(label: Text(record.semester)),
              Chip(label: Text(record.level)),
              Chip(
                label: Text(
                  'Score ${record.totalScore}/${record.totalMax}',
                ),
              ),
              Chip(label: Text('Marker: ${record.markerName}')),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(
                          () => _pdf.printScripts(
                            [record],
                            label: '${record.courseCode}_${record.matricNumber}',
                          ),
                        ),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print Individual Script'),
              ),
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () => _run(
                          () => _pdf.downloadScripts(
                            [record],
                            label: '${record.courseCode}_${record.matricNumber}',
                          ),
                        ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Download PDF'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required double width,
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: values.contains(value) ? value : 'All',
        decoration: InputDecoration(labelText: label),
        items: [
          for (final item in values)
            DropdownMenuItem(
              value: item,
              child: Text(item == 'All' ? 'All $label' : item),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }

  List<ArchivedExamScript> _filteredRecords() {
    final query = _search.toLowerCase();
    final records = _state.records.where((record) {
      if (_session != 'All' && record.academicSession != _session) return false;
      if (_semester != 'All' && record.semester != _semester) return false;
      if (_level != 'All' && record.level != _level) return false;
      if (_course != 'All' && record.courseCode != _course) return false;
      if (query.isNotEmpty) {
        final haystack = [
          record.studentName,
          record.matricNumber,
          record.courseCode,
          record.courseTitle,
          record.markerName,
        ].join(' ').toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList();
    records.sort((a, b) {
      final bySession = b.academicSession.compareTo(a.academicSession);
      if (bySession != 0) return bySession;
      final byLevel = a.level.compareTo(b.level);
      if (byLevel != 0) return byLevel;
      final byCourse = a.courseCode.compareTo(b.courseCode);
      if (byCourse != 0) return byCourse;
      return a.matricNumber.compareTo(b.matricNumber);
    });
    return records;
  }

  String _batchLabel() {
    final parts = <String>[
      if (_session != 'All') _session,
      if (_semester != 'All') _semester,
      if (_level != 'All') _level,
      if (_course != 'All') _course,
    ];
    return parts.isEmpty ? 'School_Exam_Script_Archive' : parts.join('_');
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to prepare scripts: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
