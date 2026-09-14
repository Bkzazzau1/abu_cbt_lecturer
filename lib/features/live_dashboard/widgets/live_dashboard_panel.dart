import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../data/live_dashboard_api.dart';
import '../models/live_dashboard_models.dart';

class LiveDashboardPanel extends StatefulWidget {
  const LiveDashboardPanel({super.key});

  @override
  State<LiveDashboardPanel> createState() => _LiveDashboardPanelState();
}

class _LiveDashboardPanelState extends State<LiveDashboardPanel> {
  late final LiveDashboardApi _api;
  late Future<LiveDashboardData> _future;

  @override
  void initState() {
    super.initState();
    _api = LiveDashboardApi();
    _future = _api.fetchDashboard();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _future = _api.fetchDashboard());

  Future<void> _markAllRead() async {
    await _api.markAllNotificationsRead();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.insights_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Live work dashboard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_outlined),
                      label: const Text('Refresh'),
                    ),
                    FilledButton.icon(
                      onPressed: _markAllRead,
                      icon: const Icon(Icons.done_all_outlined),
                      label: const Text('Mark alerts read'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Connected to ${ApiConfig.baseUrl}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FutureBuilder<LiveDashboardData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return _DashboardError(
                    message: snapshot.error.toString(),
                    onRetry: _reload,
                  );
                }
                final data = snapshot.data;
                if (data == null) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AnalyticsSummary(
                      analytics: data.analytics,
                      unreadNotifications: data.unreadNotifications,
                    ),
                    const SizedBox(height: 18),
                    _NotificationList(notifications: data.notifications),
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

class _AnalyticsSummary extends StatelessWidget {
  const _AnalyticsSummary({
    required this.analytics,
    required this.unreadNotifications,
  });

  final LecturerAnalyticsOverview? analytics;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final overview = analytics;
    if (overview == null) {
      return _InfoBox(
        title: 'Analytics not loaded',
        message:
            'Login token may be missing or lecturer data is not ready yet.',
      );
    }

    final cards = [
      _MetricCard(
        label: 'Unread alerts',
        value: unreadNotifications.toString(),
        icon: Icons.notifications_active_outlined,
      ),
      _MetricCard(
        label: 'Assigned courses',
        value: overview.number(overview.summary, 'assigned_courses').toString(),
        icon: Icons.menu_book_outlined,
      ),
      _MetricCard(
        label: 'Teaching hours',
        value: overview
            .number(overview.summary, 'teaching_hours_per_week')
            .toString(),
        icon: Icons.schedule_outlined,
      ),
      _MetricCard(
        label: 'Assessments',
        value: overview.number(overview.assessments, 'total').toString(),
        icon: Icons.assignment_outlined,
      ),
      _MetricCard(
        label: 'Pending marking',
        value: overview
            .number(overview.marking, 'pending_manual_marking')
            .toString(),
        icon: Icons.rate_review_outlined,
      ),
      _MetricCard(
        label: 'Avg score',
        value: overview.number(overview.marking, 'average_score').toString(),
        icon: Icons.trending_up_outlined,
      ),
      _MetricCard(
        label: 'CA submitted',
        value: overview.number(overview.ca, 'total').toString(),
        icon: Icons.fact_check_outlined,
      ),
      _MetricCard(
        label: 'Marked scripts',
        value: overview.number(overview.examScripts, 'total').toString(),
        icon: Icons.task_alt_outlined,
      ),
    ];

    return Wrap(spacing: 10, runSpacing: 10, children: cards);
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.notifications});

  final List<NotificationItem> notifications;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const _InfoBox(
        title: 'No alerts yet',
        message: 'New workflow updates from the backend will appear here.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent alerts',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final item in notifications.take(8)) _NotificationTile(item: item),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: item.read
            ? null
            : scheme.primaryContainer.withValues(alpha: 0.45),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            item.read
                ? Icons.notifications_none_outlined
                : Icons.notifications_active_outlined,
            color: scheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (item.message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: [
                    Chip(
                      label: Text(item.category),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text(item.priority),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(message),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.errorContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Backend connection issue',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
