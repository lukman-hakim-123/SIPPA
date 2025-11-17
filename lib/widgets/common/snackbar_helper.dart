import 'package:flutter/material.dart';

import '../custom_text.dart';

class SnackbarHelper {
  static void show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(vertical: 16),
        content: CustomText(text: msg, color: Colors.white),
      ),
    );
  }
}
