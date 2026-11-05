import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.isRequired = false,
    this.hint,
    this.helper,
    this.icon,
    this.suffix,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
  });

  final String label;
  final bool isRequired;
  final String? hint;
  final String? helper;
  final IconData? icon;
  final Widget? suffix;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text.rich(
            TextSpan(
              text: label,
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.critical),
                  ),
              ],
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            helperMaxLines: 2,
            prefixIcon: icon == null ? null : Icon(icon),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
