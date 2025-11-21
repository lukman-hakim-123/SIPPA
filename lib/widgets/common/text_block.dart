import 'package:flutter/material.dart';

import '../custom_text.dart';

Widget textBlock(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CustomText(text: title, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: CustomText(
            text: value.isNotEmpty ? value : '-',
            textAlign: TextAlign.right,
          ),
        ),
        const Divider(),
      ],
    ),
  );
}
