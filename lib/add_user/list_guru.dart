import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';

class GuruListPage extends ConsumerWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const GuruListPage());

  const GuruListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = 2;

    final guruAsyncValue = ref.watch(getGuruByFiltersProvider);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Daftar Guru'),
      body: guruAsyncValue.when(
        data: (guruList) {
          return ref.watch(getLatestUsersProvider).when(
              data: (data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.create',
                )) {
                  final newUser = User.fromMap(data.payload);
                  if (!guruList
                      .any((existingUser) => existingUser.id == newUser.id)) {
                    guruList.add(newUser);
                  }
                }
                return ListView.builder(
                  itemCount: guruList.length,
                  itemBuilder: (context, index) {
                    final guru = guruList[index];
                    return ListTile(
                      title: Text(guru.nama),
                      subtitle: Text('Kelompok: ${guru.kelompok}'),
                    );
                  },
                );
              },
              error: (error, stack) =>
                  Center(child: Text('Tidak ada data guru.')),
              loading: () => ListView.builder(
                    itemCount: guruList.length,
                    itemBuilder: (context, index) {
                      final guru = guruList[index];
                      return ListTile(
                        title: Text(guru.nama),
                        subtitle: Text('Kelompok: ${guru.kelompok}'),
                      );
                    },
                  ));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Tidak ada data guru.')),
      ),
      drawer: CustomDrawer(
        selectedIndex: selectedIndex,
        onItemSelected: (int index) {
          selectedIndex = index;
        },
      ),
    );
  }
}
