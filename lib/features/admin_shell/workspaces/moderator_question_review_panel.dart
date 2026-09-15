import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_officer_demo_seed.dart';
import 'exam_officer_question_submission_panel.dart';
import 'moderator_connected_review_panel.dart';

enum QuestionReviewMode { examOfficer, moderator }

class ModeratorQuestionReviewPanel extends StatefulWidget {
  const ModeratorQuestionReviewPanel({
    super.key,
    this.mode = QuestionReviewMode.examOfficer,
  });

  final QuestionReviewMode mode;

  @override
  State<ModeratorQuestionReviewPanel> createState() =>
      _ModeratorQuestionReviewPanelState();
}

class _ModeratorQuestionReviewPanelState
    extends State<ModeratorQuestionReviewPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExamOfficerDemoSeed.ensureSeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == QuestionReviewMode.examOfficer) {
      return const ExamOfficerQuestionSubmissionPanel();
    }

    return const ModeratorConnectedReviewPanel();
  }
}
