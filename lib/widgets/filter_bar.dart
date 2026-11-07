import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/incident_provider.dart';
import '../theme/app_colors.dart';

// Search box, status chips
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    const statuses = [
      null,
      IncidentStatus.submitted,
      IncidentStatus.inProgress,
      IncidentStatus.resolved,
    ];

    return Column(
      children: [
        TextField(
          onChanged: (v) => incidents.update(() => incidents.search = v),
          decoration: InputDecoration(
            hintText: 'Search by title or location',
            prefixIcon: const Icon(Icons.search),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final status in statuses)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status?.label ?? 'All'),
                    selected: incidents.statusFilter == status,
                    onSelected: (_) =>
                        incidents.update(() => incidents.statusFilter = status),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
