import 'package:flutter/material.dart';

import '../data/lecturer_question_api.dart';

/// Read-only browser for previously created exam question papers. Reuses
/// the same [LecturerQuestionApi] data source as the "Exam Questions"
/// builder — drafts still being worked on stay in that builder; anything
/// that has moved past draft (submitted for review, approved, closed) is
/// treated as the historical record shown here.
class LecturerQuestionArchivePanel extends StatefulWidget {
  const LecturerQuestionArchivePanel({super.key, this.api});

  final LecturerQuestionApi? api;

  @override
  State<LecturerQuestionArchivePanel> createState() =>
      _LecturerQuestionArchivePanelState();
}

class _LecturerQuestionArchivePanelState
    extends State<LecturerQuestionArchivePanel> {
  late final LecturerQuestionApi _api;
  late Future<List<QuestionPaperItem>> _future;
  String _query = '';
  String _selectedCourse = 'All';

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? LecturerQuestionApi();
    _future = _load();
  }

  Future<List<QuestionPaperItem>> _load() async {
    final papers = await _api.fetchQuestionPapers();
    final archived = papers.where((item) => item.status != 'draft').toList();
    archived.sort((a, b) => b.id.compareTo(a.id));
    return archived;
  }

  @override
  void dispose() {
    if (widget.api == null) _api.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<QuestionPaperItem>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final papers = snapshot.data ?? const [];
        final courses = <String>{
          'All',
          for (final paper in papers)
            if (paper.courseLabel.isNotEmpty) paper.courseLabel,
        }.toList();
        final filtered = papers.where((paper) {
          final matchesCourse =
              _selectedCourse == 'All' || paper.courseLabel == _selectedCourse;
          final matchesQuery =
              _query.trim().isEmpty ||
              paper.title.toLowerCase().contains(_query.toLowerCase()) ||
              paper.courseLabel.toLowerCase().contains(_query.toLowerCase());
          return matchesCourse && matchesQuery;
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Archive · previous exam questions',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: loading ? null : _refresh,
                      icon: const Icon(Icons.refresh_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Question papers you have previously submitted, for reference — drafts still in progress stay in Exam Questions.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 260,
                      child: TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: const InputDecoration(
                          labelText: 'Search title or course',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 240,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCourse,
                        items: [
                          for (final course in courses)
                            DropdownMenuItem(
                              value: course,
                              child: Text(
                                course == 'All' ? 'All courses' : course,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedCourse = value ?? 'All'),
                        decoration: const InputDecoration(labelText: 'Course'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      papers.isEmpty
                          ? 'No archived question papers yet.'
                          : 'No question papers match this filter.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                else
                  for (final paper in filtered) _ArchivedPaperTile(item: paper),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArchivedPaperTile extends StatelessWidget {
  const _ArchivedPaperTile({required this.item});

  final QuestionPaperItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.rule_folder_outlined, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.courseLabel.isEmpty
                        ? 'Course unavailable'
                        : item.courseLabel,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 14,
                    runSpacing: 6,
                    children: [
                      Text('${item.questionCount} questions'),
                      Text('${item.totalMarks} marks'),
                      Text('${item.durationMinutes} min'),
                    ],
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyle(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
