import 'package:flutter/material.dart';
import 'package:sippa/screens/report/widget/label_value.dart';

import '../../../models/rubrik.dart';
import '../../../widgets/custom_text.dart';

Widget rubrikCard(String title, RubrikModel? data) {
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
            const SizedBox(height: 8),
            const Divider(height: 20, thickness: 1),
            CustomText(
              text: "Tujuan:",
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 4),

            CustomText(text: data.tujuan, fontSize: 14),
            const SizedBox(height: 8),
            const Divider(height: 20, thickness: 1),
            CustomText(
              text: "Penilaian:",
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 4),
            CustomText(text: "Penilaian: ${rubrikText(data.skor)}"),
            const SizedBox(height: 8),
            const Divider(height: 20, thickness: 1),
          ],
        ],
      ),
    ),
  );
}

String rubrikText(String skor) {
  switch (skor) {
    case "1":
      return "Belum mencapai tujuan pembelajaran";
    case "2":
      return "Mencapai tujuan pembelajaran dengan batuan";
    case "3":
      return "Mencapai tujuan pembelajaran secara mandiri";
    default:
      return "Tidak diketahui";
  }
}
