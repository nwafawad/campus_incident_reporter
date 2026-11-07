import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/incident_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/incident_card.dart';
import 'main_shell.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final list = incidents.filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Reports',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        DefaultTabController(
          length: 2,
          initialIndex: incidents.mineOnly ? 0 : 1,
          child: TabBar(
            onTap: (i) => incidents.update(() => incidents.mineOnly = i == 0),
            tabs: const [
              Tab(text: 'My reports'),
              Tab(text: 'All campus'),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.all(16), child: FilterBar()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${list.length} reports · newest first',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              DropdownButton<String?>(
                value: incidents.categoryFilter,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All categories'),
                  ),
                  for (final c in categories)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) =>
                    incidents.update(() => incidents.categoryFilter = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: incidents.loading
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
              ? EmptyState(
                  icon: Icons.inbox_outlined,
                  title: incidents.mineOnly && incidents.mine.isEmpty
                      ? 'No reports yet'
                      : 'No results',
                  message: incidents.mineOnly && incidents.mine.isEmpty
                      ? 'Reports you submit will appear here.'
                      : 'Try another search or filter.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => IncidentCard(
                    incident: list[i],
                    onTap: () => openIncident(context, list[i]),
                  ),
                ),
        ),
      ],
    );
  }
}
