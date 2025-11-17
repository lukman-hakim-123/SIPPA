import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/report.dart';
import '../services/anekdot_service.dart';
import '../services/cp_service.dart';
import '../services/hk_service.dart';
import '../services/report_service.dart';
import '../services/pertumbuhan_service.dart';
import '../services/rubrik_service.dart';
import '../utils/provider.dart';

part 'report_provider.g.dart';

@riverpod
class ReportNotifier extends _$ReportNotifier {
  @override
  Future<ReportModel> build({
    required String anakId,
    required String sekolah,
    required String kelompok,
  }) async {
    final db = ref.read(appwriteTableDBProvider);
    final storage = ref.read(appwriteStorageProvider);

    // Buat instance service utama
    final reportService = ReportService(
      anekdotService: AnekdotService(db: db, storage: storage),
      cpService: CpService(db: db),
      hkService: HkService(db: db, storage: storage),
      pertumbuhanService: PertumbuhanService(db: db),
      rubrikService: RubrikService(db: db),
    );

    // Panggil method tunggal
    final result = await reportService.getReportForAnak(
      muridId: anakId,
      sekolah: sekolah,
      kelompok: kelompok,
    );

    if (result.isFailed) {
      throw Exception(result.errorMessage ?? 'Gagal memuat laporan anak.');
    }
    return result.resultValue!;
  }

  Future<void> refreshReport() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(
      await build(
        anakId: state.value?.muridId ?? '',
        sekolah: state.value?.sekolah ?? '',
        kelompok: state.value?.kelompok ?? '',
      ),
    );
  }
}
