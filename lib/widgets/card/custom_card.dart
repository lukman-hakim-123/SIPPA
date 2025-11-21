import 'package:flutter/material.dart';
import '../custom_text.dart';

class CustomCard extends StatelessWidget {
  final String kelas;
  final String tanggal;
  final String? nama;
  final String? imageUrl;
  final VoidCallback onTap;

  const CustomCard({
    super.key,
    required this.kelas,
    required this.tanggal,
    required this.nama,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          child: ClipOval(
            child: (imageUrl != null && imageUrl!.isNotEmpty)
                ? Image.network(
                    imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.person, size: 40, color: Colors.grey),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
        ),
        title: CustomText(
          text: nama ?? 'Murid tidak ditemukan',
          fontWeight: FontWeight.bold,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'Kelas: $kelas'),
            CustomText(text: tanggal),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
