import 'package:flutter/material.dart';

import '../utils/constants.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in categories)
          ChoiceChip(
            avatar: Icon(iconForCategory(category), size: 18),
            label: Text(category),
            selected: category == selected,
            showCheckmark: false,
            onSelected: (_) => onSelected(category),
          ),
      ],
    );
  }
}
