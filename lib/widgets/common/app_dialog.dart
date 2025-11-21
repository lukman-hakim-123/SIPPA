import 'package:flutter/material.dart';

import '../custom_text.dart';
import '../form/custom_text_field.dart';

class AppDialog {
  // KONFIRMASI
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = "Batal",
    String okText = "OK",
    Color okColor = Colors.blue,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        content: CustomText(text: message, fontSize: 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(text: cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(text: okText, color: okColor),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // INPUT TEKS
  static Future<String?> input(
    BuildContext context, {
    required String title,
    String hint = "",
    int minLines = 1,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: CustomText(text: title, fontWeight: FontWeight.bold),
        content: CustomTextFormField(
          controller: controller,
          minLines: 2,
          hintText: hint,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );

    return result;
  }
}
