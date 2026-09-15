import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_hall_availability_state.dart';

class IctHallTimeApprovalPanel extends StatefulWidget {
  const IctHallTimeApprovalPanel({super.key});

  @override
  State<IctHallTimeApprovalPanel> createState() =>
      _IctHallTimeApprovalPanelState();
}

class _IctHallTimeApprovalPanelState extends State<IctHallTimeApprovalPanel> {
  final ExamHallAvailabilityState _state = ExamHallAvailabilityState.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) {
        final pending = _state.requests
            .where((item) => item.status == ExamHallAvailabilityStatus.pending)
            .toList();
        final decided = _state.requests
            .where((item) => item.status != ExamHallAvailabilityStatus.pending)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hall & Time Availability',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Chip(label: Text('${pending.length} pending')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ICT only confirms whether the requested hall is available at the requested date and time. Academic details, examination questions, moderators, markers, invigilators and results are intentionally not shown here.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (pending.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 22),
                        child: Center(
                          child: Text('No hall/time request is waiting for ICT.'),
                        ),
                      )
                    else
                      for (final request in pending) _requestCard(request),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Availability Decisions',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    if (decided.isEmpty)
                      const Text('No decision history yet.')
                    else
                      for (final request in decided.take(8))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            request.status == ExamHallAvailabilityStatus.approved
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                          ),
                          title: Text(
                            '${request.hallName} • ${request.dateLabel} • ${request.timeLabel}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            request.responseNote.isEmpty
                                ? request.status.label
                                : request.responseNote,
                          ),
                          trailing: Chip(label: Text(request.status.label)),
                        ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _requestCard(ExamHallAvailabilityRequest request) {
    final conflict = _state.hasOperationalConflict(request);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: conflict ? scheme.error : scheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                request.hallName,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Chip(
                label: Text(conflict ? 'Conflict Detected' : 'Check Availability'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(request.dateLabel)),
              Chip(label: Text(request.timeLabel)),
              Chip(label: Text('${request.capacity} seats')),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _reject(request),
                icon: const Icon(Icons.close_outlined),
                label: const Text('Not Available'),
              ),
              FilledButton.icon(
                onPressed: conflict ? null : () => _approve(request),
                icon: const Icon(Icons.check_outlined),
                label: const Text('Available'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _approve(ExamHallAvailabilityRequest request) {
    try {
      _state.approve(request.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hall and time confirmed available.'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _reject(ExamHallAvailabilityRequest request) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hall / Time Not Available'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Operational reason',
            hintText: 'e.g. hall occupied, maintenance, time unavailable',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Confirm Not Available'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    _state.reject(request.id, note: note);
  }
}
