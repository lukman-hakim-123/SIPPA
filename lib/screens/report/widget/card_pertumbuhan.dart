import 'package:flutter/material.dart';

import '../../../models/pertumbuhan.dart';
import '../../../widgets/custom_text.dart';
import 'label_value.dart';

Widget pertumbuhanCard(String title, PertumbuhanModel? data) {
  return Card(
    elevation: 2,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 18),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, fontSize: 16, fontWeight: FontWeight.bold),
          const SizedBox(height: 12),

          // Jika tidak ada data
          if (data == null)
            const CustomText(text: "Tidak ada di fase ini.", fontSize: 14)
          else ...[
            labelValue("Tanggal", data.tanggal),
            const Divider(height: 20, thickness: 1),
            labelValue("Tinggi", "${data.tinggi} cm"),
            const SizedBox(height: 8),
            const Divider(height: 20, thickness: 1),
            labelValue("Berat", "${data.berat} kg"),
            const SizedBox(height: 8),
            const Divider(height: 20, thickness: 1),
            labelValue("Lingkar Kepala", "${data.kepala} cm"),
            const SizedBox(height: 8),
            const Divider(height: 20, thickness: 1),
          ],
        ],
      ),
    ),
  );
}
