import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sippa/providers/murid_provider.dart';
import '../../widgets/common/loading.dart';
import '../../models/cp.dart';
import '../../providers/cp_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/arg/cp_arg.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class DetailCpScreen extends ConsumerWidget {
  final String cpId;
  const DetailCpScreen({super.key, required this.cpId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final muridState = ref.watch(muridProvider);
    final cpList = ref.watch(cpProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Detail Capaian Pembelajaran',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/cp'),
          ),
        ),
        body: cpList.when(
          data: (list) {
            final allCp = list.where((c) => c.id == cpId).toList();
            if (allCp.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/cp');
              });
              return const Center(child: CircularProgressIndicator());
            }
            final cp = allCp.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: muridState.when(
                data: (muridList) {
                  final muridMap = {for (var m in muridList) m.id: m.nama};
                  final namaMurid =
                      muridMap[cp.muridId] ?? "Murid tidak ditemukan";
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
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
                                _buildDetailInfoCard('Kelas :', cp.kelompok),
                                _buildDetailInfoCard('Tanggal :', cp.tanggal),
                                _buildDetailCard('Kegiatan :', cp.konteks),
                                _buildDetailCard('Tujuan :', cp.tujuan),
                                _buildDetailCard(
                                  'Nilai Agama dan Budi Pekerti :',
                                  cp.agama,
                                ),
                                _buildDetailCard('Jati Diri :', cp.jatidiri),
                                _buildDetailCard(
                                  'Literasi dan STEAM :',
                                  cp.literasi,
                                ),
                                _buildDetailCard(
                                  'Umpan Balik :',
                                  cp.rekomendasi,
                                ),
                                _buildDetailCard(
                                  'Tanggapan Orang Tua:',
                                  cp.tanggapan,
                                ),
                                _buildDetailInfoCard(
                                  'Nama Sekolah :',
                                  cp.sekolah,
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
                                          '/formCp',
                                          extra: CpArgs(cp: cp),
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
                                                  child: const CustomText(
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
                                          final updatedCp = CpModel(
                                            id: cp.id,
                                            konteks: cp.konteks,
                                            tujuan: cp.tujuan,
                                            tanggal: cp.tanggal,
                                            agama: cp.agama,
                                            jatidiri: cp.jatidiri,
                                            literasi: cp.literasi,
                                            rekomendasi: cp.rekomendasi,
                                            kelompok: cp.kelompok,
                                            uid: cp.uid,
                                            muridId: cp.muridId,
                                            tanggapan: tanggapanController.text,
                                            sekolah: cp.sekolah,
                                            isDone: cp.isDone,
                                          );
                                          await ref
                                              .read(cpProvider.notifier)
                                              .updateCp(updatedCp);
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
                                          _deleteCp(context, ref, cp),
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

  Future<void> _deleteCp(
    BuildContext context,
    WidgetRef ref,
    CpModel cp,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(text: 'Hapus CP'),
        content: const CustomText(
          text: 'Apakah Anda yakin ingin menghapus data CP ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const CustomText(text: 'Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const CustomText(text: 'Hapus', color: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(cpProvider.notifier).deleteCp(cp);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            text: 'Data CP berhasil dihapus',
            color: Colors.white,
          ),
        ),
      );
      context.go('/cp');
    }
  }
}
