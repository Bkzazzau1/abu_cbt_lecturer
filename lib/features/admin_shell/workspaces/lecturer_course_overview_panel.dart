import 'package:flutter/material.dart';

import 'lecturer_course_materials_panel.dart';
import 'lecturer_course_overview_panel_legacy.dart' as legacy;
import 'lecturer_gradebook_panel.dart';

class LecturerCourseOverviewPanel extends StatefulWidget {
  const LecturerCourseOverviewPanel({super.key});

  @override
  State<LecturerCourseOverviewPanel> createState() =>
      _LecturerCourseOverviewPanelState();
}

class _LecturerCourseOverviewPanelState extends State<LecturerCourseOverviewPanel> {
  String _section = 'My Courses';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'My Courses',
                  label: Text('My Courses'),
                  icon: Icon(Icons.menu_book_outlined),
                ),
                ButtonSegment(
                  value: 'Course Materials',
                  label: Text('Course Materials'),
                  icon: Icon(Icons.library_books_outlined),
                ),
                ButtonSegment(
                  value: 'Students & Scores',
                  label: Text('Students & Scores'),
                  icon: Icon(Icons.groups_2_outlined),
                ),
              ],
              selected: {_section},
              onSelectionChanged: (selection) =>
                  setState(() => _section = selection.first),
            ),
          ),
        ),
        if (_section == 'Students & Scores')
          const LecturerGradebookPanel()
        else if (_section == 'Course Materials')
          const LecturerCourseMaterialsPanel()
        else
          const legacy.LecturerCourseOverviewPanel(),
      ],
    );
  }
}
