import 'package:flutter/material.dart';

import '../../../../widgets/custom_text.dart';

class CustomImageCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String kelas;
  final VoidCallback onTap;

  const CustomImageCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.kelas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[200],
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.image, size: 50),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // NAME + CLASS
            CustomText(text: name, fontWeight: FontWeight.bold, fontSize: 16),

            const SizedBox(height: 4),

            CustomText(text: "Kelas: $kelas", fontSize: 13, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
