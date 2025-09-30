import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sippa/providers/murid_provider.dart';
import '../../widgets/common/loading.dart';
import '../../models/anekdot.dart';
import '../../providers/anekdot_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/arg/anekdot_arg.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class DetailAnekdotScreen extends ConsumerWidget {
  final String anekdotId;
  const DetailAnekdotScreen({super.key, required this.anekdotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final url = ref.read(anekdotProvider.notifier).getPublicImageUrl;
    final muridState = ref.watch(muridProvider);
    final anekdotList = ref.watch(anekdotProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: CustomText(
            text: 'Detail Anekdot',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/anekdot'),
          ),
        ),
        body: anekdotList.when(
          data: (list) {
            final allAnekdot = list.where((a) => a.id == anekdotId).toList();
            if (allAnekdot.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/anekdot');
              });
              return const Center(child: CircularProgressIndicator());
            }
            final anekdot = allAnekdot.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: muridState.when(
                data: (muridList) {
                  final muridMap = {for (var m in muridList) m.id: m.nama};
                  final namaMurid =
                      muridMap[anekdot.muridId] ?? "Murid tidak ditemukan";
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              color: Colors.grey[300],
                            ),
                            child: Image.network(
                              url(anekdot.imageId),
                              fit: BoxFit.scaleDown,
                              width: 100,
                              height: 100,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Column(
                              children: [
                                const SizedBox(height: 8.0),
                                _buildDetailInfoCard('Nama :', namaMurid),
                                _buildDetailInfoCard(
                                  'Kelas :',
                                  anekdot.kelompok,
                                ),
                                _buildDetailInfoCard(
                                  'Tanggal :',
                                  anekdot.tanggal,
                                ),
                                _buildDetailCard(
                                  'Kegiatan :',
                                  anekdot.pengamatan,
                                ),
                                _buildDetailCard('Tujuan :', anekdot.tujuan),
                                _buildDetailCard(
                                  'Nilai Agama dan Budi Pekerti :',
                                  anekdot.nilai,
                                ),
                                _buildDetailCard(
                                  'Jati Diri :',
                                  anekdot.jatiDiri,
                                ),
                                _buildDetailCard(
                                  'Literasi dan STEAM :',
                                  anekdot.literasi,
                                ),
                                _buildDetailCard(
                                  'Umpan Balik :',
                                  anekdot.kelompok,
                                ),
                                _buildDetailCard(
                                  'Tanggapan Orang Tua:',
                                  anekdot.tanggapan,
                                ),
                                _buildDetailInfoCard(
                                  'Nama Sekolah :',
                                  anekdot.sekolah,
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      userState.when(
                        data: (profile) {
                          final int userLevel = profile!.levelUser;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomButton(
                                text: 'Edit Data',
                                onPressed: userLevel != 3
                                    ? () {
                                        GoRouter.of(context).push(
                                          '/formAnekdot',
                                          extra: AnekdotArgs(anekdot: anekdot),
                                        );
                                      }
                                    : () async {
                                        final tanggapanController =
                                            TextEditingController();
                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const CustomText(
                                                text: 'Tanggapan Orang Tua',
                                                fontWeight: FontWeight.bold,
                                              ),
                                              content: CustomTextFormField(
                                                controller: tanggapanController,
                                                hintText:
                                                    'Masukkan tanggapan...',

                                                minLines: 2,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: CustomText(
                                                    text: 'Batal',
                                                    color: Colors.red[400],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green[400],
                                                      ),
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      tanggapanController.text
                                                          .trim(),
                                                    );
                                                  },
                                                  child: CustomText(
                                                    text: 'Simpan',
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (result != null &&
                                            result.isNotEmpty) {
                                          final updatedAnekdot = AnekdotModel(
                                            id: anekdot.id,
                                            pengamatan: anekdot.pengamatan,
                                            tujuan: anekdot.tujuan,
                                            tanggal: anekdot.tanggal,
                                            nilai: anekdot.nilai,
                                            jatiDiri: anekdot.jatiDiri,
                                            literasi: anekdot.literasi,
                                            umpanBalik: anekdot.umpanBalik,
                                            kelompok: anekdot.kelompok,
                                            imageId: anekdot.imageId,
                                            uid: anekdot.uid,
                                            muridId: anekdot.muridId,
                                            tanggapan: tanggapanController.text,
                                            sekolah: anekdot.sekolah,
                                          );
                                          await ref
                                              .read(anekdotProvider.notifier)
                                              .updateAnekdot(
                                                updatedAnekdot,
                                                anekdot,
                                                null,
                                              );
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Tanggapan berhasil disimpan',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                              ),
                              const SizedBox(height: 16),
                              userLevel != 3
                                  ? CustomButton(
                                      text: 'Hapus Data',
                                      onPressed: () =>
                                          _deleteAnekdot(context, ref, anekdot),
                                      backgroundColor: Colors.red[700],
                                    )
                                  : Container(),
                            ],
                          );
                        },
                        loading: () => Loader(),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('Error: $e'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
                loading: () => const Loader(),
                error: (e, _) => Center(child: Text("Error: $e")),
              ),
            );
          },
          loading: () => const Loader(),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }

  Widget _buildDetailInfoCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: title, fontWeight: FontWeight.bold),
              CustomText(
                text: value.isNotEmpty ? value : '-',
                textAlign: TextAlign.right,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CustomText(text: title, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: CustomText(
              text: value.isNotEmpty ? value : '-',
              textAlign: TextAlign.right,
            ),
          ),
          const Divider(height: 24, color: Colors.grey),
        ],
      ),
    );
  }

  Future<void> _deleteAnekdot(
    BuildContext context,
    WidgetRef ref,
    AnekdotModel anekdot,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anekdot'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data anekdot ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(anekdotProvider.notifier).deleteAnekdot(anekdot);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            text: 'Data anekdot berhasil dihapus',
            color: Colors.white,
          ),
        ),
      );
      context.go('/anekdot');
    }
  }
}
