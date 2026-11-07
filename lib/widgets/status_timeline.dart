import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/incident.dart';
import '../theme/app_colors.dart';

enum _StepState { done, current, pending }

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({
    super.key,
    required this.incident,
    required this.updates,
  });

  final Incident incident;
  final List<StatusUpdate> updates;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM, HH:mm');
    final finished =
        incident.status == IncidentStatus.resolved ||
        incident.status == IncidentStatus.notActionable;

    final steps = [
      (
        title: 'Submitted',
        subtitle: '${date.format(incident.createdAt)} · Report received',
        note: '',
      ),
      for (final u in updates)
        (
          title: u.status.label,
          subtitle: '${date.format(u.createdAt)} · Updated by ${u.staffName}',
          note: u.note,
        ),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _Step(
            title: steps[i].title,
            subtitle: steps[i].subtitle,
            note: steps[i].note,
            state: i == steps.length - 1 && !finished
                ? _StepState.current
                : _StepState.done,
            showLine: i < steps.length - 1 || !finished,
          ),
        if (!finished)
          const _Step(
            title: 'Resolved',
            subtitle: 'You\'ll see it here when it\'s fixed',
            state: _StepState.pending,
            showLine: false,
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.subtitle,
    required this.state,
    required this.showLine,
    this.note = '',
  });

  final String title;
  final String subtitle;
  final String note;
  final _StepState state;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final dot = switch (state) {
      _StepState.done => const CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.check, size: 16, color: Colors.white),
      ),
      _StepState.current => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2.5),
        ),
        child: const Center(
          child: CircleAvatar(radius: 6, backgroundColor: AppColors.primary),
        ),
      ),
      _StepState.pending => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 2),
        ),
      ),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              dot,
              if (showLine)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: switch (state) {
                        _StepState.current => AppColors.primary,
                        _StepState.pending => AppColors.textSecondary,
                        _StepState.done => AppColors.text,
                      },
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(note),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
