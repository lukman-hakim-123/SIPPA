import '../models/anekdot.dart';
import '../models/cp.dart';
import '../models/hk.dart';
import '../models/pertumbuhan.dart';
import '../models/report.dart';
import '../models/result.dart';
import '../models/rubrik.dart';
import 'anekdot_service.dart';
import 'cp_service.dart';
import 'hk_service.dart';
import 'pertumbuhan_service.dart';
import 'rubrik_service.dart';

class ReportService {
  final AnekdotService _anekdotService;
  final CpService _cpService;
  final HkService _hkService;
  final PertumbuhanService _pertumbuhanService;
  final RubrikService _rubrikService;

  ReportService({
    required AnekdotService anekdotService,
    required CpService cpService,
    required HkService hkService,
    required PertumbuhanService pertumbuhanService,
    required RubrikService rubrikService,
  }) : _anekdotService = anekdotService,
       _cpService = cpService,
       _hkService = hkService,
       _pertumbuhanService = pertumbuhanService,
       _rubrikService = rubrikService;

  /// Mengambil semua data anak dari tiap tabel dan gabungkan
  Future<Result<ReportModel>> getReportForAnak({
    required String muridId,
    required String sekolah,
    required String kelompok,
  }) async {
    try {
      // Jalankan semua request paralel biar lebih cepat
      final results = await Future.wait([
        _anekdotService.getAllAnekdotByUId(muridId, sekolah, kelompok),
        _cpService.getAllCpByUId(muridId, sekolah, kelompok),
        _hkService.getAllHkByUId(muridId, sekolah, kelompok),
        _pertumbuhanService.getAllPertumbuhanByUId(muridId, sekolah, kelompok),
        _rubrikService.getAllRubrikByUId(muridId, sekolah, kelompok),
      ]);

      // Destructure hasil Future.wait (biar gampang dipakai)
      final anekdot = results[0] as Result<List<AnekdotModel>>;
      final capaian = results[1] as Result<List<CpModel>>;
      final hasilKarya = results[2] as Result<List<HkModel>>;
      final pertumbuhan = results[3] as Result<List<PertumbuhanModel>>;
      final rubrik = results[4] as Result<List<RubrikModel>>;

      // Cek apakah ada yang gagal
      if ([
        anekdot,
        capaian,
        hasilKarya,
        pertumbuhan,
        rubrik,
      ].any((r) => r.isFailed)) {
        return Result.failed(
          'Gagal mengambil data laporan dari salah satu tabel.',
        );
      }

      // Semua berhasil -> gabungkan ke model laporan
      final report = ReportModel(
        muridId: muridId,
        sekolah: sekolah,
        kelompok: kelompok,
        anekdotList: anekdot.resultValue ?? [],
        capaianList: capaian.resultValue ?? [],
        hasilKaryaList: hasilKarya.resultValue ?? [],
        pertumbuhanList: pertumbuhan.resultValue ?? [],
        rubrikList: rubrik.resultValue ?? [],
      );

      return Result.success(report);
    } catch (e) {
      return Result.failed('Terjadi kesalahan: $e');
    }
  }

  // /// Generate PDF dari laporan
  // Future<Result<pw.Document>> generatePdf(ReportModel laporan) async {
  //   try {
  //     final pdf = pw.Document();

  //     pdf.addPage(
  //       pw.MultiPage(
  //         build: (context) => [
  //           pw.Text(
  //             'Laporan Perkembangan Anak',
  //             style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
  //           ),
  //           pw.SizedBox(height: 10),
  //           pw.Text('Sekolah: ${laporan.sekolah}'),
  //           pw.Text('Kelompok: ${laporan.kelompok}'),
  //           pw.SizedBox(height: 20),

  //           pw.Text(
  //             'Catatan Anekdot',
  //             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
  //           ),
  //           ...laporan.anekdotList
  //               .map((a) => pw.Bullet(text: a.keterangan))
  //               .toList(),
  //           pw.SizedBox(height: 10),

  //           pw.Text(
  //             'Capaian Pembelajaran',
  //             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
  //           ),
  //           ...laporan.capaianList
  //               .map((c) => pw.Bullet(text: c.deskripsi))
  //               .toList(),
  //           pw.SizedBox(height: 10),

  //           pw.Text(
  //             'Hasil Karya',
  //             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
  //           ),
  //           ...laporan.hasilKaryaList
  //               .map((h) => pw.Bullet(text: h.judul))
  //               .toList(),
  //           pw.SizedBox(height: 10),

  //           pw.Text(
  //             'Pertumbuhan Anak',
  //             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
  //           ),
  //           ...laporan.pertumbuhanList
  //               .map((p) => pw.Bullet(text: p.catatan))
  //               .toList(),
  //           pw.SizedBox(height: 10),

  //           pw.Text(
  //             'Rubrik Penilaian',
  //             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
  //           ),
  //           ...laporan.rubrikList
  //               .map((r) => pw.Bullet(text: '${r.aspek}: ${r.nilai}'))
  //               .toList(),
  //         ],
  //       ),
  //     );

  //     return Result.success(pdf);
  //   } catch (e) {
  //     return Result.failed(e.toString());
  //   }
  // }
}
