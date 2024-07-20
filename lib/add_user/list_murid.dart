import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';

class MuridListPage extends ConsumerWidget {
  static route({required kelompok}) => MaterialPageRoute(
      builder: (context) => MuridListPage(kelompok: kelompok));

  final String kelompok;
  const MuridListPage({super.key, required this.kelompok});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = 2;

    final muridAsyncValue = ref.watch(getMuridByFiltersProvider(kelompok));
    return Scaffold(
      appBar: const CustomAppBar(title: 'Daftar Murid'),
      body: muridAsyncValue.when(
        data: (muridList) {
          return ref.watch(getLatestUsersProvider).when(
              data: (data) {
                if (data.events.contains(
                  'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.create',
                )) {
                  final newUser = User.fromMap(data.payload);
                  if (newUser.kelompok == kelompok &&
                      !muridList.any(
                          (existingUser) => existingUser.id == newUser.id)) {
                    muridList.add(newUser);
                  }
                }
                return ListView.builder(
                  itemCount: muridList.length,
                  itemBuilder: (context, index) {
                    final murid = muridList[index];
                    return ListTile(
                      title: Text(murid.nama),
                      subtitle: Text('Kelompok: ${murid.kelompok}'),
                    );
                  },
                );
              },
              error: (error, stack) =>
                  Center(child: Text('Tidak ada data murid.')),
              loading: () => ListView.builder(
                    itemCount: muridList.length,
                    itemBuilder: (context, index) {
                      final murid = muridList[index];
                      return ListTile(
                        title: Text(murid.nama),
                        subtitle: Text('Kelompok: ${murid.kelompok}'),
                      );
                    },
                  ));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Tidak ada data murid.')),
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
