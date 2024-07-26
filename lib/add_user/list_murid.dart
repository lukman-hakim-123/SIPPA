import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/add_murid_page.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

class MuridListPage extends ConsumerStatefulWidget {
  static route({required kelompok}) => MaterialPageRoute(
      builder: (context) => MuridListPage(kelompok: kelompok));

  final String kelompok;
  const MuridListPage({super.key, required this.kelompok});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MuridListPageState();
}

class _MuridListPageState extends ConsumerState<MuridListPage> {
  int selectedIndex = 6;
  List<User> muridList = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final initialList =
        await ref.read(getMuridByFiltersProvider(widget.kelompok).future);
    if (mounted) {
      setState(() => muridList = initialList);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<RealtimeMessage>>(getLatestUsersProvider, (_, next) {
      next.whenData((data) {
        if (data.events.contains(
            'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.create')) {
          final newUser = User.fromMap(data.payload);
          if (newUser.kelompok == widget.kelompok &&
              !muridList.any((existingUser) => existingUser.id == newUser.id)) {
            setState(() => muridList.add(newUser));
          }
        } else if (data.events.contains(
            'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.delete')) {
          final startingPoint = data.events[0].lastIndexOf('documents.');
          final endPoint = data.events[0].lastIndexOf('.delete');
          final deletedUserId =
              data.events[0].substring(startingPoint + 10, endPoint);

          setState(() {
            muridList.removeWhere((user) => user.id == deletedUserId);
          });
        }
      });
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Daftar Murid'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, AddMuridPage.route());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                ),
                child:
                    const CustomText(text: "Tambah Murid", color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ...muridList.map((murid) => InkWell(
                  onTap: () {},
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(murid.nama),
                      subtitle: Text('Kelompok: ${murid.kelompok}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                  context, ref, murid);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
      drawer: CustomDrawer(
        selectedIndex: selectedIndex,
        onItemSelected: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}

void _showDeleteConfirmationDialog(
    BuildContext context, WidgetRef ref, User murid) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi Hapus'),
      content: Text(
          'Apakah Anda yakin ingin menghapus murid ${murid.nama} kelompok ${murid.kelompok}?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ref.read(muridControllerProvider.notifier).deleteGuru(murid);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Murid berhasil dihapus')),
            );
          },
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}
