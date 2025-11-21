import 'package:flutter/material.dart';

import '../../utils/validation_helper.dart';
import '../custom_text.dart';
import 'custom_text_field.dart';

class LabeledTextField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final String? Function(String?)? validator;

  const LabeledTextField({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 25),
            CustomText(text: label, fontWeight: FontWeight.bold),
          ],
        ),
        const SizedBox(height: 4),
        CustomTextFormField(
          controller: controller,
          hintText: label,
          readOnly: readOnly,
          keyboardType: keyboardType ?? TextInputType.text,
          validator: validator ?? (value) => ValidationHelper.validateNotEmpty(value, label),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
