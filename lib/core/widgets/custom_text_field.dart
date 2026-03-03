import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          maxLength: maxLength,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText ?? 'သင့် $label ကို ရိုက်ထည့်ပါ',
            hintStyle: const TextStyle(color: AppColors.textHint),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textHint)
                : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
              onTap: onSuffixTap,
              child: Icon(suffixIcon, color: AppColors.textHint),
            )
                : null,
          ),
        ),
      ],
    );
  }
}