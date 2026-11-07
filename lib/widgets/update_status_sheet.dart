import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../theme/app_colors.dart';
import 'app_text_field.dart';
import 'primary_button.dart';

// opens the staff Update status bottom sheet for a report.
Future<void> showUpdateStatusSheet(BuildContext context, Incident incident) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => UpdateStatusSheet(incident: incident),
  );
}

class UpdateStatusSheet extends StatefulWidget {
  const UpdateStatusSheet({super.key, required this.incident});

  final Incident incident;

  @override
  State<UpdateStatusSheet> createState() => _UpdateStatusSheetState();
}

class _UpdateStatusSheetState extends State<UpdateStatusSheet> {
  late IncidentStatus _status = widget.incident.status;
  final _note = TextEditingController();
  bool _saving = false;
  String? _error;

  static const _descriptions = {
    IncidentStatus.submitted: 'Received, not yet started',
    IncidentStatus.inProgress: 'Someone is working on it',
    IncidentStatus.resolved: 'Fixed and checked',
    IncidentStatus.notActionable: 'Duplicate or outside campus scope',
  };

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final staffName = context.read<AuthProvider>().user!.name;
      await context.read<IncidentProvider>().updateStatus(
        widget.incident.id,
        _status,
        _note.text,
        staffName,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() {
        _saving = false;
        _error = 'Couldn\'t save the update. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // only save if something changed.
    final changed =
        _status != widget.incident.status || _note.text.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update status',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            widget.incident.title,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: RadioGroup<IncidentStatus>(
              groupValue: _status,
              onChanged: (s) => setState(() => _status = s!),
              child: Column(
                children: [
                  for (final s in IncidentStatus.values)
                    RadioListTile<IncidentStatus>(
                      value: s,
                      title: Text(s.label),
                      subtitle: Text(_descriptions[s]!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Note to reporter',
            controller: _note,
            maxLines: 3,
            hint: 'e.g. Plumber assigned, expected fix by 4 PM',
            helper: 'Shown on the reporter\'s status timeline',
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.critical)),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Save update',
                  loading: _saving,
                  onPressed: changed ? _save : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
