import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      IncidentStatus.submitted => (AppColors.pendingBg, AppColors.pendingText),
      IncidentStatus.inProgress => (
        AppColors.progressBg,
        AppColors.progressText,
      ),
      IncidentStatus.resolved => (AppColors.resolvedBg, AppColors.resolvedText),
      IncidentStatus.notActionable => (
        AppColors.neutralBg,
        AppColors.neutralText,
      ),
    };
    return _Pill(text: status.label, background: bg, foreground: fg, dot: true);
  }
}

class UrgencyBadge extends StatelessWidget {
  const UrgencyBadge(this.urgency, {super.key});

  final Urgency urgency;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (urgency) {
      Urgency.high => (AppColors.criticalTint, AppColors.criticalText),
      Urgency.medium => (AppColors.pendingBg, AppColors.pendingText),
      Urgency.low => (AppColors.neutralBg, AppColors.neutralText),
    };
    return _Pill(text: urgency.label, background: bg, foreground: fg);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
    this.dot = false,
  });

  final String text;
  final Color background;
  final Color foreground;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            CircleAvatar(radius: 3, backgroundColor: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
