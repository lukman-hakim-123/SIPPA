import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/rubrik.dart';
import '../../providers/rubrik_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/arg/rubrik_arg.dart';

import '../../widgets/app_colors.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/common/text_block.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/my_double_tap_exit.dart';

class DetailRubrikScreen extends ConsumerWidget {
  final String rubrikId;
  const DetailRubrikScreen({super.key, required this.rubrikId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final muridState = ref.watch(muridProvider);
    final rubrikState = ref.watch(rubrikProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: "Detail Rubrik",
          showBack: true,
          onBack: () => context.go('/rubrik'),
        ),

        body: rubrikState.when(
          loading: () => const Loader(),
          error: (e, _) => Text("Error: $e"),

          data: (list) {
            final match = list.where((r) => r.id == rubrikId).toList();

            if (match.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/rubrik');
              });
              return const Loader();
            }

            final r = match.first;

            return muridState.when(
              loading: () => const Loader(),
              error: (e, _) => Text("Error: $e"),

              data: (muridList) {
                final muridMap = {for (var m in muridList) m.id: m};

                final nama =
                    muridMap[r.muridId]?.nama ?? "Nama tidak ditemukan";
                final sekolah = muridMap[r.muridId]?.sekolah ?? r.sekolah;
                final kelompok = muridMap[r.muridId]?.kelompok ?? r.kelompok;

                final skorText = _mapSkor(r.skor);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoCard(nama, sekolah, kelompok, r, skorText),

                      const SizedBox(height: 20),

                      userState.when(
                        loading: () => const Loader(),
                        error: (e, _) => Text("Error: $e"),

                        data: (profile) {
                          final level = profile!.levelUser;
                          final isGuruOrAdmin = level != 3;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMainButton(context, level, r, ref),
                              const SizedBox(height: 16),

                              if (isGuruOrAdmin)
                                _buildDeleteButton(context, r, ref),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    int userLevel,
    RubrikModel r,
    WidgetRef ref,
  ) {
    final isGuruOrAdmin = userLevel != 3;

    return CustomButton(
      text: isGuruOrAdmin ? "Edit Data" : "Tanggapan Orang Tua",
      onPressed: () async {
        if (isGuruOrAdmin) {
          context.push('/formRubrik', extra: RubrikArgs(rubrik: r));
        } else {
          final result = await AppDialog.input(
            context,
            title: "Tanggapan Orang Tua",
            hint: "Masukkan tanggapan...",
          );

          if (result != null && result.isNotEmpty) {
            final updated = r.copyWith(tanggapan: result);
            await ref.read(rubrikProvider.notifier).updateRubrik(updated);

            if (!context.mounted) return;

            SnackbarHelper.show(context, "Tanggapan berhasil disimpan");
          }
        }
      },
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    RubrikModel r,
    WidgetRef ref,
  ) {
    return CustomButton(
      text: "Hapus Data",
      backgroundColor: Colors.red[700],
      onPressed: () async {
        final confirm = await AppDialog.confirm(
          context,
          title: "Hapus Rubrik",
          message: "Yakin ingin menghapus data ini?",
        );

        if (confirm) {
          await ref.read(rubrikProvider.notifier).deleteRubrik(r);

          if (!context.mounted) return;
          context.go('/rubrik');
        }
      },
    );
  }

  Widget _buildInfoCard(
    String nama,
    String sekolah,
    String kelompok,
    RubrikModel r,
    String skorText,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 8),

          infoRow("Nama :", nama),
          infoRow("Kelas :", kelompok),
          infoRow("Tanggal :", r.tanggal),

          textBlock("Tujuan :", r.tujuan),
          textBlock("Skor :", skorText),
          textBlock("Agama & Budi Pekerti :", r.agama),
          textBlock("Jati Diri :", r.jatidiri),
          textBlock("Literasi & STEAM :", r.literasi),
          textBlock("Umpan Balik :", r.rekomendasi),
          textBlock("Tanggapan Orang Tua :", r.tanggapan),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _mapSkor(String skor) {
    switch (skor) {
      case "1":
        return "Skor 1 — Belum mencapai tujuan pembelajaran";
      case "2":
        return "Skor 2 — Mencapai tujuan pembelajaran dengan bantuan";
      case "3":
        return "Skor 3 — Mencapai tujuan pembelajaran secara mandiri";
      default:
        return "-";
    }
  }
}
