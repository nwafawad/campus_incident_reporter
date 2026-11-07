import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/home_top_card.dart';
import '../widgets/incident_card.dart';
import '../widgets/stat_card.dart';
import 'main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll; // switches to the Reports tab

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final incidents = context.watch<IncidentProvider>();
    final mine = incidents.mine;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    // My report that changed most recently (in the last 3 days), if any.
    final recentlyUpdated =
        mine
            .where(
              (i) =>
                  i.status != IncidentStatus.submitted &&
                  DateTime.now().difference(i.updatedAt).inDays < 3,
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final update = recentlyUpdated.firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), // room for the FAB
      children: [
        // Greeting + avatar
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    user.name.split(' ').first,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryTint,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Search bar: opens the Reports tab
        TextField(
          readOnly: true,
          onTap: onSeeAll,
          decoration: InputDecoration(
            hintText: 'Search campus reports',
            prefixIcon: const Icon(Icons.search),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (incidents.loading)
          const Center(child: CircularProgressIndicator())
        else if (mine.isEmpty)
          // First-time student: welcome card instead of empty counts.
          HomeTopCard(
            icon: Icons.campaign_outlined,
            title: 'Spotted a problem on campus?',
            message:
                'Report it in under a minute. Staff will see it right away.',
            buttonLabel: 'Report an issue',
            onPressed: () => openReportForm(context),
          )
        else ...[
          if (update != null) ...[
            HomeTopCard(
              icon: Icons.notifications_active_outlined,
              title: 'Your report is now ${update.status.label}',
              message: update.title,
              buttonLabel: 'View report',
              onPressed: () => openIncident(context, update),
            ),
            const SizedBox(height: 24),
          ],
          _SectionHeader('Your reports', onSeeAll: onSeeAll),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  count: incidents.countMine(IncidentStatus.submitted),
                  label: 'Submitted',
                  icon: Icons.description_outlined,
                  background: AppColors.pendingCard,
                  color: AppColors.pendingText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  count: incidents.countMine(IncidentStatus.inProgress),
                  label: 'In progress',
                  icon: Icons.schedule,
                  background: AppColors.progressCard,
                  color: AppColors.progressText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  count: incidents.countMine(IncidentStatus.resolved),
                  label: 'Resolved',
                  icon: Icons.check,
                  background: AppColors.resolvedCard,
                  color: AppColors.resolvedText,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),

        // Category shortcuts: open the form with that category picked
        Text('Report an issue', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: [
            for (final category in categories)
              Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () => openReportForm(context, category: category),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CategoryIcon(category, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        // Recent activity: my 3 newest reports
        if (mine.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionHeader('Recent activity', onSeeAll: onSeeAll),
          const SizedBox(height: 12),
          for (final incident in mine.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: IncidentCard(
                incident: incident,
                onTap: () => openIncident(context, incident),
              ),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }
}
