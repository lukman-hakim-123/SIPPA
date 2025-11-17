import 'report.dart';
import 'anekdot.dart';
import 'cp.dart';
import 'hk.dart';
import 'pertumbuhan.dart';
import 'rubrik.dart';

class ReportPhase {
  final AnekdotModel? anekdot;
  final CpModel? capaian;
  final HkModel? hasilKarya;
  final PertumbuhanModel? pertumbuhan;
  final RubrikModel? rubrik;

  ReportPhase({
    this.anekdot,
    this.capaian,
    this.hasilKarya,
    this.pertumbuhan,
    this.rubrik,
  });
}

ReportPhase getPhase(ReportModel data, int index) {
  return ReportPhase(
    anekdot: data.anekdotList.length > index ? data.anekdotList[index] : null,
    capaian: data.capaianList.length > index ? data.capaianList[index] : null,
    hasilKarya: data.hasilKaryaList.length > index
        ? data.hasilKaryaList[index]
        : null,
    pertumbuhan: data.pertumbuhanList.length > index
        ? data.pertumbuhanList[index]
        : null,
    rubrik: data.rubrikList.length > index ? data.rubrikList[index] : null,
  );
}

bool hasMorePhase(ReportModel d, int i) {
  return d.anekdotList.length > i + 1 ||
      d.capaianList.length > i + 1 ||
      d.hasilKaryaList.length > i + 1 ||
      d.pertumbuhanList.length > i + 1 ||
      d.rubrikList.length > i + 1;
}
