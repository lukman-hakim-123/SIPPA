import 'package:flutter/material.dart';

import '../custom_text.dart';
import 'custom_text_field.dart';

class PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback toggleObscure;
  final String? Function(String?) validator;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.obscure,
    required this.toggleObscure,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock, size: 25),
            const SizedBox(width: 6),
            CustomText(text: label, fontWeight: FontWeight.bold),
          ],
        ),
        const SizedBox(height: 8),
        CustomTextFormField(
          controller: controller,
          obscureText: obscure,
          maxLines: 1,
          validator: validator,
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleObscure,
          ),
        ),
      ],
    );
  }
}
