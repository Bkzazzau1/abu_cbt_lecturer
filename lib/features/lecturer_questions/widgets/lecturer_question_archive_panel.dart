import 'package:flutter/material.dart';

import '../data/lecturer_question_api.dart';

/// Read-only browser for every question asked in the last five academic
/// sessions. This is the question bank the platform checks against before a
/// question can be reused: anything asked within the last
/// [ArchivedQuestionItem.noRepeatWindowSessions] sessions stays locked, and
/// only becomes eligible again once that window has passed.
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
  late Future<List<ArchivedQuestionItem>> _future;
  String _query = '';
  String _selectedCourse = 'All';
  String _selectedSession = 'All';
  String _selectedDifficulty = 'All';

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? LecturerQuestionApi();
    _future = _load();
  }

  Future<List<ArchivedQuestionItem>> _load() => _api.fetchArchivedQuestions();

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

    return FutureBuilder<List<ArchivedQuestionItem>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final questions = snapshot.data ?? const [];
        final courses = <String>{
          'All',
          for (final item in questions)
            if (item.courseLabel.isNotEmpty) item.courseLabel,
        }.toList();
        final sessions = <String>{
          'All',
          for (final item in questions) item.session,
        }.toList();
        const difficulties = ['All', 'low', 'medium', 'high'];

        final filtered = questions.where((item) {
          final matchesCourse =
              _selectedCourse == 'All' || item.courseLabel == _selectedCourse;
          final matchesSession =
              _selectedSession == 'All' || item.session == _selectedSession;
          final matchesDifficulty =
              _selectedDifficulty == 'All' ||
              item.difficulty == _selectedDifficulty;
          final matchesQuery =
              _query.trim().isEmpty ||
              item.questionText.toLowerCase().contains(_query.toLowerCase()) ||
              item.courseLabel.toLowerCase().contains(_query.toLowerCase());
          return matchesCourse &&
              matchesSession &&
              matchesDifficulty &&
              matchesQuery;
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
                        'Archive · five-year question bank',
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
                  'Every question asked in the last five sessions, kept so the '
                  'same question is not set again until its no-repeat window '
                  'has passed.',
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
                          labelText: 'Search question or course',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
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
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedSession,
                        items: [
                          for (final session in sessions)
                            DropdownMenuItem(
                              value: session,
                              child: Text(
                                session == 'All' ? 'All sessions' : session,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedSession = value ?? 'All'),
                        decoration: const InputDecoration(labelText: 'Session'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedDifficulty,
                        items: [
                          for (final difficulty in difficulties)
                            DropdownMenuItem(
                              value: difficulty,
                              child: Text(
                                difficulty == 'All'
                                    ? 'All difficulties'
                                    : difficulty[0].toUpperCase() +
                                          difficulty.substring(1),
                              ),
                            ),
                        ],
                        onChanged: (value) => setState(
                          () => _selectedDifficulty = value ?? 'All',
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                        ),
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
                      questions.isEmpty
                          ? 'No archived questions yet.'
                          : 'No questions match this filter.',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                else
                  for (final item in filtered)
                    _ArchivedQuestionTile(item: item),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArchivedQuestionTile extends StatelessWidget {
  const _ArchivedQuestionTile({required this.item});

  final ArchivedQuestionItem item;

  Color _difficultyColor(ColorScheme scheme) {
    switch (item.difficulty) {
      case 'high':
        return scheme.error;
      case 'medium':
        return scheme.tertiary;
      case 'low':
      default:
        return scheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locked = item.isLocked();
    final difficultyColor = _difficultyColor(scheme);

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
                    item.questionText,
                    style: const TextStyle(fontWeight: FontWeight.w700),
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
                      Text('Session ${item.session}'),
                      Text(item.typeLabel),
                      Text('${item.marks} marks'),
                      Text(item.paperTitle),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Pill(
                  label: item.difficultyLabel,
                  color: difficultyColor,
                  scheme: scheme,
                ),
                const SizedBox(height: 6),
                _Pill(
                  label: locked
                      ? 'Locked until ${item.eligibleAgainSession}'
                      : 'Eligible to reuse',
                  color: locked ? scheme.error : scheme.primary,
                  scheme: scheme,
                  outlined: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.scheme,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final ColorScheme scheme;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: outlined ? Border.all(color: color) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
