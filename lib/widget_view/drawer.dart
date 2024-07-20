import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/add_guru_page.dart';
import 'package:sippa/add_user/add_murid_page.dart';
import 'package:sippa/add_user/list_guru.dart';
import 'package:sippa/add_user/list_murid.dart';
import 'package:sippa/anekdot/anekdot_page.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/common/loading.dart';

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
    return Drawer(
      child: currentUserDetailAsyncValue.when(
        data: (userDetails) {
          if (userDetails == null) {
            return const Center(
              child: Loader(),
            );
          }
          final levelUser = userDetails.levelUser;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(userDetails.nama),
              ),
              ListTile(
                title: Text(levelUser.toString()),
                selected: selectedIndex == 0,
                onTap: () {
                  Navigator.pushReplacement(context, AnekdotPage.route());
                },
              ),
              ListTile(
                title: Text(userDetails.kelompok),
                selected: selectedIndex == 0,
                onTap: () {
                  // Navigator.pushReplacement(context, AddAnekdotPage.route());
                },
              ),
              ListTile(
                title: const Text('list'),
                selected: selectedIndex == 1,
                onTap: () {
                  // Navigator.pushReplacement(context, AnekdotList.route());
                },
              ),
              ListTile(
                title: const Text('list guru'),
                selected: selectedIndex == 1,
                onTap: () {
                  Navigator.push(context, GuruListPage.route());
                },
              ),
              ListTile(
                title: const Text('list murid'),
                selected: selectedIndex == 1,
                onTap: () {
                  Navigator.push(context,
                      MuridListPage.route(kelompok: userDetails.kelompok));
                },
              ),
              ..._buildMenuItems(levelUser, selectedIndex, context),
              ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                selected: selectedIndex == 4,
                onTap: () {
                  ref.read(authControllerProvider.notifier).logout(context);
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(error.toString()),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(
    int? levelUser,
    int selectedIndex,
    BuildContext context,
  ) {
    List<Widget> items = [];
    if (levelUser == 1) {
      items.addAll([
        ListTile(
          title: const Text('Tambah Murid'),
          selected: selectedIndex == 2,
          onTap: () {
            Navigator.pushReplacement(context, AddMuridPage.route());
            onItemSelected(2);
          },
        ),
        ListTile(
          title: const Text('Tambah Guru'),
          selected: selectedIndex == 3,
          onTap: () {
            Navigator.pushReplacement(context, AddGuruPage.route());
            onItemSelected(3);
          },
        ),
      ]);
    } else if (levelUser == 2) {
      items.add(
        ListTile(
          title: const Text('Tambah Murid'),
          selected: selectedIndex == 2,
          onTap: () {
            Navigator.pushReplacement(context, AddMuridPage.route());
            onItemSelected(2);
          },
        ),
      );
    }
    return items;
  }
}
