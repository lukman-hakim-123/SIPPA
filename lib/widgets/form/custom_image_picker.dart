import 'dart:io';
import 'package:flutter/material.dart';

import '../custom_text.dart';

class CustomImagePicker extends StatelessWidget {
  final File? pickedImage;
  final bool isEdit;
  final String? imageUrl;
  final VoidCallback onPick;

  const CustomImagePicker({
    super.key,
    required this.pickedImage,
    required this.isEdit,
    required this.imageUrl,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = pickedImage != null
        ? Image.file(pickedImage!, fit: BoxFit.scaleDown)
        : (isEdit && imageUrl != null && imageUrl!.isNotEmpty)
        ? Image.network(
            imageUrl!,
            fit: BoxFit.scaleDown,
            loadingBuilder: (_, child, loading) =>
                loading == null ? child : const CircularProgressIndicator(),
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 50),
          )
        : const Icon(Icons.image, size: 50, color: Colors.grey);

    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: imageWidget),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onPick,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          child: CustomText(text: isEdit ? "Ganti Foto" : "Tambah Foto"),
        ),
      ],
    );
  }
}
