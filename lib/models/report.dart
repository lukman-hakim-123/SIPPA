import 'cp.dart';
import 'hk.dart';
import 'anekdot.dart';
import 'pertumbuhan.dart';
import 'rubrik.dart';

class ReportModel {
  final String muridId;
  final String sekolah;
  final String kelompok;
  final List<AnekdotModel> anekdotList;
  final List<CpModel> capaianList;
  final List<HkModel> hasilKaryaList;
  final List<PertumbuhanModel> pertumbuhanList;
  final List<RubrikModel> rubrikList;

  ReportModel({
    required this.muridId,
    required this.sekolah,
    required this.kelompok,
    required this.anekdotList,
    required this.capaianList,
    required this.hasilKaryaList,
    required this.pertumbuhanList,
    required this.rubrikList,
  });
}
