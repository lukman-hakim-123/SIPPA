import 'package:flutter/material.dart';

Widget buildImage(String imageUrl) {
  return Container(
    height: 200,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Image.network(
      imageUrl,
      fit: BoxFit.scaleDown,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) =>
          const Icon(Icons.error, size: 40, color: Colors.red),
    ),
  );
}
