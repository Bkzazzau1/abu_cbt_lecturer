import 'package:flutter/material.dart';

import '../../../models/dashboard_models.dart';

class AdminMetricCard extends StatelessWidget {
  const AdminMetricCard({super.key, required this.metric});

  static const double gridExtent = 180;

  final AdminMetric metric;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = metric.status.color(scheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.14),
              foregroundColor: statusColor,
              child: Icon(metric.icon),
            ),
            const SizedBox(height: 14),
            Text(
              metric.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 2),
            Text(
              metric.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  metric.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
