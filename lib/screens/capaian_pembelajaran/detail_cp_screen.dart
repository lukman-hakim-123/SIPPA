import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sippa/models/cp.dart';
import 'package:sippa/providers/cp_provider.dart';
import 'package:sippa/providers/murid_provider.dart';
import 'package:sippa/providers/user_provider.dart';
import 'package:sippa/widgets/common/app_dialog.dart';
import 'package:sippa/widgets/common/info_row.dart';
import 'package:sippa/widgets/common/loading.dart';
import 'package:sippa/widgets/common/text_block.dart';
import 'package:sippa/widgets/custom_app_bar.dart';
import 'package:sippa/widgets/custom_button.dart';
import 'package:sippa/widgets/my_double_tap_exit.dart';
import 'package:sippa/utils/arg/cp_arg.dart';
import 'package:sippa/widgets/app_colors.dart';

class DetailCpScreen extends ConsumerWidget {
  final String cpId;
  const DetailCpScreen({super.key, required this.cpId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final muridState = ref.watch(muridProvider);
    final cpState = ref.watch(cpProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Detail Capaian Pembelajaran',
          showBack: true,
          onBack: () => context.go('/cp'),
        ),
        body: cpState.when(
          data: (cpList) {
            final match = cpList.where((c) => c.id == cpId).toList();
            if (match.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/cp');
              });
              return const Loader();
            }
            final cp = match.first;

            return muridState.when(
              data: (muridList) {
                final muridMap = {for (var m in muridList) m.id: m.nama};
                final namaMurid =
                    muridMap[cp.muridId] ?? "Murid tidak ditemukan";

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoCards(namaMurid, cp),
                      const SizedBox(height: 20),
                      userState.when(
                        data: (profile) {
                          final userLevel = profile!.levelUser;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMainButton(context, userLevel, cp, ref),
                              const SizedBox(height: 16),
                              if (userLevel != 3)
                                _buildDeleteButton(context, cp, ref),
                            ],
                          );
                        },
                        loading: () => const Loader(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Loader(),
              error: (e, _) => Text('Error: $e'),
            );
          },
          loading: () => const Loader(),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    int userLevel,
    CpModel cp,
    WidgetRef ref,
  ) {
    final isGuruOrAdmin = userLevel != 3;

    return CustomButton(
      text: isGuruOrAdmin ? "Edit Data" : "Tanggapan Orang Tua",
      onPressed: () async {
        if (isGuruOrAdmin) {
          context.push('/formCp', extra: CpArgs(cp: cp));
        } else {
          final result = await AppDialog.input(
            context,
            title: "Tanggapan Orang Tua",
            hint: "Masukkan tanggapan...",
          );

          if (result != null && result.isNotEmpty) {
            final updated = cp.copyWith(tanggapan: result);
            await ref.read(cpProvider.notifier).updateCp(updated);
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Tanggapan disimpan")));
          }
        }
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context, CpModel cp, WidgetRef ref) {
    return CustomButton(
      text: "Hapus Data",
      backgroundColor: Colors.red[700],
      onPressed: () async {
        final confirm = await AppDialog.confirm(
          context,
          title: "Hapus Capaian Pembelajaran",
          message: "Yakin ingin menghapus data ini?",
        );

        if (confirm) {
          await ref.read(cpProvider.notifier).deleteCp(cp);
          if (!context.mounted) return;
          context.go('/cp');
        }
      },
    );
  }

  Widget _buildInfoCards(String namaMurid, CpModel cp) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 8),
          infoRow("Nama :", namaMurid),
          infoRow("Kelas :", cp.kelompok),
          infoRow("Tanggal :", cp.tanggal),
          textBlock("Kegiatan :", cp.kegiatan),
          textBlock("Tujuan :", cp.tujuan),
          textBlock("Nilai Agama dan Budi Pekerti :", cp.nilaiAgama),
          textBlock("Jati Diri :", cp.jatiDiri),
          textBlock("Literasi dan STEAM :", cp.literasi),
          textBlock("Umpan Balik :", cp.rekomendasi),
          textBlock("Tanggapan Orang Tua :", cp.tanggapan),
          infoRow("Nama Sekolah :", cp.sekolah),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
