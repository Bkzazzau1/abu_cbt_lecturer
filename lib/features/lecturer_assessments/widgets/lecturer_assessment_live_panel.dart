import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../data/lecturer_assessment_api.dart';
import '../models/lecturer_assessment.dart';

class LecturerAssessmentLivePanel extends StatefulWidget {
  const LecturerAssessmentLivePanel({super.key});

  @override
  State<LecturerAssessmentLivePanel> createState() => _LecturerAssessmentLivePanelState();
}

class _LecturerAssessmentLivePanelState extends State<LecturerAssessmentLivePanel> {
  late final LecturerAssessmentApi _api;
  late Future<List<LecturerAssessment>> _future;

  @override
  void initState() {
    super.initState();
    _api = LecturerAssessmentApi();
    _future = _api.fetchAssessments();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() {
    setState(() => _future = _api.fetchAssessments());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                    Icon(Icons.rule_folder_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Live assessment questions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_outlined),
                      label: const Text('Refresh'),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_outlined),
                      label: const Text('New assessment'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Connected to ${ApiConfig.baseUrl}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<LecturerAssessment>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return _ErrorState(message: snapshot.error.toString(), onRetry: _reload);
                }
                final assessments = snapshot.data ?? const [];
                if (assessments.isEmpty) {
                  return _EmptyState(onRetry: _reload);
                }
                return Column(
                  children: [
                    for (final assessment in assessments)
                      _AssessmentTile(assessment: assessment),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({required this.assessment});

  final LecturerAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            child: const Icon(Icons.assignment_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assessment.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: assessment.courseCode ?? 'Course not set'),
                    _InfoChip(label: assessment.displayType),
                    _InfoChip(label: assessment.status),
                    _InfoChip(label: '${assessment.questionCount} questions'),
                    _InfoChip(label: '${assessment.totalMarks.toStringAsFixed(0)} marks'),
                    _InfoChip(label: '${assessment.durationMinutes} mins'),
                    _InfoChip(label: '${assessment.proctoringLevel} monitoring'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 42),
          const SizedBox(height: 8),
          Text('No assessments returned from the backend yet.', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Check again'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backend connection issue', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
