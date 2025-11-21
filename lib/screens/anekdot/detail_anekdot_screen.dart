import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sippa/models/anekdot.dart';
import 'package:sippa/providers/anekdot_provider.dart';
import 'package:sippa/providers/murid_provider.dart';
import 'package:sippa/providers/user_provider.dart';

import '../../utils/arg/anekdot_arg.dart';
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

class DetailAnekdotScreen extends ConsumerWidget {
  final String anekdotId;
  const DetailAnekdotScreen({super.key, required this.anekdotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.read(anekdotProvider.notifier).getPublicImageUrl;

    final anekdotState = ref.watch(anekdotProvider);
    final muridState = ref.watch(muridProvider);
    final userState = ref.watch(userProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Detail Anekdot',
          showBack: true,
          onBack: () => context.go('/anekdot'),
        ),

        body: anekdotState.when(
          loading: () => const Loader(),
          error: (e, _) => ErrorPage(error: e.toString()),

          data: (list) {
            final match = list.where((a) => a.id == anekdotId).toList();

            // Jika tidak ditemukan → kembali
            if (match.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/anekdot');
              });
              return const Loader();
            }
            final anekdot = match.first;

            return muridState.when(
              loading: () => const Loader(),
              error: (e, _) => ErrorText(error: e.toString()),

              data: (muridList) {
                final muridMap = {for (var m in muridList) m.id: m.nama};
                final namaMurid =
                    muridMap[anekdot.muridId] ?? "Murid tidak ditemukan";

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      buildImage(imageUrl(anekdot.imageId)),
                      const SizedBox(height: 24),

                      _buildInfoCards(anekdot, namaMurid),
                      const SizedBox(height: 20),

                      userState.when(
                        loading: () => const Loader(),
                        error: (e, _) => Text("Error: $e"),

                        data: (profile) {
                          final userLevel = profile!.levelUser;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMainButton(
                                context,
                                userLevel,
                                anekdot,
                                ref,
                              ),
                              const SizedBox(height: 16),

                              if (userLevel != 3)
                                _buildDeleteButton(context, anekdot, ref),
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
    AnekdotModel anekdot,
    WidgetRef ref,
  ) {
    final isGuruOrAdmin = userLevel != 3;

    return CustomButton(
      text: isGuruOrAdmin ? "Edit Data" : "Tanggapan Orang Tua",
      onPressed: () async {
        if (isGuruOrAdmin) {
          context.push('/formAnekdot', extra: AnekdotArgs(anekdot: anekdot));
        } else {
          final result = await AppDialog.input(
            context,
            title: "Tanggapan Orang Tua",
            hint: "Masukkan tanggapan...",
          );

          if (result != null && result.isNotEmpty) {
            final updated = anekdot.copyWith(tanggapan: result);

            await ref
                .read(anekdotProvider.notifier)
                .updateAnekdot(updated, anekdot, null);

            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Tanggapan disimpan")));
          }
        }
      },
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    AnekdotModel anekdot,
    WidgetRef ref,
  ) {
    return CustomButton(
      text: "Hapus Data",
      backgroundColor: Colors.red[700],
      onPressed: () async {
        final confirm = await AppDialog.confirm(
          context,
          title: "Hapus Anekdot",
          message: "Yakin ingin menghapus data ini?",
        );

        if (confirm) {
          await ref.read(anekdotProvider.notifier).deleteAnekdot(anekdot);
          if (!context.mounted) return;
          context.go('/anekdot');
        }
      },
    );
  }

  Widget _buildInfoCards(AnekdotModel a, String namaMurid) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const SizedBox(height: 8),
          infoRow("Nama :", namaMurid),
          infoRow("Kelas :", a.kelompok),
          infoRow("Tanggal :", a.tanggal),
          textBlock("Kegiatan :", a.kegiatan),
          textBlock("Tujuan :", a.tujuan),
          textBlock("Nilai Agama & Budi Pekerti :", a.nilaiAgama),
          textBlock("Jati Diri :", a.jatiDiri),
          textBlock("Literasi & STEAM :", a.literasi),
          textBlock("Umpan Balik :", a.rekomendasi),
          textBlock("Tanggapan Orang Tua :", a.tanggapan),
          infoRow("Nama Sekolah :", a.sekolah),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
