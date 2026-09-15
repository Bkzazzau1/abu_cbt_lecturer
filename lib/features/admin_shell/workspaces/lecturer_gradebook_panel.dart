import 'package:flutter/material.dart';

import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';
import '../../lecturer_workflow/services/lecturer_gradebook_pdf_service.dart';

class LecturerGradebookPanel extends StatefulWidget {
  const LecturerGradebookPanel({super.key});

  @override
  State<LecturerGradebookPanel> createState() => _LecturerGradebookPanelState();
}

class _LecturerGradebookPanelState extends State<LecturerGradebookPanel> {
  final LecturerGradebookState _state = LecturerGradebookState.instance;
  final LecturerGradebookPdfService _pdfService =
      const LecturerGradebookPdfService();
  final TextEditingController _searchController = TextEditingController();

  String _courseCode = 'CSC 305';
  String _query = '';
  String _sort = 'Matric Number';
  bool _busy = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final course = _state.course(_courseCode);
        final allStudents = _state.studentsFor(_courseCode);
        final visibleStudents = _visibleStudents(allStudents);
        final complete = _state.completeCount(_courseCode);
        final missing = allStudents.length - complete;
        final distribution = _state.gradeDistribution(_courseCode);

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
                          Icons.groups_2_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Students & Scores',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        _StatusChip(
                          label: course.resultsSubmitted
                              ? 'Submitted to Exam Officer'
                              : 'Open Gradebook',
                          submitted: course.resultsSubmitted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 270,
                          child: DropdownButtonFormField<String>(
                            initialValue: _courseCode,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Course',
                              prefixIcon: Icon(Icons.menu_book_outlined),
                            ),
                            items: [
                              for (final item in _state.courses)
                                DropdownMenuItem(
                                  value: item.code,
                                  child: Text('${item.code} • ${item.title}'),
                                ),
                            ],
                            onChanged: _busy
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    setState(() {
                                      _courseCode = value;
                                      _query = '';
                                      _searchController.clear();
                                    });
                                  },
                          ),
                        ),
                        _InfoChip(label: course.level),
                        _InfoChip(label: course.academicSession),
                        _InfoChip(label: course.semester),
                        _InfoChip(label: 'CA 1 /${course.ca1Max}'),
                        _InfoChip(label: 'CA 2 /${course.ca2Max}'),
                        _InfoChip(label: 'Exam /${course.examMax}'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Teaching team',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final lecturer in course.lecturers)
                          Chip(
                            avatar: const Icon(Icons.person_outline, size: 18),
                            label: Text(
                              '${lecturer.role} • ${lecturer.name}',
                            ),
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _Metric(
                          label: 'Students',
                          value: '${allStudents.length}',
                        ),
                        _Metric(label: 'Complete', value: '$complete'),
                        _Metric(label: 'Missing', value: '$missing'),
                        _Metric(
                          label: 'Class Average',
                          value:
                              '${_state.classAverage(_courseCode).toStringAsFixed(1)}%',
                        ),
                        _Metric(
                          label: 'Pass Rate',
                          value:
                              '${_state.passRate(_courseCode).toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _runPdfAction(
                                    () => _pdfService.download(
                                      course: course,
                                      students: allStudents,
                                      kind:
                                          LecturerGradebookPdfKind.matricList,
                                    ),
                                  ),
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Download Matric List'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _runPdfAction(
                                    () => _pdfService.printSheet(
                                      course: course,
                                      students: allStudents,
                                      kind:
                                          LecturerGradebookPdfKind.matricList,
                                    ),
                                  ),
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('Print Matric List'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _runPdfAction(
                                    () => _pdfService.download(
                                      course: course,
                                      students: allStudents,
                                      kind:
                                          LecturerGradebookPdfKind.gradeSheet,
                                    ),
                                  ),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Download Grade Sheet'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _runPdfAction(
                                    () => _pdfService.printSheet(
                                      course: course,
                                      students: allStudents,
                                      kind:
                                          LecturerGradebookPdfKind.gradeSheet,
                                    ),
                                  ),
                          icon: const Icon(Icons.print_outlined),
                          label: const Text('Print Grade Sheet'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _runPdfAction(
                                    () => _pdfService.printSheet(
                                      course: course,
                                      students: allStudents,
                                      kind: LecturerGradebookPdfKind
                                          .blankScoreSheet,
                                    ),
                                  ),
                          icon: const Icon(Icons.note_alt_outlined),
                          label: const Text('Print Blank Score Sheet'),
                        ),
                        FilledButton.icon(
                          onPressed: course.resultsSubmitted ||
                                  !_state.canSubmitResults(_courseCode)
                              ? null
                              : () => _submitResults(course),
                          icon: const Icon(Icons.publish_outlined),
                          label: Text(
                            course.resultsSubmitted
                                ? 'Results Submitted'
                                : 'Submit Final Results',
                          ),
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 320,
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Search student',
                              hintText: 'Name or matric number',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) => setState(
                              () => _query = value.trim().toLowerCase(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 210,
                          child: DropdownButtonFormField<String>(
                            initialValue: _sort,
                            decoration: const InputDecoration(
                              labelText: 'Sort',
                              prefixIcon: Icon(Icons.sort),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Matric Number',
                                child: Text('Matric Number'),
                              ),
                              DropdownMenuItem(
                                value: 'Name',
                                child: Text('Student Name'),
                              ),
                              DropdownMenuItem(
                                value: 'Highest Total',
                                child: Text('Highest Total'),
                              ),
                              DropdownMenuItem(
                                value: 'Lowest Total',
                                child: Text('Lowest Total'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _sort = value);
                              }
                            },
                          ),
                        ),
                        for (final grade
                            in const ['A', 'B', 'C', 'D', 'E', 'F'])
                          _InfoChip(
                            label: '$grade ${distribution[grade] ?? 0}',
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          const DataColumn(label: Text('Student')),
                          const DataColumn(label: Text('Matric Number')),
                          DataColumn(
                            label: Text('CA 1 /${course.ca1Max}'),
                          ),
                          DataColumn(
                            label: Text('CA 2 /${course.ca2Max}'),
                          ),
                          DataColumn(
                            label: Text('Exam /${course.examMax}'),
                          ),
                          DataColumn(
                            label: Text('Total /${course.totalMax}'),
                          ),
                          const DataColumn(label: Text('Grade')),
                          const DataColumn(label: Text('Updated By')),
                        ],
                        rows: [
                          for (final student in visibleStudents)
                            DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 170,
                                    child: Text(
                                      student.studentName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(student.matricNumber)),
                                DataCell(
                                  _ScoreField(
                                    key: ValueKey(
                                      '${student.courseCode}-${student.matricNumber}-ca1',
                                    ),
                                    value: student.ca1,
                                    max: course.ca1Max,
                                    locked: course.resultsSubmitted,
                                    onChanged: (value) => _state.updateCa1(
                                      course.code,
                                      student.matricNumber,
                                      value,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  _ScoreField(
                                    key: ValueKey(
                                      '${student.courseCode}-${student.matricNumber}-ca2',
                                    ),
                                    value: student.ca2,
                                    max: course.ca2Max,
                                    locked: course.resultsSubmitted,
                                    onChanged: (value) => _state.updateCa2(
                                      course.code,
                                      student.matricNumber,
                                      value,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    student.exam?.toString() ?? '—',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    student.complete
                                        ? '${student.total}'
                                        : '—',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    student.gradeFor(course),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    student.lastUpdatedBy.isEmpty
                                        ? '—'
                                        : student.lastUpdatedBy,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<LecturerGradebookStudent> _visibleStudents(
    List<LecturerGradebookStudent> students,
  ) {
    final filtered = students.where((student) {
      if (_query.isEmpty) return true;
      return student.studentName.toLowerCase().contains(_query) ||
          student.matricNumber.toLowerCase().contains(_query);
    }).toList();

    switch (_sort) {
      case 'Name':
        filtered.sort((a, b) => a.studentName.compareTo(b.studentName));
        break;
      case 'Highest Total':
        filtered.sort((a, b) => b.total.compareTo(a.total));
        break;
      case 'Lowest Total':
        filtered.sort((a, b) => a.total.compareTo(b.total));
        break;
      default:
        filtered.sort(
          (a, b) => a.matricNumber.compareTo(b.matricNumber),
        );
    }
    return filtered;
  }

  Future<void> _runPdfAction(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to prepare the PDF.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitResults(LecturerGradebookCourse course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Final Results'),
        content: Text(
          '${course.code} • ${course.title}\n\nSubmit the completed class gradebook to the Exam Officer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _state.submitResults(course.code);
  }
}

class _ScoreField extends StatefulWidget {
  const _ScoreField({
    super.key,
    required this.value,
    required this.max,
    required this.locked,
    required this.onChanged,
  });

  final int? value;
  final int max;
  final bool locked;
  final ValueChanged<int?> onChanged;

  @override
  State<_ScoreField> createState() => _ScoreFieldState();
}

class _ScoreFieldState extends State<_ScoreField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
    _focusNode = FocusNode()..addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(covariant _ScoreField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus) {
      final value = widget.value?.toString() ?? '';
      if (_controller.text != value) _controller.text = value;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _commit() {
    if (widget.locked) return;
    final raw = _controller.text.trim();
    final parsed = raw.isEmpty ? null : int.tryParse(raw);
    final normalized = parsed?.clamp(0, widget.max).toInt();
    final normalizedText = normalized?.toString() ?? '';
    if (_controller.text != normalizedText) {
      _controller.text = normalizedText;
    }
    if (normalized != widget.value) widget.onChanged(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        readOnly: widget.locked,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onSubmitted: (_) => _commit(),
        decoration: InputDecoration(
          isDense: true,
          hintText: '—',
          suffixText: '/${widget.max}',
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.analytics_outlined, size: 18),
      label: Text('$label: $value'),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.submitted});

  final String label;
  final bool submitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = submitted ? scheme.primary : scheme.secondary;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
