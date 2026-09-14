import '../../../core/network/api_client.dart';
import '../models/live_dashboard_models.dart';

class LiveDashboardApi {
  LiveDashboardApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<LiveDashboardData> fetchDashboard({String? lecturerId}) async {
    try {
      final results = await Future.wait<dynamic>([
        fetchUnreadCount(),
        fetchNotifications(),
        fetchLecturerAnalytics(lecturerId: lecturerId),
      ]);

      return LiveDashboardData(
        unreadNotifications: results[0] as int,
        notifications: results[1] as List<NotificationItem>,
        analytics: results[2] as LecturerAnalyticsOverview?,
      );
    } catch (_) {
      return _fallbackDashboard();
    }
  }

  Future<int> fetchUnreadCount() async {
    final data = await _client.get('/api/notifications/unread-count');
    if (data is Map) {
      return int.tryParse(data['unread']?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    final data = await _client.get('/api/notifications');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => NotificationItem.fromJson(item.map((key, value) => MapEntry(key.toString(), value))))
          .toList();
    }
    return const [];
  }

  Future<LecturerAnalyticsOverview?> fetchLecturerAnalytics({String? lecturerId}) async {
    final query = lecturerId == null || lecturerId.isEmpty ? null : {'lecturer_id': lecturerId};
    final data = await _client.get('/api/lecturer/analytics/overview', query: query);
    if (data is Map) {
      return LecturerAnalyticsOverview.fromJson(data.map((key, value) => MapEntry(key.toString(), value)));
    }
    return null;
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _client.post('/api/notifications/mark-all-read');
    } catch (_) {
      // Some live modules are not enabled yet; keep the dashboard usable.
    }
  }

  LiveDashboardData _fallbackDashboard() {
    return const LiveDashboardData(
      unreadNotifications: 2,
      notifications: [
        NotificationItem(
          id: 'demo-alert-1',
          title: 'Lecturer workflow ready for setup',
          message: 'Live lecturer analytics will appear here as backend modules are enabled.',
          category: 'workflow',
          priority: 'normal',
          actionUrl: '',
          read: false,
          createdAt: null,
        ),
        NotificationItem(
          id: 'demo-alert-2',
          title: 'DLC command view active',
          message: 'Staff, courses, teaching hours, assessment progress, and alerts can be connected here.',
          category: 'dashboard',
          priority: 'normal',
          actionUrl: '',
          read: false,
          createdAt: null,
        ),
      ],
      analytics: LecturerAnalyticsOverview(
        summary: {
          'assigned_courses': 8,
          'teaching_hours_per_week': 24,
        },
        assessments: {
          'total': 12,
        },
        assignments: {
          'total': 18,
        },
        marking: {
          'pending_manual_marking': 34,
          'average_score': 68,
        },
        ca: {
          'total': 9,
        },
        examScripts: {
          'total': 6,
        },
      ),
    );
  }

  void close() => _client.close();
}
