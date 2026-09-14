import 'package:flutter/material.dart';

class LecturerCourseDeliveryFlowPanel extends StatefulWidget {
  const LecturerCourseDeliveryFlowPanel({super.key, required this.section});

  final String section;

  @override
  State<LecturerCourseDeliveryFlowPanel> createState() =>
      _LecturerCourseDeliveryFlowPanelState();
}

class _LecturerCourseDeliveryFlowPanelState
    extends State<LecturerCourseDeliveryFlowPanel> {
  String _course = 'CSC 201';
  String _materialType = 'Lecture notes';
  String _videoStatus = 'Draft';
  String _examQuestionType = 'Mixed';
  String _cbtUploadFormat = 'Excel template';
  bool _allowLateSubmission = true;
  bool _autoMarkObjective = true;
  bool _requiresModerator = true;
  bool _lecturerMicOn = true;
  bool _lecturerCameraOn = true;
  bool _attendanceRecording = true;
  final List<_LiveStudentControl> _liveStudents = [
    _LiveStudentControl(
      name: 'Zainab Ibrahim',
      matricNo: '2023/C/CSC/0188',
      present: true,
      micOn: false,
      cameraOn: true,
      sharePending: true,
      attendanceMinutes: 42,
    ),
    _LiveStudentControl(
      name: 'David Emmanuel',
      matricNo: '2023/C/SENG/0400',
      present: true,
      micOn: true,
      cameraOn: false,
      sharePending: false,
      shareApproved: true,
      attendanceMinutes: 39,
    ),
    _LiveStudentControl(
      name: 'Maryam Bello',
      matricNo: '2022/C/CSC/0112',
      present: true,
      micOn: false,
      cameraOn: false,
      sharePending: false,
      attendanceMinutes: 36,
    ),
    _LiveStudentControl(
      name: 'Ibrahim Yahaya',
      matricNo: '2023/C/SENG/0400',
      present: false,
      micOn: false,
      cameraOn: false,
      sharePending: false,
      attendanceMinutes: 0,
    ),
  ];
  final List<_QuestionDraftItem> _questionDrafts = [
    _QuestionDraftItem(
      number: 1,
      type: 'Objective',
      marks: '2',
      topic: 'Stacks and queues',
      question: 'Which data structure follows last-in-first-out order?',
      answer: 'Stack',
    ),
    _QuestionDraftItem(
      number: 2,
      type: 'Essay',
      marks: '20',
      topic: 'Binary search trees',
      question:
          'Explain insertion and search operations in a binary search tree.',
      answer:
          'Compare at each node, branch left/right, discuss balanced tree cost.',
    ),
  ];

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
                Icon(Icons.cloud_upload_outlined, color: scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.section,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save draft'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _FlowChip(
                  label: 'Assigned courses: 3',
                  icon: Icons.menu_book_outlined,
                ),
                _FlowChip(
                  label: 'Materials: 31/38',
                  icon: Icons.upload_file_outlined,
                ),
                _FlowChip(
                  label: 'Videos: 24/34',
                  icon: Icons.video_library_outlined,
                ),
                _FlowChip(
                  label: 'Live classes: 6',
                  icon: Icons.live_tv_outlined,
                ),
                _FlowChip(label: 'Exam drafts: 4', icon: Icons.quiz_outlined),
              ],
            ),
            const SizedBox(height: 16),
            _CourseSelector(
              course: _course,
              onCourseChanged: (value) => setState(() => _course = value),
            ),
            const SizedBox(height: 18),
            if (widget.section == 'Course Materials') _materialUploadFlow(),
            if (widget.section == 'Video Lectures') _videoUploadFlow(),
            if (widget.section == 'Live Classes') _liveSessionFlow(),
            if (widget.section == 'Assignments' ||
                widget.section == 'Quizzes & Tests')
              _assignmentFlow(),
            if (widget.section == 'Exam Questions') _examQuestionFlow(),
            if (widget.section == 'Student Engagement')
              _studentEngagementFlow(),
            if (widget.section == 'Messages / Q&A') _messagesQaFlow(),
            if (widget.section == 'Profile') _settingsFlow(),
          ],
        ),
      ),
    );
  }

  Widget _materialUploadFlow() {
    return _FlowSection(
      title: 'Course material upload',
      icon: Icons.upload_file_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.attach_file_outlined),
          label: const Text('Select file'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Submit for review'),
        ),
      ],
      children: [
        _ResponsiveFields(
          children: [
            _FieldShell(
              width: 260,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _materialType,
                items: const [
                  DropdownMenuItem(
                    value: 'Course outline',
                    child: Text('Course outline'),
                  ),
                  DropdownMenuItem(
                    value: 'Lecture notes',
                    child: Text('Lecture notes'),
                  ),
                  DropdownMenuItem(value: 'PDF file', child: Text('PDF file')),
                  DropdownMenuItem(
                    value: 'PowerPoint slides',
                    child: Text('PowerPoint slides'),
                  ),
                  DropdownMenuItem(
                    value: 'Reading materials',
                    child: Text('Reading materials'),
                  ),
                  DropdownMenuItem(
                    value: 'Practical guide',
                    child: Text('Practical guide'),
                  ),
                  DropdownMenuItem(
                    value: 'External link',
                    child: Text('External link'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _materialType = value ?? 'Lecture notes'),
                decoration: const InputDecoration(labelText: 'Material type'),
              ),
            ),
            const _FieldShell(
              width: 260,
              child: TextField(
                decoration: InputDecoration(labelText: 'Topic / title'),
              ),
            ),
            const _FieldShell(
              width: 180,
              child: TextField(decoration: InputDecoration(labelText: 'Week')),
            ),
            const _FieldShell(
              width: 260,
              child: TextField(
                decoration: InputDecoration(labelText: 'Version note'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const TextField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Material summary',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniPill(label: 'Draft'),
            _MiniPill(label: 'Submitted'),
            _MiniPill(label: 'Approved'),
            _MiniPill(label: 'Needs correction'),
            _MiniPill(label: 'Published'),
          ],
        ),
        const SizedBox(height: 14),
        const _ExistingItemList(
          title: 'Recent materials',
          items: [
            'Week 1 course outline - Published',
            'Week 2 lecture notes - Approved',
            'Database indexing slides - Needs correction',
          ],
        ),
      ],
    );
  }

  Widget _videoUploadFlow() {
    return _FlowSection(
      title: 'Video lecture upload',
      icon: Icons.video_library_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.link_outlined),
          label: const Text('Add video link'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Upload video'),
        ),
      ],
      children: [
        _ResponsiveFields(
          children: [
            const _FieldShell(
              width: 300,
              child: TextField(
                decoration: InputDecoration(labelText: 'Video title'),
              ),
            ),
            const _FieldShell(
              width: 240,
              child: TextField(decoration: InputDecoration(labelText: 'Topic')),
            ),
            const _FieldShell(
              width: 160,
              child: TextField(decoration: InputDecoration(labelText: 'Week')),
            ),
            const _FieldShell(
              width: 180,
              child: TextField(
                decoration: InputDecoration(labelText: 'Duration'),
              ),
            ),
            _FieldShell(
              width: 220,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _videoStatus,
                items: const [
                  DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                  DropdownMenuItem(
                    value: 'Submitted',
                    child: Text('Submitted'),
                  ),
                  DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                  DropdownMenuItem(
                    value: 'Published',
                    child: Text('Published'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _videoStatus = value ?? 'Draft'),
                decoration: const InputDecoration(labelText: 'Upload status'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Video URL or storage path',
            prefixIcon: Icon(Icons.link_outlined),
          ),
        ),
        const SizedBox(height: 14),
        const _ExistingItemList(
          title: 'Video engagement samples',
          items: [
            'Week 1 Introduction - 780 views - 68% completion',
            'Week 2 Arrays and lists - 612 views - 71% completion',
            'Week 4 Trees practical - Draft',
          ],
        ),
      ],
    );
  }

  Widget _liveSessionFlow() {
    return _FlowSection(
      title: 'Create lecturer live session',
      icon: Icons.live_tv_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month_outlined),
          label: const Text('Save schedule'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.publish_outlined),
          label: const Text('Publish to students'),
        ),
      ],
      children: [
        const _ResponsiveFields(
          children: [
            _FieldShell(
              width: 300,
              child: TextField(
                decoration: InputDecoration(labelText: 'Live class topic'),
              ),
            ),
            _FieldShell(
              width: 220,
              child: TextField(
                decoration: InputDecoration(labelText: 'Session date'),
              ),
            ),
            _FieldShell(
              width: 180,
              child: TextField(
                decoration: InputDecoration(labelText: 'Start time'),
              ),
            ),
            _FieldShell(
              width: 180,
              child: TextField(
                decoration: InputDecoration(labelText: 'End time'),
              ),
            ),
            _FieldShell(
              width: 200,
              child: TextField(
                decoration: InputDecoration(labelText: 'Attendance opens'),
              ),
            ),
            _FieldShell(
              width: 260,
              child: TextField(
                decoration: InputDecoration(labelText: 'Attached material'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 320,
              child: SwitchListTile(
                value: _requiresModerator,
                onChanged: (value) =>
                    setState(() => _requiresModerator = value),
                title: const Text('Share recording after class'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(
              width: 320,
              child: SwitchListTile(
                value: _autoMarkObjective,
                onChanged: (value) =>
                    setState(() => _autoMarkObjective = value),
                title: const Text('Enable student attendance tracking'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const TextField(
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Class agenda / student preparation note',
            prefixIcon: Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 14),
        _LecturerLiveRoomPanel(
          course: _course,
          lecturerMicOn: _lecturerMicOn,
          lecturerCameraOn: _lecturerCameraOn,
          attendanceRecording: _attendanceRecording,
          students: _liveStudents,
          onToggleLecturerMic: () =>
              setState(() => _lecturerMicOn = !_lecturerMicOn),
          onToggleLecturerCamera: () =>
              setState(() => _lecturerCameraOn = !_lecturerCameraOn),
          onToggleAttendance: () =>
              setState(() => _attendanceRecording = !_attendanceRecording),
          onToggleStudentMic: (student) =>
              setState(() => student.micOn = !student.micOn),
          onToggleStudentCamera: (student) =>
              setState(() => student.cameraOn = !student.cameraOn),
          onApproveShare: (student) => setState(() {
            student.sharePending = false;
            student.shareApproved = true;
          }),
          onDenyShare: (student) =>
              setState(() => student.sharePending = false),
          onRemoveStudent: (student) => setState(() => student.present = false),
        ),
        const SizedBox(height: 14),
        const _ExistingItemList(
          title: 'Lecturer-created live classes visible to students',
          items: [
            'CSC 201 - Recursion clinic - Friday 10:00 AM - Attendance enabled',
            'CSC 305 - Database normalisation Q&A - Monday 2:00 PM - Recording allowed',
          ],
        ),
      ],
    );
  }

  Widget _assignmentFlow() {
    final isQuiz = widget.section == 'Quizzes & Tests';
    return _FlowSection(
      title: isQuiz ? 'Quiz and test setup' : 'Assignment setup',
      icon: isQuiz ? Icons.quiz_outlined : Icons.assignment_ind_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.rule_outlined),
          label: const Text('Rubric'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.publish_outlined),
          label: Text(isQuiz ? 'Publish quiz' : 'Publish assignment'),
        ),
      ],
      children: [
        _ResponsiveFields(
          children: [
            _FieldShell(
              width: 320,
              child: TextField(
                decoration: InputDecoration(
                  labelText: isQuiz ? 'Quiz title' : 'Assignment title',
                ),
              ),
            ),
            const _FieldShell(
              width: 180,
              child: TextField(decoration: InputDecoration(labelText: 'Marks')),
            ),
            const _FieldShell(
              width: 220,
              child: TextField(
                decoration: InputDecoration(labelText: 'Start date'),
              ),
            ),
            const _FieldShell(
              width: 220,
              child: TextField(
                decoration: InputDecoration(labelText: 'Deadline'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: isQuiz
                ? 'Question instructions'
                : 'Assignment instructions',
            prefixIcon: const Icon(Icons.notes_outlined),
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _allowLateSubmission,
          onChanged: (value) =>
              setState(() => _allowLateSubmission = value ?? true),
          title: const Text('Allow late submission rule'),
          contentPadding: EdgeInsets.zero,
        ),
        if (isQuiz)
          CheckboxListTile(
            value: _autoMarkObjective,
            onChanged: (value) =>
                setState(() => _autoMarkObjective = value ?? true),
            title: const Text('Auto-mark objective questions'),
            contentPadding: EdgeInsets.zero,
          ),
        const _ExistingItemList(
          title: 'Assessment samples',
          items: [
            'Assignment 2 - Rubric complete - 100 marks',
            'Quiz 3 - Objective + short answer - Manual marking pending',
            'Practical guide task - Draft',
          ],
        ),
      ],
    );
  }

  Widget _examQuestionFlow() {
    return _FlowSection(
      title: 'Exam question submission',
      icon: Icons.rule_folder_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file_outlined),
          label: const Text('Upload marking guide'),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.dataset_outlined),
          label: const Text('Upload CBT questions'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send_outlined),
          label: const Text('Submit for moderation'),
        ),
      ],
      children: [
        _ResponsiveFields(
          children: [
            _FieldShell(
              width: 260,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _examQuestionType,
                items: const [
                  DropdownMenuItem(
                    value: 'Objective',
                    child: Text('Objective'),
                  ),
                  DropdownMenuItem(value: 'Essay', child: Text('Essay')),
                  DropdownMenuItem(value: 'Mixed', child: Text('Mixed')),
                  DropdownMenuItem(
                    value: 'Practical',
                    child: Text('Practical'),
                  ),
                  DropdownMenuItem(
                    value: 'Oral/Live',
                    child: Text('Oral/Live'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _examQuestionType = value ?? 'Mixed'),
                decoration: const InputDecoration(labelText: 'Question type'),
              ),
            ),
            const _FieldShell(
              width: 220,
              child: TextField(
                decoration: InputDecoration(labelText: 'Exam window'),
              ),
            ),
            const _FieldShell(
              width: 180,
              child: TextField(
                decoration: InputDecoration(labelText: 'Total marks'),
              ),
            ),
            const _FieldShell(
              width: 260,
              child: TextField(
                decoration: InputDecoration(labelText: 'Moderator'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _QuestionBuilder(
          questions: _questionDrafts,
          onAddQuestion: _addQuestionDraft,
          onQuestionChanged: () => setState(() {}),
        ),
        const SizedBox(height: 12),
        _CbtUploadPanel(
          uploadFormat: _cbtUploadFormat,
          autoMarkObjective: _autoMarkObjective,
          onFormatChanged: (value) => setState(() => _cbtUploadFormat = value),
          onAutoMarkChanged: (value) =>
              setState(() => _autoMarkObjective = value),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _requiresModerator,
          onChanged: (value) => setState(() => _requiresModerator = value),
          title: const Text('Require moderator review before exam office'),
          contentPadding: EdgeInsets.zero,
        ),
        const _ExistingItemList(
          title: 'Question workflow',
          items: [
            'CSC 201 - Submitted to moderator',
            'CSC 305 - Returned for correction',
            'CSC 411 - Draft with marking guide pending',
          ],
        ),
      ],
    );
  }

  void _addQuestionDraft() {
    setState(() {
      _questionDrafts.add(
        _QuestionDraftItem(
          number: _questionDrafts.length + 1,
          type: _examQuestionType == 'Mixed' ? 'Essay' : _examQuestionType,
          marks: '10',
          topic: 'Course learning outcome',
          question: '',
          answer: '',
        ),
      );
    });
  }

  Widget _studentEngagementFlow() {
    return _FlowSection(
      title: 'Student engagement supervision',
      icon: Icons.groups_2_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_outlined),
          label: const Text('Export engagement'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.campaign_outlined),
          label: const Text('Send reminder'),
        ),
      ],
      children: const [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FlowChip(label: 'Active students: 284', icon: Icons.people_alt),
            _FlowChip(
              label: 'Low activity: 31',
              icon: Icons.trending_down_outlined,
            ),
            _FlowChip(
              label: 'Attendance risk: 18',
              icon: Icons.event_busy_outlined,
            ),
            _FlowChip(
              label: 'Unread feedback: 42',
              icon: Icons.mark_chat_unread_outlined,
            ),
          ],
        ),
        SizedBox(height: 14),
        _ExistingItemList(
          title: 'Students needing lecturer attention',
          items: [
            'Aisha Musa - missed two live sessions - send attendance note',
            'David Emmanuel - assignment feedback not viewed',
            'Ibrahim Yahaya - active in Q&A but missing quiz attempt',
          ],
        ),
      ],
    );
  }

  Widget _messagesQaFlow() {
    return _FlowSection(
      title: 'Course messages and Q&A',
      icon: Icons.forum_outlined,
      actions: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.push_pin_outlined),
          label: const Text('Pin answer'),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send_outlined),
          label: const Text('Reply to class'),
        ),
      ],
      children: const [
        TextField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Lecturer response',
            prefixIcon: Icon(Icons.reply_outlined),
          ),
        ),
        SizedBox(height: 14),
        _ExistingItemList(
          title: 'Open student questions',
          items: [
            'Can the recursion clinic recording be shared after class?',
            'Please clarify how Assignment 2 rubric awards presentation marks.',
            'Will CBT objective questions be uploaded as practice samples?',
          ],
        ),
      ],
    );
  }

  Widget _settingsFlow() {
    return _FlowSection(
      title: 'Lecturer course delivery settings',
      icon: Icons.settings_outlined,
      actions: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save settings'),
        ),
      ],
      children: [
        SwitchListTile(
          value: _allowLateSubmission,
          onChanged: (value) => setState(() => _allowLateSubmission = value),
          title: const Text('Default late submission rule'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: _autoMarkObjective,
          onChanged: (value) => setState(() => _autoMarkObjective = value),
          title: const Text('Auto-mark objective questions by default'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: _requiresModerator,
          onChanged: (value) => setState(() => _requiresModerator = value),
          title: const Text('Require moderation before final exam submission'),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

class _CourseSelector extends StatelessWidget {
  const _CourseSelector({required this.course, required this.onCourseChanged});

  final String course;
  final ValueChanged<String> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: course,
        items: const [
          DropdownMenuItem(
            value: 'CSC 201',
            child: Text('CSC 201 - Data Structures'),
          ),
          DropdownMenuItem(
            value: 'CSC 305',
            child: Text('CSC 305 - Database Systems'),
          ),
          DropdownMenuItem(
            value: 'CSC 411',
            child: Text('CSC 411 - Artificial Intelligence'),
          ),
        ],
        onChanged: (value) => onCourseChanged(value ?? 'CSC 201'),
        decoration: const InputDecoration(labelText: 'Assigned course'),
      ),
    );
  }
}

class _FlowSection extends StatelessWidget {
  const _FlowSection({
    required this.title,
    required this.icon,
    required this.children,
    this.actions = const [],
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 10, children: children);
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}

class _QuestionBuilder extends StatelessWidget {
  const _QuestionBuilder({
    required this.questions,
    required this.onAddQuestion,
    required this.onQuestionChanged,
  });

  final List<_QuestionDraftItem> questions;
  final VoidCallback onAddQuestion;
  final VoidCallback onQuestionChanged;

  @override
  Widget build(BuildContext context) {
    final totalMarks = questions.fold<int>(
      0,
      (total, question) => total + (int.tryParse(question.marks) ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Question-by-question builder',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            _MiniPill(label: '${questions.length} questions'),
            _MiniPill(label: '$totalMarks marks drafted'),
            OutlinedButton.icon(
              onPressed: onAddQuestion,
              icon: const Icon(Icons.add_outlined),
              label: const Text('Add question'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final question in questions) ...[
          _QuestionDraftCard(question: question, onChanged: onQuestionChanged),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _QuestionDraftCard extends StatefulWidget {
  const _QuestionDraftCard({required this.question, required this.onChanged});

  final _QuestionDraftItem question;
  final VoidCallback onChanged;

  @override
  State<_QuestionDraftCard> createState() => _QuestionDraftCardState();
}

class _QuestionDraftCardState extends State<_QuestionDraftCard> {
  late String _type;
  late String _marks;

  @override
  void initState() {
    super.initState();
    _type = widget.question.type;
    _marks = widget.question.marks;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FieldShell(
                width: 180,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _type,
                  items: const [
                    DropdownMenuItem(
                      value: 'Objective',
                      child: Text('Objective'),
                    ),
                    DropdownMenuItem(value: 'Essay', child: Text('Essay')),
                    DropdownMenuItem(
                      value: 'Practical',
                      child: Text('Practical'),
                    ),
                    DropdownMenuItem(
                      value: 'Short answer',
                      child: Text('Short answer'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _type = value ?? _type);
                    widget.question.type = _type;
                    widget.onChanged();
                  },
                  decoration: InputDecoration(
                    labelText: 'Question ${widget.question.number} type',
                  ),
                ),
              ),
              _FieldShell(
                width: 130,
                child: TextFormField(
                  initialValue: _marks,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() => _marks = value);
                    widget.question.marks = value;
                    widget.onChanged();
                  },
                  decoration: const InputDecoration(labelText: 'Marks'),
                ),
              ),
              _FieldShell(
                width: 240,
                child: TextFormField(
                  initialValue: widget.question.topic,
                  onChanged: (value) {
                    widget.question.topic = value;
                    widget.onChanged();
                  },
                  decoration: const InputDecoration(labelText: 'Topic / CLO'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: widget.question.question,
            minLines: 2,
            maxLines: 4,
            onChanged: (value) {
              widget.question.question = value;
              widget.onChanged();
            },
            decoration: const InputDecoration(
              labelText: 'Question text',
              prefixIcon: Icon(Icons.help_outline),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: widget.question.answer,
            minLines: 2,
            maxLines: 4,
            onChanged: (value) {
              widget.question.answer = value;
              widget.onChanged();
            },
            decoration: InputDecoration(
              labelText: _type == 'Objective'
                  ? 'Correct option / answer key'
                  : 'Marking guide / expected answer',
              prefixIcon: const Icon(Icons.rule_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _CbtUploadPanel extends StatelessWidget {
  const _CbtUploadPanel({
    required this.uploadFormat,
    required this.autoMarkObjective,
    required this.onFormatChanged,
    required this.onAutoMarkChanged,
  });

  final String uploadFormat;
  final bool autoMarkObjective;
  final ValueChanged<String> onFormatChanged;
  final ValueChanged<bool> onAutoMarkChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
        color: scheme.primaryContainer.withValues(alpha: 0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.computer_outlined, color: scheme.primary),
              Text(
                'Separate CBT question upload',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              _MiniPill(label: 'Objective bank'),
              _MiniPill(label: 'Auto-mark keys'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FieldShell(
                width: 240,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: uploadFormat,
                  items: const [
                    DropdownMenuItem(
                      value: 'Excel template',
                      child: Text('Excel template'),
                    ),
                    DropdownMenuItem(
                      value: 'CSV bank',
                      child: Text('CSV bank'),
                    ),
                    DropdownMenuItem(
                      value: 'QTI package',
                      child: Text('QTI package'),
                    ),
                    DropdownMenuItem(
                      value: 'Manual paste',
                      child: Text('Manual paste'),
                    ),
                  ],
                  onChanged: (value) =>
                      onFormatChanged(value ?? 'Excel template'),
                  decoration: const InputDecoration(labelText: 'CBT format'),
                ),
              ),
              const _FieldShell(
                width: 260,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'CBT file / question bank',
                    prefixIcon: Icon(Icons.attach_file_outlined),
                  ),
                ),
              ),
              const _FieldShell(
                width: 220,
                child: TextField(
                  decoration: InputDecoration(labelText: 'Question count'),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Upload CBT bank'),
              ),
            ],
          ),
          SwitchListTile(
            value: autoMarkObjective,
            onChanged: (value) => onAutoMarkChanged(value),
            title: const Text(
              'Auto-mark CBT objective questions using answer keys',
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _LecturerLiveRoomPanel extends StatelessWidget {
  const _LecturerLiveRoomPanel({
    required this.course,
    required this.lecturerMicOn,
    required this.lecturerCameraOn,
    required this.attendanceRecording,
    required this.students,
    required this.onToggleLecturerMic,
    required this.onToggleLecturerCamera,
    required this.onToggleAttendance,
    required this.onToggleStudentMic,
    required this.onToggleStudentCamera,
    required this.onApproveShare,
    required this.onDenyShare,
    required this.onRemoveStudent,
  });

  final String course;
  final bool lecturerMicOn;
  final bool lecturerCameraOn;
  final bool attendanceRecording;
  final List<_LiveStudentControl> students;
  final VoidCallback onToggleLecturerMic;
  final VoidCallback onToggleLecturerCamera;
  final VoidCallback onToggleAttendance;
  final ValueChanged<_LiveStudentControl> onToggleStudentMic;
  final ValueChanged<_LiveStudentControl> onToggleStudentCamera;
  final ValueChanged<_LiveStudentControl> onApproveShare;
  final ValueChanged<_LiveStudentControl> onDenyShare;
  final ValueChanged<_LiveStudentControl> onRemoveStudent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final presentStudents = students
        .where((student) => student.present)
        .toList();
    final pendingShare = students
        .where((student) => student.sharePending)
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.video_camera_front_outlined, color: scheme.primary),
              Text(
                'Lecturer live classroom control room',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              _MiniPill(label: '$course room'),
              _MiniPill(label: '${presentStudents.length} present'),
              _MiniPill(label: '${pendingShare.length} share pending'),
              _MiniPill(
                label: attendanceRecording
                    ? 'Attendance recording'
                    : 'Attendance paused',
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 980;
              final stageWidth = wide
                  ? constraints.maxWidth * 0.58
                  : constraints.maxWidth;
              final sideWidth = wide
                  ? constraints.maxWidth - stageWidth - 14
                  : constraints.maxWidth;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: stageWidth,
                    child: _LecturerStagePanel(
                      course: course,
                      lecturerMicOn: lecturerMicOn,
                      lecturerCameraOn: lecturerCameraOn,
                      attendanceRecording: attendanceRecording,
                      onToggleLecturerMic: onToggleLecturerMic,
                      onToggleLecturerCamera: onToggleLecturerCamera,
                      onToggleAttendance: onToggleAttendance,
                    ),
                  ),
                  SizedBox(
                    width: sideWidth,
                    child: _LecturerControlSidePanel(
                      students: students,
                      onToggleStudentMic: onToggleStudentMic,
                      onToggleStudentCamera: onToggleStudentCamera,
                      onApproveShare: onApproveShare,
                      onDenyShare: onDenyShare,
                      onRemoveStudent: onRemoveStudent,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LecturerStagePanel extends StatelessWidget {
  const _LecturerStagePanel({
    required this.course,
    required this.lecturerMicOn,
    required this.lecturerCameraOn,
    required this.attendanceRecording,
    required this.onToggleLecturerMic,
    required this.onToggleLecturerCamera,
    required this.onToggleAttendance,
  });

  final String course;
  final bool lecturerMicOn;
  final bool lecturerCameraOn;
  final bool attendanceRecording;
  final VoidCallback onToggleLecturerMic;
  final VoidCallback onToggleLecturerCamera;
  final VoidCallback onToggleAttendance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const _RoomPill(
                icon: Icons.radio_button_checked,
                label: 'Live class',
              ),
              _RoomPill(icon: Icons.school_outlined, label: course),
              const _RoomPill(icon: Icons.schedule_outlined, label: '50 min'),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 8,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF182C51),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      lecturerCameraOn
                          ? Icons.videocam_outlined
                          : Icons.videocam_off_outlined,
                      color: Colors.white.withValues(alpha: 0.72),
                      size: 56,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Text(
                    'Dr. Musa Ibrahim',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    width: 150,
                    height: 92,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      Icons.present_to_all_outlined,
                      color: scheme.primary,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onToggleLecturerMic,
                icon: Icon(lecturerMicOn ? Icons.mic : Icons.mic_off),
                label: Text(lecturerMicOn ? 'Mute self' : 'Unmute self'),
              ),
              FilledButton.tonalIcon(
                onPressed: onToggleLecturerCamera,
                icon: Icon(
                  lecturerCameraOn ? Icons.videocam : Icons.videocam_off,
                ),
                label: Text(lecturerCameraOn ? 'Camera off' : 'Camera on'),
              ),
              FilledButton.tonalIcon(
                onPressed: onToggleAttendance,
                icon: Icon(
                  attendanceRecording
                      ? Icons.fact_check_outlined
                      : Icons.pause_circle_outline,
                ),
                label: Text(
                  attendanceRecording
                      ? 'Pause attendance'
                      : 'Record attendance',
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.screen_share_outlined),
                label: const Text('Share lecturer screen'),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('End class'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LecturerControlSidePanel extends StatelessWidget {
  const _LecturerControlSidePanel({
    required this.students,
    required this.onToggleStudentMic,
    required this.onToggleStudentCamera,
    required this.onApproveShare,
    required this.onDenyShare,
    required this.onRemoveStudent,
  });

  final List<_LiveStudentControl> students;
  final ValueChanged<_LiveStudentControl> onToggleStudentMic;
  final ValueChanged<_LiveStudentControl> onToggleStudentCamera;
  final ValueChanged<_LiveStudentControl> onApproveShare;
  final ValueChanged<_LiveStudentControl> onDenyShare;
  final ValueChanged<_LiveStudentControl> onRemoveStudent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pendingShare = students
        .where((student) => student.sharePending)
        .toList();

    return Container(
      constraints: const BoxConstraints(minHeight: 430),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ControlTab(label: 'People', icon: Icons.groups_outlined),
              _ControlTab(label: 'Q&A', icon: Icons.question_answer_outlined),
              _ControlTab(label: 'Chat', icon: Icons.chat_outlined),
              _ControlTab(label: 'Notes', icon: Icons.notes_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Screen-share approvals',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (pendingShare.isEmpty)
            const _MutedPanelText('No student screen-share request pending.')
          else
            for (final student in pendingShare)
              _ShareApprovalTile(
                student: student,
                onApprove: () => onApproveShare(student),
                onDeny: () => onDenyShare(student),
              ),
          const SizedBox(height: 12),
          Text(
            'Attendance and student controls',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final student in students)
            _StudentControlTile(
              student: student,
              onToggleMic: () => onToggleStudentMic(student),
              onToggleCamera: () => onToggleStudentCamera(student),
              onRemove: () => onRemoveStudent(student),
            ),
        ],
      ),
    );
  }
}

class _ShareApprovalTile extends StatelessWidget {
  const _ShareApprovalTile({
    required this.student,
    required this.onApprove,
    required this.onDeny,
  });

  final _LiveStudentControl student;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Icon(Icons.screen_share_outlined, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${student.name} wants to share screen',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Approve screen share',
            onPressed: onApprove,
            icon: const Icon(Icons.check_circle_outline),
          ),
          IconButton(
            tooltip: 'Deny screen share',
            onPressed: onDeny,
            icon: const Icon(Icons.cancel_outlined),
          ),
        ],
      ),
    );
  }
}

class _StudentControlTile extends StatelessWidget {
  const _StudentControlTile({
    required this.student,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onRemove,
  });

  final _LiveStudentControl student;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = student.present ? scheme.primary : scheme.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withValues(alpha: 0.16),
                child: Text(
                  student.name
                      .split(' ')
                      .where((part) => part.isNotEmpty)
                      .map((part) => part[0])
                      .take(2)
                      .join(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${student.matricNo} • ${student.attendanceMinutes} min',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              _MiniPill(label: student.present ? 'Present' : 'Absent'),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: student.present ? onToggleMic : null,
                icon: Icon(student.micOn ? Icons.mic : Icons.mic_off),
                label: Text(student.micOn ? 'Mute' : 'Unmute'),
              ),
              OutlinedButton.icon(
                onPressed: student.present ? onToggleCamera : null,
                icon: Icon(
                  student.cameraOn ? Icons.videocam : Icons.videocam_off,
                ),
                label: Text(student.cameraOn ? 'Camera off' : 'Camera on'),
              ),
              OutlinedButton.icon(
                onPressed: student.present ? onRemove : null,
                icon: const Icon(Icons.person_remove_outlined),
                label: const Text('Remove'),
              ),
              if (student.shareApproved) _MiniPill(label: 'Sharing approved'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomPill extends StatelessWidget {
  const _RoomPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlTab extends StatelessWidget {
  const _ControlTab({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _MutedPanelText extends StatelessWidget {
  const _MutedPanelText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _ExistingItemList extends StatelessWidget {
  const _ExistingItemList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}

class _FlowChip extends StatelessWidget {
  const _FlowChip({required this.label, required this.icon});

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

class _QuestionDraftItem {
  _QuestionDraftItem({
    required this.number,
    required this.type,
    required this.marks,
    required this.question,
    required this.answer,
    this.topic = 'Course learning outcome',
  });

  final int number;
  String type;
  String marks;
  String question;
  String answer;
  String topic;
}

class _LiveStudentControl {
  _LiveStudentControl({
    required this.name,
    required this.matricNo,
    required this.present,
    required this.micOn,
    required this.cameraOn,
    required this.sharePending,
    required this.attendanceMinutes,
    this.shareApproved = false,
  });

  final String name;
  final String matricNo;
  bool present;
  bool micOn;
  bool cameraOn;
  bool sharePending;
  bool shareApproved;
  int attendanceMinutes;
}
