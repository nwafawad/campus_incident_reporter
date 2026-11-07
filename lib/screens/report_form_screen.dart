import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/report_form_provider.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/category_chips.dart';
import '../widgets/location_picker.dart';
import '../widgets/photo_picker.dart';
import '../widgets/primary_button.dart';
import 'incident_detail_screen.dart';

class ReportFormScreen extends StatelessWidget {
  const ReportFormScreen({super.key});

  Future<void> _submit(BuildContext context) async {
    final form = context.read<ReportFormProvider>();
    final user = context.read<AuthProvider>().user!;
    final id = await form.submit(user);
    if (id == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (form.editing == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: id)),
      );
      messenger.showSnackBar(const SnackBar(content: Text('Report submitted')));
    } else {
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Report updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<ReportFormProvider>();
    final isEditing = form.editing != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? 'Edit report' : 'New report'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _Label('Category', isRequired: true),
          CategoryChips(
            selected: form.category,
            onSelected: (c) => form.update(() => form.category = c),
          ),
          const SizedBox(height: 24),

          AppTextField(
            label: 'Title',
            isRequired: true,
            initialValue: form.title,
            maxLength: titleMaxLength,
            helper: 'Keep it short and specific',
            validator: (v) => validateRequired(v, 'Title'),
            onChanged: (v) => form.update(() => form.title = v),
          ),
          const SizedBox(height: 16),

          AppTextField(
            label: 'Description',
            isRequired: true,
            initialValue: form.description,
            maxLength: descriptionMaxLength,
            maxLines: 4,
            helper: 'What happened, when, and who is affected',
            validator: (v) => validateRequired(v, 'Description'),
            onChanged: (v) => form.update(() => form.description = v),
          ),
          const SizedBox(height: 16),

          const _Label('Location on Bumbogo campus', isRequired: true),
          LocationPicker(
            zone: form.zone,
            area: form.area,
            landmark: form.landmark,
            onZone: (z) => form.update(() {
              form.zone = z;
              form.area = null;
            }),
            onArea: (a) => form.update(() => form.area = a),
            onLandmark: (v) => form.landmark = v,
          ),
          const SizedBox(height: 24),

          const _Label('How urgent is it?'),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<Urgency>(
              segments: [
                for (final u in Urgency.values)
                  ButtonSegment(value: u, label: Text(u.label)),
              ],
              selected: {form.urgency},
              onSelectionChanged: (s) =>
                  form.update(() => form.urgency = s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: form.urgency == Urgency.high
                    ? AppColors.criticalTint
                    : AppColors.primaryTint,
                selectedForegroundColor: form.urgency == Urgency.high
                    ? AppColors.criticalText
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          const _Label('Photos (optional)'),
          PhotoPicker(
            photos: form.photos,
            photoUrls: form.photoUrls,
            onAdd: (p) => form.update(() => form.photos.add(p)),
            onRemovePhoto: (p) => form.update(() => form.photos.remove(p)),
            onRemoveUrl: (u) => form.update(() => form.photoUrls.remove(u)),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SwitchListTile(
              value: form.anonymous,
              onChanged: (v) => form.update(() => form.anonymous = v),
              secondary: const Icon(Icons.visibility_off_outlined),
              title: const Text('Hide my name from other students'),
              subtitle: const Text('Staff can still see who reported it'),
            ),
          ),

          if (form.error != null) ...[
            const SizedBox(height: 16),
            Text(
              form.error!,
              style: const TextStyle(color: AppColors.critical),
            ),
          ],
        ],
      ),

      // submit is pinned to the bottom so its always reachable.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            label: isEditing ? 'Save changes' : 'Submit report',
            icon: Icons.send_outlined,
            loading: form.submitting,
            onPressed: form.canSubmit ? () => _submit(context) : null,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.critical),
              ),
          ],
        ),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
