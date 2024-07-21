import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        final kelompok = userDetails.kelompok;
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
              title: const Text('Anekdot'),
              selected: selectedIndex == 0,
              onTap: () {
                Navigator.pushReplacement(context, AnekdotPage.route());
              },
            ),
            ..._buildMenuItems(levelUser, selectedIndex, context, kelompok),
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
      error: (error, stackTrace) {
        return const Center(
          child: Loader(),
        );
      },
    ));
  }
  // WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   ref.read(authControllerProvider.notifier).logout(context);
  // });

  List<Widget> _buildMenuItems(int? levelUser, int selectedIndex,
      BuildContext context, String? kelompok) {
    List<Widget> items = [];
    if (levelUser == 1) {
      items.addAll([
        ListTile(
          title: const Text('List Murid'),
          selected: selectedIndex == 2,
          onTap: () {
            Navigator.pushReplacement(
                context, MuridListPage.route(kelompok: kelompok));
            onItemSelected(2);
          },
        ),
        ListTile(
          title: const Text('List Guru'),
          selected: selectedIndex == 3,
          onTap: () {
            Navigator.pushReplacement(context, GuruListPage.route());
            onItemSelected(3);
          },
        ),
      ]);
    } else if (levelUser == 2) {
      items.add(
        ListTile(
          title: const Text('List Murid'),
          selected: selectedIndex == 2,
          onTap: () {
            Navigator.pushReplacement(
                context, MuridListPage.route(kelompok: kelompok));
            onItemSelected(2);
          },
        ),
      );
    }
    return items;
  }
}
