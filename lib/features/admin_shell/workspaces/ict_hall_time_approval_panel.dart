import 'package:flutter/material.dart';

import '../../exam_officer/data/exam_hall_availability_state.dart';
import '../../lecturer_workflow/data/cbt_calendar_state.dart';

class IctHallTimeApprovalPanel extends StatefulWidget {
  const IctHallTimeApprovalPanel({super.key});

  @override
  State<IctHallTimeApprovalPanel> createState() =>
      _IctHallTimeApprovalPanelState();
}

class _IctHallTimeApprovalPanelState extends State<IctHallTimeApprovalPanel> {
  final ExamHallAvailabilityState _state = ExamHallAvailabilityState.instance;
  final CbtCalendarState _calendar = CbtCalendarState.instance;

  String _hallFilter = 'all';
  HallTimeRequestType? _typeFilter;
  bool _conflictsOnly = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_state, _calendar]),
      builder: (context, _) {
        final pending = _filteredPending();
        final allPending = _state.requests
            .where((item) => item.status == ExamHallAvailabilityStatus.pending)
            .toList();
        final approved = _state.requests
            .where((item) => item.status == ExamHallAvailabilityStatus.approved)
            .toList();
        final rejected = _state.requests
            .where((item) => item.status == ExamHallAvailabilityStatus.rejected)
            .toList();
        final conflictCount = allPending
            .where(_state.hasOperationalConflict)
            .length;
        final totalSeats = ExamHallAvailabilityState.halls.fold<int>(
          0,
          (sum, hall) => sum + hall.capacity,
        );
        final bookedWindows = _calendar.slots.where((slot) => slot.isBooked).length;
        final availableWindows =
            _calendar.slots.where((slot) => slot.isAvailable).length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1100;
            final medium = constraints.maxWidth >= 720;
            final metricColumns = wide ? 4 : (medium ? 2 : 1);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _hero(context, allPending.length, conflictCount),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: metricColumns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: medium ? 2.35 : 3.4,
                  children: [
                    _metricCard(
                      context,
                      label: 'Pending Requests',
                      value: '${allPending.length}',
                      supporting: '${conflictCount == 0 ? 'No' : conflictCount} conflict${conflictCount == 1 ? '' : 's'} detected',
                      icon: Icons.pending_actions_outlined,
                    ),
                    _metricCard(
                      context,
                      label: 'Hall Capacity',
                      value: '$totalSeats',
                      supporting: '${ExamHallAvailabilityState.halls.length} monitored halls',
                      icon: Icons.event_seat_outlined,
                    ),
                    _metricCard(
                      context,
                      label: 'Confirmed Decisions',
                      value: '${approved.length}',
                      supporting: '${rejected.length} not available',
                      icon: Icons.fact_check_outlined,
                    ),
                    _metricCard(
                      context,
                      label: 'Operational Windows',
                      value: '$bookedWindows booked',
                      supporting: '$availableWindows currently available',
                      icon: Icons.calendar_view_week_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _hallBoard(context, wide),
                const SizedBox(height: 16),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: _pendingPanel(context, pending, allPending.length)),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: _upcomingSchedule(context)),
                    ],
                  )
                else ...[
                  _pendingPanel(context, pending, allPending.length),
                  const SizedBox(height: 16),
                  _upcomingSchedule(context),
                ],
                const SizedBox(height: 16),
                _decisionHistory(context),
              ],
            );
          },
        );
      },
    );
  }

  Widget _hero(BuildContext context, int pending, int conflicts) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dns_outlined, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'ICT Hall Operations',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Operational control for examination and CA hall availability. ICT confirms physical hall and time availability only; academic content and decisions remain outside this workspace.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroChip(context, '$pending pending', Icons.inbox_outlined),
              _heroChip(
                context,
                conflicts == 0 ? 'No conflicts' : '$conflicts conflicts',
                conflicts == 0
                    ? Icons.verified_outlined
                    : Icons.warning_amber_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip(BuildContext context, String text, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 7),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _metricCard(
    BuildContext context, {
    required String label,
    required String value,
    required String supporting,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    supporting,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hallBoard(BuildContext context, bool wide) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.meeting_room_outlined),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Hall Operations Board',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Chip(label: Text('${ExamHallAvailabilityState.halls.length} halls')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Capacity, operational windows, pending checks and the next scheduled hall use.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: wide ? 4 : 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: wide ? 1.28 : 3.1,
              children: [
                for (final hall in ExamHallAvailabilityState.halls)
                  _hallCard(context, hall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _hallCard(BuildContext context, ExamHallDefinition hall) {
    final slots = _calendar.slots
        .where((slot) => slot.venue == hall.name)
        .toList()
      ..sort((a, b) {
        final date = a.date.compareTo(b.date);
        return date != 0 ? date : a.startTime.compareTo(b.startTime);
      });
    final reserved = slots.where((slot) => slot.isBooked || !slot.enabled).length;
    final available = slots.where((slot) => slot.isAvailable).length;
    final pending = _state.requests
        .where(
          (request) =>
              request.hallId == hall.id &&
              request.status == ExamHallAvailabilityStatus.pending,
        )
        .length;
    final next = slots.isEmpty ? null : slots.first;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hall.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              CircleAvatar(
                radius: 17,
                child: Text('${hall.capacity}', style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _smallChip('$available available'),
              _smallChip('$reserved reserved'),
              _smallChip('$pending pending'),
            ],
          ),
          const Spacer(),
          Text(
            next == null
                ? 'No operational window loaded'
                : 'Next: ${next.dateLabel} • ${next.startTime}–${next.endTime}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _smallChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Widget _pendingPanel(
    BuildContext context,
    List<ExamHallAvailabilityRequest> pending,
    int totalPending,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inbox_outlined),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Availability Request Queue',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Chip(label: Text('${pending.length}/$totalPending shown')),
              ],
            ),
            const SizedBox(height: 12),
            _filters(context),
            const SizedBox(height: 14),
            if (pending.isEmpty)
              _emptyState(
                context,
                icon: Icons.task_alt_outlined,
                title: totalPending == 0
                    ? 'No request is waiting for ICT'
                    : 'No request matches these filters',
                text: totalPending == 0
                    ? 'New examination and CA hall/time requests will appear here.'
                    : 'Change the hall, request type or conflict filter.',
              )
            else
              for (final request in pending) _requestCard(request),
          ],
        ),
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('All requests'),
          selected: _typeFilter == null,
          onSelected: (_) => setState(() => _typeFilter = null),
        ),
        ChoiceChip(
          label: const Text('Examinations'),
          selected: _typeFilter == HallTimeRequestType.examination,
          onSelected: (_) => setState(
            () => _typeFilter = HallTimeRequestType.examination,
          ),
        ),
        ChoiceChip(
          label: const Text('CA'),
          selected: _typeFilter == HallTimeRequestType.continuousAssessment,
          onSelected: (_) => setState(
            () => _typeFilter = HallTimeRequestType.continuousAssessment,
          ),
        ),
        SizedBox(
          width: 210,
          child: DropdownButtonFormField<String>(
            initialValue: _hallFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Hall',
              isDense: true,
              prefixIcon: Icon(Icons.meeting_room_outlined),
            ),
            items: [
              const DropdownMenuItem(
                value: 'all',
                child: Text('All halls', overflow: TextOverflow.ellipsis),
              ),
              for (final hall in ExamHallAvailabilityState.halls)
                DropdownMenuItem(
                  value: hall.id,
                  child: Text(hall.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _hallFilter = value);
            },
          ),
        ),
        FilterChip(
          label: const Text('Conflicts only'),
          selected: _conflictsOnly,
          avatar: const Icon(Icons.warning_amber_rounded, size: 17),
          onSelected: (value) => setState(() => _conflictsOnly = value),
        ),
      ],
    );
  }

  List<ExamHallAvailabilityRequest> _filteredPending() {
    final result = _state.requests.where((item) {
      if (item.status != ExamHallAvailabilityStatus.pending) return false;
      if (_typeFilter != null && item.requestType != _typeFilter) return false;
      if (_hallFilter != 'all' && item.hallId != _hallFilter) return false;
      if (_conflictsOnly && !_state.hasOperationalConflict(item)) return false;
      return true;
    }).toList();
    result.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return a.startTime.compareTo(b.startTime);
    });
    return result;
  }

  Widget _requestCard(ExamHallAvailabilityRequest request) {
    final conflict = _state.hasOperationalConflict(request);
    final scheme = Theme.of(context).colorScheme;
    final duration = _durationMinutes(request.startTime, request.endTime);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: conflict ? scheme.errorContainer.withValues(alpha: 0.25) : null,
        border: Border.all(
          color: conflict ? scheme.error : scheme.outlineVariant,
          width: conflict ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: request.requestType == HallTimeRequestType.examination
                      ? scheme.primaryContainer
                      : scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  request.requestType == HallTimeRequestType.examination
                      ? Icons.assignment_outlined
                      : Icons.quiz_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.requestType.label} Hall Request',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.hallName,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Chip(
                avatar: Icon(
                  conflict
                      ? Icons.warning_amber_rounded
                      : Icons.schedule_outlined,
                  size: 16,
                ),
                label: Text(conflict ? 'Conflict' : 'Pending'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _detailPill(Icons.calendar_today_outlined, request.dateLabel),
              _detailPill(Icons.schedule_outlined, request.timeLabel),
              _detailPill(Icons.timelapse_outlined, '$duration min'),
              _detailPill(Icons.event_seat_outlined, '${request.capacity} seats'),
            ],
          ),
          if (conflict) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: scheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This hall overlaps an existing booked or blocked operational window.',
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _reject(request),
                icon: const Icon(Icons.close_outlined),
                label: const Text('Not Available'),
              ),
              FilledButton.icon(
                onPressed: conflict ? null : () => _approve(request),
                icon: const Icon(Icons.check_outlined),
                label: const Text('Confirm Available'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _upcomingSchedule(BuildContext context) {
    final slots = [..._calendar.slots]
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.startTime.compareTo(b.startTime);
      });

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Operational Hall Schedule',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Chip(label: Text('${slots.length} windows')),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Hall use only. Course, question and invigilation information is not exposed to ICT.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (slots.isEmpty)
              _emptyState(
                context,
                icon: Icons.event_busy_outlined,
                title: 'No operational windows loaded',
                text: 'Approved hall/time windows will appear here.',
              )
            else
              for (final slot in slots.take(10))
                _scheduleRow(context, slot),
          ],
        ),
      ),
    );
  }

  Widget _scheduleRow(BuildContext context, CbtCalendarSlot slot) {
    final scheme = Theme.of(context).colorScheme;
    final status = slot.isBooked
        ? 'Reserved'
        : slot.isAvailable
            ? 'Available'
            : 'Blocked';
    final icon = slot.isBooked
        ? Icons.lock_clock_outlined
        : slot.isAvailable
            ? Icons.event_available_outlined
            : Icons.block_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.venue,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${slot.dateLabel} • ${slot.startTime}–${slot.endTime} • ${slot.capacity} seats',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Chip(label: Text(status)),
          ],
        ),
      ),
    );
  }

  Widget _decisionHistory(BuildContext context) {
    final decided = _state.requests
        .where((item) => item.status != ExamHallAvailabilityStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history_outlined),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Availability Decision History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                Chip(label: Text('${decided.length} decisions')),
              ],
            ),
            const SizedBox(height: 12),
            if (decided.isEmpty)
              const Text('No decision history yet.')
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Hall')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Capacity')),
                    DataColumn(label: Text('Decision')),
                    DataColumn(label: Text('Operational Note')),
                  ],
                  rows: [
                    for (final request in decided.take(20))
                      DataRow(
                        cells: [
                          DataCell(Text(request.requestType.label)),
                          DataCell(Text(request.hallName)),
                          DataCell(Text(request.dateLabel)),
                          DataCell(Text(request.timeLabel)),
                          DataCell(Text('${request.capacity}')),
                          DataCell(
                            Chip(
                              label: Text(request.status.label),
                              avatar: Icon(
                                request.status == ExamHallAvailabilityStatus.approved
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                size: 16,
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 330,
                              child: Text(
                                request.responseNote.isEmpty
                                    ? '—'
                                    : request.responseNote,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: scheme.primary),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _approve(ExamHallAvailabilityRequest request) {
    try {
      _state.approve(request.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${request.hallName} confirmed available for ${request.dateLabel} ${request.timeLabel}.',
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }

  Future<void> _reject(ExamHallAvailabilityRequest request) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hall / Time Not Available'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${request.hallName} • ${request.dateLabel} • ${request.timeLabel}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Operational reason',
                  hintText: 'e.g. occupied hall, maintenance, network work, unavailable time',
                ),
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

  int _durationMinutes(String start, String end) {
    int parse(String value) {
      final parts = value.split(':');
      if (parts.length != 2) return 0;
      return (int.tryParse(parts[0]) ?? 0) * 60 +
          (int.tryParse(parts[1]) ?? 0);
    }

    final value = parse(end) - parse(start);
    return value < 0 ? 0 : value;
  }
}
