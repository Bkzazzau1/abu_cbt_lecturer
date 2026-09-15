import 'package:flutter/material.dart';

import 'exam_analytics_panel.dart';

class ExamAnalyticsPage extends StatelessWidget {
  const ExamAnalyticsPage({
    super.key,
    required this.audience,
  });

  final ExamAnalyticsAudience audience;

  @override
  Widget build(BuildContext context) {
    final isHod = audience == ExamAnalyticsAudience.hod;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHod
              ? 'Department Exam Analytics'
              : 'Exam Analytics & Intelligence',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ExamAnalyticsPanel(audience: audience),
        ),
      ),
    );
  }
}
