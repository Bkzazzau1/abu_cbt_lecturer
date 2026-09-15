import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../lecturer_workflow/data/cbt_calendar_state.dart';
import '../data/lecturer_question_api.dart';

const _caFormats = <_CaFormat>[
  _CaFormat('single_choice', 'Single Choice', Icons.radio_button_checked_outlined),
  _CaFormat('multiple_choice', 'Multiple Choice', Icons.check_box_outlined),
  _CaFormat('fill_blank', 'Fill in the Blank', Icons.short_text_outlined),
  _CaFormat('essay', 'Essay', Icons.notes_outlined),
  _CaFormat('drag_drop', 'Drag & Drop', Icons.drag_indicator_outlined),
  _CaFormat('image_question', 'Image Question', Icons.image_outlined),
  _CaFormat('file_upload', 'File Upload', Icons.upload_file_outlined),
];

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
    _CaQuestionDraft.forType('single_choice'),
    _CaQuestionDraft.forType('essay'),
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
      final issue = _questions[i].firstIssue(i + 1);
      if (issue != null) {
        issues.add(issue);
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
        ..add(_CaQuestionDraft.forType('single_choice'))
        ..add(_CaQuestionDraft.forType('essay'));
    });
  }

  void _addQuestion(String type) {
    setState(() => _questions.add(_CaQuestionDraft.forType(type)));
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

  Future<void> _uploadQuestionImage(_CaQuestionDraft draft) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp', 'svg', 'tif', 'tiff', 'heic', 'heif',
      ],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    if (file.bytes == null) {
      _showIssue('Could not read selected image.');
      return;
    }
    setState(() => draft.imageUploading = true);
    try {
      final url = await _api.uploadFile(
        bytes: file.bytes!,
        fileName: file.name,
        category: 'ca_question_image',
      );
      if (!mounted) return;
      setState(() {
        draft.imageUploading = false;
        draft.imageFileName = file.name;
        draft.imageFileUrl = url;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => draft.imageUploading = false);
      _showIssue(error.toString());
    }
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
                        Icon(Icons.quiz_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Continuous Assessment Questions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        Chip(label: Text('$_totalMarks marks')),
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
                                DropdownMenuItem(value: course.id, child: Text(course.label)),
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
                            decoration: const InputDecoration(labelText: 'Duration (min)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Question Types',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final format in _caFormats)
                          OutlinedButton.icon(
                            onPressed: () => _addQuestion(format.type),
                            icon: Icon(format.icon),
                            label: Text(format.title),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < _questions.length; i++) ...[
                      _CaQuestionCard(
                        number: i + 1,
                        draft: _questions[i],
                        onRemove: () => _removeQuestion(_questions[i]),
                        onUploadImage: () => _uploadQuestionImage(_questions[i]),
                      ),
                      const SizedBox(height: 10),
                    ],
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
                        Icon(Icons.calendar_month_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'CBT Calendar Slots',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        Chip(label: Text('${_calendar.availableSlots.length} available')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RadioGroup<String>(
                      groupValue: _selectedSlotId,
                      onChanged: (value) => setState(() => _selectedSlotId = value),
                      child: Column(
                        children: [
                          for (final slot in _calendar.slots)
                            RadioListTile<String>(
                              value: slot.id,
                              enabled: slot.isAvailable,
                              title: Text(slot.scheduleLabel),
                              subtitle: Text('Capacity: ${slot.capacity}'),
                              secondary: Chip(label: Text(slot.statusLabel)),
                            ),
                        ],
                      ),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
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
              Text(slot.scheduleLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
            if (request != null) ...[
              const SizedBox(height: 12),
              Text('Requested: ${request.dateLabel} • ${request.startTime}–${request.endTime}'),
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
    required this.onUploadImage,
  });

  final int number;
  final _CaQuestionDraft draft;
  final VoidCallback onRemove;
  final VoidCallback onUploadImage;

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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Question ${widget.number}', style: const TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: draft.type,
                  decoration: const InputDecoration(labelText: 'Question type'),
                  items: [
                    for (final format in _caFormats)
                      DropdownMenuItem(value: format.type, child: Text(format.title)),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => draft.setType(value));
                  },
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: draft.marks,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Marks'),
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
          _fieldsForType(draft),
        ],
      ),
    );
  }

  Widget _fieldsForType(_CaQuestionDraft draft) {
    if (draft.type == 'single_choice' || draft.type == 'multiple_choice') {
      final multiple = draft.type == 'multiple_choice';
      return RadioGroup<String>(
        groupValue: draft.singleCorrect,
        onChanged: (value) {
          if (value != null) setState(() => draft.singleCorrect = value);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < draft.options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 46,
                      child: multiple
                          ? Checkbox(
                              value: draft.correctOptions.contains(String.fromCharCode(65 + i)),
                              onChanged: (value) {
                                final key = String.fromCharCode(65 + i);
                                setState(() {
                                  if (value == true) {
                                    draft.correctOptions.add(key);
                                  } else {
                                    draft.correctOptions.remove(key);
                                  }
                                });
                              },
                            )
                          : Radio<String>(
                              value: String.fromCharCode(65 + i),
                            ),
                    ),
                    SizedBox(width: 30, child: Text('${String.fromCharCode(65 + i)}.')),
                    Expanded(
                      child: TextField(
                        controller: draft.options[i],
                        decoration: const InputDecoration(labelText: 'Answer option'),
                      ),
                    ),
                  ],
                ),
              ),
            if (multiple)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: draft.partialMarking,
                onChanged: (value) => setState(() => draft.partialMarking = value),
                title: const Text('Allow partial marking'),
              ),
          ],
        ),
      );
    }

    if (draft.type == 'drag_drop') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < draft.pairs.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: draft.pairs[i].left,
                      decoration: InputDecoration(labelText: 'Pair ${i + 1} left item'),
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      controller: draft.pairs[i].right,
                      decoration: const InputDecoration(labelText: 'Correct match'),
                    ),
                  ),
                  IconButton(
                    onPressed: draft.pairs.length <= 2
                        ? null
                        : () => setState(() => draft.removePair(i)),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => setState(draft.addPair),
            icon: const Icon(Icons.add_outlined),
            label: const Text('Add matching pair'),
          ),
        ],
      );
    }

    if (draft.type == 'image_question') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.tonalIcon(
            onPressed: draft.imageUploading ? null : widget.onUploadImage,
            icon: draft.imageUploading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.image_outlined),
            label: Text(draft.imageFileName.isEmpty ? 'Upload question image' : 'Change image'),
          ),
          if (draft.imageFileName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Uploaded: ${draft.imageFileName}'),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: draft.answer,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Theory answer marking guide'),
          ),
        ],
      );
    }

    if (draft.type == 'essay') {
      return Column(
        children: [
          TextField(
            controller: draft.answer,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Marking guide / expected answer'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: draft.rubric,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Rubric points'),
          ),
        ],
      );
    }

    return TextField(
      controller: draft.answer,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: draft.type == 'fill_blank'
            ? 'Correct / accepted answers'
            : 'Expected file / practical marking guide',
        helperText: draft.type == 'fill_blank' ? 'Separate alternatives with semicolon or new line.' : null,
      ),
    );
  }
}

class _CaQuestionDraft {
  _CaQuestionDraft._(this.type)
      : prompt = TextEditingController(),
        marks = TextEditingController(text: '2'),
        answer = TextEditingController(),
        rubric = TextEditingController();

  factory _CaQuestionDraft.forType(String type) {
    final item = _CaQuestionDraft._(type);
    item.setType(type, seed: true);
    return item;
  }

  String type;
  final TextEditingController prompt;
  final TextEditingController marks;
  final TextEditingController answer;
  final TextEditingController rubric;
  final List<TextEditingController> options = [];
  final Set<String> correctOptions = {};
  final List<_CaPairDraft> pairs = [];
  String singleCorrect = 'A';
  bool partialMarking = false;
  bool imageUploading = false;
  String imageFileName = '';
  String imageFileUrl = '';

  void setType(String value, {bool seed = false}) {
    type = value;
    if (type == 'single_choice' || type == 'multiple_choice') {
      if (options.isEmpty) {
        options.addAll(List.generate(4, (_) => TextEditingController()));
      }
      if (type == 'multiple_choice' && correctOptions.isEmpty) {
        correctOptions.addAll(const ['A', 'B']);
      }
    }
    if (type == 'drag_drop' && pairs.isEmpty) {
      pairs.add(_CaPairDraft());
      pairs.add(_CaPairDraft());
    }
    if (!seed) return;
    switch (type) {
      case 'single_choice':
        prompt.text = 'Which statement best describes a stack data structure?';
        options[0].text = 'It follows LIFO ordering';
        options[1].text = 'It follows FIFO ordering';
        options[2].text = 'It stores only numbers';
        options[3].text = 'It cannot remove items';
        singleCorrect = 'A';
        break;
      case 'multiple_choice':
        prompt.text = 'Select all linear data structures.';
        options[0].text = 'Array';
        options[1].text = 'Queue';
        options[2].text = 'Tree';
        options[3].text = 'Graph';
        break;
      case 'fill_blank':
        prompt.text = 'A queue follows the ____ principle.';
        answer.text = 'FIFO; first in first out';
        break;
      case 'essay':
        prompt.text = 'Explain one practical application of a queue data structure.';
        marks.text = '8';
        answer.text = 'Award marks for a valid queue application and a correct FIFO explanation.';
        rubric.text = 'Application 4 marks; explanation 4 marks.';
        break;
      case 'drag_drop':
        prompt.text = 'Match each structure to its ordering rule.';
        pairs[0].left.text = 'Stack';
        pairs[0].right.text = 'LIFO';
        pairs[1].left.text = 'Queue';
        pairs[1].right.text = 'FIFO';
        break;
      case 'image_question':
        prompt.text = 'Study the uploaded diagram and answer the question.';
        answer.text = 'Award marks using the diagram evidence and expected concept.';
        break;
      case 'file_upload':
        prompt.text = 'Upload the requested practical solution file.';
        answer.text = 'Check correctness, completeness, readability and explanation.';
        break;
    }
  }

  void addPair() => pairs.add(_CaPairDraft());

  void removePair(int index) {
    final pair = pairs.removeAt(index);
    pair.dispose();
  }

  String? firstIssue(int number) {
    if (prompt.text.trim().isEmpty) return 'Enter Question $number.';
    if ((int.tryParse(marks.text.trim()) ?? 0) <= 0) {
      return 'Enter valid marks for Question $number.';
    }
    if (type == 'single_choice' || type == 'multiple_choice') {
      if (options.any((item) => item.text.trim().isEmpty)) {
        return 'Complete all answer options for Question $number.';
      }
      if (type == 'multiple_choice' && correctOptions.isEmpty) {
        return 'Select at least one correct answer for Question $number.';
      }
    } else if (type == 'drag_drop') {
      if (pairs.length < 2 || pairs.any((pair) => !pair.complete)) {
        return 'Complete at least two matching pairs for Question $number.';
      }
    } else if (type == 'image_question') {
      if (imageFileName.isEmpty) return 'Upload the image for Question $number.';
      if (answer.text.trim().isEmpty) return 'Enter the marking guide for Question $number.';
    } else if (answer.text.trim().isEmpty) {
      return 'Enter the answer or marking guide for Question $number.';
    }
    return null;
  }

  CaQuestionSnapshot snapshot() {
    final marksValue = int.tryParse(marks.text.trim()) ?? 0;
    final optionTexts = [for (final option in options) option.text.trim()];
    final correct = type == 'single_choice'
        ? <String>[singleCorrect]
        : correctOptions.toList()..sort();
    String answerValue = answer.text.trim();
    if (type == 'single_choice' && options.isNotEmpty) {
      final index = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.indexOf(singleCorrect);
      if (index >= 0 && index < options.length) {
        answerValue = '$singleCorrect: ${options[index].text.trim()}';
      }
    } else if (type == 'multiple_choice') {
      answerValue = correct.join('; ');
    } else if (type == 'drag_drop') {
      answerValue = pairs.where((pair) => pair.complete).map((pair) => '${pair.left.text.trim()}→${pair.right.text.trim()}').join('; ');
    }
    return CaQuestionSnapshot(
      type: type,
      prompt: prompt.text.trim(),
      marks: marksValue,
      answer: answerValue,
      options: optionTexts,
      correctOptions: correct,
      partialMarking: partialMarking,
      rubric: rubric.text.trim(),
      matchPairs: [
        for (final pair in pairs)
          if (pair.complete)
            CaMatchPair(left: pair.left.text.trim(), right: pair.right.text.trim()),
      ],
      imageFileName: imageFileName,
      imageFileUrl: imageFileUrl,
    );
  }

  void dispose() {
    prompt.dispose();
    marks.dispose();
    answer.dispose();
    rubric.dispose();
    for (final option in options) {
      option.dispose();
    }
    for (final pair in pairs) {
      pair.dispose();
    }
  }
}

class _CaPairDraft {
  _CaPairDraft()
      : left = TextEditingController(),
        right = TextEditingController();

  final TextEditingController left;
  final TextEditingController right;
  bool get complete => left.text.trim().isNotEmpty && right.text.trim().isNotEmpty;

  void dispose() {
    left.dispose();
    right.dispose();
  }
}

class _CaFormat {
  const _CaFormat(this.type, this.title, this.icon);
  final String type;
  final String title;
  final IconData icon;
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
