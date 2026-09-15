import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../lecturer_workflow/data/cbt_calendar_state.dart';
import '../data/lecturer_question_api.dart';

class LecturerCaQuestionPanel extends StatefulWidget {
  const LecturerCaQuestionPanel({super.key});

  @override
  State<LecturerCaQuestionPanel> createState() => _LecturerCaQuestionPanelState();
}

class _LecturerCaQuestionPanelState extends State<LecturerCaQuestionPanel> {
  final LecturerQuestionApi _api = LecturerQuestionApi();
  final CbtCalendarState _calendar = CbtCalendarState.instance;
  final TextEditingController _title = TextEditingController(text: 'CA 1 CBT');
  final TextEditingController _duration = TextEditingController(text: '30');

  bool _loading = true;
  int? _courseId;
  String _caLabel = 'CA 1';
  String? _selectedSlotId;
  String? _activeAssessmentId;
  List<QuestionCourseOption> _courses = const [];
  final List<_CaQuestionDraft> _questions = [
    _CaQuestionDraft.objective(),
    _CaQuestionDraft.essay(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _api.close();
    _title.dispose();
    _duration.dispose();
    for (final question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final courses = await _api.fetchCourses();
    if (!mounted) return;
    setState(() {
      _courses = courses;
      _courseId = courses.isEmpty ? null : courses.first.id;
      _loading = false;
    });
  }

  int get _totalMarks => _questions.fold<int>(
        0,
        (total, question) => total + (int.tryParse(question.marks.text) ?? 0),
      );

  QuestionCourseOption? get _selectedCourse {
    for (final course in _courses) {
      if (course.id == _courseId) return course;
    }
    return null;
  }

  CaAssessmentRecord? _activeAssessment() {
    final id = _activeAssessmentId;
    if (id == null) return null;
    for (final assessment in _calendar.assessments) {
      if (assessment.id == id) return assessment;
    }
    return null;
  }

  List<String> _validate() {
    final issues = <String>[];
    if (_selectedCourse == null) issues.add('Select a course.');
    if (_title.text.trim().isEmpty) issues.add('Enter the CA title.');
    if ((int.tryParse(_duration.text.trim()) ?? 0) <= 0) {
      issues.add('Enter a valid duration.');
    }
    if (_questions.isEmpty) issues.add('Add at least one question.');
    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.prompt.text.trim().isEmpty) {
        issues.add('Enter Question ${i + 1}.');
        break;
      }
      if ((int.tryParse(question.marks.text.trim()) ?? 0) <= 0) {
        issues.add('Enter valid marks for Question ${i + 1}.');
        break;
      }
      if (question.type == 'single_choice') {
        if (question.options.any((item) => item.text.trim().isEmpty)) {
          issues.add('Complete all options for Question ${i + 1}.');
          break;
        }
      } else if (question.answer.text.trim().isEmpty) {
        issues.add('Enter the marking guide for Question ${i + 1}.');
        break;
      }
    }
    return issues;
  }

  List<CaQuestionSnapshot> _snapshots() => [
        for (final question in _questions) question.snapshot(),
      ];

  void _showIssue(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _schedule() {
    final issues = _validate();
    if (issues.isNotEmpty) {
      _showIssue(issues.first);
      return;
    }
    final slotId = _selectedSlotId;
    if (slotId == null) {
      _showIssue('Select an available CBT calendar slot.');
      return;
    }
    final course = _selectedCourse!;
    try {
      final assessment = _calendar.scheduleCa(
        courseId: course.id,
        courseCode: course.code,
        courseTitle: course.title,
        caLabel: _caLabel,
        title: _title.text.trim(),
        durationMinutes: int.parse(_duration.text.trim()),
        questions: _snapshots(),
        slotId: slotId,
      );
      setState(() => _activeAssessmentId = assessment.id);
    } catch (error) {
      _showIssue(error.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Future<void> _requestSlot() async {
    final issues = _validate();
    if (issues.isNotEmpty) {
      _showIssue(issues.first);
      return;
    }
    final preferred = await showDialog<_RequestedSlot>(
      context: context,
      builder: (_) => const _SlotRequestDialog(),
    );
    if (preferred == null || !mounted) return;
    final course = _selectedCourse!;
    final request = _calendar.requestSlot(
      courseId: course.id,
      courseCode: course.code,
      courseTitle: course.title,
      caLabel: _caLabel,
      title: _title.text.trim(),
      durationMinutes: int.parse(_duration.text.trim()),
      questions: _snapshots(),
      lecturerName: AuthSession.instance.session?.name ?? 'Lecturer',
      preferredDate: preferred.date,
      startTime: preferred.startTime,
      endTime: preferred.endTime,
    );
    setState(() => _activeAssessmentId = request.assessmentId);
  }

  void _newCa() {
    setState(() {
      _activeAssessmentId = null;
      _selectedSlotId = null;
      _caLabel = 'CA 1';
      _title.text = 'CA 1 CBT';
      _duration.text = '30';
      for (final question in _questions) {
        question.dispose();
      }
      _questions
        ..clear()
        ..add(_CaQuestionDraft.objective())
        ..add(_CaQuestionDraft.essay());
    });
  }

  void _addQuestion(String type) {
    setState(() {
      _questions.add(
        type == 'single_choice'
            ? _CaQuestionDraft.objective()
            : _CaQuestionDraft.essay(),
      );
    });
  }

  void _removeQuestion(_CaQuestionDraft question) {
    if (_questions.length == 1) {
      _showIssue('A CA must contain at least one question.');
      return;
    }
    setState(() {
      _questions.remove(question);
      question.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _calendar,
      builder: (context, _) {
        final active = _activeAssessment();
        if (active != null) {
          return _CaSubmissionStatus(
            assessment: active,
            calendar: _calendar,
            onNewCa: _newCa,
          );
        }

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
                          Icons.quiz_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Continuous Assessment Questions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 330,
                          child: DropdownButtonFormField<int>(
                            initialValue: _courseId,
                            decoration: const InputDecoration(
                              labelText: 'Course',
                              prefixIcon: Icon(Icons.menu_book_outlined),
                            ),
                            items: [
                              for (final course in _courses)
                                DropdownMenuItem(
                                  value: course.id,
                                  child: Text(course.label),
                                ),
                            ],
                            onChanged: (value) => setState(() => _courseId = value),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            initialValue: _caLabel,
                            decoration: const InputDecoration(labelText: 'Assessment'),
                            items: const [
                              DropdownMenuItem(value: 'CA 1', child: Text('CA 1')),
                              DropdownMenuItem(value: 'CA 2', child: Text('CA 2')),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _caLabel = value;
                                _title.text = '$value CBT';
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 290,
                          child: TextField(
                            controller: _title,
                            decoration: const InputDecoration(labelText: 'CA title'),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _duration,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Duration (min)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Questions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        Chip(label: Text('Total: $_totalMarks marks')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _questions.length; i++) ...[
                      _CaQuestionCard(
                        number: i + 1,
                        draft: _questions[i],
                        onRemove: () => _removeQuestion(_questions[i]),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _addQuestion('single_choice'),
                          icon: const Icon(Icons.radio_button_checked_outlined),
                          label: const Text('Add Objective'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _addQuestion('essay'),
                          icon: const Icon(Icons.notes_outlined),
                          label: const Text('Add Essay'),
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
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'CBT Calendar Slots',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        Chip(
                          label: Text('${_calendar.availableSlots.length} available'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final slot in _calendar.slots)
                      RadioListTile<String>(
                        value: slot.id,
                        groupValue: _selectedSlotId,
                        onChanged: slot.isAvailable
                            ? (value) => setState(() => _selectedSlotId = value)
                            : null,
                        title: Text(slot.scheduleLabel),
                        subtitle: Text('Capacity: ${slot.capacity}'),
                        secondary: Chip(label: Text(slot.statusLabel)),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: _selectedSlotId == null ? null : _schedule,
                          icon: const Icon(Icons.event_available_outlined),
                          label: const Text('Schedule CA'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _requestSlot,
                          icon: const Icon(Icons.outgoing_mail),
                          label: const Text('Request CBT Slot'),
                        ),
                      ],
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
}

class _CaSubmissionStatus extends StatelessWidget {
  const _CaSubmissionStatus({
    required this.assessment,
    required this.calendar,
    required this.onNewCa,
  });

  final CaAssessmentRecord assessment;
  final CbtCalendarState calendar;
  final VoidCallback onNewCa;

  @override
  Widget build(BuildContext context) {
    final slot = calendar.slotForAssessment(assessment);
    final request = calendar.requestForAssessment(assessment);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  assessment.status == CaAssessmentStatus.scheduled
                      ? Icons.event_available_outlined
                      : assessment.status == CaAssessmentStatus.slotRejected
                          ? Icons.event_busy_outlined
                          : Icons.hourglass_top_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${assessment.courseCode} • ${assessment.caLabel}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Chip(label: Text(assessment.status.label)),
              ],
            ),
            const SizedBox(height: 14),
            Text(assessment.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text('${assessment.questionCount} questions')),
                Chip(label: Text('${assessment.totalMarks} marks')),
                Chip(label: Text('${assessment.durationMinutes} minutes')),
              ],
            ),
            if (slot != null) ...[
              const SizedBox(height: 12),
              Text(
                slot.scheduleLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
            if (request != null) ...[
              const SizedBox(height: 12),
              Text(
                'Requested: ${request.dateLabel} • ${request.startTime}–${request.endTime}',
              ),
              if (request.responseNote.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(request.responseNote),
              ],
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onNewCa,
              icon: const Icon(Icons.add_outlined),
              label: const Text('New CA'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaQuestionCard extends StatefulWidget {
  const _CaQuestionCard({
    required this.number,
    required this.draft,
    required this.onRemove,
  });

  final int number;
  final _CaQuestionDraft draft;
  final VoidCallback onRemove;

  @override
  State<_CaQuestionCard> createState() => _CaQuestionCardState();
}

class _CaQuestionCardState extends State<_CaQuestionCard> {
  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${widget.number}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String>(
                  initialValue: draft.type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'single_choice',
                      child: Text('Single choice'),
                    ),
                    DropdownMenuItem(value: 'essay', child: Text('Essay')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => draft.type = value);
                  },
                ),
              ),
              IconButton(
                tooltip: 'Remove question',
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: draft.prompt,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Question'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 140,
            child: TextField(
              controller: draft.marks,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Marks'),
            ),
          ),
          const SizedBox(height: 10),
          if (draft.type == 'single_choice') ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < draft.options.length; i++)
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: draft.options[i],
                      decoration: InputDecoration(
                        labelText: 'Option ${String.fromCharCode(65 + i)}',
                      ),
                    ),
                  ),
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    initialValue: draft.correctOption,
                    decoration: const InputDecoration(labelText: 'Correct option'),
                    items: const [
                      DropdownMenuItem(value: 'A', child: Text('A')),
                      DropdownMenuItem(value: 'B', child: Text('B')),
                      DropdownMenuItem(value: 'C', child: Text('C')),
                      DropdownMenuItem(value: 'D', child: Text('D')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => draft.correctOption = value);
                    },
                  ),
                ),
              ],
            ),
          ] else
            TextField(
              controller: draft.answer,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Marking guide / answer'),
            ),
        ],
      ),
    );
  }
}

class _CaQuestionDraft {
  _CaQuestionDraft({
    required this.type,
    required String prompt,
    required String marks,
    required String answer,
    required List<String> options,
    this.correctOption = 'A',
  })  : prompt = TextEditingController(text: prompt),
        marks = TextEditingController(text: marks),
        answer = TextEditingController(text: answer),
        options = [for (final option in options) TextEditingController(text: option)];

  factory _CaQuestionDraft.objective() => _CaQuestionDraft(
        type: 'single_choice',
        prompt: 'Which statement best describes a stack data structure?',
        marks: '2',
        answer: '',
        options: const [
          'It follows LIFO ordering',
          'It follows FIFO ordering',
          'It stores only numbers',
          'It cannot remove items',
        ],
      );

  factory _CaQuestionDraft.essay() => _CaQuestionDraft(
        type: 'essay',
        prompt: 'Explain one practical application of a queue data structure.',
        marks: '8',
        answer: 'Award marks for a valid queue application and a correct FIFO explanation.',
        options: const ['', '', '', ''],
      );

  String type;
  final TextEditingController prompt;
  final TextEditingController marks;
  final TextEditingController answer;
  final List<TextEditingController> options;
  String correctOption;

  CaQuestionSnapshot snapshot() {
    final marksValue = int.tryParse(marks.text.trim()) ?? 0;
    if (type == 'single_choice') {
      final index = 'ABCD'.indexOf(correctOption);
      final correct = index >= 0 ? options[index].text.trim() : '';
      return CaQuestionSnapshot(
        type: type,
        prompt: prompt.text.trim(),
        marks: marksValue,
        answer: '$correctOption: $correct',
        options: [for (final option in options) option.text.trim()],
      );
    }
    return CaQuestionSnapshot(
      type: type,
      prompt: prompt.text.trim(),
      marks: marksValue,
      answer: answer.text.trim(),
    );
  }

  void dispose() {
    prompt.dispose();
    marks.dispose();
    answer.dispose();
    for (final option in options) {
      option.dispose();
    }
  }
}

class _RequestedSlot {
  const _RequestedSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  final DateTime date;
  final String startTime;
  final String endTime;
}

class _SlotRequestDialog extends StatefulWidget {
  const _SlotRequestDialog();

  @override
  State<_SlotRequestDialog> createState() => _SlotRequestDialogState();
}

class _SlotRequestDialogState extends State<_SlotRequestDialog> {
  DateTime _date = DateTime(2026, 9, 24);
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);

  String _time(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';
    return AlertDialog(
      title: const Text('Request CBT Slot'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Preferred date'),
              subtitle: Text(dateLabel),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2026, 9, 15),
                  lastDate: DateTime(2027, 12, 31),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Start time'),
              subtitle: Text(_time(_start)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _start);
                if (picked != null) setState(() => _start = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('End time'),
              subtitle: Text(_time(_end)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _end);
                if (picked != null) setState(() => _end = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _RequestedSlot(
              date: _date,
              startTime: _time(_start),
              endTime: _time(_end),
            ),
          ),
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}
