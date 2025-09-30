import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sippa/providers/murid_provider.dart';
import '../../widgets/common/loading.dart';
import '../../models/pertumbuhan.dart';
import '../../providers/pertumbuhan_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/arg/pertumbuhan_arg.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class DetailPertumbuhanScreen extends ConsumerWidget {
  final String pertumbuhanId;
  const DetailPertumbuhanScreen({super.key, required this.pertumbuhanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final muridState = ref.watch(muridProvider);
    final pertumbuhanList = ref.watch(pertumbuhanProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Detail Pertumbuhan Anak',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/pertumbuhan'),
          ),
        ),
        body: pertumbuhanList.when(
          data: (list) {
            final all = list.where((p) => p.id == pertumbuhanId).toList();
            if (all.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) context.go('/pertumbuhan');
              });
              return const Center(child: CircularProgressIndicator());
            }
            final pertumbuhan = all.first;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: muridState.when(
                data: (muridList) {
                  final muridMap = {for (var m in muridList) m.id: m.nama};
                  final namaMurid =
                      muridMap[pertumbuhan.muridId] ?? "Murid tidak ditemukan";
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
                                _buildDetailInfoCard(
                                  'Kelas :',
                                  pertumbuhan.kelompok,
                                ),
                                _buildDetailInfoCard(
                                  'Tanggal :',
                                  pertumbuhan.tanggal,
                                ),
                                _buildDetailInfoCard(
                                  'Tinggi Badan :',
                                  '${pertumbuhan.tinggi} cm',
                                ),
                                _buildDetailInfoCard(
                                  'Berat Badan :',
                                  "${pertumbuhan.berat} kg",
                                ),
                                _buildDetailInfoCard(
                                  'Lingkar Kepala :',
                                  '${pertumbuhan.kepala} cm',
                                ),
                                _buildDetailCard(
                                  'Kondisi Fisik :',
                                  pertumbuhan.fisik,
                                ),
                                _buildDetailCard(
                                  'Umpan Balik :',
                                  pertumbuhan.rekomendasi,
                                ),
                                _buildDetailCard(
                                  'Tanggapan Orang Tua:',
                                  pertumbuhan.tanggapan,
                                ),
                                _buildDetailInfoCard(
                                  'Nama Sekolah :',
                                  pertumbuhan.sekolah,
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
                                          '/formPertumbuhan',
                                          extra: PertumbuhanArgs(
                                            pertumbuhan: pertumbuhan,
                                          ),
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
                                          final updated = PertumbuhanModel(
                                            id: pertumbuhan.id,
                                            tanggal: pertumbuhan.tanggal,
                                            rekomendasi:
                                                pertumbuhan.rekomendasi,
                                            kelompok: pertumbuhan.kelompok,
                                            uid: pertumbuhan.uid,
                                            muridId: pertumbuhan.muridId,
                                            tanggapan: tanggapanController.text,
                                            sekolah: pertumbuhan.sekolah,
                                            tinggi: pertumbuhan.tinggi,
                                            berat: pertumbuhan.berat,
                                            kepala: pertumbuhan.kepala,
                                            fisik: pertumbuhan.fisik,
                                          );
                                          await ref
                                              .read(
                                                pertumbuhanProvider.notifier,
                                              )
                                              .updatePertumbuhan(updated);
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
                                      onPressed: () => _deletePertumbuhan(
                                        context,
                                        ref,
                                        pertumbuhan,
                                      ),
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

  Future<void> _deletePertumbuhan(
    BuildContext context,
    WidgetRef ref,
    PertumbuhanModel pertumbuhan,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(text: 'Hapus Data Pertumbuhan Anak'),
        content: const CustomText(
          text: 'Apakah Anda yakin ingin menghapus data ini?',
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
      await ref
          .read(pertumbuhanProvider.notifier)
          .deletePertumbuhan(pertumbuhan);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            text: 'Data pertumbuhan anak berhasil dihapus',
            color: Colors.white,
          ),
        ),
      );
      context.go('/pertumbuhan');
    }
  }
}
