import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';
import '../../lecturer_workflow/data/lecturer_question_import_state.dart';
import '../data/lecturer_question_api.dart';

const _questionImportTypes = <String, String>{
  'single_choice': 'Single Choice',
  'multiple_choice': 'Multiple Choice',
  'fill_blank': 'Fill in the Blank',
  'essay': 'Essay',
  'drag_drop': 'Drag & Drop',
  'image_question': 'Image Question',
  'file_upload': 'File Upload',
};

class LecturerQuestionImportPanel extends StatefulWidget {
  const LecturerQuestionImportPanel({super.key});

  @override
  State<LecturerQuestionImportPanel> createState() =>
      _LecturerQuestionImportPanelState();
}

class _LecturerQuestionImportPanelState
    extends State<LecturerQuestionImportPanel> {
  final LecturerQuestionImportState _imports = LecturerQuestionImportState.instance;
  final LecturerGradebookState _gradebook = LecturerGradebookState.instance;
  final LecturerQuestionApi _api = LecturerQuestionApi();
  final TextEditingController _count = TextEditingController(text: '20');

  String? _courseCode;
  String _target = 'Exam';
  String _questionType = 'single_choice';
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    if (_gradebook.courses.isNotEmpty) {
      _courseCode = _gradebook.courses.first.code;
    }
  }

  @override
  void dispose() {
    _api.close();
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _courseCode;
    return AnimatedBuilder(
      animation: _imports,
      builder: (context, _) {
        final batches = code == null
            ? const <LecturerQuestionImportBatch>[]
            : _imports.batches
                .where((item) => item.courseCode == code)
                .toList(growable: false);
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
                          Icons.upload_file_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Upload Question Bank',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 320,
                          child: DropdownButtonFormField<String>(
                            initialValue: code,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Course',
                              prefixIcon: Icon(Icons.menu_book_outlined),
                            ),
                            items: [
                              for (final course in _gradebook.courses)
                                DropdownMenuItem(
                                  value: course.code,
                                  child: Text('${course.code} • ${course.title}'),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _courseCode = value),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            initialValue: _target,
                            decoration: const InputDecoration(
                              labelText: 'Use for',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Exam', child: Text('Exam')),
                              DropdownMenuItem(value: 'CA 1', child: Text('CA 1')),
                              DropdownMenuItem(value: 'CA 2', child: Text('CA 2')),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => _target = value);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 230,
                          child: DropdownButtonFormField<String>(
                            initialValue: _questionType,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Question type',
                            ),
                            items: [
                              for (final entry in _questionImportTypes.entries)
                                DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _questionType = value);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _count,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Questions in file',
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _uploading || code == null ? null : _upload,
                          icon: _uploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.file_upload_outlined),
                          label: Text(
                            'Upload ${_questionImportTypes[_questionType]}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Upload CSV, Excel, Word, PDF, text or JSON question banks. Select the target question type before uploading so the bank is classified correctly for Exam, CA 1 or CA 2.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
                      'Imported Question Banks',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    if (batches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('No uploaded question bank for this course yet.'),
                      )
                    else
                      for (final batch in batches)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.quiz_outlined),
                          ),
                          title: Text(batch.fileName),
                          subtitle: Text(
                            '${batch.target} • ${_questionImportTypes[batch.questionType] ?? batch.questionType} • ${batch.questionCount} questions • ${batch.uploadedBy}',
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Chip(label: Text('Ready for Review')),
                              IconButton(
                                tooltip: 'Remove uploaded bank',
                                onPressed: () => _imports.removeBatch(batch.id),
                                icon: const Icon(Icons.delete_outline),
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

  Future<void> _upload() async {
    final code = _courseCode;
    final count = int.tryParse(_count.text.trim()) ?? 0;
    if (code == null) return;
    if (count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the number of questions in the file.')),
      );
      return;
    }

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const [
        'csv',
        'xlsx',
        'xls',
        'docx',
        'doc',
        'pdf',
        'txt',
        'json',
      ],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;
    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() => _uploading = true);
    try {
      final url = await _api.uploadFile(
        bytes: bytes,
        fileName: file.name,
        category:
            'question_bank_${_target.replaceAll(' ', '_')}_$_questionType',
      );
      _imports.addBatch(
        courseCode: code,
        target: _target,
        questionType: _questionType,
        questionCount: count,
        fileName: file.name,
        sourceUrl: url,
        uploadedBy: AuthSession.instance.session?.name ?? 'Course Lecturer',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_questionImportTypes[_questionType]} question bank uploaded for $_target.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}
