import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/anekdot.dart';
import '../models/cp.dart';
import '../models/hk.dart';
import '../models/pertumbuhan.dart';
import '../models/rubrik.dart';
import '../providers/anekdot_provider.dart';
import '../providers/hk_provider.dart';

Future<void> printFullPhasePDF({
  required BuildContext context,
  required String nama,
  required WidgetRef ref,
  required String kelompok,
  required int phaseIndex,

  required AnekdotModel? anekdot,
  required CpModel? capaian,
  required HkModel? hasilKarya,
  required PertumbuhanModel? pertumbuhan,
  required RubrikModel? rubrik,
}) async {
  final doc = pw.Document();
  // LOAD FONTS
  final tnr = pw.Font.ttf(await rootBundle.load("assets/fonts/times.ttf"));
  final tnrBold = pw.Font.ttf(
    await rootBundle.load("assets/fonts/Times New Roman Bold.ttf"),
  );

  pw.TextStyle normal = pw.TextStyle(font: tnr, fontSize: 11);
  pw.TextStyle bold = pw.TextStyle(font: tnrBold, fontSize: 11);

  final urlAnekdot = ref.read(anekdotProvider.notifier).getPublicImageUrl;
  final urlHasilKarya = ref.read(hkProvider.notifier).getPublicImageUrl;

  // buat url dari imageId
  String? imageUrl;
  String? imageUrlHk;

  if (anekdot != null && anekdot.imageId.isNotEmpty) {
    imageUrl = urlAnekdot(anekdot.imageId);
  }

  if (hasilKarya != null && hasilKarya.imageId.isNotEmpty) {
    imageUrlHk = urlHasilKarya(hasilKarya.imageId);
  }
  pw.MemoryImage? fotoPdf;
  pw.MemoryImage? fotoPdfHk;

  if (imageUrl != null) {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      fotoPdf = pw.MemoryImage(response.bodyBytes);
    } catch (_) {}
  }

  if (imageUrlHk != null) {
    try {
      final response = await http.get(Uri.parse(imageUrlHk));
      fotoPdfHk = pw.MemoryImage(response.bodyBytes);
    } catch (_) {}
  }

  pw.Widget headerTitle(String text) {
    return pw.Center(
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: tnrBold,
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget sectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20, bottom: 8),
      child: pw.Text(text, style: pw.TextStyle(font: tnrBold, fontSize: 14)),
    );
  }

  pw.TableRow row(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: bold),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value, style: normal),
        ),
      ],
    );
  }

  pw.Widget table(List<pw.TableRow> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600),
      columnWidths: {0: pw.FixedColumnWidth(160), 1: pw.FlexColumnWidth()},
      children: rows,
    );
  }

  pw.Widget identityRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "$label : ",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  //--------------------------------------------------------------------------

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        /// TITLE
        headerTitle("LAPORAN PERKEMBANGAN ANAK\nFASE ${phaseIndex + 1}"),

        pw.SizedBox(height: 20),

        /// IDENTITAS
        sectionTitle("IDENTITAS ANAK"),

        identityRow("Nama Anak", nama),
        identityRow("Kelompok", kelompok),

        pw.SizedBox(height: 4),

        /// ------------------ ANEKDOT ------------------
        if (anekdot != null) ...[
          sectionTitle("ANEKDOT"),
          table([
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text("Foto", style: bold),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: fotoPdf != null
                      ? pw.Center(
                          child: pw.Container(
                            height: 120,
                            child: pw.Image(fotoPdf, fit: pw.BoxFit.contain),
                          ),
                        )
                      : pw.Text("-"),
                ),
              ],
            ),
            row("Tanggal", anekdot.tanggal),
            row("Kegiatan", anekdot.kegiatan),
            row("Tujuan", anekdot.tujuan),
            row("Nilai Agama & Budi Pekerti", anekdot.nilaiAgama),
            row("Jati Diri", anekdot.jatiDiri),
            row("Literasi & STEAM", anekdot.literasi),
            row("Umpan Balik", anekdot.umpanBalik),
            row(
              "Tanggapan Orang Tua",
              (anekdot.tanggapan == '' || anekdot.tanggapan.isEmpty)
                  ? "-"
                  : anekdot.tanggapan,
            ),
          ]),
        ],

        /// ------------------ CAPAIAN ------------------
        if (capaian != null) ...[
          sectionTitle("CAPAIAN PEMBELAJARAN"),
          table([
            row("Tanggal", capaian.tanggal),
            row("Kegiatan", capaian.kegiatan),
            row("Tujuan", capaian.tujuan),
            row("Nilai Agama & Budi Pekerti", capaian.nilaiAgama),
            row("Jati Diri", capaian.jatiDiri),
            row("Literasi & STEAM", capaian.literasi),
            row("Umpan Balik", capaian.rekomendasi),
            row(
              "Tanggapan Orang Tua",
              (capaian.tanggapan == '' || capaian.tanggapan.isEmpty)
                  ? "-"
                  : capaian.tanggapan,
            ),
          ]),
        ],

        /// ------------------ HASIL KARYA ------------------
        if (hasilKarya != null) ...[
          sectionTitle("HASIL KARYA ANAK"),
          table([
            pw.TableRow(
              verticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text("Foto", style: bold),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: fotoPdfHk != null
                      ? pw.Center(
                          child: pw.Container(
                            height: 120,
                            child: pw.Image(fotoPdfHk, fit: pw.BoxFit.contain),
                          ),
                        )
                      : pw.Text("-"),
                ),
              ],
            ),
            row("Tanggal", hasilKarya.tanggal),
            row("Kegiatan", hasilKarya.deskripsi),
            row("Tujuan", hasilKarya.semester),
            row("Nilai Agama & Budi Pekerti", hasilKarya.nilai),
            row("Jati Diri", hasilKarya.jatiDiri),
            row("Literasi & STEAM", hasilKarya.literasi),
            row("Umpan Balik", hasilKarya.rekomendasi),
            row(
              "Tanggapan Orang Tua",
              (hasilKarya.tanggapan == '' || hasilKarya.tanggapan.isEmpty)
                  ? "-"
                  : hasilKarya.tanggapan,
            ),
          ]),
        ],

        /// ------------------ PERTUMBUHAN ------------------
        if (pertumbuhan != null) ...[
          sectionTitle("PERTUMBUHAN ANAK"),
          table([
            row("Tanggal", pertumbuhan.tanggal),
            row("Berat Badan (kg)", pertumbuhan.berat.toString()),
            row("Tinggi Badan (cm)", pertumbuhan.tinggi.toString()),
            row("Lingkar Kepala (cm)", pertumbuhan.kepala.toString()),
            row("Kondisi Fisik", pertumbuhan.fisik),
            row("Umpan Balik", pertumbuhan.rekomendasi),
            row(
              "Tanggapan Orang Tua",
              (pertumbuhan.tanggapan == '' || pertumbuhan.tanggapan.isEmpty)
                  ? "-"
                  : pertumbuhan.tanggapan,
            ),
          ]),
        ],

        /// ------------------ RUBRIK ------------------
        if (rubrik != null) ...[
          sectionTitle("RUBRIK PENILAIAN"),
          table([
            row("Tanggal", rubrik.tanggal),
            row("Tujuan", rubrik.tujuan),
            row("Skor", rubrik.skor),
            row("Nilai Agama & Budi Pekerti", rubrik.agama),
            row("Jati Diri", rubrik.jatidiri),
            row("Literasi & STEAM", rubrik.literasi),
            row("Umpan Balik", rubrik.rekomendasi),
            row(
              "Tanggapan Orang Tua",
              (rubrik.tanggapan == '' || rubrik.tanggapan.isEmpty)
                  ? "-"
                  : rubrik.tanggapan,
            ),
          ]),
        ],
      ],
    ),
  );

  // SAVE
  await Printing.layoutPdf(onLayout: (_) => doc.save());
}
