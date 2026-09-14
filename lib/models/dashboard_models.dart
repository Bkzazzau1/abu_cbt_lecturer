import 'package:flutter/material.dart';

import 'admin_role.dart';

enum WorkStatus { normal, warning, urgent, complete }

extension WorkStatusX on WorkStatus {
  String get label {
    switch (this) {
      case WorkStatus.normal:
        return 'Normal';
      case WorkStatus.warning:
        return 'Attention';
      case WorkStatus.urgent:
        return 'Urgent';
      case WorkStatus.complete:
        return 'Complete';
    }
  }

  Color color(ColorScheme scheme) {
    switch (this) {
      case WorkStatus.normal:
        return scheme.tertiary;
      case WorkStatus.warning:
        return scheme.secondary;
      case WorkStatus.urgent:
        return scheme.error;
      case WorkStatus.complete:
        return scheme.primary;
    }
  }
}

class AdminMetric {
  const AdminMetric({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.status,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final WorkStatus status;
}

class AdminTask {
  const AdminTask({
    required this.title,
    required this.ownerRole,
    required this.due,
    required this.status,
    required this.description,
  });

  final String title;
  final AdminRole ownerRole;
  final String due;
  final WorkStatus status;
  final String description;
}

class ExamRoom {
  const ExamRoom({
    required this.courseCode,
    required this.room,
    required this.time,
    required this.invigilator,
    required this.candidateCount,
    required this.status,
  });

  final String courseCode;
  final String room;
  final String time;
  final String invigilator;
  final int candidateCount;
  final WorkStatus status;
}

class AdminAlert {
  const AdminAlert({
    required this.title,
    required this.message,
    required this.status,
    required this.time,
  });

  final String title;
  final String message;
  final WorkStatus status;
  final String time;
}
