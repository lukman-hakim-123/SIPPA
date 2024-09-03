import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/add_user/list_guru.dart';
import 'package:sippa/add_user/list_murid.dart';
import 'package:sippa/anekdot/anekdot_page.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/capaian_pembelajaran/cp_page.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/common/error.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/foto_berseri/foto_berseri_page.dart';
import 'package:sippa/hasil_karya/hasil_karya_page.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/observasi/observasi_page.dart';
import 'package:sippa/pertumbuhan/pertumbuhan_page.dart';
import 'package:sippa/rubrik/rubrik_page.dart';
import 'package:sippa/tanggapan_ortu/tanggapan_page.dart';
import 'package:sippa/widget_view/edit_profil_page.dart';

class CustomDrawer extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserDetailAsyncValue = ref.watch(currentUserDetailsProvider);
    final latestUsersAsyncValue = ref.watch(getLatestUsersProvider);

    return currentUserDetailAsyncValue.when(
      data: (userDetails) {
        if (userDetails == null) {
          return const Loader();
        }

        User copyOfUser = userDetails;

        latestUsersAsyncValue.when(
          data: (data) {
            if (data.events.contains(
                'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.${userDetails.id}.update')) {
              copyOfUser = User.fromMap(data.payload);
            }
          },
          error: (error, st) => ErrorText(error: error.toString()),
          loading: () => const SizedBox.shrink(), // No extra widget needed here
        );

        final levelUser = copyOfUser.levelUser;
        final kelompok = copyOfUser.kelompok;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipOval(
                          child: ref
                              .watch(getUserImageProvider(copyOfUser.imageId))
                              .when(
                                data: (imageData) {
                                  if (imageData != null) {
                                    return Image.memory(
                                      imageData,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return Image.asset(
                                      'assets/images/pp_kosong.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  }
                                },
                                loading: () => const Loader(),
                                error: (_, __) => const Center(
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        copyOfUser.nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        copyOfUser.email,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text('Catatan Anekdotal'),
                selected: selectedIndex == 0,
                onTap: () {
                  Navigator.pushReplacement(context, AnekdotPage.route());
                  onItemSelected(0);
                },
              ),
              // ListTile(
              //   title: const Text('Observasi'),
              //   selected: selectedIndex == 1,
              //   onTap: () {
              //     Navigator.pushReplacement(context, ObservasiPage.route());

              //     onItemSelected(1);
              //   },
              // ),
              ListTile(
                title: const Text('Ceklis'),
                selected: selectedIndex == 2,
                onTap: () {
                  Navigator.pushReplacement(context, CpPage.route());
                  onItemSelected(2);
                },
              ),
              ListTile(
                title: const Text('Dokumentasi Hasil Karya'),
                selected: selectedIndex == 3,
                onTap: () {
                  Navigator.pushReplacement(context, HkPage.route());
                  onItemSelected(3);
                },
              ),
              // ListTile(
              //   title: const Text('Foto Berseri'),
              //   selected: selectedIndex == 4,
              //   onTap: () {
              //     Navigator.pushReplacement(context, FbPage.route());
              //     onItemSelected(4);
              //   },
              // ),
              // ListTile(
              //   title: const Text('Tanggapan OrangTua'),
              //   selected: selectedIndex == 5,
              //   onTap: () {
              //     Navigator.pushReplacement(context, TanggapanPage.route());
              //     onItemSelected(5);
              //   },
              // ),
              ListTile(
                title: const Text('Rubrik'),
                selected: selectedIndex == 5,
                onTap: () {
                  Navigator.pushReplacement(context, RubrikPage.route());
                  onItemSelected(5);
                },
              ),
              ListTile(
                title: const Text('Catatan Pertumbuhan'),
                selected: selectedIndex == 8,
                onTap: () {
                  Navigator.pushReplacement(context, PertumbuhanPage.route());
                  onItemSelected(8);
                },
              ),
              ..._buildMenuItems(levelUser, selectedIndex, context, kelompok),
              ListTile(
                title: const Text(
                  'Profil',
                ),
                selected: selectedIndex == 9,
                onTap: () {
                  Navigator.pushReplacement(
                      context, EditProfilePage.route(userDetails: userDetails));
                  onItemSelected(9);
                },
              ),
              ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                selected: selectedIndex == 9,
                onTap: () {
                  ref.read(authControllerProvider.notifier).logout(context);
                },
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return const Center(
          child: Loader(),
        );
      },
    );
  }

  List<Widget> _buildMenuItems(int? levelUser, int selectedIndex,
      BuildContext context, String? kelompok) {
    List<Widget> items = [];
    if (levelUser == 1) {
      items.addAll([
        ListTile(
          title: const Text('List Murid'),
          selected: selectedIndex == 6,
          onTap: () {
            Navigator.pushReplacement(
                context, MuridListPage.route(kelompok: kelompok));
            onItemSelected(6);
          },
        ),
        ListTile(
          title: const Text('List Guru'),
          selected: selectedIndex == 7,
          onTap: () {
            Navigator.pushReplacement(context, GuruListPage.route());
            onItemSelected(7);
          },
        ),
      ]);
    } else if (levelUser == 2) {
      items.add(
        ListTile(
          title: const Text('List Murid'),
          selected: selectedIndex == 6,
          onTap: () {
            Navigator.pushReplacement(
                context, MuridListPage.route(kelompok: kelompok));
            onItemSelected(6);
          },
        ),
      );
    }
    return items;
  }
}
