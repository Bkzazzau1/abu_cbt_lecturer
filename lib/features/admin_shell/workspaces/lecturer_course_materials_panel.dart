import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../lecturer_questions/data/lecturer_question_api.dart';
import '../../lecturer_workflow/data/lecturer_course_materials_state.dart';
import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';

class LecturerCourseMaterialsPanel extends StatefulWidget {
  const LecturerCourseMaterialsPanel({super.key});

  @override
  State<LecturerCourseMaterialsPanel> createState() =>
      _LecturerCourseMaterialsPanelState();
}

class _LecturerCourseMaterialsPanelState
    extends State<LecturerCourseMaterialsPanel> {
  final LecturerCourseMaterialsState _materials =
      LecturerCourseMaterialsState.instance;
  final LecturerGradebookState _gradebook = LecturerGradebookState.instance;
  final LecturerQuestionApi _api = LecturerQuestionApi();

  String? _courseCode;
  String _category = 'Lecture Notes';
  bool _uploading = false;
  String _aiOutput = '';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _courseCode;
    if (code == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No assigned course is available.'),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _materials,
      builder: (context, _) {
        final items = _materials.materialsFor(code);
        final aiCount = _materials.aiSourceCount(code);
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
                          Icons.library_books_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Course Materials',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Chip(label: Text('$aiCount AI source${aiCount == 1 ? '' : 's'}')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 330,
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
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _courseCode = value;
                                _aiOutput = '';
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<String>(
                            initialValue: _category,
                            decoration: const InputDecoration(
                              labelText: 'Material type',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Lecture Notes',
                                child: Text('Lecture Notes'),
                              ),
                              DropdownMenuItem(
                                value: 'Slides',
                                child: Text('Slides'),
                              ),
                              DropdownMenuItem(
                                value: 'Handout',
                                child: Text('Handout'),
                              ),
                              DropdownMenuItem(
                                value: 'Reading',
                                child: Text('Reading'),
                              ),
                              DropdownMenuItem(
                                value: 'Past Questions',
                                child: Text('Past Questions'),
                              ),
                              DropdownMenuItem(
                                value: 'Reference',
                                child: Text('Reference'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) setState(() => _category = value);
                            },
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: _uploading ? null : _uploadMaterials,
                          icon: _uploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload_file_outlined),
                          label: const Text('Upload Materials'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'PDF, Word, PowerPoint, spreadsheet, text, markdown and image materials can be attached to the course. Active sources are available to the question AI.',
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
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'AI Course Assistant',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: aiCount == 0
                              ? null
                              : () => setState(() {
                                    final topics = _materials.keyTopicsFor(code);
                                    _aiOutput = topics.isEmpty
                                        ? 'No key topics are available yet.'
                                        : 'Key topics: ${topics.join(' • ')}';
                                  }),
                          icon: const Icon(Icons.topic_outlined),
                          label: const Text('Key Topics'),
                        ),
                        OutlinedButton.icon(
                          onPressed: aiCount == 0
                              ? null
                              : () => setState(() {
                                    _aiOutput =
                                        _materials.teachingSummaryFor(code);
                                  }),
                          icon: const Icon(Icons.summarize_outlined),
                          label: const Text('Teaching Summary'),
                        ),
                      ],
                    ),
                    if (_aiOutput.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(_aiOutput),
                      ),
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
                    Text(
                      'Uploaded Materials',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('No material uploaded for this course yet.'),
                      )
                    else
                      for (final material in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            child: Icon(Icons.description_outlined),
                          ),
                          title: Text(material.fileName),
                          subtitle: Text(
                            '${material.category} • ${material.sizeLabel} • ${material.uploadedBy}',
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Switch(
                                value: material.useForAi,
                                onChanged: (value) =>
                                    _materials.setUseForAi(material.id, value),
                              ),
                              Text(material.useForAi ? 'Use for AI' : 'AI off'),
                              IconButton(
                                tooltip: 'Remove material',
                                onPressed: () =>
                                    _materials.removeMaterial(material.id),
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

  Future<void> _uploadMaterials() async {
    final code = _courseCode;
    if (code == null) return;
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
        'csv',
        'txt',
        'md',
        'json',
        'png',
        'jpg',
        'jpeg',
        'webp',
      ],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return;

    setState(() => _uploading = true);
    try {
      for (final file in picked.files) {
        final bytes = file.bytes;
        if (bytes == null) continue;
        final url = await _api.uploadFile(
          bytes: bytes,
          fileName: file.name,
          category: 'course_material_${code.replaceAll(' ', '_')}',
        );
        _materials.addMaterial(
          courseCode: code,
          fileName: file.name,
          category: _category,
          sizeBytes: file.size,
          sourceUrl: url,
          uploadedBy:
              AuthSession.instance.session?.name ?? 'Course Lecturer',
          bytes: bytes,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${picked.files.length} course material${picked.files.length == 1 ? '' : 's'} added.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}
