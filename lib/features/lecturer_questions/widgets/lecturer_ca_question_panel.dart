import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../exam_officer/data/exam_hall_availability_state.dart';
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
  final ExamHallAvailabilityState _hallState =
      ExamHallAvailabilityState.instance;
  final TextEditingController _title = TextEditingController(text: 'CA 1 CBT');
  final TextEditingController _duration = TextEditingController(text: '30');

  bool _loading = true;
  bool _startFreshCa = false;
  int? _courseId;
  String _caLabel = 'CA 1';
  String? _activeHallRequestId;
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

  ExamHallAvailabilityRequest? _activeHallRequest() {
    final id = _activeHallRequestId;
    if (id != null) {
      return _hallState.requestById(id);
    }
    if (_startFreshCa) return null;

    final lecturerName = AuthSession.instance.session?.name ?? 'Lecturer';
    for (final request in _hallState.requests) {
      if (request.requestType == HallTimeRequestType.continuousAssessment &&
          request.caPlan?.lecturerName == lecturerName) {
        return request;
      }
    }
    return null;
  }

  CaAssessmentRecord? _scheduledAssessment(
    ExamHallAvailabilityRequest request,
  ) {
    final id = request.scheduledAssessmentId;
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

  Future<void> _requestSlot() async {
    final issues = _validate();
    if (issues.isNotEmpty) {
      _showIssue(issues.first);
      return;
    }
    final duration = int.parse(_duration.text.trim());
    final preferred = await showDialog<_RequestedSlot>(
      context: context,
      builder: (_) => _SlotRequestDialog(requiredDuration: duration),
    );
    if (preferred == null || !mounted) return;
    final course = _selectedCourse!;
    try {
      final request = _hallState.requestCaAvailability(
        courseId: course.id,
        courseCode: course.code,
        courseTitle: course.title,
        caLabel: _caLabel,
        title: _title.text.trim(),
        durationMinutes: duration,
        questions: _snapshots(),
        lecturerName: AuthSession.instance.session?.name ?? 'Lecturer',
        hallId: preferred.hallId,
        date: preferred.date,
        startTime: preferred.startTime,
        endTime: preferred.endTime,
      );
      setState(() {
        _activeHallRequestId = request.id;
        _startFreshCa = false;
      });
    } catch (error) {
      _showIssue(error.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Future<void> _reassignHallTime(
    ExamHallAvailabilityRequest rejected,
  ) async {
    final plan = rejected.caPlan;
    if (plan == null) return;
    final preferred = await showDialog<_RequestedSlot>(
      context: context,
      builder: (_) => _SlotRequestDialog(requiredDuration: plan.durationMinutes),
    );
    if (preferred == null || !mounted) return;
    try {
      final request = _hallState.reassignCaAvailability(
        rejectedRequestId: rejected.id,
        hallId: preferred.hallId,
        date: preferred.date,
        startTime: preferred.startTime,
        endTime: preferred.endTime,
      );
      setState(() {
        _activeHallRequestId = request.id;
        _startFreshCa = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New CA hall/time request sent to ICT.'),
        ),
      );
    } catch (error) {
      _showIssue(error.toString().replaceFirst('Bad state: ', ''));
    }
  }

  void _newCa() {
    setState(() {
      _activeHallRequestId = null;
      _startFreshCa = true;
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
      animation: _hallState,
      builder: (context, _) => AnimatedBuilder(
        animation: _calendar,
        builder: (context, _) {
          final request = _activeHallRequest();
          if (request != null) {
            final assessment = _scheduledAssessment(request);
            if (assessment != null) {
              return _CaSubmissionStatus(
                assessment: assessment,
                calendar: _calendar,
                onNewCa: _newCa,
              );
            }
            return _CaHallRequestStatus(
              request: request,
              onReassign: request.status == ExamHallAvailabilityStatus.rejected
                  ? () => _reassignHallTime(request)
                  : null,
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
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Course',
                                prefixIcon: Icon(Icons.menu_book_outlined),
                              ),
                              items: [
                                for (final course in _courses)
                                  DropdownMenuItem(
                                    value: course.id,
                                    child: Text(course.label, overflow: TextOverflow.ellipsis),
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
                          Icon(Icons.meeting_room_outlined, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'CA Hall & Time Approval',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose the proposed CBT hall, date and time. ICT only confirms operational availability. The CA is scheduled only after ICT approves the hall/time request.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _requestSlot,
                        icon: const Icon(Icons.outgoing_mail),
                        label: const Text('Choose Hall & Time and Send to ICT'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CaHallRequestStatus extends StatelessWidget {
  const _CaHallRequestStatus({
    required this.request,
    required this.onReassign,
    required this.onNewCa,
  });

  final ExamHallAvailabilityRequest request;
  final VoidCallback? onReassign;
  final VoidCallback onNewCa;

  @override
  Widget build(BuildContext context) {
    final plan = request.caPlan;
    final questionCount = plan?.questions.length ?? 0;
    final totalMarks = plan?.questions.fold<int>(
          0,
          (total, question) => total + question.marks,
        ) ??
        0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  request.status == ExamHallAvailabilityStatus.rejected
                      ? Icons.event_busy_outlined
                      : Icons.hourglass_top_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${plan?.courseCode ?? 'CA'} • ${plan?.caLabel ?? 'Continuous Assessment'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Chip(label: Text(request.status.label)),
              ],
            ),
            const SizedBox(height: 12),
            if (plan != null) ...[
              Text(plan.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Chip(label: Text('$questionCount questions')),
                  Chip(label: Text('$totalMarks marks')),
                  Chip(label: Text('${plan.durationMinutes} minutes')),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              request.scheduleLabel,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text('Hall capacity: ${request.capacity}'),
            if (request.responseNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(request.responseNote),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (onReassign != null)
                  FilledButton.icon(
                    onPressed: onReassign,
                    icon: const Icon(Icons.replay_outlined),
                    label: const Text('Reassign Hall & Time'),
                  ),
                OutlinedButton.icon(
                  onPressed: onNewCa,
                  icon: const Icon(Icons.add_outlined),
                  label: const Text('New CA'),
                ),
              ],
            ),
          ],
        ),
      ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${assessment.courseCode} • ${assessment.caLabel}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const Chip(label: Text('ICT Approved • Scheduled')),
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
              const SizedBox(height: 6),
              Text('Hall capacity: ${slot.capacity}'),
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
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Question type'),
                  items: [
                    for (final format in _caFormats)
                      DropdownMenuItem(
                        value: format.type,
                        child: Text(format.title, overflow: TextOverflow.ellipsis),
                      ),
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
    required this.hallId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  final String hallId;
  final DateTime date;
  final String startTime;
  final String endTime;
}

class _SlotRequestDialog extends StatefulWidget {
  const _SlotRequestDialog({required this.requiredDuration});

  final int requiredDuration;

  @override
  State<_SlotRequestDialog> createState() => _SlotRequestDialogState();
}

class _SlotRequestDialogState extends State<_SlotRequestDialog> {
  String _hallId = ExamHallAvailabilityState.halls.first.id;
  DateTime _date = DateTime(2026, 9, 24);
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);

  String _time(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  int _minutes(String start, String end) {
    int parse(String value) {
      final parts = value.split(':');
      if (parts.length != 2) return 0;
      return (int.tryParse(parts[0]) ?? 0) * 60 +
          (int.tryParse(parts[1]) ?? 0);
    }

    final value = parse(end) - parse(start);
    return value < 0 ? 0 : value;
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';
    final hall = ExamHallAvailabilityState.halls
        .firstWhere((item) => item.id == _hallId);
    final requestedMinutes = _minutes(_time(_start), _time(_end));
    final validDuration = requestedMinutes >= widget.requiredDuration;

    return AlertDialog(
      title: const Text('Request CA Hall & Time'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _hallId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Proposed CBT hall',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                items: [
                  for (final item in ExamHallAvailabilityState.halls)
                    DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        '${item.name} • ${item.capacity} seats',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _hallId = value);
                },
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('${hall.capacity} seats')),
                  Chip(label: Text('${widget.requiredDuration} min required')),
                  Chip(label: Text('$requestedMinutes min requested')),
                ],
              ),
              if (!validDuration) ...[
                const SizedBox(height: 8),
                Text(
                  'The selected time window is shorter than the CA duration.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: validDuration
              ? () => Navigator.pop(
                    context,
                    _RequestedSlot(
                      hallId: _hallId,
                      date: _date,
                      startTime: _time(_start),
                      endTime: _time(_end),
                    ),
                  )
              : null,
          child: const Text('Send to ICT'),
        ),
      ],
    );
  }
}
