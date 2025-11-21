import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../../providers/anekdot_provider.dart';
import '../../providers/hk_provider.dart';
import '../../providers/report_provider.dart';
import '../../utils/print_report.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/my_double_tap_exit.dart';
import 'widget/card_pertumbuhan.dart';
import 'widget/card_rubrik.dart';
import 'widget/card_section.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final User murid;

  const ReportScreen({super.key, required this.murid});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  int phaseIndex = 0;
  bool isInitialized = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(
      reportProvider(
        anakId: widget.murid.id,
        sekolah: widget.murid.sekolah,
        kelompok: widget.murid.kelompok,
      ),
    );

    final urlAnekdot = ref.read(anekdotProvider.notifier).getPublicImageUrl;
    final urlHasilKarya = ref.read(hkProvider.notifier).getPublicImageUrl;

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Laporan Anak',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/pilihMuridReport'),
          ),
        ),
        body: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (e, st) => Center(
            child: CustomText(text: "Terjadi kesalahan: $e", color: Colors.red),
          ),

          data: (report) {
            // Hitung jumlah fases (maks panjang list terbesar)
            final maxPhase = [
              report.anekdotList.length,
              report.capaianList.length,
              report.hasilKaryaList.length,
              report.pertumbuhanList.length,
              report.rubrikList.length,
            ].reduce((a, b) => a > b ? a : b);

            final phases = List.generate(maxPhase, (i) => i).reversed.toList();

            if (!isInitialized) {
              phaseIndex = phases.first;
              isInitialized = true;
            }

            final anekdots = report.anekdotList.reversed.toList();
            final capaians = report.capaianList.reversed.toList();
            final hasilKaryas = report.hasilKaryaList.reversed.toList();
            final pertumbuhans = report.pertumbuhanList.reversed.toList();
            final rubriks = report.rubrikList.reversed.toList();

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: "Nama: ${widget.murid.nama}",
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 5),
                      CustomText(
                        text: "Kelompok: ${report.kelompok}",
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 12),
                    itemCount: phases.length,
                    itemBuilder: (_, i) {
                      final phase = phases[i];
                      final isActive = phaseIndex == phase;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          checkmarkColor: Colors.white,
                          label: Text("Fase ${phase + 1}"),
                          selected: isActive,
                          onSelected: (_) {
                            setState(() => phaseIndex = phase);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isActive ? Colors.white : Colors.black,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      sectionCard(
                        "Anekdot",
                        phaseIndex < anekdots.length
                            ? SectionData(
                                imageUrl: urlAnekdot(
                                  anekdots[phaseIndex].imageId,
                                ),
                                tanggal: anekdots[phaseIndex].tanggal,
                                kegiatan: anekdots[phaseIndex].kegiatan,
                                tujuan: anekdots[phaseIndex].tujuan,
                              )
                            : null,
                      ),
                      sectionCard(
                        "Capaian Pembelajaran",
                        phaseIndex < capaians.length
                            ? SectionData(
                                tanggal: capaians[phaseIndex].tanggal,
                                kegiatan: capaians[phaseIndex].kegiatan,
                                tujuan: capaians[phaseIndex].tujuan,
                              )
                            : null,
                      ),
                      sectionCard(
                        "Hasil Karya",
                        phaseIndex < hasilKaryas.length
                            ? SectionData(
                                imageUrl: urlHasilKarya(
                                  hasilKaryas[phaseIndex].imageId,
                                ),
                                tanggal: hasilKaryas[phaseIndex].tanggal,
                                kegiatan: hasilKaryas[phaseIndex].kegiatan,
                                tujuan: hasilKaryas[phaseIndex].tujuan,
                              )
                            : null,
                      ),
                      pertumbuhanCard(
                        "Pertumbuhan Anak",
                        phaseIndex < pertumbuhans.length
                            ? pertumbuhans[phaseIndex]
                            : null,
                      ),

                      rubrikCard(
                        "Rubrik",
                        phaseIndex < rubriks.length
                            ? rubriks[phaseIndex]
                            : null,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButton(
                    isLoading: isLoading,
                    onPressed: () async {
                      setState(() => isLoading = true);

                      await printFullPhasePDF(
                        context: context,
                        ref: ref,
                        nama: widget.murid.nama,
                        kelompok: widget.murid.kelompok,
                        phaseIndex: phaseIndex,
                        anekdot: phaseIndex < anekdots.length
                            ? anekdots[phaseIndex]
                            : null,
                        capaian: phaseIndex < capaians.length
                            ? capaians[phaseIndex]
                            : null,
                        hasilKarya: phaseIndex < hasilKaryas.length
                            ? hasilKaryas[phaseIndex]
                            : null,
                        pertumbuhan: phaseIndex < pertumbuhans.length
                            ? pertumbuhans[phaseIndex]
                            : null,
                        rubrik: phaseIndex < rubriks.length
                            ? rubriks[phaseIndex]
                            : null,
                      );

                      setState(() => isLoading = false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.print, color: Colors.white),
                        CustomText(
                          text: " Cetak Fase Ini",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
