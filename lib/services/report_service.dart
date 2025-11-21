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
        _anekdotService.getAllAnekdotByUId(muridId),
        _cpService.getAllCpByUId(muridId),
        _hkService.getAllHkByUId(muridId),
        _pertumbuhanService.getAllPertumbuhanByUId(muridId),
        _rubrikService.getAllRubrikByUId(muridId),
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
}
