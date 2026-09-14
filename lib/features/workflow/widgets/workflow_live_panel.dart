import 'package:flutter/material.dart';

import '../data/workflow_api.dart';

class WorkflowLivePanel extends StatefulWidget {
  const WorkflowLivePanel({super.key});

  @override
  State<WorkflowLivePanel> createState() => _WorkflowLivePanelState();
}

class _WorkflowLivePanelState extends State<WorkflowLivePanel> {
  late final WorkflowApi _api;
  late Future<WorkflowDashboardData> _future;

  @override
  void initState() {
    super.initState();
    _api = WorkflowApi();
    _future = _api.fetchDashboard();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  void _reload() => setState(() => _future = _api.fetchDashboard());

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
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_tree_outlined, color: scheme.primary),
                    const SizedBox(width: 10),
                    Text('Live lecturer workflow', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                OutlinedButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh_outlined), label: const Text('Refresh')),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<WorkflowDashboardData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return _WorkflowError(message: snapshot.error.toString(), onRetry: _reload);
                }
                final data = snapshot.data;
                if (data == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    _WorkflowSection(title: 'Assignments', icon: Icons.assignment_outlined, items: data.assignments),
                    const SizedBox(height: 16),
                    _WorkflowSection(title: 'CA submissions', icon: Icons.fact_check_outlined, items: data.caSubmissions),
                    const SizedBox(height: 16),
                    _WorkflowSection(title: 'Marked exam scripts', icon: Icons.task_alt_outlined, items: data.markedScripts),
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

class _WorkflowSection extends StatelessWidget {
  const _WorkflowSection({required this.title, required this.icon, required this.items});

  final String title;
  final IconData icon;
  final List<WorkflowItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: scheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 8),
              Text('$title (${items.length})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text('No records returned yet.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant))
          else
            for (final item in items.take(5)) _WorkflowTile(item: item),
        ],
      ),
    );
  }
}

class _WorkflowTile extends StatelessWidget {
  const _WorkflowTile({required this.item});

  final WorkflowItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.subtitle.isEmpty ? item.fileUrl : item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Chip(label: Text(item.status), visualDensity: VisualDensity.compact),
    );
  }
}

class _WorkflowError extends StatelessWidget {
  const _WorkflowError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Theme.of(context).colorScheme.errorContainer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workflow connection issue', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(message),
          const SizedBox(height: 10),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_outlined), label: const Text('Try again')),
        ],
      ),
    );
  }
}
