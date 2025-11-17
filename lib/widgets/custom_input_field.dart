import 'package:flutter/material.dart';
import '../utils/validation_helper.dart';
import 'custom_text.dart';
import 'custom_text_field.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int minLines;
  final bool readOnly;
  final IconData? icon;
  final VoidCallback? onTap;

  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    this.minLines = 1,
    this.readOnly = false,
    this.icon,
    this.onTap,
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
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          onTap: onTap,
          validator: (v) => ValidationHelper.validateNotEmpty(v, label),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
