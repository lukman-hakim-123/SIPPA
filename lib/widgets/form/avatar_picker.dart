import 'dart:io';
import 'package:flutter/material.dart';
import '../custom_text.dart';

class AvatarPicker extends StatelessWidget {
  final File? pickedImage;
  final String? imageUrl;
  final bool isEdit;
  final VoidCallback onPickImage;

  const AvatarPicker({
    super.key,
    required this.pickedImage,
    required this.imageUrl,
    required this.isEdit,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 53,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: pickedImage != null
                ? ClipOval(
                    child: Image.file(
                      pickedImage!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                : (isEdit && imageUrl != null && imageUrl!.isNotEmpty)
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                : const Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          onPressed: onPickImage,
          child: CustomText(text: isEdit ? 'Ganti Foto' : 'Tambah Foto'),
        ),
      ],
    );
  }
}
