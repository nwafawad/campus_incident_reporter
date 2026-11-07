import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/status_timeline.dart';
import '../widgets/primary_button.dart';
import '../widgets/update_status_sheet.dart';
import 'main_shell.dart';

class IncidentDetailScreen extends StatefulWidget {
  const IncidentDetailScreen({super.key, required this.incidentId});

  final String incidentId;

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  // Created once, so the timeline doesn't reconnect on every rebuild.
  late final _updates = context.read<IncidentProvider>().updatesFor(
    widget.incidentId,
  );

  Future<void> _delete(Incident incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.critical),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<IncidentProvider>().delete(incident.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentProvider>();
    final user = context.watch<AuthProvider>().user!;
    final incident = incidents.byId(widget.incidentId);

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report details')),
        body: const EmptyState(
          icon: Icons.search_off,
          title: 'Report not found',
          message: 'It may have been deleted.',
        ),
      );
    }

    final isMine = incident.reporterId == user.uid;
    final reporter = isMine
        ? (incident.anonymous
              ? 'Reported by you · name hidden from students'
              : 'Reported by you')
        : (incident.anonymous && !user.isStaff
              ? 'Reported anonymously'
              : 'Reported by ${incident.reporterName}');

    return Scaffold(
      appBar: AppBar(title: const Text('Report details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (incident.photoUrls.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 220,
                child: PageView(
                  children: [
                    for (final url in incident.photoUrls)
                      Image.network(url, fit: BoxFit.cover),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusBadge(incident.status),
              _CategoryTag(incident.category),
              UrgencyBadge(incident.urgency),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            incident.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          _InfoRow(
            icon: Icons.place_outlined,
            text: '${incident.zone} · ${incident.area}',
            subtitle: incident.landmark.isEmpty ? null : incident.landmark,
          ),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text:
                'Submitted ${DateFormat('d MMM y, HH:mm').format(incident.createdAt)}',
          ),
          _InfoRow(icon: Icons.person_outline, text: reporter),
          _InfoRow(
            icon: Icons.people_outline,
            text: '${incident.affectedBy.length} affected',
            // me too instead of filing a duplicate report.
            trailing: isMine
                ? null
                : FilledButton(
                    onPressed: () => incidents.toggleMeToo(incident),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(96, 40),
                      backgroundColor: AppColors.primaryTint,
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      incident.affectedBy.contains(user.uid)
                          ? 'Added ✓'
                          : 'Me too',
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(incident.description),
          const SizedBox(height: 24),

          Text(
            'Status timeline',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<StatusUpdate>>(
            stream: _updates,
            builder: (context, snapshot) => StatusTimeline(
              incident: incident,
              updates: snapshot.data ?? [],
            ),
          ),
          if (user.isStaff) ...[
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Update status',
              icon: Icons.edit_note,
              onPressed: () => showUpdateStatusSheet(context, incident),
            ),
            const SizedBox(height: 16),
          ],
          // edit, delete reporter only, and only while still Submitted.
          if (isMine) ...[
            if (incident.isLocked)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.pendingCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.pendingText),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Editing and deleting are locked once staff start working on a report.',
                        style: TextStyle(color: AppColors.pendingText),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: incident.isLocked
                        ? null
                        : () => openReportForm(context, editing: incident),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: incident.isLocked
                        ? null
                        : () => _delete(incident),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.critical,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String text;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag(this.category);

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconForCategory(category), size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            category,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
