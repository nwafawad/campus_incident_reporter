import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.count,
    required this.label,
    required this.background,
    required this.color,
    this.icon,
    this.onTap,
  });

  final int count;
  final String label;
  final Color background;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 12),
              ],
              Text('$count', style: Theme.of(context).textTheme.headlineMedium),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
