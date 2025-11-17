import 'package:flutter/material.dart';

import '../../../widgets/custom_text.dart';
import 'label_value.dart';

Widget sectionCard(String title, SectionData? data) {
  return Card(
    elevation: 2,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 18),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          CustomText(text: title, fontSize: 16, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),

          // Jika tidak ada data
          if (data == null)
            const CustomText(text: "Tidak ada di fase ini.", fontSize: 14)
          else ...[
            // Gambar jika ada
            if (data.imageUrl != null) ...[
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    data.imageUrl!,
                    fit: BoxFit.scaleDown,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tanggal
            if (data.tanggal != null) ...[
              labelValue("Tanggal", data.tanggal),
              const Divider(height: 20, thickness: 1),
            ],

            // Kegiatan
            if (data.kegiatan != null) ...[
              CustomText(
                text: "Kegiatan:",
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 4),
              CustomText(text: data.kegiatan ?? '-', fontSize: 14),
              const SizedBox(height: 8),
              const Divider(height: 20, thickness: 1),
            ],

            // Tujuan
            if (data.tujuan != null) ...[
              CustomText(
                text: "Tujuan:",
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 4),
              CustomText(text: data.tujuan ?? '-', fontSize: 14),
              const SizedBox(height: 8),
              const Divider(height: 20, thickness: 1),
            ],
          ],
        ],
      ),
    ),
  );
}

class SectionData {
  final String? imageUrl;
  final String? tanggal;
  final String? kegiatan;
  final String? tujuan;

  SectionData({this.imageUrl, this.tanggal, this.kegiatan, this.tujuan});
}
