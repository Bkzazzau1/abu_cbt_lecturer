import 'package:flutter/material.dart';

class LecturerCourseOverviewPanel extends StatelessWidget {
  const LecturerCourseOverviewPanel({super.key});

  static const _courses = [
    _LecturerCourse(
      'CSC 201',
      'Data Structures',
      '200 Level',
      'Semester 1',
      420,
      'Dr. Bala Yusuf',
      0.82,
      'Active',
    ),
    _LecturerCourse(
      'CSC 305',
      'Database Systems',
      '300 Level',
      'Semester 1',
      248,
      'Prof. Hauwa Musa',
      0.74,
      'Materials pending',
    ),
    _LecturerCourse(
      'CSC 411',
      'Artificial Intelligence',
      '400 Level',
      'Semester 2',
      136,
      'Dr. Sani Bello',
      0.58,
      'Needs attention',
    ),
  ];

  static const _signals = [
    _LecturerSignal(
      'Lecture materials uploaded',
      '31/38',
      0.82,
      Icons.upload_file_outlined,
    ),
    _LecturerSignal(
      'Video lectures uploaded',
      '24/34',
      0.71,
      Icons.video_library_outlined,
    ),
    _LecturerSignal(
      'Assignments marked',
      '302/418',
      0.72,
      Icons.edit_note_outlined,
    ),
    _LecturerSignal('Scores submitted', '8/12', 0.67, Icons.publish_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Assigned Course Delivery',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lecturer workspace for assigned DLC courses only: materials, videos, live classes, assessments, engagement, marking, and score submission.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 980;
                final panelWidth = wide
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(
                      width: panelWidth,
                      child: const _CoursePanel(courses: _courses),
                    ),
                    SizedBox(
                      width: panelWidth,
                      child: const _SignalPanel(signals: _signals),
                    ),
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

class _CoursePanel extends StatelessWidget {
  const _CoursePanel({required this.courses});

  final List<_LecturerCourse> courses;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My courses',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final course in courses) _CourseRow(course: course),
          ],
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({required this.course});

  final _LecturerCourse course;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = course.progress < 0.65 ? scheme.error : scheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${course.code} - ${course.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(course.progress * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${course.level} • ${course.semester} • ${course.students} students • Moderator: ${course.moderator}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: course.progress,
            minHeight: 7,
            color: statusColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _SignalPanel extends StatelessWidget {
  const _SignalPanel({required this.signals});

  final List<_LecturerSignal> signals;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course delivery signals',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final signal in signals) _SignalRow(signal: signal),
          ],
        ),
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.signal});

  final _LecturerSignal signal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(signal.icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        signal.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(signal.value),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: signal.progress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(999),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LecturerCourse {
  const _LecturerCourse(
    this.code,
    this.title,
    this.level,
    this.semester,
    this.students,
    this.moderator,
    this.progress,
    this.status,
  );

  final String code;
  final String title;
  final String level;
  final String semester;
  final int students;
  final String moderator;
  final double progress;
  final String status;
}

class _LecturerSignal {
  const _LecturerSignal(this.label, this.value, this.progress, this.icon);

  final String label;
  final String value;
  final double progress;
  final IconData icon;
}
