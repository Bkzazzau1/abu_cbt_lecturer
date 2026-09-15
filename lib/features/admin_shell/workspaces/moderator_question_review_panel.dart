import 'package:flutter/material.dart';

import 'exam_officer_question_submission_panel.dart';
import 'moderator_question_review_panel_legacy.dart' as legacy;

enum QuestionReviewMode { examOfficer, moderator }

class ModeratorQuestionReviewPanel extends StatelessWidget {
  const ModeratorQuestionReviewPanel({
    super.key,
    this.mode = QuestionReviewMode.examOfficer,
  });

  final QuestionReviewMode mode;

  @override
  Widget build(BuildContext context) {
    if (mode == QuestionReviewMode.examOfficer) {
      return const ExamOfficerQuestionSubmissionPanel();
    }

    return const legacy.ModeratorQuestionReviewPanel(
      mode: legacy.QuestionReviewMode.moderator,
    );
  }
}
