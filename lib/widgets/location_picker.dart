import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'app_text_field.dart';

/// Zone (dropdown, grouped) -> Area (chips) -> optional landmark.
class LocationPicker extends StatelessWidget {
  const LocationPicker({
    super.key,
    required this.zone,
    required this.area,
    required this.landmark,
    required this.onZone,
    required this.onArea,
    required this.onLandmark,
  });

  final String? zone;
  final String? area;
  final String landmark;
  final ValueChanged<String> onZone;
  final ValueChanged<String> onArea;
  final ValueChanged<String> onLandmark;

  @override
  Widget build(BuildContext context) {
    final selectedZone = zoneByName(zone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: zone,
          isExpanded: true,
          hint: const Text('Choose a zone'),
          decoration: InputDecoration(
            labelText: 'Step 1, Zone',
            prefixIcon: const Icon(Icons.place_outlined),
            helperText: selectedZone == null
                ? null
                : '${zoneGroups[selectedZone.group]} · ${selectedZone.building}',
          ),
          items: [
            for (final group in zoneGroups.entries) ...[
              DropdownMenuItem(
                enabled: false,
                child: Text(
                  group.value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              for (final z in campusZones.where((z) => z.group == group.key))
                DropdownMenuItem(value: z.name, child: Text(z.name)),
            ],
          ],
          onChanged: (value) => onZone(value!),
        ),

        if (selectedZone != null) ...[
          const SizedBox(height: 16),
          Text(
            'Step 2, Area in ${selectedZone.name}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in selectedZone.areas)
                ChoiceChip(
                  label: Text(a),
                  selected: a == area,
                  onSelected: (_) => onArea(a),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),

        AppTextField(
          label: 'Specific spot or landmark (optional)',
          initialValue: landmark,
          hint: 'e.g. Next to the 2nd-floor water dispenser',
          helper: 'Helps staff find the problem faster',
          onChanged: onLandmark,
        ),
      ],
    );
  }
}
