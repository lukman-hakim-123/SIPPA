import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/pertumbuhan.dart';
import '../../providers/pertumbuhan_provider.dart';
import '../../providers/murid_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/arg/pertumbuhan_arg.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class PertumbuhanScreen extends ConsumerStatefulWidget {
  const PertumbuhanScreen({super.key});

  @override
  ConsumerState<PertumbuhanScreen> createState() => _PertumbuhanScreenState();
}

class _PertumbuhanScreenState extends ConsumerState<PertumbuhanScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final pertumbuhanState = ref.watch(pertumbuhanProvider);
    final userState = ref.watch(userProvider);
    final muridList = ref.watch(muridProvider).value ?? [];
    final muridMap = {for (var m in muridList) m.id: m};

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: CustomText(
            text: 'Pertumbuhan Anak',
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
                ref.invalidate(pertumbuhanProvider);
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
                          context.go('/pilihAnakPertumbuhan');
                        },
                        height: 45.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            CustomText(
                              text: 'Tambah data Pertumbuhan',
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
                      child: pertumbuhanState.when(
                        data: (pertumbuhanList) {
                          if (pertumbuhanList.isEmpty) {
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
                          final filtered = pertumbuhanList.where((p) {
                            final muridName =
                                muridMap[p.muridId]?.id.toLowerCase() ?? '';
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
                              .read(muridProvider.notifier)
                              .getPublicImageUrl;
                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final p = filtered[index];
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
                                      child:
                                          muridMap[p.muridId]?.imageId !=
                                                  null &&
                                              muridMap[p.muridId]!
                                                  .imageId
                                                  .isNotEmpty
                                          ? Image.network(
                                              url(muridMap[p.muridId]!.imageId),
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
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.person,
                                                    color: Colors.grey,
                                                    size: 40,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                    ),
                                  ),
                                  title: CustomText(
                                    text:
                                        muridMap[p.muridId]?.nama ??
                                        'Murid tidak ditemukan',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CustomText(text: 'kelas: ${p.kelompok}'),
                                      CustomText(text: p.tanggal),
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
                                                  '/formPertumbuhan',
                                                  extra: PertumbuhanArgs(
                                                    pertumbuhan: p,
                                                  ),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () =>
                                                  _deletePertumbuhan(
                                                    context,
                                                    ref,
                                                    p,
                                                  ),
                                            ),
                                          ],
                                        )
                                      : null,
                                  onTap: () => context.go(
                                    '/detailPertumbuhan',
                                    extra: p.id,
                                  ),
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

  Future<void> _deletePertumbuhan(
    BuildContext context,
    WidgetRef ref,
    PertumbuhanModel p,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(text: 'Hapus Pertumbuhan'),
        content: CustomText(
          text: 'Apakah Anda yakin ingin menghapus data ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(text: 'Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(text: 'Hapus', color: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(pertumbuhanProvider.notifier).deletePertumbuhan(p);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            text: 'Data Pertumbuhan berhasil dihapus',
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
