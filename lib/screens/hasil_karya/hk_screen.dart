import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/hk.dart';
import '../../providers/hk_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/arg/hk_arg.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class HkScreen extends ConsumerStatefulWidget {
  const HkScreen({super.key});

  @override
  ConsumerState<HkScreen> createState() => _HkScreenState();
}

class _HkScreenState extends ConsumerState<HkScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final hkState = ref.watch(hkProvider);
    final userState = ref.watch(userProvider);
    final muridList = ref.watch(muridProvider).value ?? [];
    final muridMap = {for (var m in muridList) m.id: m.nama};

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Hasil Karya',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.go('/home');
            },
          ),
        ),
        body: userState.when(
          data: (profile) {
            final int userLevel = profile!.levelUser;
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(hkProvider);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 20.0,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: CustomTextFormField(
                        controller: searchController,
                        hintText: 'Search...',
                        suffixIcon: const Icon(Icons.search),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    if (userLevel != 3)
                      CustomButton(
                        onPressed: () {
                          context.go('/pilihAnakHk');
                        },
                        height: 45.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            CustomText(
                              text: 'Tambah Hasil Karya',
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            Icon(Icons.add, color: Colors.white, size: 25.0),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: hkState.when(
                        data: (hkList) {
                          if (hkList.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: CustomText(
                                  text: 'Belum ada data',
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }
                          final filtered = hkList.where((hk) {
                            final muridName =
                                muridMap[hk.muridId]?.toLowerCase() ?? '';
                            return muridName.contains(searchQuery);
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                              child: CustomText(
                                text: 'Data tidak ditemukan',
                                fontSize: 16,
                              ),
                            );
                          }
                          final url = ref
                              .read(hkProvider.notifier)
                              .getPublicImageUrl;
                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final hk = filtered[index];
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 16,
                                    right: 4,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    child: ClipOval(
                                      child: Image.network(
                                        url(hk.imageId),
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        loadingBuilder: (context, child, loadingProgress) {
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
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                      ),
                                    ),
                                  ),
                                  title: CustomText(
                                    text:
                                        muridMap[hk.muridId] ??
                                        'Murid tidak ditemukan',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(text: 'kelas: ${hk.kelompok}'),
                                      CustomText(text: hk.tanggal),
                                    ],
                                  ),
                                  trailing: userLevel != 3
                                      ? Wrap(
                                          spacing: 0,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () {
                                                context.go(
                                                  '/formHk',
                                                  extra: HkArgs(hk: hk),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  _deleteHk(context, ref, hk),
                                            ),
                                          ],
                                        )
                                      : null,
                                  onTap: () =>
                                      context.go('/detailHk', extra: hk.id),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                        error: (error, stack) =>
                            Center(child: Text('Terjadi kesalahan: $error')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Future<void> _deleteHk(
    BuildContext context,
    WidgetRef ref,
    HkModel hk,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(text: 'Hapus Hasil Karya'),
        content: const CustomText(
          text: 'Apakah Anda yakin ingin menghapus data Hasil Karya ini?',
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
      ref.read(hkProvider.notifier).deleteHk(hk);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            text: 'Data Hasil Karya berhasil dihapus',
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
