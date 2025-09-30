import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sippa/models/user.dart';
import '../../providers/guru_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class GuruScreen extends ConsumerStatefulWidget {
  const GuruScreen({super.key});

  @override
  ConsumerState<GuruScreen> createState() => _GuruScreenState();
}

class _GuruScreenState extends ConsumerState<GuruScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final guruState = ref.watch(guruProvider);
    final userProfileState = ref.watch(userProvider);
    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: CustomText(
            text: 'Data Guru',
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
        body: userProfileState.when(
          data: (profile) {
            final int userLevel = profile!.levelUser;
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(guruProvider);
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
                          context.go('/formGuru');
                        },
                        height: 45.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            CustomText(
                              text: 'Tambah data guru',
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
                      child: guruState.when(
                        data: (guruList) {
                          if (guruList.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: CustomText(
                                  text: 'Belum ada data guru',
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }
                          final filtered = guruList.where((guru) {
                            return guru.nama.toLowerCase().contains(
                              searchQuery,
                            );
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
                              .read(guruProvider.notifier)
                              .getPublicImageUrl;
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 20),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final guru = filtered[index];
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    child: ClipOval(
                                      child: Image.network(
                                        url(guru.imageId),
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
                                    text: guru.nama,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CustomText(
                                        text: 'kelas: ${guru.kelompok}',
                                      ),
                                    ],
                                  ),
                                  trailing: userLevel != 3
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () {
                                                context.go(
                                                  '/formGuru',
                                                  extra: guru,
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () => _deleteGuru(
                                                context,
                                                ref,
                                                guru,
                                              ),
                                            ),
                                          ],
                                        )
                                      : null,
                                  onTap: () =>
                                      context.go('/detailGuru', extra: guru),
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

  Future<void> _deleteGuru(
    BuildContext context,
    WidgetRef ref,
    User guru,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(text: 'Hapus Guru'),
        content: CustomText(
          text: 'Apakah Anda yakin ingin menghapus guru ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(text: 'Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(text: 'Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(guruProvider.notifier).deleteGuru(guru);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            text: 'Data guru berhasil dihapus',
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
