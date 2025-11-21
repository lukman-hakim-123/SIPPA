import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/hk.dart';
import '../../providers/hk_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/arg/hk_arg.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/build_image.dart';
import '../../widgets/common/error.dart';
import '../../widgets/common/info_row.dart';
import '../../widgets/common/loading.dart';
import '../../widgets/common/text_block.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/my_double_tap_exit.dart';

class DetailHkScreen extends ConsumerWidget {
  final String hkId;
  const DetailHkScreen({super.key, required this.hkId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.read(hkProvider.notifier).getPublicImageUrl;
    final hkState = ref.watch(hkProvider);
    final muridState = ref.watch(muridProvider);
    final userState = ref.watch(userProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Detail Hasil Karya',
          showBack: true,
          onBack: () => context.go('/hk'),
        ),

        body: hkState.when(
          loading: () => const Loader(),
          error: (e, _) => ErrorPage(error: e.toString()),

          data: (list) {
            final match = list.where((hk) => hk.id == hkId).toList();

            // Jika tidak ditemukan → kembali
            if (match.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/hk');
              });
              return const Loader();
            }
            final hk = match.first;

            return muridState.when(
              loading: () => const Loader(),
              error: (e, _) => ErrorText(error: e.toString()),

              data: (muridList) {
                final muridMap = {for (var m in muridList) m.id: m.nama};
                final namaMurid =
                    muridMap[hk.muridId] ?? "Murid tidak ditemukan";

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      buildImage(imageUrl(hk.imageId)),
                      const SizedBox(height: 24),

                      _buildInfoCards(hk, namaMurid),
                      const SizedBox(height: 20),

                      userState.when(
                        loading: () => const Loader(),
                        error: (e, _) => Text("Error: $e"),

                        data: (profile) {
                          final userLevel = profile!.levelUser;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMainButton(context, userLevel, hk, ref),
                              const SizedBox(height: 16),

                              if (userLevel != 3)
                                _buildDeleteButton(context, hk, ref),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),
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
    HkModel hk,
    WidgetRef ref,
  ) {
    final isGuruOrAdmin = userLevel != 3;

    return CustomButton(
      text: isGuruOrAdmin ? "Edit Data" : "Tanggapan Orang Tua",
      onPressed: () async {
        if (isGuruOrAdmin) {
          context.push('/formHk', extra: HkArgs(hk: hk));
        } else {
          final result = await AppDialog.input(
            context,
            title: "Tanggapan Orang Tua",
            hint: "Masukkan tanggapan...",
          );

          if (result != null && result.isNotEmpty) {
            final updated = hk.copyWith(tanggapan: result);

            await ref.read(hkProvider.notifier).updateHk(updated, hk, null);

            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Tanggapan disimpan")));
          }
        }
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context, HkModel hk, WidgetRef ref) {
    return CustomButton(
      text: "Hapus Data",
      backgroundColor: Colors.red[700],
      onPressed: () async {
        final confirm = await AppDialog.confirm(
          context,
          title: "Hapus Hasil Karya",
          message: "Yakin ingin menghapus data ini?",
        );

        if (confirm) {
          await ref.read(hkProvider.notifier).deleteHk(hk);
          if (!context.mounted) return;
          context.go('/hk');
        }
      },
    );
  }

  Widget _buildInfoCards(HkModel hk, String namaMurid) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const SizedBox(height: 8),
          infoRow("Nama :", namaMurid),
          infoRow("Kelas :", hk.kelompok),
          infoRow("Tanggal :", hk.tanggal),
          textBlock("Kegiatan :", hk.kegiatan),
          textBlock("Tujuan :", hk.tujuan),
          textBlock("Nilai Agama & Budi Pekerti :", hk.nilaiAgama),
          textBlock("Jati Diri :", hk.jatiDiri),
          textBlock("Literasi & STEAM :", hk.literasi),
          textBlock("Umpan Balik :", hk.rekomendasi),
          textBlock("Tanggapan Orang Tua :", hk.tanggapan),
          infoRow("Nama Sekolah :", hk.sekolah),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
