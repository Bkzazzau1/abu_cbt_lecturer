import '../../../core/network/api_client.dart';

class WorkflowApi {
  WorkflowApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<WorkflowDashboardData> fetchDashboard() async {
    try {
      final results = await Future.wait<dynamic>([
        _client.get('/api/lecturer/assignments'),
        _client.get('/api/lecturer/ca-submissions'),
        _client.get('/api/lecturer/marked-exam-scripts'),
      ]);

      return WorkflowDashboardData(
        assignments: _parseList(results[0]),
        caSubmissions: _parseList(results[1]),
        markedScripts: _parseList(results[2]),
      );
    } catch (_) {
      return const WorkflowDashboardData(assignments: [], caSubmissions: [], markedScripts: []);
    }
  }

  List<WorkflowItem> _parseList(dynamic data) {
    if (data is! List) return const [];
    return data.whereType<Map>().map((item) {
      final json = item.map((key, value) => MapEntry(key.toString(), value));
      return WorkflowItem.fromJson(json);
    }).toList();
  }

  void close() => _client.close();
}

class WorkflowDashboardData {
  const WorkflowDashboardData({
    required this.assignments,
    required this.caSubmissions,
    required this.markedScripts,
  });

  final List<WorkflowItem> assignments;
  final List<WorkflowItem> caSubmissions;
  final List<WorkflowItem> markedScripts;
}

class WorkflowItem {
  const WorkflowItem({
    required this.id,
    required this.title,
    required this.status,
    required this.subtitle,
    required this.fileUrl,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final String subtitle;
  final String fileUrl;
  final DateTime? createdAt;

  factory WorkflowItem.fromJson(Map<String, dynamic> json) {
    final course = json['course'];
    final courseText = course is Map
        ? [course['code']?.toString() ?? '', course['title']?.toString() ?? ''].where((item) => item.isNotEmpty).join(' • ')
        : '';
    final title = json['title']?.toString().trim();
    final summary = json['summary']?.toString().trim();

    return WorkflowItem(
      id: json['id']?.toString() ?? '',
      title: title == null || title.isEmpty ? (summary == null || summary.isEmpty ? 'Submission' : summary) : title,
      status: json['status']?.toString() ?? 'pending',
      subtitle: courseText.isNotEmpty ? courseText : json['academic_session']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
