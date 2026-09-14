class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.actionUrl,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String category;
  final String priority;
  final String actionUrl;
  final bool read;
  final DateTime? createdAt;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
      priority: json['priority']?.toString() ?? 'normal',
      actionUrl: json['action_url']?.toString() ?? '',
      read: json['read_at'] != null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class LecturerAnalyticsOverview {
  const LecturerAnalyticsOverview({
    required this.summary,
    required this.assessments,
    required this.assignments,
    required this.marking,
    required this.ca,
    required this.examScripts,
  });

  final Map<String, dynamic> summary;
  final Map<String, dynamic> assessments;
  final Map<String, dynamic> assignments;
  final Map<String, dynamic> marking;
  final Map<String, dynamic> ca;
  final Map<String, dynamic> examScripts;

  factory LecturerAnalyticsOverview.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> asMap(String key) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
      return <String, dynamic>{};
    }

    return LecturerAnalyticsOverview(
      summary: asMap('summary'),
      assessments: asMap('assessments'),
      assignments: asMap('assignments'),
      marking: asMap('marking'),
      ca: asMap('ca'),
      examScripts: asMap('exam_scripts'),
    );
  }

  num number(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class LiveDashboardData {
  const LiveDashboardData({
    required this.unreadNotifications,
    required this.notifications,
    required this.analytics,
  });

  final int unreadNotifications;
  final List<NotificationItem> notifications;
  final LecturerAnalyticsOverview? analytics;
}
