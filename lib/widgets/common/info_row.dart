import 'package:flutter/material.dart';

import '../custom_text.dart';

Widget infoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(text: title, fontWeight: FontWeight.bold),
            CustomText(
              text: value.isNotEmpty ? value : '-',
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        const Divider(),
      ],
    ),
  );
}
