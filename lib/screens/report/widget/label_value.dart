import 'package:flutter/material.dart';

Widget labelValue(String label, String? value) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: value ?? "-",
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
