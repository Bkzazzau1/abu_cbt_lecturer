import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_demo_seed.dart';
import 'exam_officer_question_submission_panel.dart';
import 'moderator_connected_review_panel.dart';

enum QuestionReviewMode { examOfficer, moderator }

class ModeratorQuestionReviewPanel extends StatelessWidget {
  const ModeratorQuestionReviewPanel({
    super.key,
    this.mode = QuestionReviewMode.examOfficer,
  });

  final QuestionReviewMode mode;

  @override
  Widget build(BuildContext context) {
    ExamOfficerDemoSeed.ensureSeeded();

    if (mode == QuestionReviewMode.examOfficer) {
      return const ExamOfficerQuestionSubmissionPanel();
    }

    return const ModeratorConnectedReviewPanel();
  }
}
