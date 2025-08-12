import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/add_user/edit_guru_page.dart';
import 'package:sippa/common/loading.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/add_user/add_guru_page.dart';
import 'package:sippa/widget_view/teks.dart';

class GuruListPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const GuruListPage());
  const GuruListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuruListPageState();
}

class _GuruListPageState extends ConsumerState<GuruListPage> {
  int selectedIndex = 7;
  List<User> guruList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    final list = await ref.read(getGuruByFiltersProvider.future);
    if (mounted) {
      setState(() {
        guruList = list;
        isLoading = false;
      });
    }
  }

  void _updateList(User deletedGuru) {
    setState(() {
      guruList.removeWhere((guru) => guru.id == deletedGuru.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<RealtimeMessage>>(getLatestUsersProvider, (_, next) {
      next.whenData((data) {
        // CREATE
        if (data.events.contains(
            'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.create')) {
          final newUser = User.fromMap(data.payload);
          if (!guruList.any((existingUser) => existingUser.id == newUser.id)) {
            setState(() => guruList.add(newUser));
          }
        }
        // UPDATE
        else if (data.events.contains(
          'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.update',
        )) {
          final startingPoint = data.events[0].lastIndexOf('documents.');
          final endPoint = data.events[0].lastIndexOf('.update');
          final guruId = data.events[0].substring(startingPoint + 10, endPoint);

          final index = guruList.indexWhere((e) => e.id == guruId);
          if (index != -1) {
            setState(() {
              guruList[index] = User.fromMap(data.payload);
            });
          }
        }
        // DELETE
        else if (data.events.contains(
            'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.delete')) {
          final startingPoint = data.events[0].lastIndexOf('documents.');
          final endPoint = data.events[0].lastIndexOf('.delete');
          final deletedUserId =
              data.events[0].substring(startingPoint + 10, endPoint);

          setState(() {
            guruList.removeWhere((user) => user.id == deletedUserId);
          });
        }
      });
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Daftar Guru'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, AddGuruPage.route())
                      .then((_) => _loadInitialData());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                ),
                child:
                    const CustomText(text: "Tambah Guru", color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: Loader())
                  : RefreshIndicator(
                      onRefresh: _loadInitialData,
                      child: guruList.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 180),
                                Center(
                                  child: Text(
                                    'Belum ada data murid',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: guruList.length,
                              itemBuilder: (context, index) {
                                final guru = guruList[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: ClipOval(
                                      child: SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: ref
                                            .watch(getUserImageProvider(
                                                guru.imageId))
                                            .when(
                                              data: (imageData) {
                                                if (imageData != null) {
                                                  return Image.memory(
                                                    imageData,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                          Icons.error,
                                                          color: Colors.red);
                                                    },
                                                  );
                                                } else {
                                                  return Image.asset(
                                                    'assets/images/pp_kosong.jpg',
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                          Icons.error,
                                                          color: Colors.red);
                                                    },
                                                  );
                                                }
                                              },
                                              loading: () => const Loader(),
                                              error: (_, __) => const Icon(
                                                  Icons.error,
                                                  color: Colors.red),
                                            ),
                                      ),
                                    ),
                                    title: Text(guru.nama),
                                    subtitle:
                                        Text('Kelompok: ${guru.kelompok}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.push(context,
                                                    EditGuruPage.route(guru))
                                                .then(
                                                    (_) => _loadInitialData());
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(
                                                context,
                                                ref,
                                                guru,
                                                _updateList);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ),
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
    BuildContext context, WidgetRef ref, User guru, Function(User) updateList) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi Hapus'),
      content: Text(
          'Apakah Anda yakin ingin menghapus guru ${guru.nama} kelompok ${guru.kelompok}?'),
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
            ref.read(muridControllerProvider.notifier).deleteGuru(guru);
            updateList(guru);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Guru berhasil dihapus')),
            );
          },
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}
