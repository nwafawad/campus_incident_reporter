import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/incident_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/update_status_sheet.dart';
import 'main_shell.dart';

class StaffQueueScreen extends StatefulWidget {
  const StaffQueueScreen({super.key});

  @override
  State<StaffQueueScreen> createState() => _StaffQueueScreenState();
}

class _StaffQueueScreenState extends State<StaffQueueScreen> {
  IncidentStatus _show = IncidentStatus.submitted;
  String _sort = 'Urgency';
  String? _category;
  String? _building;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final all = context.watch<IncidentProvider>().all;

    int count(IncidentStatus s) => all.where((i) => i.status == s).length;
    final now = DateTime.now();
    final resolvedToday = all
        .where(
          (i) =>
              i.status == IncidentStatus.resolved &&
              i.updatedAt.year == now.year &&
              i.updatedAt.month == now.month &&
              i.updatedAt.day == now.day,
        )
        .length;

    final list = all
        .where(
          (i) =>
              i.status == _show &&
              (_category == null || i.category == _category) &&
              (_building == null || buildingForZone(i.zone) == _building),
        )
        .toList();
    if (_sort == 'Urgency') {
      // highest urgency first oldest first within the same urgency.
      list.sort((a, b) {
        final byUrgency = b.urgency.index.compareTo(a.urgency.index);
        return byUrgency != 0 ? byUrgency : a.createdAt.compareTo(b.createdAt);
      });
    }

    final listName = switch (_show) {
      IncidentStatus.submitted => 'New reports',
      IncidentStatus.inProgress => 'In progress',
      _ => 'Resolved',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Staff',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Incident queue',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accentTint,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tap a count to switch the list below.
        Row(
          children: [
            Expanded(
              child: StatCard(
                count: count(IncidentStatus.submitted),
                label: 'New',
                background: AppColors.pendingCard,
                color: AppColors.pendingText,
                onTap: () => setState(() => _show = IncidentStatus.submitted),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                count: count(IncidentStatus.inProgress),
                label: 'In progress',
                background: AppColors.progressCard,
                color: AppColors.progressText,
                onTap: () => setState(() => _show = IncidentStatus.inProgress),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                count: resolvedToday,
                label: 'Resolved today',
                background: AppColors.resolvedCard,
                color: AppColors.resolvedText,
                onTap: () => setState(() => _show = IncidentStatus.resolved),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterDropdown<String>(
              value: _sort,
              items: const {
                'Urgency': 'Sort: Urgency',
                'Newest': 'Sort: Newest',
              },
              onChanged: (v) => setState(() => _sort = v),
            ),
            _FilterDropdown<String?>(
              value: _category,
              items: {null: 'All categories', for (final c in categories) c: c},
              onChanged: (v) => setState(() => _category = v),
            ),
            _FilterDropdown<String?>(
              value: _building,
              items: {
                null: 'All buildings',
                for (final b in campusBuildings) b: b,
              },
              onChanged: (v) => setState(() => _building = v),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text(
          '$listName · ${_sort == 'Urgency' ? 'highest urgency first' : 'newest first'}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),

        if (list.isEmpty)
          const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Nothing here',
            message: 'No reports match these filters.',
          )
        else
          for (final incident in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IncidentCard(
                incident: incident,
                onTap: () => openIncident(context, incident),
                onUpdate: () => showUpdateStatusSheet(context, incident),
              ),
            ),
      ],
    );
  }
}

// small outlined dropdown
class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        underline: const SizedBox(),
        items: [
          for (final e in items.entries)
            DropdownMenuItem(value: e.key, child: Text(e.value)),
        ],
        onChanged: (v) => onChanged(v as T),
      ),
    );
  }
}
