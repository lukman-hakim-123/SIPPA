import 'package:flutter/material.dart';
import '../../utils/validation_helper.dart';
import '../custom_text.dart';
import 'custom_text_field.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int minLines;
  final bool readOnly;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? suffixText;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    this.minLines = 1,
    this.readOnly = false,
    this.icon,
    this.onTap,
    this.validator,
    this.keyboardType,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(text: label, fontWeight: FontWeight.bold),
        const SizedBox(height: 4),
        CustomTextFormField(
          controller: controller,
          hintText: label,
          minLines: minLines,
          readOnly: readOnly,
          keyboardType: keyboardType ?? TextInputType.text,
          suffix: suffixText != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CustomText(
                    text: suffixText!,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          onTap: onTap,
          validator:
              validator ?? (v) => ValidationHelper.validateNotEmpty(v, label),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
