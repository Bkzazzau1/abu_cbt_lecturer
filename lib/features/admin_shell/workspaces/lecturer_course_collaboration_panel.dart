import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';
import '../../lecturer_workflow/data/lecturer_course_collaboration_state.dart';
import '../../lecturer_workflow/data/lecturer_gradebook_state.dart';

class LecturerCourseCollaborationPanel extends StatefulWidget {
  const LecturerCourseCollaborationPanel({super.key});

  @override
  State<LecturerCourseCollaborationPanel> createState() =>
      _LecturerCourseCollaborationPanelState();
}

class _LecturerCourseCollaborationPanelState
    extends State<LecturerCourseCollaborationPanel> {
  final LecturerCourseCollaborationState _state =
      LecturerCourseCollaborationState.instance;
  final LecturerGradebookState _gradebook = LecturerGradebookState.instance;

  String _courseCode = 'CSC 305';

  String get _actor => AuthSession.instance.session?.name ?? 'Course Lecturer';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_state, _gradebook]),
      builder: (context, _) {
        final collaborators = _state.collaboratorsFor(_courseCode);
        final work = _state.workFor(_courseCode);

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
                          Icons.groups_3_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Course Collaboration',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        const Chip(label: Text('Equal Lecturer Access')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 280,
                          child: DropdownButtonFormField<String>(
                            initialValue: _courseCode,
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
                              if (value != null) {
                                setState(() => _courseCode = value);
                              }
                            },
                          ),
                        ),
                        for (final lecturer in collaborators)
                          Chip(
                            avatar: const Icon(Icons.person_outline, size: 18),
                            label: Text('${lecturer.role} • ${lecturer.name}'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final item in work) ...[
              _WorkCard(
                item: item,
                actor: _actor,
                state: _state,
                onEdit: item.locked ? null : () => _edit(item),
                onSuggest: () => _suggest(item),
                onReview: () => _review(item),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Future<void> _edit(LecturerCourseWorkItem item) async {
    final title = TextEditingController(text: item.title);
    final details = TextEditingController(text: item.details);
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.category}'),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: details,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Shared work details'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
    if (save == true) {
      _state.editWork(
        id: item.id,
        actor: _actor,
        title: title.text,
        details: details.text,
      );
    }
    title.dispose();
    details.dispose();
  }

  Future<void> _suggest(LecturerCourseWorkItem item) async {
    final controller = TextEditingController();
    final send = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suggestion • ${item.title}'),
        content: SizedBox(
          width: 520,
          child: TextField(
            controller: controller,
            autofocus: true,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Suggestion',
              hintText: 'Write what should be adjusted or reviewed',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.send_outlined),
            label: const Text('Add Suggestion'),
          ),
        ],
      ),
    );
    if (send == true) {
      _state.addSuggestion(
        id: item.id,
        actor: _actor,
        message: controller.text,
      );
    }
    controller.dispose();
  }

  Future<void> _review(LecturerCourseWorkItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.72,
            child: AnimatedBuilder(
              animation: _state,
              builder: (context, _) {
                final current = _state.workItem(item.id);
                return ListView(
                  children: [
                    Text(
                      current.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text('${current.category} • ${current.status}'),
                    const SizedBox(height: 18),
                    Text(
                      'Suggestions',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    if (current.suggestions.isEmpty)
                      const Text('No suggestions yet.'),
                    for (final suggestion in current.suggestions)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          suggestion.resolved
                              ? Icons.check_circle_outline
                              : Icons.chat_bubble_outline,
                        ),
                        title: Text(suggestion.message),
                        subtitle: Text(
                          suggestion.resolved
                              ? '${suggestion.author} • resolved by ${suggestion.resolvedBy}'
                              : suggestion.author,
                        ),
                        trailing: suggestion.resolved
                            ? null
                            : TextButton(
                                onPressed: () => _state.resolveSuggestion(
                                  workId: current.id,
                                  suggestionId: suggestion.id,
                                  actor: _actor,
                                ),
                                child: const Text('Resolve'),
                              ),
                      ),
                    const Divider(height: 28),
                    Text(
                      'Activity',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    for (final activity in current.activity)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history_outlined),
                        title: Text(activity.action),
                        subtitle: Text(activity.actor),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.item,
    required this.actor,
    required this.state,
    required this.onEdit,
    required this.onSuggest,
    required this.onReview,
  });

  final LecturerCourseWorkItem item;
  final String actor;
  final LecturerCourseCollaborationState state;
  final VoidCallback? onEdit;
  final VoidCallback onSuggest;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                Chip(label: Text(item.category)),
                Chip(label: Text(item.status)),
                if (item.locked)
                  const Chip(
                    avatar: Icon(Icons.lock_outline, size: 16),
                    label: Text('Locked'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(item.details),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Created by ${item.createdBy}')),
                Chip(label: Text('Last edit ${item.lastEditedBy}')),
                Chip(label: Text('${item.openSuggestionCount} open suggestions')),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(item.locked ? 'Editing Locked' : 'Edit Shared Work'),
                ),
                OutlinedButton.icon(
                  onPressed: onSuggest,
                  icon: const Icon(Icons.add_comment_outlined),
                  label: const Text('Add Suggestion'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onReview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Review Activity'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
