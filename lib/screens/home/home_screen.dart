import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/loading.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/my_double_tap_exit.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': 'assets/icons/anekdot.png',
      'label': 'Catatan Anekdot',
      'route': '/anekdot',
    },
    {
      'icon': 'assets/icons/cp.png',
      'label': 'Capaian Pembelajaran',
      'route': '/cp',
    },
    {'icon': 'assets/icons/hk.png', 'label': 'Hasil Karya', 'route': '/hk'},
    {
      'icon': 'assets/icons/pertumbuhan.png',
      'label': 'Pertumbuhan Anak',
      'route': '/pertumbuhan',
    },
    {'icon': 'assets/icons/rubrik.png', 'label': 'Rubrik', 'route': '/rubrik'},
    {
      'icon': 'assets/icons/report.png',
      'label': 'Laporan',
      'route': '/pilihMuridReport',
    },
    {
      'icon': 'assets/icons/murid.png',
      'label': 'Daftar Murid',
      'route': '/murid',
      'minLevel': 2,
    },
    {
      'icon': 'assets/icons/guru.png',
      'label': 'Daftar Guru',
      'route': '/guru',
      'minLevel': 1,
    },
    {
      'icon': 'assets/icons/admin.png',
      'label': 'Daftar Admin',
      'route': '/admin',
      'minLevel': 0,
    },
    {
      'icon': 'assets/icons/profile.png',
      'label': 'Profile',
      'route': '/profile',
    },
    {'icon': 'assets/icons/logout.png', 'label': 'Logout', 'action': 'logout'},
  ];

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userProfileState = ref.watch(userProvider);

    final now = DateTime.now();
    final hari = DateFormat('EEEE', 'id_ID').format(now);
    final tanggal = DateFormat('d MMMM yyyy', 'id_ID').format(now);

    ref.listen<AsyncValue<models.User?>>(authProvider, (prev, next) {
      if (next is AsyncData && next.value == null) {
        if (context.mounted) {
          context.go('/login');
        }
      }
    });

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: authState.when(
          data: (user) {
            return userProfileState.when(
              data: (profile) {
                final int userLevel = profile!.levelUser;
                final url = ref.read(userProvider.notifier).getPublicImageUrl;

                final filteredMenu = menuItems.where((item) {
                  final minLevel = item['minLevel'] as int?;
                  if (minLevel != null && userLevel > minLevel) {
                    return false;
                  }
                  return true;
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // header
                      Container(
                        padding: const EdgeInsets.only(
                          top: 60,
                          bottom: 20,
                          left: 20,
                          right: 20,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: AppColors.tertiary,
                                  child: (profile.imageId.isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            url(profile.imageId),
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
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 120,
                                  child: CustomText(
                                    text: profile.nama,
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomText(text: hari, color: Colors.white),
                                CustomText(
                                  text: tanggal,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // grid menu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(top: 30, bottom: 25),
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1,
                                ),
                            itemCount: filteredMenu.length,
                            itemBuilder: (context, index) {
                              final item = filteredMenu[index];
                              return GestureDetector(
                                onTap: () {
                                  if (item['action'] == 'logout') {
                                    _logout(context, ref);
                                  } else {
                                    context.go(item['route']);
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      item['icon'],
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomText(
                                      text: item['label'],
                                      textAlign: TextAlign.center,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 100.0),
                    ],
                  ),
                );
              },
              loading: () => Loader(),
              error: (err, _) => Center(child: Text("Error: $err")),
            );
          },
          loading: () => LoadingPage(),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
