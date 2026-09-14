import 'package:flutter/material.dart';

import '../data/live_dashboard_api.dart';
import '../models/live_dashboard_models.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  late final LiveDashboardApi _api;
  late Future<int> _countFuture;

  @override
  void initState() {
    super.initState();
    _api = LiveDashboardApi();
    _countFuture = _api.fetchUnreadCount();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _countFuture = _api.fetchUnreadCount());

  Future<void> _openNotifications() async {
    final notifications = await _api.fetchNotifications();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.75,
        child: _NotificationSheet(
          notifications: notifications,
          onMarkAllRead: () async {
            await _api.markAllNotificationsRead();
            _reload();
          },
        ),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _countFuture,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Alerts',
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_outlined),
            ),
            if (count > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onError, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotificationSheet extends StatelessWidget {
  const _NotificationSheet({required this.notifications, required this.onMarkAllRead});

  final List<NotificationItem> notifications;
  final Future<void> Function() onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(child: Text('Alerts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
              TextButton.icon(onPressed: onMarkAllRead, icon: const Icon(Icons.done_all_outlined), label: const Text('Mark all read')),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: notifications.isEmpty
                ? Center(child: Text('No alerts yet.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)))
                : ListView.separated(
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return ListTile(
                        leading: Icon(item.read ? Icons.notifications_none_outlined : Icons.notifications_active_outlined, color: scheme.primary),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(item.message.isEmpty ? item.category : item.message),
                        trailing: Chip(label: Text(item.priority), visualDensity: VisualDensity.compact),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: notifications.length,
                  ),
          ),
        ],
      ),
    );
  }
}
