import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sippa/models/user.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    // ignore: unused_local_variable
    final userState = ref.watch(userProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Data Admin',
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
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminProvider);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
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
                CustomButton(
                  onPressed: () {
                    context.go('/formAdmin');
                  },
                  height: 45.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      CustomText(
                        text: 'Tambah data admin',
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
                  child: adminState.when(
                    data: (adminList) {
                      if (adminList.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: const Center(
                            child: CustomText(
                              text: 'Belum ada data admin',
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                      final filtered = adminList.where((admin) {
                        return admin.nama.toLowerCase().contains(searchQuery);
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
                          .read(adminProvider.notifier)
                          .getPublicImageUrl;

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final admin = filtered[index];
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                child: ClipOval(
                                  child: Image.network(
                                    url(admin.imageId),
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
                                text: admin.nama,
                                fontWeight: FontWeight.bold,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  CustomText(text: 'sekolah: ${admin.sekolah}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      context.go('/formAdmin', extra: admin);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _deleteAdmin(context, ref, admin),
                                  ),
                                ],
                              ),
                              onTap: () =>
                                  context.go('/detailAdmin', extra: admin),
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
        ),
      ),
    );
  }

  Future<void> _deleteAdmin(
    BuildContext context,
    WidgetRef ref,
    User admin,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomText(text: 'Hapus Admin'),
        content: const CustomText(
          text: 'Apakah Anda yakin ingin menghapus admin ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const CustomText(text: 'Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const CustomText(text: 'Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(adminProvider.notifier).deleteAdmin(admin);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomText(
            text: 'Data admin berhasil dihapus',
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
