import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'status_badge.dart';

String timeAgo(DateTime time) {
  final d = DateTime.now().difference(time);
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes}m ago';
  if (d.inDays < 1) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

class CategoryIcon extends StatelessWidget {
  const CategoryIcon(this.category, {super.key, this.size = 56});

  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(iconForCategory(category), color: AppColors.primary),
    );
  }
}

class IncidentCard extends StatelessWidget {
  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
    this.onUpdate,
  });

  final Incident incident;
  final VoidCallback onTap;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final i = incident;
    final forStaff = onUpdate != null;
    final overdue =
        i.status == IncidentStatus.submitted &&
        DateTime.now().difference(i.createdAt) > overdueAfter;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CategoryIcon(i.category),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${i.zone} · ${i.area} · ${timeAgo(i.createdAt)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        forStaff
                            ? UrgencyBadge(i.urgency)
                            : StatusBadge(i.status),
                        _iconText(
                          Icons.people_outline,
                          '${i.affectedBy.length} affected',
                          AppColors.textSecondary,
                        ),
                        if (forStaff && overdue)
                          _iconText(
                            Icons.schedule,
                            'Overdue',
                            AppColors.criticalText,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              forStaff
                  ? FilledButton(
                      onPressed: onUpdate,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(80, 44),
                        backgroundColor: AppColors.primaryTint,
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Update'),
                    )
                  : const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 13, color: color)),
    ],
  );
}
