import 'package:flutter/material.dart';

import '../../lecturer_workflow/data/cbt_calendar_state.dart';

class IctCbtCalendarPanel extends StatefulWidget {
  const IctCbtCalendarPanel({super.key});

  @override
  State<IctCbtCalendarPanel> createState() => _IctCbtCalendarPanelState();
}

class _IctCbtCalendarPanelState extends State<IctCbtCalendarPanel> {
  final CbtCalendarState _calendar = CbtCalendarState.instance;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _calendar,
      builder: (context, _) {
        final pending = _calendar.requests
            .where((request) => request.status == CbtSlotRequestStatus.pending)
            .length;
        final available = _calendar.slots.where((slot) => slot.isAvailable).length;
        final unavailable = _calendar.slots
            .where((slot) => !slot.isAvailable && !slot.isBooked)
            .length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'CBT Calendar & CA Slot Requests',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _addSlot,
                      icon: const Icon(Icons.add_outlined),
                      label: const Text('Add Slot'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Chip(label: Text('Available: $available')),
                    Chip(label: Text('Unavailable: $unavailable')),
                    Chip(label: Text('Pending requests: $pending')),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'CBT Calendar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                for (final slot in _calendar.slots) _SlotRow(slot: slot, calendar: _calendar),
                const SizedBox(height: 20),
                Text(
                  'CA Slot Requests',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                if (_calendar.requests.isEmpty)
                  const Text('No CA slot requests.')
                else
                  for (final request in _calendar.requests)
                    _RequestRow(
                      request: request,
                      onApprove: request.status == CbtSlotRequestStatus.pending
                          ? () => _calendar.approveRequest(request.id)
                          : null,
                      onReject: request.status == CbtSlotRequestStatus.pending
                          ? () => _reject(request)
                          : null,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addSlot() async {
    final result = await showDialog<_NewSlot>(
      context: context,
      builder: (_) => const _AddSlotDialog(),
    );
    if (result == null || !mounted) return;
    _calendar.addSlot(
      date: result.date,
      startTime: result.startTime,
      endTime: result.endTime,
      venue: result.venue,
      capacity: result.capacity,
    );
  }

  Future<void> _reject(CbtSlotRequest request) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject CA Slot Request'),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (note == null) return;
    _calendar.rejectRequest(request.id, note: note);
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot, required this.calendar});

  final CbtCalendarSlot slot;
  final CbtCalendarState calendar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.scheduleLabel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  slot.isBooked
                      ? '${slot.bookedCourseCode} • ${slot.bookedCaLabel} • Capacity ${slot.capacity}'
                      : 'Capacity ${slot.capacity}',
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(label: Text(slot.statusLabel)),
              if (!slot.isBooked)
                Switch(
                  value: slot.enabled,
                  onChanged: (value) => calendar.setSlotAvailability(slot.id, value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final CbtSlotRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${request.courseCode} • ${request.caLabel}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(request.lecturerName),
                const SizedBox(height: 5),
                Text(
                  '${request.dateLabel} • ${request.startTime}–${request.endTime} • ${request.durationMinutes} min • ${request.questionCount} questions • ${request.totalMarks} marks',
                ),
                if (request.responseNote.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(request.responseNote),
                ],
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(label: Text(request.status.label)),
              if (onReject != null)
                OutlinedButton(
                  onPressed: onReject,
                  child: const Text('Reject'),
                ),
              if (onApprove != null)
                FilledButton(
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewSlot {
  const _NewSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.capacity,
  });

  final DateTime date;
  final String startTime;
  final String endTime;
  final String venue;
  final int capacity;
}

class _AddSlotDialog extends StatefulWidget {
  const _AddSlotDialog();

  @override
  State<_AddSlotDialog> createState() => _AddSlotDialogState();
}

class _AddSlotDialogState extends State<_AddSlotDialog> {
  DateTime _date = DateTime(2026, 9, 24);
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _venue = TextEditingController(text: 'CBT Centre A');
  final TextEditingController _capacity = TextEditingController(text: '250');

  @override
  void dispose() {
    _venue.dispose();
    _capacity.dispose();
    super.dispose();
  }

  String _time(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';
    return AlertDialog(
      title: const Text('Add CBT Calendar Slot'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date'),
              subtitle: Text(dateLabel),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2026, 9, 15),
                  lastDate: DateTime(2027, 12, 31),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Start'),
              subtitle: Text(_time(_start)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _start);
                if (picked != null) setState(() => _start = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('End'),
              subtitle: Text(_time(_end)),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _end);
                if (picked != null) setState(() => _end = picked);
              },
            ),
            TextField(
              controller: _venue,
              decoration: const InputDecoration(labelText: 'Venue'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _capacity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capacity'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final capacity = int.tryParse(_capacity.text.trim()) ?? 0;
            if (_venue.text.trim().isEmpty || capacity <= 0) return;
            Navigator.pop(
              context,
              _NewSlot(
                date: _date,
                startTime: _time(_start),
                endTime: _time(_end),
                venue: _venue.text.trim(),
                capacity: capacity,
              ),
            );
          },
          child: const Text('Add Slot'),
        ),
      ],
    );
  }
}
