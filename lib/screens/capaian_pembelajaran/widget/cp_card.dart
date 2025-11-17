import 'package:flutter/material.dart';
import '../../../widgets/custom_text.dart';

class CpCard extends StatelessWidget {
  final dynamic cp;
  final dynamic murid;
  final String Function(String id) imageUrlBuilder;
  final VoidCallback onTap;

  const CpCard({
    super.key,
    required this.cp,
    required this.murid,
    required this.imageUrlBuilder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = murid?.imageId != null && murid!.imageId.isNotEmpty;

    return Card(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          child: ClipOval(
            child: hasImage
                ? Image.network(
                    imageUrlBuilder(murid!.imageId),
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
          text: murid?.nama ?? 'Murid tidak ditemukan',
          fontWeight: FontWeight.bold,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'Kelas: ${cp.kelompok}'),
            CustomText(text: cp.tanggal),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
