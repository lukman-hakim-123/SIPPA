import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/pertumbuhan.dart';
import '../../providers/pertumbuhan_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';

import '../../widgets/common/loading.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/snackbar_helper.dart';
import '../../widgets/common/text_block.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/my_double_tap_exit.dart';

import '../../utils/arg/pertumbuhan_arg.dart';

class DetailPertumbuhanScreen extends ConsumerWidget {
  final String pertumbuhanId;
  const DetailPertumbuhanScreen({super.key, required this.pertumbuhanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final muridState = ref.watch(muridProvider);
    final pertumbuhanState = ref.watch(pertumbuhanProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: "Detail Pertumbuhan Anak",
          showBack: true,
          onBack: () => context.go('/pertumbuhan'),
        ),
        body: pertumbuhanState.when(
          data: (list) {
            final match = list.where((p) => p.id == pertumbuhanId).toList();
            if (match.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/pertumbuhan');
              });
              return const Loader();
            }
            final p = match.first;

            return muridState.when(
              data: (muridList) {
                final muridMap = {for (var m in muridList) m.id: m.nama};
                final namaMurid =
                    muridMap[p.muridId] ?? "Murid tidak ditemukan";

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoCards(namaMurid, p),
                      const SizedBox(height: 20),
                      userState.when(
                        data: (profile) {
                          final userLevel = profile!.levelUser;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMainButton(context, userLevel, p, ref),
                              const SizedBox(height: 16),
                              if (userLevel != 3)
                                _buildDeleteButton(context, p, ref),
                            ],
                          );
                        },
                        loading: () => const Loader(),
                        error: (e, _) => Text("Error: $e"),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Loader(),
              error: (e, _) => Text("Error: $e"),
            );
          },
          loading: () => const Loader(),
          error: (e, _) => Text("Error: $e"),
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    int userLevel,
    PertumbuhanModel p,
    WidgetRef ref,
  ) {
    final isGuruOrAdmin = userLevel != 3;

    return CustomButton(
      text: isGuruOrAdmin ? "Edit Data" : "Tanggapan Orang Tua",
      onPressed: () async {
        if (isGuruOrAdmin) {
          context.push(
            '/formPertumbuhan',
            extra: PertumbuhanArgs(pertumbuhan: p),
          );
        } else {
          final result = await AppDialog.input(
            context,
            title: "Tanggapan Orang Tua",
            hint: "Masukkan tanggapan...",
          );

          if (result != null && result.isNotEmpty) {
            final updated = p.copyWith(tanggapan: result);

            await ref
                .read(pertumbuhanProvider.notifier)
                .updatePertumbuhan(updated);

            if (!context.mounted) return;

            SnackbarHelper.show(context, "Tanggapan berhasil disimpan");
          }
        }
      },
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    PertumbuhanModel p,
    WidgetRef ref,
  ) {
    return CustomButton(
      text: "Hapus Data",
      backgroundColor: Colors.red[700],
      onPressed: () async {
        final confirm = await AppDialog.confirm(
          context,
          title: "Hapus Data Pertumbuhan",
          message: "Yakin ingin menghapus data ini?",
        );

        if (confirm) {
          await ref.read(pertumbuhanProvider.notifier).deletePertumbuhan(p);

          if (!context.mounted) return;
          context.go('/pertumbuhan');
        }
      },
    );
  }

  Widget _buildInfoCards(String namaMurid, PertumbuhanModel p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 8),
          infoRow("Nama :", namaMurid),
          infoRow("Kelas :", p.kelompok),
          infoRow("Tanggal :", p.tanggal),
          infoRow("Tinggi Badan :", "${p.tinggi} cm"),
          infoRow("Berat Badan :", "${p.berat} kg"),
          infoRow("Lingkar Kepala :", "${p.kepala} cm"),
          textBlock("Kondisi Fisik :", p.fisik),
          textBlock("Umpan Balik :", p.rekomendasi),
          textBlock("Tanggapan Orang Tua :", p.tanggapan),
          infoRow("Nama Sekolah :", p.sekolah),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
